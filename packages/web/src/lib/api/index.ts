import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { healthRoutes } from './routes/health.js';

// Hono app type with Cloudflare bindings
type Bindings = {
  REPOLORE_DB: D1Database;
  OUTLINE_QUEUE: Queue;
  CONTENT_QUEUE: Queue;
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENCRYPTION_KEY: string;
  NANOGPT_API_KEY: string;
};

// Create Hono app with base path
export const app = new Hono<{ Bindings: Bindings }>();

// Middleware
app.use(logger());

// CORS for MCP cloud API requests
app.use(
  '/api/mcp/*',
  cors({
    origin: '*',
    allowMethods: ['GET', 'POST', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization', 'X-RepoLore-Key'],
  })
);

// Mount routes
app.route('/api/health', healthRoutes);

// 404 handler
app.notFound((c) => {
  return c.json({ success: false, error: 'Not found' }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error('API Error:', err);
  return c.json({ success: false, error: 'Internal server error' }, 500);
});

export type AppType = typeof app;
