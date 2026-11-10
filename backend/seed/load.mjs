// Puts the seed into the local Firestore emulator. It writes nowhere else.
//
//   node seed/load.mjs           load into the emulator in FIRESTORE_EMULATOR_HOST, or in firebase.json
//   node seed/load.mjs --check   check the seed file only. Needs no emulator
//
// With the emulators running, `npm --prefix backend run seed`.
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { loadSeed, SEED, seedDocuments } from './seed.mjs';

// A "demo-" project is one the emulators run without a cloud project or a login.
const PROJECT_ID = 'demo-mfw';
const LOCAL = /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/;

const fail = (code, message) => {
  console.error(message);
  process.exit(code);
};

const args = process.argv.slice(2);
if (args.some((arg) => arg !== '--check')) fail(2, 'Usage: node seed/load.mjs [--check]');

let ids;
try {
  ids = seedDocuments(SEED).map(({ data }) => data.category_id);
} catch (error) {
  fail(1, error.message);
}

if (args.includes('--check')) {
  console.log(`The seed is usable: ${ids.join(', ')}`);
  process.exit(0);
}

const config = JSON.parse(readFileSync(new URL('../firebase.json', import.meta.url), 'utf8'));
const host = process.env.FIRESTORE_EMULATOR_HOST ?? `${config.emulators.firestore.host}:${config.emulators.firestore.port}`;
if (!LOCAL.test(host)) fail(2, `Refused: ${host} is not a local emulator address. Nothing was written.`);
process.env.FIRESTORE_EMULATOR_HOST = host;

// The Admin SDK from the functions folder, as the tests use it. Nothing is installed for the loader.
const requireFromFunctions = createRequire(new URL('../functions/package.json', import.meta.url));
const { deleteApp, initializeApp } = requireFromFunctions('firebase-admin/app');
const { getFirestore } = requireFromFunctions('firebase-admin/firestore');

const app = initializeApp({ projectId: PROJECT_ID }, 'seed-loader');
try {
  const { written, others } = await loadSeed(getFirestore(app));
  console.log(`Loaded into the emulator at ${host}: ${written.join(', ')}`);
  if (others.length > 0) console.log(`Left alone, because they are not in the seed: ${others.join(', ')}`);
} finally {
  await deleteApp(app);
}
