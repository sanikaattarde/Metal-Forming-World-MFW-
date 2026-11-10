// OP-42: the first-admin bootstrap and recovery step (MOD12-P1-T02, SECURITY_AND_ACCESS_CONTROL.md
// section 7.1). Run by one developer, verified by the other. Never deployed, and holds no key (SC-19).
//
//   Run:     node scripts/bootstrap-admin.mjs (--email <address> | --uid <id>) --reference <text> [--recovery]
//   Verify:  node scripts/bootstrap-admin.mjs --verify (--email <address> | --uid <id>)
//
// Where it writes:
//   - With no --project, only to the local emulators named in FIRESTORE_EMULATOR_HOST and
//     FIREBASE_AUTH_EMULATOR_HOST (for example inside `firebase emulators:exec`). Anything else is refused.
//   - With --project <id> --confirm <id>, to that real project, with the developer's own Application
//     Default Credentials under role-based access (NFR-SEC-012). The emulator variables must not be set.
//
// The output names the account by its identifier only, never by its email address.
import { createRequire } from 'node:module';
import { parseArgs } from 'node:util';

const LOCAL = /^(127\.0\.0\.1|localhost|\[::1\]):\d+$/;
const EMULATOR_PROJECT = 'demo-mfw';

const fail = (code, message) => {
  console.error(message);
  process.exit(code);
};

let values;
try {
  ({ values } = parseArgs({
    options: {
      email: { type: 'string' },
      uid: { type: 'string' },
      reference: { type: 'string' },
      recovery: { type: 'boolean', default: false },
      verify: { type: 'boolean', default: false },
      project: { type: 'string' },
      confirm: { type: 'string' },
    },
    strict: true,
    allowPositionals: false,
  }));
} catch (error) {
  fail(2, `Usage error: ${error.message}`);
}

if ((values.email === undefined) === (values.uid === undefined)) fail(2, 'Give exactly one of --email and --uid.');
if (!values.verify && values.reference === undefined) fail(2, 'Give --reference: the reference to the written request (GS-Q33).');
if (values.verify && (values.reference !== undefined || values.recovery)) fail(2, '--verify takes no --reference or --recovery.');

const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
let projectId;
if (values.project === undefined) {
  if (!firestoreHost || !authHost || !LOCAL.test(firestoreHost) || !LOCAL.test(authHost)) {
    fail(2, 'Refused: not on the local emulators, and no --project was given. Nothing was written.');
  }
  projectId = EMULATOR_PROJECT;
} else {
  if (firestoreHost || authHost) fail(2, 'Refused: the emulator variables are set, so --project is ambiguous. Nothing was written.');
  if (values.project.startsWith('demo-')) fail(2, 'Refused: a demo- project is for the emulators only.');
  if (values.confirm !== values.project) fail(2, 'Refused: --confirm must repeat the --project identifier.');
  projectId = values.project;
}

// The Admin SDK and the compiled step from the functions folder: `npm --prefix functions run build` first.
const requireFromFunctions = createRequire(new URL('../functions/package.json', import.meta.url));
const { deleteApp, initializeApp } = requireFromFunctions('firebase-admin/app');
const { getAuth } = requireFromFunctions('firebase-admin/auth');
const { getFirestore } = requireFromFunctions('firebase-admin/firestore');
const { bootstrapAdmin, BootstrapRefused, verifyBootstrap } = await import('../functions/dist/bootstrap.js');

const app = initializeApp({ projectId }, 'bootstrap-step');
const backend = { db: getFirestore(app), auth: getAuth(app) };
const target = values.email !== undefined ? { email: values.email } : { uid: values.uid };

// The exit status is set, not forced, so that the app closes its connections before the process ends.
try {
  if (values.verify) {
    console.log(JSON.stringify({ project: projectId, ...(await verifyBootstrap(backend, target)) }));
  } else {
    const result = await bootstrapAdmin(backend, { target, reference: values.reference, recovery: values.recovery });
    console.log(JSON.stringify({ project: projectId, ...result }));
  }
} catch (error) {
  if (error instanceof BootstrapRefused) {
    console.error(error.message);
    process.exitCode = 1;
  } else {
    console.error(`The step failed: ${error.code ?? error.name}. Run --verify to see what, if anything, was written.`);
    process.exitCode = 3;
  }
} finally {
  await deleteApp(app);
}
