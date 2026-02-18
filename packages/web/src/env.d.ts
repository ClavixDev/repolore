/// <reference types="astro/client" />

declare namespace App {
  interface Locals {
    runtime: {
      env: {
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
    };
    user?: {
      id: string;
      email: string;
      name: string | null;
      role: string;
    };
  }
}

declare module '@repolore/shared' {
  export * from '../shared/src/types';
  export * from '../shared/src/constants';
  export * from '../shared/src/schemas';
}
