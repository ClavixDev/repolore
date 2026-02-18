import { Hono } from 'hono';
import { APP_INFO } from '@repolore/shared';

export const healthRoutes = new Hono();

healthRoutes.get('/', (c) => {
  return c.json({
    status: 'ok',
    version: APP_INFO.VERSION,
    timestamp: new Date().toISOString(),
  });
});
