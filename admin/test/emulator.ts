// SPIKE. Test set-up against the local emulators, through their REST interfaces with the emulators' owner
// token, which only the emulators accept. No cloud project is reached.
import { EMULATOR } from '../src/services';

const authHost: string | undefined = import.meta.env.FIREBASE_AUTH_EMULATOR_HOST;
const firestoreHost: string | undefined = import.meta.env.FIRESTORE_EMULATOR_HOST;

export const AUTH_URL = `http://${authHost}`;
export const PASSWORD = 'admin-spike-password-1';
const OWNER = { 'Content-Type': 'application/json', Authorization: 'Bearer owner' };
const DOCUMENTS = `http://${firestoreHost}/v1/projects/${EMULATOR.projectId}/databases/(default)/documents`;

export function requireEmulators(): void {
  if (!authHost || !firestoreHost) {
    throw new Error('The emulator hosts are not set: run these tests with `npm test`, which starts the emulators');
  }
}

async function send(url: string, body?: unknown, method = 'POST') {
  const reply = await fetch(url, { method, headers: OWNER, body: body === undefined ? undefined : JSON.stringify(body) });
  const text = await reply.text();
  if (!reply.ok) throw new Error(`${method} ${url.replace(/\?.*$/, '')} failed: ${reply.status} ${text.slice(0, 200)}`);
  return text ? JSON.parse(text) : {};
}

export async function clearAll(): Promise<void> {
  await send(`http://${authHost}/emulator/v1/projects/${EMULATOR.projectId}/accounts`, undefined, 'DELETE');
  await send(`http://${firestoreHost}/emulator/v1/projects/${EMULATOR.projectId}/databases/(default)/documents`, undefined, 'DELETE');
}

export async function createAccount(email: string, { verified = true } = {}): Promise<string> {
  const account = await send(`http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=${EMULATOR.apiKey}`, {
    email,
    password: PASSWORD,
    returnSecureToken: true,
  });
  if (verified) await updateAccount(account.localId, { emailVerified: true });
  return account.localId;
}

export function updateAccount(uid: string, change: { emailVerified?: boolean; disableUser?: boolean }) {
  return send(`http://${authHost}/identitytoolkit.googleapis.com/v1/projects/${EMULATOR.projectId}/accounts:update`, { localId: uid, ...change });
}

type Plain = string | number | boolean | null | Date | Plain[] | { [key: string]: Plain };

function toValue(value: Plain): unknown {
  if (value === null) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(toValue) } };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  if (typeof value === 'string') return { stringValue: value };
  return { mapValue: { fields: Object.fromEntries(Object.entries(value).map(([k, v]) => [k, toValue(v)])) } };
}

export function setDoc(path: string, data: Record<string, Plain>) {
  return send(`${DOCUMENTS}/${path}`, { fields: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, toValue(v)])) }, 'PATCH');
}

// An admin as the backend expects one: an account, a verified email and an active role record.
export async function createAdmin(email: string, { verified = true } = {}): Promise<string> {
  const uid = await createAccount(email, { verified });
  await setDoc(`admin_roles/${uid}`, { user_id: uid, is_active: true, granted_by: 'test-seed', granted_at: new Date() });
  return uid;
}

export const removeRole = (uid: string) => setDoc(`admin_roles/${uid}`, { user_id: uid, is_active: false, granted_by: 'test-seed', granted_at: new Date(), revoked_at: new Date() });
