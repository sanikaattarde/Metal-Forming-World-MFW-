// The one way to declare a privileged operation. It runs the sign-in check and the
// admin gate before the handler sees any input, so that an operation cannot leave them out (SC-02,
// INV-08, API_AND_BACKEND_CONTRACT.md section 2.3). A refusal writes nothing (GS-Q44). A refused access or
// a failed check is logged as a security event under the operation's name (MOD02-P2-T03). Each call is counted
// against its class's rate limit (MOD13-P1-T07).
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { requireAdmin } from './admin.js';
import { enforceRate } from './rateLimits.js';
import { unauthenticated } from './errors.js';
import { logSecurityRefusals } from './safeLog.js';
import { isObject } from './validation.js';

export interface AdminContext {
  uid: string;
  db: Firestore;
  data: Record<string, unknown>;
}

export function adminCall<T>(operation: string, handler: (context: AdminContext) => Promise<T>) {
  return onCall((request) => {
    const uid = request.auth?.uid;
    return logSecurityRefusals(operation, uid, async () => {
      if (!uid) throw unauthenticated();

      const db = getFirestore();
      await requireAdmin({ db, auth: getAuth() }, uid);
      // After the gate, so that only an admin's calls write a counter (SC-18).
      await enforceRate(db, uid, operation);

      const data: unknown = request.data;
      return handler({ uid, db, data: isObject(data) ? data : {} });
    });
  });
}
