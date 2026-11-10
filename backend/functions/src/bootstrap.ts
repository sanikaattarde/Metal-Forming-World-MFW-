// OP-42 bootstrapAdmin, the developer-run step that creates the first admin and recovers from a lockout
// (MOD12-P1-T02; SC-14; SECURITY_AND_ACCESS_CONTROL.md section 7.1; GS-Q33). It is not an operation a
// client can call: index.ts does not export it, so it is never deployed. scripts/bootstrap-admin.mjs runs
// it with the developer's own access under role-based access (NFR-SEC-012), with no key in the repository
// (SC-19). One developer runs it; the other verifies the result with `--verify`.
//
// Effects, in one transaction: the admin role record with the fixed marker as granted_by, the guard record
// with the new count, and the change record bootstrap_admin holding the written reference (INV-03, INV-04,
// SC-13). The step refuses while an active admin exists, unless it is declared a recovery.
import type { Auth } from 'firebase-admin/auth';
import { FieldValue } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { derivedId } from './validation.js';

// granted_by and actor_user_id for the step (DATABASE_AND_DATA_MODEL.md sections 4.17 and 4.18).
export const BOOTSTRAP_MARKER = 'bootstrap-step';

// PLACEHOLDER. No document sets a length for the written reference. It names a document; it never holds one.
export const MAX_REFERENCE_LENGTH = 200;

export type BootstrapRefusal =
  | 'REFERENCE_INVALID'
  | 'ACCOUNT_NOT_FOUND'
  | 'EMAIL_NOT_VERIFIED'
  | 'ACCOUNT_CLOSED'
  | 'ACTIVE_ADMIN_EXISTS'
  | 'ALREADY_AN_ADMIN';

export class BootstrapRefused extends Error {
  constructor(readonly reason: BootstrapRefusal) {
    super(`The bootstrap step refused: ${reason}. Nothing was written.`);
    this.name = 'BootstrapRefused';
  }
}

export interface BootstrapBackend {
  db: Firestore;
  auth: Auth;
}

export type BootstrapTarget = { email: string } | { uid: string };

export interface BootstrapRequest {
  target: BootstrapTarget;
  // The reference to the written request from MFW's authorised approver (GS-Q33). Never its content.
  reference: string;
  // A recovery may run while active admins exist, for example when every admin is locked out.
  recovery: boolean;
}

export interface BootstrapResult {
  uid: string;
  event_id: string;
  active_admin_count: number;
  recovery: boolean;
}

const checkReference = (value: unknown): string => {
  if (typeof value !== 'string') throw new BootstrapRefused('REFERENCE_INVALID');
  const reference = value.trim();
  if (reference.length === 0 || reference.length > MAX_REFERENCE_LENGTH || /[\r\n]/.test(reference)) {
    throw new BootstrapRefused('REFERENCE_INVALID');
  }
  return reference;
};

async function findAccount(auth: Auth, target: BootstrapTarget) {
  try {
    return 'email' in target ? await auth.getUserByEmail(target.email.trim()) : await auth.getUser(target.uid);
  } catch (error) {
    if ((error as { code?: string }).code === 'auth/user-not-found') throw new BootstrapRefused('ACCOUNT_NOT_FOUND');
    throw error;
  }
}

export async function bootstrapAdmin({ db, auth }: BootstrapBackend, request: BootstrapRequest): Promise<BootstrapResult> {
  const reference = checkReference(request.reference);

  // The person registered an ordinary reader account (OP-42 precondition), with a verified email, as an add
  // in the panel needs (GS-Q44).
  const account = await findAccount(auth, request.target);
  if (account.disabled) throw new BootstrapRefused('ACCOUNT_CLOSED');
  if (account.emailVerified !== true) throw new BootstrapRefused('EMAIL_NOT_VERIFIED');
  const uid = account.uid;

  const roleRef = db.collection('admin_roles').doc(uid);
  const guardRef = db.doc('admin_guard/current');
  const eventId = derivedId('bootstrap_admin', uid, reference);
  const eventRef = db.collection('admin_audit').doc(eventId);

  // A refusal is returned from the transaction, not thrown in it, so the transaction ends with no writes and
  // releases what it read at once, even if the process that ran it exits straight after.
  const outcome = await db.runTransaction(async (tx): Promise<{ refusal: BootstrapRefusal } | { count: number }> => {
    const [userSnap, roleSnap, guardSnap] = await tx.getAll(db.doc(`users/${uid}`), roleRef, guardRef);
    const active = await tx.get(db.collection('admin_roles').where('is_active', '==', true));

    if (userSnap.exists && userSnap.get('status') !== 'active') return { refusal: 'ACCOUNT_CLOSED' };
    if (roleSnap.exists && roleSnap.get('is_active') === true) return { refusal: 'ALREADY_AN_ADMIN' };
    if (!request.recovery && active.size > 0) return { refusal: 'ACTIVE_ADMIN_EXISTS' };

    // The count is recomputed from the role records rather than trusted from the guard, because a recovery
    // is run exactly when something has gone wrong. The repair task (OP-41) still checks the accounts.
    const next = active.size + 1;
    const now = FieldValue.serverTimestamp();
    // A removed admin's record is replaced, so revoked_at goes.
    tx.set(roleRef, { user_id: uid, is_active: true, granted_by: BOOTSTRAP_MARKER, granted_at: now });
    const version: unknown = guardSnap.get('version');
    tx.set(guardRef, {
      guard_id: 'current',
      active_admin_count: next,
      version: guardSnap.exists && Number.isInteger(version) ? (version as number) + 1 : 1,
      updated_at: now,
    });
    tx.set(eventRef, {
      event_id: eventId,
      action: 'bootstrap_admin',
      actor_user_id: BOOTSTRAP_MARKER,
      target_user_id: uid,
      reference,
      recent_sign_in_checked: false,
      occurred_at: now,
    });
    return { count: next };
  });

  if ('refusal' in outcome) throw new BootstrapRefused(outcome.refusal);
  return { uid, event_id: eventId, active_admin_count: outcome.count, recovery: request.recovery };
}

export interface BootstrapCheck {
  uid: string;
  role_active: boolean;
  granted_by: string | null;
  guard_count: number | null;
  bootstrap_events: number;
}

// What the second developer reads back to verify the step (SECURITY_AND_ACCESS_CONTROL.md section 7.1, step 4).
export async function verifyBootstrap({ db, auth }: BootstrapBackend, target: BootstrapTarget): Promise<BootstrapCheck> {
  const { uid } = await findAccount(auth, target);
  const [role, guard, events] = await Promise.all([
    db.collection('admin_roles').doc(uid).get(),
    db.doc('admin_guard/current').get(),
    db.collection('admin_audit').where('target_user_id', '==', uid).where('action', '==', 'bootstrap_admin').get(),
  ]);
  const count: unknown = guard.get('active_admin_count');
  return {
    uid,
    role_active: role.exists && role.get('is_active') === true,
    granted_by: role.exists ? String(role.get('granted_by')) : null,
    guard_count: Number.isInteger(count) ? (count as number) : null,
    bootstrap_events: events.size,
  };
}
