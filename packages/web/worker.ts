// Custom Cloudflare Worker entry point
// This wraps Astro's handler and adds queue consumer support

import { handleOutlineQueue, handleContentQueue, type Env } from './src/lib/queue/handlers.js';

// Import Astro's generated handler (will be available after build)
// @ts-ignore - This file is created by Astro build
declare const astroHandler: {
  fetch: (request: Request, env: Env, ctx: ExecutionContext) => Promise<Response>;
};

// Check if we're in development mode
const isDev = typeof import.meta.env !== 'undefined' && import.meta.env.DEV;

export default {
  // HTTP requests - delegated to Astro
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    if (isDev) {
      // In dev, Astro's dev server handles requests
      return new Response('Dev mode - use astro dev', { status: 200 });
    }

    // Import Astro's handler dynamically
    const { default: astroApp } = await import('./dist/_worker.js');
    return astroApp.fetch(request, env, ctx);
  },

  // Queue consumers - NOT handled by Astro
  async queue(batch: MessageBatch<unknown>, env: Env, ctx: ExecutionContext): Promise<void> {
    console.log(`[worker] Queue handler invoked for ${batch.queue}`);

    switch (batch.queue) {
      case 'repolore-outline-queue':
        await handleOutlineQueue(batch, env, ctx);
        break;
      case 'repolore-content-queue':
        await handleContentQueue(batch, env, ctx);
        break;
      default:
        console.warn(`[worker] Unknown queue: ${batch.queue}`);
    }
  },
};
