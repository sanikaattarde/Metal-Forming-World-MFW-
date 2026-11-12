// OP-35 addAdmin, OP-37 removeAdmin, OP-38 listAdmins and OP-39 listAdminChanges, from API_AND_BACKEND_CONTRACT.md
// section 5.2 (MOD12-P3-T02; FR-ADMIN-003, FR-ADMIN-004; INV-03 to INV-09; GS-Q44).
//
// SWITCHED OFF. DEC-027 says in-panel add and remove is not built as agreed scope until MFW confirms it in writing
// (OQ-58). Every operation here refuses with FEATURE_OFF unless `config/private.admin_management_enabled` is true,
// which no seed sets. PROVISIONAL.
//
// An addition or a removal is one transaction over the role record, the guard record and the change record
// (INV-03, INV-04), checks the state the caller saw (INV-07), and needs a recent sign-in (OQ-56; the window is a
// PLACEHOLDER). After a removal the target's sessions are ended (INV-09); a failure there does not undo it. A repeat of
// the same request returns the first result. A target is named by its identifier or its email address (the address
// is a PROPOSED addition to the contract, so the panel need not know identifiers).
import { getAuth } from 'firebase-admin/auth';
import type { Auth, UserRecord } from 'firebase-admin/auth';
import { FieldValue } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { applyAdminRemoval, planAdminRemoval } from './admin.js';
import { adminCall } from './adminCall.js';
import { invalidArgument, notAnAdmin, notFound } from './errors.js';
import { derivedId, isNonEmptyText, unknownFields } from './validation.js';

// PLACEHOLDER until OQ-56: how recent a sign-in must be, in seconds.
export const PLACEHOLDER_RECENT_SIGN_IN_SECONDS = 5 * 60;

const refused = (reason: string, message: string) => new HttpsError('failed-precondition', message, { reason });
export const featureOff = () => refused('FEATURE_OFF', 'Adding and removing admins in the panel is not switched on.');
const recentSignIn = () => refused('RECENT_SIGN_IN_REQUIRED', 'Sign in again, then repeat the change.');
const alreadyAdmin = () => refused('ALREADY_ADMIN', 'That account is already an admin.');
const targetClosed = () => refused('TARGET_ACCOUNT_CLOSED', 'That account is closed.');
const targetUnverified = () => refused('TARGET_EMAIL_NOT_VERIFIED', 'That account has not verified its email address.');
const stale = () => new HttpsError('aborted', 'The admin list changed. Reload it.', { reason: 'STALE_ADMIN_STATE' });

export interface ManagementBackend {
  db: Firestore;
  auth: Auth;
  nowSeconds?: () => number;
}

async function requireSwitchedOn(db: Firestore): Promise<void> {
  if ((await db.doc('config/private').get()).get('admin_management_enabled') !== true) throw featureOff();
}

function requireRecentSignIn(authTime: number | undefined, now: number): void {
  if (authTime === undefined || now - authTime > PLACEHOLDER_RECENT_SIGN_IN_SECONDS) throw recentSignIn();
}

async function findTarget(auth: Auth, data: Record<string, unknown>): Promise<UserRecord> {
  try {
    if (isNonEmptyText(data.target_user_id)) return await auth.getUser(data.target_user_id);
    return await auth.getUserByEmail(String(data.target_email));
  } catch (error) {
    if ((error as { code?: string }).code === 'auth/user-not-found') throw notFound();
    throw error;
  }
}

const FIELDS = new Set(['request_id', 'target_user_id', 'target_email', 'expected_state', 'confirmation']);

function checkInput(data: Record<string, unknown>, removal: boolean): void {
  const invalid = unknownFields(data, FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isNonEmptyText(data.target_user_id) && !isNonEmptyText(data.target_email)) invalid.push('target_user_id');
  if (data.expected_state !== 'admin' && data.expected_state !== 'not_admin') invalid.push('expected_state');
  if (removal && !isNonEmptyText(data.confirmation)) invalid.push('confirmation');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());
}

const roleView = (uid: string, email: string | undefined, isActive: boolean) => ({ user_id: uid, email: email ?? null, is_active: isActive });

