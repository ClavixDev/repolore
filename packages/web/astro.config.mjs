import { defineConfig } from 'astro/config';
import cloudflare from '@astrojs/cloudflare';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';

// @ts-check
export default defineConfig({
  output: 'server',
  adapter: cloudflare({
    mode: 'advanced',
  }),
  integrations: [react()],
  vite: {
    plugins: [tailwindcss()],
    resolve: {
      alias: {
        '@': '/src',
      },
    },
    build: {
      rollupOptions: {
        external: ['tslib'],
      },
    },
  },
});
