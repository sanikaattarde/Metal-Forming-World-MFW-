// The registered-readers calls (MOD12-P2-T06) against the backend's real OP-31 and OP-32 on the local
// emulators. PROVISIONAL (OQ-29, OQ-31, OQ-51). Synthetic accounts only. Emulator only.
import { afterAll, beforeAll, beforeEach, expect, test } from 'vitest';
import { adminApi } from '../src/adminApi';
import type { CallFn } from '../src/adminApi';
import { exportReaders, listReaders } from '../src/data';
import { emulatorBackend, servicesFor } from '../src/services';
import type { Backend, Services } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAccount, createAdmin, PASSWORD, requireEmulators, setDoc } from './emulator';

let backend: Backend;
let services: Services;
let api: CallFn;
let n = 0;

beforeAll(() => {
  requireEmulators();
  backend = emulatorBackend(AUTH_URL, 'b56-admin');
  services = servicesFor(backend);
  api = adminApi(services.call, () => {
    throw new Error('the session ended during a test');
  });
});

afterAll(async () => {
  await backend.auth.signOut();
});

beforeEach(async () => {
  await backend.auth.signOut();
  await clearAll();
  n += 1;
  await createAdmin(`admin-${n}@example.test`);
  const uid = await createAccount(`reader-${n}@example.test`);
  await setDoc(`users/${uid}`, { user_id: uid, status: 'active', created_at: new Date('2026-11-01T08:00:00Z') });
  await setDoc(`users/${uid}/profile/current`, { user_id: uid, full_name: '=1+1', age_value: 40, gender: 'Man', job_title: 'Buyer', industry_segment_id: 's9' });
  expect(await signInAdmin(services, `admin-${n}@example.test`, PASSWORD)).toBe('signed-in');
});

test('PAC-03: OP-31 lists the reader with the provider email and the profile fields', async () => {
  const page = await listReaders(api);
  expect(page.items).toHaveLength(1);
  expect(page.items[0]).toMatchObject({ email: `reader-${n}@example.test`, full_name: '=1+1', age_value: 40, job_title: 'Buyer' });
  expect(page.next_cursor).toBeNull();
});

test('SEC-CHK-12: OP-32 neutralises a formula cell in the file it returns', async () => {
  const file = await exportReaders(api);
  expect(file.row_count).toBe(1);
  expect(file.csv.split('\r\n')[1].split(',')[1]).toBe("'=1+1");
});
