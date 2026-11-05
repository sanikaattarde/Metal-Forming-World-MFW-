// SPIKE (DEC-004 OPEN). Vite builds and serves the admin panel; Vitest runs its tests. TD-14 names no
// build tool, so this one is a spike choice (admin/NOTES.md).
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [react()],
  // Local only: the dev server and the preview listen on the loopback address.
  server: { host: '127.0.0.1', port: 5173, strictPort: true },
  preview: { host: '127.0.0.1', port: 4173, strictPort: true },
  build: { outDir: 'dist', sourcemap: false },
  test: {
    include: ['test/**/*.test.{ts,tsx}'],
    // Node by default. A component test asks for the simulated browser with `@vitest-environment jsdom`.
    environment: 'node',
    // The Auth emulator is shared, so the files run one after another.
    fileParallelism: false,
  },
});
