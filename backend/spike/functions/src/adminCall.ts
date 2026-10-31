// SPIKE (DEC-003 OPEN). The one way to declare a privileged operation. It runs the sign-in check and the
// admin gate before the handler sees any input, so that an operation cannot leave them out (SC-02,
// INV-08, API_AND_BACKEND_CONTRACT.md section 2.3). A refusal writes nothing (GS-Q44).
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { requireAdmin } from './admin.js';
import { unauthenticated } from './errors.js';
import { isObject } from './validation.js';

export interface AdminContext {
  uid: string;
  db: Firestore;
  data: Record<string, unknown>;
}

export function adminCall<T>(handler: (context: AdminContext) => Promise<T>) {
  return onCall(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw unauthenticated();

    const db = getFirestore();
    await requireAdmin({ db, auth: getAuth() }, uid);

    const data: unknown = request.data;
    return handler({ uid, db, data: isObject(data) ? data : {} });
  });
}
