// The project configuration of a build (CFG-01, DEC-004). No emulator and no project is reached.
import { expect, test } from 'vitest';
import { createServices, projectConfigFrom } from '../src/services';

const FULL = {
  VITE_FIREBASE_API_KEY: 'placeholder-key',
  VITE_FIREBASE_AUTH_DOMAIN: 'mfw-test.example.test',
  VITE_FIREBASE_PROJECT_ID: 'mfw-test-placeholder',
};

test('CFG-01: with no project values the build has no project, and uses the emulators locally', () => {
  expect(projectConfigFrom({})).toBeNull();
  expect(projectConfigFrom({ VITE_FIREBASE_API_KEY: '  ', MODE: 'test' })).toBeNull();
});

test('CFG-01: the three values make a project configuration, trimmed, with the app identifier when given', () => {
  expect(projectConfigFrom({ ...FULL, VITE_FIREBASE_PROJECT_ID: ' mfw-test-placeholder ' })).toEqual({
    apiKey: 'placeholder-key',
    authDomain: 'mfw-test.example.test',
    projectId: 'mfw-test-placeholder',
  });
  expect(projectConfigFrom({ ...FULL, VITE_FIREBASE_APP_ID: '1:2:web:3' })?.appId).toBe('1:2:web:3');
});

for (const missing of Object.keys(FULL)) {
  test(`CFG-01: a configuration without ${missing} is refused, so a build cannot half-connect`, () => {
    expect(() => projectConfigFrom({ ...FULL, [missing]: '' })).toThrow(/incomplete/);
  });
}

test('CFG-01: a demo project name is refused for a real project', () => {
  expect(() => projectConfigFrom({ ...FULL, VITE_FIREBASE_PROJECT_ID: 'demo-mfw' })).toThrow(/emulators only/);
});

test('CFG-01: with no project values, a page served from another address gets no services', async () => {
  expect(await createServices('admin.example.test', {})).toBeNull();
});

test('CFG-01: with project values, services exist on any address, and nothing is called yet', async () => {
  const services = await createServices('admin.example.test', FULL);
  expect(services).not.toBeNull();
  expect(typeof services?.signIn).toBe('function');
});

test('CFG-01: an unusable configuration makes createServices fail, so the entry point shows its notice', async () => {
  await expect(createServices('admin.example.test', { ...FULL, VITE_FIREBASE_AUTH_DOMAIN: '' })).rejects.toThrow(/incomplete/);
});
