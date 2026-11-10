// OP-14 getMyAdminRole, for any signed-in reader. The panel uses it to show or
// hide controls. It is never an authorisation: every privileged operation checks again (GS-D20).
// The output shape is PROPOSED. A removed admin keeps the role record, so `is_admin` stays true
// and `is_active` is false. The panel should go by `is_active`.
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { readStanding } from './admin.js';
import { accountClosed, unauthenticated } from './errors.js';

export const getMyAdminRole = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw unauthenticated();

  const standing = await readStanding({ db: getFirestore(), auth: getAuth() }, uid);
  if (standing.accountClosed) throw accountClosed();
  // email_verified is an addition to OP-14, PROPOSED (MOD12-P2-T01): the panel admits an admin only when
  // the role is active and the email is verified.
  return { is_admin: standing.hasRole, is_active: standing.roleActive, email_verified: standing.emailVerified };
});
