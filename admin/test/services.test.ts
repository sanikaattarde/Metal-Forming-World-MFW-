// SPIKE (DEC-004 OPEN). How the panel sets up the provider. No emulator call is made here.
import { inMemoryPersistence } from 'firebase/auth';
import { expect, test, vi } from 'vitest';

const seen = vi.hoisted(() => [] as unknown[]);

vi.mock('firebase/auth', async (importOriginal) => {
  const real = await importOriginal<typeof import('firebase/auth')>();
  return {
    ...real,
    initializeAuth: (...args: Parameters<typeof real.initializeAuth>) => {
      seen.push(args[1]);
      return real.initializeAuth(...args);
    },
  };
});

const { emulatorAuth } = await import('../src/services');

// Limit: under Vitest the SDK's Node build is loaded, where the browser persistences are the same object as
// in-memory persistence. So this test shows that the option is passed, not which one: swapping in browser
// storage is not caught here. The browser check in NOTES.md section 2 covers that.
test('B3: the provider is set up through initializeAuth with in-memory sessions (CODING_STANDARDS.md §15 item 5)', () => {
  emulatorAuth('http://127.0.0.1:9099', 'b3-setup');
  expect(seen).toEqual([{ persistence: inMemoryPersistence }]);
});
