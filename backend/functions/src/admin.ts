// The admin gate, the last-admin guard and the count repair.
// This is the only module that writes `admin_roles` and `admin_guard` (INV-05). The data model is
// DATABASE_AND_DATA_MODEL.md sections 4.17 and 4.21, and the rules are INV-03, INV-08 and INV-09.
//
// Not built, because they wait for OQ-58: OP-34, OP-35, OP-37, OP-38, OP-39, the change record
// (ADMIN_AUDIT_EVENT), INV-04, INV-06 and INV-07. Also not built: OP-42, the real bootstrap step.
import type { Auth } from 'firebase-admin/auth';
import { FieldValue } from 'firebase-admin/firestore';
import type { DocumentReference, Firestore, Transaction } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { accountClosed, cannotVerify, emailNotVerified, forbidden, lastAdmin, notAnAdmin } from './errors.js';

const GUARD_PATH = 'admin_guard/current';
const roleRef = (db: Firestore, uid: string) => db.collection('admin_roles').doc(uid);

// Passed in, so that a test can make a read fail and check that the call is refused.
export interface Backend {
  db: Firestore;
  auth: Auth;
}

export interface Standing {
  accountClosed: boolean;
  hasRole: boolean;
  roleActive: boolean;
  // The provider's flag, read on this call. OQ-20's working position asks for a verified email (MOD12-P2-T01).
  emailVerified: boolean;
}

// Reads the current role record and the account status on this call. Trusts no claim and no
// cached value (INV-08, SC-02, SC-04). Fails closed if any of them cannot be read (SC-03).
export async function readStanding({ db, auth }: Backend, uid: string): Promise<Standing> {
  try {
    const [role, user, providerUser] = await Promise.all([
      roleRef(db, uid).get(),
      db.doc(`users/${uid}`).get(),
      auth.getUser(uid).catch((error: { code?: string }) => {
        if (error.code === 'auth/user-not-found') return null;
        throw error;
      }),
    ]);
    return {
      // A registered reader may have no account record yet (OP-10 creates it). The provider and the
      // role record still decide, so a missing record is not a closed account.
      accountClosed: !providerUser || providerUser.disabled || (user.exists && user.get('status') !== 'active'),
      hasRole: role.exists,
      roleActive: role.exists && role.get('is_active') === true,
      emailVerified: providerUser?.emailVerified === true,
    };
  } catch {
    logger.error('admin check refused: the role record or the account could not be read');
    throw cannotVerify();
  }
}

// Every privileged operation calls this first (SC-02). A refusal writes nothing (GS-Q44).
export async function requireAdmin(backend: Backend, uid: string): Promise<void> {
  const standing = await readStanding(backend, uid);
  if (standing.accountClosed) throw accountClosed();
  if (!standing.roleActive) throw forbidden();
  // After the role check, so that a caller who is not an admin learns nothing more.
  if (!standing.emailVerified) throw emailNotVerified();
}

export interface RemovalPlan {
  role: DocumentReference;
  guard: DocumentReference;
  count: number;
  version: number;
}

// The read half of taking an admin out of the count, for use inside a caller's transaction. A
// transaction reads before it writes, so OP-12 can read its own records as well, then apply both.
// Returns null if the account is not an active admin. Refuses if it would leave no active admin (INV-03).
export async function planAdminRemoval(tx: Transaction, db: Firestore, targetUid: string): Promise<RemovalPlan | null> {
  const role = roleRef(db, targetUid);
  const guard = db.doc(GUARD_PATH);
  const [roleSnap, guardSnap] = await tx.getAll(role, guard);

  if (!roleSnap.exists || roleSnap.get('is_active') !== true) return null;

  const count: unknown = guardSnap.get('active_admin_count');
  const version: unknown = guardSnap.get('version');
  if (!guardSnap.exists || !Number.isInteger(count) || !Number.isInteger(version)) {
    logger.error('admin removal refused: the guard record is missing or malformed');
    throw cannotVerify();
  }

  const remaining = (count as number) - 1;
  if (remaining < 1) throw lastAdmin();
  return { role, guard, count: remaining, version: (version as number) + 1 };
}

// The write half. A removed record is kept, with revoked_at set (DM section 4.17).
export function applyAdminRemoval(tx: Transaction, plan: RemovalPlan): void {
  const now = FieldValue.serverTimestamp();
  tx.update(plan.role, { is_active: false, revoked_at: now });
  tx.update(plan.guard, { active_admin_count: plan.count, version: plan.version, updated_at: now });
}

// One transaction with the guard record, so that two removals at once cannot both pass (INV-03).
// OP-37 and its checks (recent sign-in, expected state, change record) wait for OQ-58.
export async function removeAdminRole({ db }: Backend, targetUid: string): Promise<void> {
  await db.runTransaction(async (tx) => {
    const plan = await planAdminRemoval(tx, db, targetUid);
    if (!plan) throw notAnAdmin();
    applyAdminRemoval(tx, plan);
  });
}

export interface RepairReport {
  stored: number | null;
  actual: number;
  corrected: boolean;
  guard_missing: boolean;
  no_active_admin: boolean;
}

// The repair task of OP-41 (DM section 10.3): recomputes the count, reports any difference and
// corrects it. An outside change, such as disabling an account in the console, is detected here and
// not prevented (INV-03). It reports numbers only. It does not create a missing guard record,
// because the bootstrap step does that. Not scheduled yet.
export async function repairAdminCount({ db, auth }: Backend): Promise<RepairReport> {
  const report = await db.runTransaction(async (tx): Promise<RepairReport> => {
    const guard = db.doc(GUARD_PATH);
    const guardSnap = await tx.get(guard);
    const roles = await tx.get(db.collection('admin_roles').where('is_active', '==', true));
    const uids = roles.docs.map((doc) => doc.id);

    let actual = 0;
    if (uids.length > 0) {
      const users = await tx.getAll(...uids.map((uid) => db.doc(`users/${uid}`)));
      const { users: providerUsers } = await auth.getUsers(uids.map((uid) => ({ uid })));
      const usable = new Set(providerUsers.filter((user) => !user.disabled).map((user) => user.uid));
      actual = uids.filter((uid, index) => {
        const user = users[index];
        return usable.has(uid) && (!user.exists || user.get('status') === 'active');
      }).length;
    }

    if (!guardSnap.exists) {
      return { stored: null, actual, corrected: false, guard_missing: true, no_active_admin: actual === 0 };
    }

    const stored: unknown = guardSnap.get('active_admin_count');
    const corrected = stored !== actual;
    if (corrected) {
      const version: unknown = guardSnap.get('version');
      tx.update(guard, {
        active_admin_count: actual,
        version: Number.isInteger(version) ? (version as number) + 1 : 1,
        updated_at: FieldValue.serverTimestamp(),
      });
    }
    return {
      stored: Number.isInteger(stored) ? (stored as number) : null,
      actual,
      corrected,
      guard_missing: false,
      no_active_admin: actual === 0,
    };
  });

  if (report.corrected || report.guard_missing || report.no_active_admin) {
    logger.warn('admin count repair found a difference', { ...report });
  }
  return report;
}
