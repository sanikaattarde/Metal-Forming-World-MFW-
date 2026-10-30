// SPIKE helper (DEC-003 OPEN). Local emulators only.
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

const config = JSON.parse(readFileSync(new URL('../firebase.json', import.meta.url), 'utf8'));
const read = (name) => readFileSync(new URL(`../${name}`, import.meta.url), 'utf8');

// A "demo-" project name is meant to keep the emulators offline. NOT VERIFIED here.
export const PROJECT_ID = 'demo-mfw-spike';
export const AUTH_BASE = `http://${config.emulators.auth.host}:${config.emulators.auth.port}`;

export async function newTestEnv() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: config.emulators.firestore.host,
      port: config.emulators.firestore.port,
      rules: read('firestore.rules'),
    },
    storage: {
      host: config.emulators.storage.host,
      port: config.emulators.storage.port,
      rules: read('storage.rules'),
    },
  });
}
