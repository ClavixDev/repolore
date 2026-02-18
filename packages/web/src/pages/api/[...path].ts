import type { APIRoute } from 'astro';
import { app } from '../../lib/api/index.js';

// Handler for all HTTP methods
const handler: APIRoute = async ({ request, locals }) => {
  const env = locals.runtime.env;
  return app.fetch(request, env);
};

// Export handlers for all HTTP methods
export const GET = handler;
export const POST = handler;
export const PATCH = handler;
export const PUT = handler;
export const DELETE = handler;
export const OPTIONS = handler;