export async function changeAdminAs(
  backend: ManagementBackend,
  caller: { uid: string; authTime?: number },
  data: Record<string, unknown>,
  removal: boolean,
) {
  const { db, auth } = backend;
  await requireSwitchedOn(db);
  checkInput(data, removal);
  requireRecentSignIn(caller.authTime, (backend.nowSeconds ?? (() => Math.floor(Date.now() / 1000)))());
  const target = await findTarget(auth, data);
  if (removal && (data.confirmation as string).trim().toLowerCase() !== (target.email ?? '').toLowerCase()) {
    throw invalidArgument(['confirmation']);
  }

  const action = removal ? 'admin_remove' : 'admin_add';
  const eventId = derivedId(action, caller.uid, data.request_id as string);
  const eventRef = db.collection('admin_audit').doc(eventId);
  const roleRef = db.collection('admin_roles').doc(target.uid);
  const guardRef = db.doc('admin_guard/current');

  const repeat = await db.runTransaction(async (tx) => {
    const [event, role, guard, user] = await tx.getAll(eventRef, roleRef, guardRef, db.doc(`users/${target.uid}`));
    if (event.exists) return true;
    const isAdmin = role.exists && role.get('is_active') === true;
    if ((data.expected_state === 'admin') !== isAdmin) throw stale();
    const now = FieldValue.serverTimestamp();

    if (removal) {
      if (!isAdmin) throw notAnAdmin();
      const plan = await planAdminRemoval(tx, db, target.uid);
      if (!plan) throw notAnAdmin();
      applyAdminRemoval(tx, plan);
    } else {
      if (isAdmin) throw alreadyAdmin();
      if (target.disabled || (user.exists && user.get('status') !== 'active')) throw targetClosed();
      if (target.emailVerified !== true) throw targetUnverified();
      const count: unknown = guard.get('active_admin_count');
      const version: unknown = guard.get('version');
      if (!guard.exists || !Number.isInteger(count) || !Number.isInteger(version)) throw stale();
      tx.set(roleRef, { user_id: target.uid, is_active: true, granted_by: caller.uid, granted_at: now });
      tx.update(guardRef, { active_admin_count: (count as number) + 1, version: (version as number) + 1, updated_at: now });
    }
    // The narrow change record: who changed whom, and when (GS-Q44). No email, no name.
    tx.set(eventRef, { event_id: eventId, action, actor_user_id: caller.uid, target_user_id: target.uid, recent_sign_in_checked: true, occurred_at: now });
    return false;
  });

  if (removal && !repeat) {
    // INV-09: end the removed admin's sessions, with one retry. The removal stands either way.
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        await auth.revokeRefreshTokens(target.uid);
        break;
      } catch {
        if (attempt === 1) logger.error('removeAdmin: the removed admin\'s sessions could not be ended');
      }
    }
  }
  return roleView(target.uid, target.email, !removal);
}

export async function listAdminsAs({ db, auth }: ManagementBackend) {
  await requireSwitchedOn(db);
  const roles = await db.collection('admin_roles').where('is_active', '==', true).get();
  const uids = roles.docs.map((doc) => doc.id);
  const { users } = uids.length === 0 ? { users: [] } : await auth.getUsers(uids.map((uid) => ({ uid })));
  const emails = new Map(users.map((user) => [user.uid, user.email]));
  return { items: uids.map((uid) => roleView(uid, emails.get(uid), true)).sort((a, b) => String(a.email).localeCompare(String(b.email))) };
}

// PLACEHOLDER page size.
const CHANGES_PER_PAGE = 20;

export async function listAdminChangesAs({ db }: ManagementBackend, data: Record<string, unknown>) {
  await requireSwitchedOn(db);
  const cursor = isNonEmptyText(data.cursor) ? data.cursor : null;
  let query = db.collection('admin_audit').orderBy('occurred_at', 'desc').orderBy('event_id').limit(CHANGES_PER_PAGE + 1);
  if (cursor) {
    const after = await db.collection('admin_audit').doc(cursor).get();
    if (after.exists) query = query.startAfter(after);
  }
  const docs = (await query.get()).docs;
  const page = docs.slice(0, CHANGES_PER_PAGE);
  return {
    items: page.map((doc) => ({
      event_id: doc.id,
      action: doc.get('action'),
      actor_user_id: doc.get('actor_user_id'),
      target_user_id: doc.get('target_user_id'),
      occurred_at: doc.get('occurred_at')?.toDate?.().toISOString() ?? null,
    })),
    next_cursor: docs.length > CHANGES_PER_PAGE ? page[page.length - 1].id : null,
  };
}

const backend = (db: Firestore): ManagementBackend => ({ db, auth: getAuth() });

export const addAdmin = adminCall('addAdmin', ({ uid, db, data, authTime }) => changeAdminAs(backend(db), { uid, authTime }, data, false));
export const removeAdmin = adminCall('removeAdmin', ({ uid, db, data, authTime }) => changeAdminAs(backend(db), { uid, authTime }, data, true));
export const listAdmins = adminCall('listAdmins', ({ db }) => listAdminsAs(backend(db)));
export const listAdminChanges = adminCall('listAdminChanges', ({ db, data }) => listAdminChangesAs(backend(db), data));
