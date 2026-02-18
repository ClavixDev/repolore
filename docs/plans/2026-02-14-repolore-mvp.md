# RepoLore MVP — Full Product PRD & Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Each phase is a milestone. Complete all tasks in a phase before moving to the next.

**Goal:** Build RepoLore — a "commits-to-content" platform that transforms code changes into SEO-ready blog posts and social media content for indie developers and vibecoders.

**Architecture:** Single Cloudflare Worker running Astro SSR with Hono API routes, D1 database, Cloudflare Queues for async AI generation via nanoGPT, GitHub App for repo access, Google/GitHub OAuth for auth, and Polar.sh for billing. Separate npm-published MCP server package for IDE integration.

**Tech Stack:** Astro 5 SSR, Hono, Cloudflare Workers/D1/Queues, TypeScript, Tailwind CSS 4, shadcn/ui, nanoGPT API (DeepSeek v3.2), Polar.sh, MCP SDK, pnpm + Turborepo monorepo.

**Domain:** `repolore.com`

---

## Table of Contents

1. [Product Vision & Audience](#1-product-vision--audience)
2. [Architecture Overview](#2-architecture-overview)
3. [Design System](#3-design-system)
4. [Database Schema](#4-database-schema)
5. [Monetization & Tiers](#5-monetization--tiers)
6. [Phase 1: Project Scaffold & Infrastructure](#phase-1-project-scaffold--infrastructure)
7. [Phase 2: Authentication & User Management](#phase-2-authentication--user-management)
8. [Phase 3: Public Website (Landing + Pages)](#phase-3-public-website-landing--pages)
9. [Phase 4: Dashboard Core](#phase-4-dashboard-core)
10. [Phase 5: GitHub App Integration](#phase-5-github-app-integration)
11. [Phase 6: AI Content Generation Pipeline](#phase-6-ai-content-generation-pipeline)
12. [Phase 7: MCP Server Package](#phase-7-mcp-server-package)
13. [Phase 8: Billing Integration (Polar.sh)](#phase-8-billing-integration-polarsh)
14. [Phase 9: Push Notifications & Polish](#phase-9-push-notifications--polish)
15. [System Prompts Reference](#system-prompts-reference)
16. [REPOLORE.md Specification](#repoloremd-specification)
17. [API Reference](#api-reference)

---

## 1. Product Vision & Audience

### The Problem
Indie hackers and vibecoders ship fast (using Cursor, Windsurf, Claude Code) but fail to market their work. They have raw data (commits, PRs, diffs) but lack the bridge to SEO-ready content. Context-switching from coding to writing is painful.

### The Solution
RepoLore connects to GitHub repositories, understands code changes, and transforms technical updates into ranking content: blog posts, changelogs, and social media posts (X/Twitter, LinkedIn).

### Target Audience
- Indie hackers shipping SaaS products
- AI-assisted developers ("vibecoders")
- Solo founders who code but don't market
- Small teams without dedicated content writers
- #buildinpublic community on X/Twitter

### Core Value Proposition
"Your AI copilot writes code. RepoLore writes the marketing."

One PR merge → multiple pieces of content (blog post, changelog, X thread, LinkedIn post).

### What RepoLore Is NOT
- Not a generic AI writing tool (it has your codebase context)
- Not a CMS or blog platform (it generates content you publish elsewhere)
- Not a social media scheduler (it creates content, not scheduling)

---

## 2. Architecture Overview

### Single Worker Architecture
Everything runs inside a single Cloudflare Worker. Astro SSR handles page rendering and serves the frontend. Hono is mounted at `/api/*` for all API routes. The same worker handles webhooks, queue consumers, and OAuth callbacks.

```
repolore/
├── packages/
│   ├── web/              ← Astro SSR app (landing + dashboard + API)
│   │   ├── src/
│   │   │   ├── pages/         ← Astro pages (public + dashboard)
│   │   │   ├── components/    ← UI components (React islands)
│   │   │   ├── layouts/       ← Page layouts
│   │   │   ├── lib/           ← Server-side utilities
│   │   │   │   ├── api/       ← Hono app + routes
│   │   │   │   ├── auth/      ← OAuth flows
│   │   │   │   ├── db/        ← D1 queries
│   │   │   │   ├── ai/        ← nanoGPT client
│   │   │   │   └── queue/     ← Queue producers/consumers
│   │   │   └── styles/        ← Global CSS + Tailwind
│   │   ├── public/            ← Static assets
│   │   ├── migrations/        ← D1 SQL migrations
│   │   ├── astro.config.mjs
│   │   ├── wrangler.toml
│   │   └── package.json
│   ├── mcp/              ← MCP server (npm package)
│   │   ├── src/
│   │   │   ├── index.ts       ← MCP server entry
│   │   │   ├── tools/         ← MCP tool handlers
│   │   │   ├── prompts/       ← System prompts for content generation
│   │   │   ├── git/           ← Local git operations
│   │   │   └── cloud/         ← Optional cloud API client
│   │   └── package.json
│   └── shared/           ← Shared types & constants
│       ├── src/
│       │   ├── types.ts
│       │   ├── schemas.ts     ← Zod schemas
│       │   └── constants.ts
│       └── package.json
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

### Request Flow

```
Browser/MCP → Cloudflare Worker
                ├── Astro SSR (pages, layouts, components)
                ├── Hono API (/api/*)
                │   ├── /api/auth/*        → OAuth flows
                │   ├── /api/projects/*    → CRUD
                │   ├── /api/generations/* → Content management
                │   ├── /api/github/*      → Webhook receiver
                │   ├── /api/billing/*     → Polar.sh webhooks
                │   └── /api/mcp/*         → MCP cloud endpoints
                ├── D1 (database)
                ├── Queues (async AI generation)
                │   ├── outline-queue → Analyze diff, generate outline
                │   └── content-queue → Generate full content from approved outline
                └── D1 sessions table
```

### Worker Entry & Queue Consumers

**⚠️ Critical Architecture Note:** Astro's `@astrojs/cloudflare` adapter only exports a `fetch` handler. Cloudflare Queues require a `queue` handler export from the same worker. Astro does NOT natively support this.

**Solution:** Create a custom worker entry file (`packages/web/worker.ts`) that wraps Astro's generated handler and adds the queue consumer export:

```typescript
// packages/web/worker.ts — Custom worker entry point
import { default as astroHandler } from './dist/_worker.js';
import { handleOutlineQueue } from './src/lib/queue/consumers/outline';
import { handleContentQueue } from './src/lib/queue/consumers/content';

export default {
  // Astro handles all HTTP requests (pages + API)
  fetch: astroHandler.fetch,

  // Queue consumers — NOT handled by Astro
  async queue(batch, env, ctx) {
    switch (batch.queue) {
      case 'repolore-outline-queue':
        await handleOutlineQueue(batch, env, ctx);
        break;
      case 'repolore-content-queue':
        await handleContentQueue(batch, env, ctx);
        break;
    }
  },
};
```

In `wrangler.toml`, set `main = "./worker.ts"` instead of letting Astro's adapter auto-configure the entry. The `[assets]` directive still points to Astro's built client assets. This must be spiked and verified in Phase 1 before proceeding — if the wrapper approach doesn't work with Astro's adapter, the fallback is to use Astro's built `_worker.js` directly and mount a separate queue-only worker (second worker, same D1 binding). The single-worker approach is strongly preferred.

### Queue Architecture

**Queue 1: `outline-queue`**
- Triggered by: API request (dashboard or MCP cloud mode)
- Input: `{ projectId, sourceType, sourceRef, contentTypes[], userContext? }`
- Process: Fetches diff from GitHub API → builds prompt with project config → calls nanoGPT → generates outline
- Output: Creates `outline` row in D1 with status `pending_approval`

**Queue 2: `content-queue`**
- Triggered by: Outline approval (API call)
- Input: `{ outlineId, contentTypes[] }`
- Process: Reads approved outline → builds full content prompt per type → calls nanoGPT → generates content
- Output: Creates `generation` rows in D1 with status `draft`

---

## 3. Design System

### Style: "Neon Velocity" with Terminal Touches

**Philosophy:** Dark, confident, dev-native. Not corporate. Stands out in screenshots and X/Twitter posts. The dual accent system communicates the product's bridge between code (green) and content (gold).

### Color Palette

```css
/* Background layers */
--bg-base: #0A0A0F;        /* Deepest background */
--bg-surface: #12121A;      /* Card/panel surfaces */
--bg-elevated: #1A1A25;     /* Elevated elements, hover states */
--bg-overlay: #22222F;      /* Modals, dropdowns */

/* Text */
--text-primary: #F0F0F5;    /* Primary text */
--text-secondary: #8888A0;  /* Secondary/muted text */
--text-tertiary: #55556A;   /* Disabled, placeholder */

/* Accent: Code/Tech (Green) */
--accent-green: #39FF14;    /* Primary green accent */
--accent-green-muted: #2AD10E; /* Softer green for larger surfaces */
--accent-green-bg: rgba(57, 255, 20, 0.08); /* Green tint for backgrounds */
--accent-green-border: rgba(57, 255, 20, 0.2); /* Green tint for borders */

/* Accent: Content/Story (Gold) */
--accent-gold: #F5A623;     /* Primary gold accent */
--accent-gold-muted: #D4912A; /* Softer gold */
--accent-gold-bg: rgba(245, 166, 35, 0.08); /* Gold tint for backgrounds */
--accent-gold-border: rgba(245, 166, 35, 0.2); /* Gold tint for borders */

/* Semantic */
--success: #39FF14;
--warning: #F5A623;
--error: #FF4444;
--info: #4488FF;

/* Borders */
--border-default: rgba(255, 255, 255, 0.06);
--border-hover: rgba(255, 255, 255, 0.12);
```

### Typography

```css
/* Display/Headlines: Space Grotesk (variable, self-hosted) */
font-family: 'Space Grotesk', system-ui, sans-serif;

/* Code/Data/Monospace: Geist Mono (Vercel, open source) */
font-family: 'Geist Mono', 'JetBrains Mono', monospace;

/* Scale */
--text-xs: 0.75rem;    /* 12px - labels, metadata */
--text-sm: 0.875rem;   /* 14px - body small */
--text-base: 1rem;     /* 16px - body */
--text-lg: 1.125rem;   /* 18px - body large */
--text-xl: 1.25rem;    /* 20px - section headers */
--text-2xl: 1.5rem;    /* 24px - card titles */
--text-3xl: 2rem;      /* 32px - page titles */
--text-4xl: 2.5rem;    /* 40px - hero subtitle */
--text-5xl: 3.5rem;    /* 56px - hero headline */
--text-6xl: 4.5rem;    /* 72px - landing hero (desktop) */
```

### Component Patterns

**Cards:** `bg-surface` with `border-default`, subtle hover glow with green or gold depending on content type. No border-radius greater than 8px. Bento grid layout for feature sections.

**Buttons:**
- Primary: solid green background, dark text
- Secondary: bordered, transparent bg, green text
- Gold CTA: solid gold background for content-related actions
- Ghost: transparent, text only

**Code blocks:** `bg-base` with green-tinted left border, Geist Mono font, with subtle line numbers.

**Terminal-inspired elements:** Use monospace font for git refs, commit SHAs, file paths, and MCP command examples. NOT for general UI chrome.

**Green = code/tech side:** diffs, git references, status indicators, MCP commands, technical features
**Gold = content/story side:** blog previews, generated content, brand voice, CTA buttons, "Lore"

### Tailwind Config (CSS-first, Tailwind v4)

Tailwind v4 uses CSS `@theme` directives instead of `tailwind.config.mjs`. All theme customization goes in `global.css`:

```css
/* packages/web/src/styles/global.css */
@import "tailwindcss";

@theme {
  --color-bg-base: #0A0A0F;
  --color-bg-surface: #12121A;
  --color-bg-elevated: #1A1A25;
  --color-bg-overlay: #22222F;

  --color-text-primary: #F0F0F5;
  --color-text-secondary: #8888A0;
  --color-text-tertiary: #55556A;

  --color-accent-green: #39FF14;
  --color-accent-green-muted: #2AD10E;
  --color-accent-gold: #F5A623;
  --color-accent-gold-muted: #D4912A;

  --color-success: #39FF14;
  --color-warning: #F5A623;
  --color-error: #FF4444;
  --color-info: #4488FF;

  --font-sans: "Space Grotesk", system-ui, sans-serif;
  --font-mono: "Geist Mono", "JetBrains Mono", monospace;
}
```

Use as: `bg-bg-base`, `text-accent-green`, `font-mono`, etc.

---

## 4. Database Schema

All tables in a single D1 database. Uses `TEXT` for IDs (UUIDs generated server-side via `crypto.randomUUID()`).

```sql
-- Users (authenticated via Google or GitHub OAuth)
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user', -- 'user' | 'admin'
  api_key_hash TEXT, -- SHA-256 hash of API key (for MCP cloud auth). Key shown once on generation, hash stored.
  ai_endpoint TEXT,          -- BYOK: OpenAI-compatible API endpoint URL (e.g. https://api.openai.com/v1)
  ai_model TEXT,             -- BYOK: model ID (e.g. gpt-4o-mini, deepseek-chat)
  ai_api_key TEXT,           -- BYOK: encrypted API key (AES-GCM, same as OAuth tokens)
  preferences_json TEXT NOT NULL DEFAULT '{}', -- UI preferences (e.g. onboarding_dismissed)
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- OAuth accounts (linked to users, supports multiple providers)
CREATE TABLE oauth_accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL, -- 'google' | 'github'
  provider_account_id TEXT NOT NULL,
  access_token TEXT, -- encrypted
  refresh_token TEXT, -- encrypted (Google only)
  token_expires_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(provider, provider_account_id)
);

-- Sessions (stored in D1, referenced by cookie)
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- GitHub App installations (separate from OAuth — for repo access)
CREATE TABLE github_installations (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE, -- nullable: webhook fires before setup redirect links the user
  installation_id INTEGER NOT NULL UNIQUE, -- GitHub's installation ID
  account_login TEXT NOT NULL, -- GitHub username or org
  account_type TEXT NOT NULL, -- 'User' | 'Organization'
  permissions_json TEXT, -- JSON of granted permissions
  access_token TEXT, -- cached installation access token (expires after 1 hour)
  token_expires_at TEXT, -- expiry timestamp for cached token
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Projects (1 project = 1+ repos)
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  config_json TEXT NOT NULL DEFAULT '{}', -- brand voice, tone, SEO pillars, frontmatter template
  repolore_md TEXT, -- cached copy of REPOLORE.md from repo
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Project repositories (join table, supports multi-repo projects on paid plans)
CREATE TABLE project_repos (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  installation_id INTEGER NOT NULL REFERENCES github_installations(installation_id) ON DELETE CASCADE,
  repo_full_name TEXT NOT NULL, -- 'owner/repo'
  is_primary INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(project_id, repo_full_name)
);

-- Project memories (auto-added learnings after content is approved)
CREATE TABLE memories (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- 'learning' | 'style_note' | 'topic_covered'
  content TEXT NOT NULL,
  source_generation_id TEXT, -- which generation created this memory
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Outlines (step 1 of generation: diff → outline for approval)
CREATE TABLE outlines (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  source_type TEXT NOT NULL, -- 'pr' | 'commit' | 'diff' | 'manual'
  source_ref TEXT, -- PR URL, commit SHA, or null for manual
  content_types_json TEXT NOT NULL, -- '["blog","tweet","linkedin"]'
  user_context TEXT, -- optional user-provided context ("this was a nightmare to fix")
  diff_content TEXT, -- cached diff from GitHub (needed by content-queue for blog/changelog prompts)
  outline_content TEXT, -- the generated outline (markdown)
  status TEXT NOT NULL DEFAULT 'queued', -- 'queued' | 'generating' | 'pending_approval' | 'approved' | 'rejected' | 'saved_for_later' | 'completed' | 'failed'
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Generations (step 2: approved outline → full content)
CREATE TABLE generations (
  id TEXT PRIMARY KEY,
  outline_id TEXT NOT NULL REFERENCES outlines(id) ON DELETE CASCADE,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- 'blog' | 'changelog' | 'tweet' | 'linkedin'
  content TEXT, -- the generated content (markdown for blog, plain text for social)
  metadata_json TEXT DEFAULT '{}', -- title, slug, tags, frontmatter, seo_description, character_count
  status TEXT NOT NULL DEFAULT 'queued', -- 'queued' | 'generating' | 'draft' | 'published' | 'archived' | 'failed'
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Push notification subscriptions (Web Push API)
CREATE TABLE push_subscriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  endpoint TEXT NOT NULL,
  keys_json TEXT NOT NULL, -- { p256dh, auth }
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(user_id, endpoint)
);

-- Billing (Polar.sh subscription tracking)
CREATE TABLE subscriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  polar_subscription_id TEXT NOT NULL UNIQUE,
  polar_customer_id TEXT,
  plan TEXT NOT NULL, -- 'free' | 'hacker'
  status TEXT NOT NULL, -- 'active' | 'canceled' | 'past_due'
  current_period_end TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Usage tracking (for enforcing tier limits)
-- Effective usage = (cloud_outlines_count * 0.1) + cloud_generations_count
-- Outlines count as 0.1 to prevent abuse (generating outlines and using content elsewhere)
-- Tier limits: Free = 20 effective items/month, Hacker = 200 effective items/month
-- Increment cloud_outlines_count when: outline created via cloud API or MCP push
-- Increment cloud_generations_count when: generation created via cloud queue or content pushed from MCP
CREATE TABLE usage (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  period TEXT NOT NULL, -- '2026-02' (monthly)
  cloud_outlines_count INTEGER NOT NULL DEFAULT 0,
  cloud_generations_count INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, period)
);

-- Indexes
CREATE INDEX idx_oauth_accounts_user ON oauth_accounts(user_id);
CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
CREATE INDEX idx_projects_user ON projects(user_id);
CREATE INDEX idx_project_repos_project ON project_repos(project_id);
CREATE INDEX idx_memories_project ON memories(project_id);
CREATE INDEX idx_outlines_project ON outlines(project_id);
CREATE INDEX idx_outlines_status ON outlines(status);
CREATE INDEX idx_generations_outline ON generations(outline_id);
CREATE INDEX idx_generations_project ON generations(project_id);
CREATE INDEX idx_generations_type ON generations(type);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_usage_user_period ON usage(user_id, period);
```

---

## 5. Monetization & Tiers

### Free Tier
- BYO-AI via MCP (local, no cloud)
- BYOK (Bring Your Own Key) for cloud/dashboard generation — user provides OpenAI-compatible endpoint, model ID, and API key
- 2 repositories connected
- 20 effective cloud items/month (outlines count as 0.1, generations count as 1.0)
- Brand voice config up to 500 characters
- Basic dashboard (view stored content, generate via BYOK)
- REPOLORE.md local only (no cloud sync)

### Hacker Tier (~$9-12/month via Polar.sh)
- Everything in Free
- RepoLore AI included (nanoGPT/DeepSeek — no API key needed) + BYOK option
- 5 repositories connected
- 200 effective cloud items/month (outlines × 0.1 + generations × 1.0)
- Brand voice config up to 2000 characters
- REPOLORE.md cloud sync
- Full dashboard (edit, export, copy)
- Content export (Markdown with frontmatter, copy-paste ready)
- Push notifications for completed generations

### Pro Tier (future, not in MVP)
- Unlimited repos, multi-repo projects
- Webhook auto-drafts on PR merge
- Content analytics
- API access to pull generated content
- Priority AI generation
- RSS feed of generated content

---

## Phase 1: Project Scaffold & Infrastructure [✅ COMPLETED]

> **Status:** COMPLETED - All tasks implemented and verified. Foundation ready for Phase 3.

**Goal:** Set up the monorepo, Astro project, Hono API mount, D1 database, and Cloudflare Worker deployment pipeline.

### Task 1.1: Initialize Monorepo

**Files:**
- Create: `package.json` (root)
- Create: `pnpm-workspace.yaml`
- Create: `turbo.json`
- Create: `.gitignore`
- Create: `.prettierrc`
- Create: `tsconfig.json` (root)

**Steps:**
1. Initialize pnpm workspace with `packages/*` glob
2. Configure Turborepo with `build`, `dev`, `lint` pipelines
3. Root `package.json`: private, `packageManager: pnpm@9.15.0`, engines `node>=20`
4. Root `.gitignore`: `node_modules`, `.wrangler`, `dist`, `.astro`, `.turbo`, `.env`, `.dev.vars`
5. Prettier config: `tabWidth: 4` (matching gdprmetrics convention)

### Task 1.2: Create Shared Package

**Files:**
- Create: `packages/shared/package.json`
- Create: `packages/shared/tsconfig.json`
- Create: `packages/shared/src/types.ts`
- Create: `packages/shared/src/constants.ts`
- Create: `packages/shared/src/schemas.ts`

**Steps:**
1. Package name: `@repolore/shared`
2. Export types for: `User`, `Project`, `Outline`, `Generation`, `ContentType`, `OutlineStatus`, `GenerationStatus`, `TierLimits`
3. Constants: content types (`blog`, `changelog`, `tweet`, `linkedin`), tier limits, outline/generation statuses
4. Zod schemas for API request/response validation
5. `ContentType` enum: `'blog' | 'changelog' | 'tweet' | 'linkedin'`

### Task 1.3: Create Astro Web App

**Files:**
- Create: `packages/web/package.json`
- Create: `packages/web/astro.config.mjs`
- Create: `packages/web/tsconfig.json`
- Create: `packages/web/src/styles/global.css`
- Create: `packages/web/src/env.d.ts`
- Create: `packages/web/src/pages/index.astro`
- Create: `packages/web/public/fonts/` (Geist Mono, Space Grotesk)

**Steps:**
1. Astro 5 with `@astrojs/cloudflare` adapter, `@astrojs/react` integration
2. Output mode: `server` (full SSR)
3. Install and configure: `tailwindcss` (v4) via `@tailwindcss/vite` plugin (NOT `@astrojs/tailwind` which is for Tailwind v3), `shadcn/ui` (for React islands). No `tailwind.config.mjs` — Tailwind v4 uses CSS-first config via `@theme` directives in `global.css`.
4. Set up design system colors and fonts in `global.css` using Tailwind v4's `@theme` block as specified in Section 3
5. Self-host fonts in `public/fonts/` for performance (no Google Fonts external requests)
6. Basic index page with "RepoLore — Coming Soon" to verify deployment
7. Configure shadcn/ui with `components.json` for Astro + React: path aliases, dark theme as default

### Task 1.4: Configure Hono API Mount

**Files:**
- Create: `packages/web/src/lib/api/index.ts` (Hono app)
- Create: `packages/web/src/lib/api/routes/health.ts`
- Create: `packages/web/src/pages/api/[...path].ts` (Astro catch-all → Hono)

**Steps:**
1. Create Hono app instance with basePath `/api`
2. Health check route: `GET /api/health` → `{ status: 'ok', version: '0.1.0' }`
3. Astro catch-all API route that delegates all `/api/*` requests to Hono. **Important:** The catch-all must export handlers for ALL HTTP methods (`GET`, `POST`, `PATCH`, `PUT`, `DELETE`, `OPTIONS`). Each export creates the appropriate `Request` and passes it to the Hono app's `fetch` method:
   ```typescript
   // src/pages/api/[...path].ts
   import type { APIRoute } from 'astro';
   import { app } from '../../lib/api';

   const handler: APIRoute = async ({ request, locals }) => {
     const env = locals.runtime.env;
     return app.fetch(request, env);
   };

   export const GET = handler;
   export const POST = handler;
   export const PATCH = handler;
   export const PUT = handler;
   export const DELETE = handler;
   export const OPTIONS = handler;
   ```
4. Pass Cloudflare bindings (D1, Queues) from Astro's `locals.runtime.env` to Hono context
5. Add CORS middleware for MCP cloud requests (later)

### Task 1.4b: Spike — Worker Entry with Queue Consumers

**Files:**
- Create: `packages/web/worker.ts`

**Steps:**
1. Create the custom worker entry file as described in the Architecture section
2. Build Astro: `pnpm build`
3. Verify `dist/_worker.js` exists after Astro build
4. Test that `worker.ts` can import the Astro handler and re-export `fetch`
5. Test that adding a `queue` export doesn't break the `fetch` handler
6. **If the wrapper approach fails:** Document the issue and plan the fallback (separate queue worker). Do NOT proceed to Phase 6 without this resolved.
7. This spike can be minimal — queue consumers can be stubs (`console.log('queue received')`) until Phase 6

### Task 1.5: D1 Database Setup

**Files:**
- Create: `packages/web/migrations/0001_initial_schema.sql`
- Create: `packages/web/src/lib/db/index.ts` (D1 query helpers)
- Modify: `packages/web/wrangler.toml`

**Steps:**
1. Create D1 database: `wrangler d1 create repolore-db`
2. Write initial migration SQL with full schema from Section 4
3. Create typed query helpers (no ORM — raw SQL with type assertions, same pattern as gdprmetrics)
4. Add D1 binding to `wrangler.toml`

### Task 1.6: Wrangler Configuration

**Files:**
- Create: `packages/web/wrangler.toml`
- Create: `packages/web/.dev.vars.example`

**Steps:**
1. Worker name: `repolore`
2. Compatibility date: current
3. Compatibility flags: `["nodejs_compat"]`
4. Bindings: D1 (`REPOLORE_DB`), Queues (`OUTLINE_QUEUE`, `CONTENT_QUEUE`). No KV — sessions are in D1.
5. Queue consumers defined in same worker via custom worker entry (see Architecture section)
6. Set `main = "./worker.ts"` pointing to custom entry that wraps Astro + queue handlers
7. `.dev.vars.example` with all required secrets listed (no values):
   - `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`
   - `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
   - `GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY`, `GITHUB_APP_WEBHOOK_SECRET`
   - `NANOGPT_API_KEY`
   - `POLAR_WEBHOOK_SECRET`, `POLAR_HACKER_PRODUCT_ID`, `POLAR_HACKER_CHECKOUT_LINK`, `POLAR_ACCESS_TOKEN`
   - `ENCRYPTION_KEY` (for encrypting stored OAuth tokens via AES-GCM)
   - `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY` (for Web Push notifications, generated in Phase 9)
8. `[vars]`: `NODE_ENV = "production"`

### Task 1.7: Deployment Verification

**Steps:**
1. `pnpm install` from root
2. `pnpm dev` — verify Astro dev server starts, index page renders, `/api/health` returns OK
3. `pnpm build` — verify build succeeds
4. Deploy to Cloudflare: `wrangler deploy` from `packages/web`
5. Verify live: `https://repolore.com` shows coming soon page, `/api/health` returns OK
6. Commit: `feat: initial project scaffold with Astro + Hono + D1 on CF Workers`

---

## Phase 2: Authentication & User Management [✅ COMPLETED]

> **Status:** COMPLETED - All tasks implemented and verified. Google OAuth, GitHub OAuth, session management with sliding refresh, CSRF protection, and protected routes all functional.

**Goal:** Implement Google OAuth + GitHub OAuth for login/signup, session management via D1 + secure cookies, and admin role (manual DB assignment).

### Task 2.1: Session Management

**Files:**
- Create: `packages/web/src/lib/auth/session.ts`
- Create: `packages/web/src/lib/auth/middleware.ts`
- Create: `packages/web/src/lib/auth/crypto.ts`

**Steps:**
1. `session.ts`: Functions for `createSession(userId)`, `getSession(sessionId)`, `deleteSession(sessionId)`, `cleanExpiredSessions()`
2. Sessions stored in D1 `sessions` table (not KV — simpler, D1 is fast enough for auth)
3. Session ID: `crypto.randomUUID()`, stored as HTTP-only, Secure, SameSite=Lax cookie named `repolore_session`
4. Session expiry: 30 days, sliding window refresh. Only update `expires_at` in D1 if less than 15 days remain (avoids a D1 write on every authenticated request — at most one refresh per 15-day window per session)
5. `middleware.ts`: Astro middleware that reads cookie, validates session, attaches `user` to `Astro.locals`
6. `crypto.ts`: AES-GCM encryption/decryption for OAuth tokens stored in D1 (using `ENCRYPTION_KEY` secret and Web Crypto API)

### Task 2.1b: CSRF Protection (moved from Phase 9 — must be in place before any mutating API routes)

**Files:**
- Modify: `packages/web/src/lib/api/index.ts` (Hono app)

**Steps:**
1. **Browser requests (session cookie auth):** Protected by `SameSite=Lax` cookie attribute. Combined with checking the `Origin` header on state-changing requests, this is sufficient for MVP.
2. **Hono middleware:** On all `POST`, `PATCH`, `PUT`, `DELETE` routes (except webhooks), verify that the `Origin` header matches `repolore.com` (or `localhost` in dev). Reject with 403 if mismatched. Webhooks (`/api/github/webhook`, `/api/billing/webhook`) are exempt — they use signature verification instead.
3. **MCP cloud requests (API key auth):** No CSRF concern — API key is sent in `X-RepoLore-Key` header, not in cookies. CORS middleware allows these cross-origin requests.
4. No CSRF tokens needed — the combination of SameSite cookies + Origin header check + API key auth covers all vectors.

### Task 2.2: Google OAuth

**Files:**
- Create: `packages/web/src/lib/auth/google.ts`
- Create: `packages/web/src/lib/api/routes/auth.ts`

**Steps:**
1. `google.ts`: Functions for `getGoogleAuthUrl(state)`, `exchangeGoogleCode(code)`, `getGoogleUser(accessToken)`
2. Scopes: `openid email profile`
3. Redirect URI: `https://repolore.com/api/auth/google/callback` (and dev variant)
4. Hono routes in `auth.ts`:
   - `GET /api/auth/google` → Generate state, store in cookie, redirect to Google
   - `GET /api/auth/google/callback` → Verify state, exchange code, upsert user + oauth_account, create session, redirect to `/dashboard`
5. Upsert logic: If `oauth_accounts` has matching `provider=google, provider_account_id`, link to existing user. Otherwise create new user + oauth_account.

### Task 2.3: GitHub OAuth (Login Only)

**Files:**
- Create: `packages/web/src/lib/auth/github.ts`
- Modify: `packages/web/src/lib/api/routes/auth.ts`

**Steps:**
1. `github.ts`: Functions for `getGitHubAuthUrl(state)`, `exchangeGitHubCode(code)`, `getGitHubUser(accessToken)`
2. Scopes: `read:user user:email` (login only — NOT repo access)
3. Redirect URI: `https://repolore.com/api/auth/github/callback`
4. Add to Hono auth routes:
   - `GET /api/auth/github` → redirect to GitHub OAuth
   - `GET /api/auth/github/callback` → exchange, upsert user, create session, redirect to `/dashboard`
5. Same upsert logic as Google. If a user logs in with GitHub email matching an existing Google-auth user, link the accounts (same user, new oauth_account row).

### Task 2.4: Auth API Routes & Logout

**Files:**
- Modify: `packages/web/src/lib/api/routes/auth.ts`

**Steps:**
1. `GET /api/auth/me` → Returns current user (from session) or 401
2. `POST /api/auth/logout` → Delete session from D1, clear cookie, redirect to `/`
3. All auth routes handle errors gracefully (redirect to `/login?error=...`)

### Task 2.5: Auth Middleware Integration

**Files:**
- Create: `packages/web/src/middleware.ts` (Astro middleware)
- Create: `packages/web/src/pages/login.astro`
- Create: `packages/web/src/pages/dashboard/index.astro` (placeholder)

**Steps:**
1. Astro middleware: for `/dashboard/*` routes, check session. If no valid session → redirect to `/login`
2. For public routes, attach user to `locals` if session exists (for conditional nav rendering)
3. Login page: two buttons — "Continue with Google", "Continue with GitHub"
4. Dashboard placeholder: "Welcome, {user.name}" to verify auth works
5. Test full flow: login → dashboard → logout → redirect to home

### Task 2.6: Admin Role

**Steps:**
1. No admin UI for role assignment. Admin sets their own role directly in D1 after registering:
   ```sql
   UPDATE users SET role = 'admin' WHERE email = 'your@email.com';
   ```
2. Admin middleware check: simple `user.role === 'admin'` guard on admin-only routes (future use)
3. Commit: `feat: Google + GitHub OAuth with session management`

---

## Phase 3: Public Website (Landing + Pages) [✅ COMPLETED]

> **Status:** COMPLETED - Landing page, pricing, why-us, contact, and legal pages all implemented with Neon Velocity design system.
> **Note:** Footer "Docs" link is a placeholder (actual docs page in Phase 9). Custom 404 page deferred to Phase 9.

**Goal:** Build the public-facing website: landing page, pricing, "why us", and contact page. Design system applied. No dashboard yet (just auth gate).

### Task 3.1: Layout & Navigation

**Files:**
- Create: `packages/web/src/layouts/BaseLayout.astro` (shared HTML shell)
- Create: `packages/web/src/layouts/PublicLayout.astro` (public pages with nav/footer)
- Create: `packages/web/src/components/Header.astro`
- Create: `packages/web/src/components/Footer.astro`
- Create: `packages/web/src/components/MobileMenu.tsx` (React island for mobile nav toggle)

**Steps:**
1. `BaseLayout.astro`: HTML head (meta, fonts, global CSS), dark background, body
2. `PublicLayout.astro`: wraps content with Header + Footer
3. Header: RepoLore logo (text-based initially), nav links (Home, Pricing, Why Us, Contact), Login/Dashboard button (conditional on auth state)
4. Footer: Logo, product links, legal links (Privacy, Terms), social links (X, GitHub, LinkedIn), copyright
5. Mobile: hamburger menu, slide-in nav
6. Apply Neon Velocity design system throughout — dark bg, green/gold accents

### Task 3.2: Landing Page (Home)

**Files:**
- Modify: `packages/web/src/pages/index.astro`

**Steps:**
1. **Hero section:**
   - Headline: "Your Code Has a Story. Let It Tell Itself." (or similar — large, Space Grotesk)
   - Subheadline: "Turn commits into blog posts, changelogs, and social content. Stop copy-pasting diffs into ChatGPT."
   - CTA: "Get Started Free" (green button) + "See How It Works" (ghost button)
   - Visual: Terminal-style code block showing a git diff transforming into a blog post preview (green → gold transition)

2. **Social proof bar:** "Used by indie hackers shipping with Cursor, Windsurf, and Claude Code"

3. **How It Works section (3 steps):**
   - Step 1: "Connect Your Repo" — GitHub App install, green accent
   - Step 2: "Ship Your Code" — merge a PR, commit, green accent
   - Step 3: "Content, Delivered" — blog post + tweet + LinkedIn post appear, gold accent
   - Show actual MCP command example: `@repolore/outline --type blog,tweet`

4. **Content Types showcase (bento grid):**
   - Blog Post card (with example excerpt, gold accent)
   - Changelog Entry card (structured format)
   - X/Twitter Post card (280 chars, thread preview)
   - LinkedIn Post card (professional tone preview)

5. **"Why Not Just ChatGPT?" section:**
   - Comparison: generic AI vs RepoLore
   - Points: has your diff context, knows your brand voice, remembers past content, outputs with frontmatter
   - Terminal-style comparison showing generic output vs. RepoLore output

6. **CTA section:** "Your AI Copilot Writes Code. RepoLore Writes the Marketing." + signup button

### Task 3.3: Pricing Page

**Files:**
- Create: `packages/web/src/pages/pricing.astro`

**Steps:**
1. Two-tier layout: Free and Hacker (Pro shown as "Coming Soon" greyed out)
2. Feature comparison table
3. Free: "Get Started" → goes to signup
4. Hacker: "Start Hacking" → goes to Polar.sh checkout (via API redirect)
5. FAQ section below pricing (billing questions, what counts as storage item, BYO-AI explanation)
6. Note about BYO-AI quality variance: "MCP uses your IDE's AI model. Output quality depends on your model. For consistent, optimized results, upgrade to Hacker for RepoLore AI."

### Task 3.4: Why Us Page

**Files:**
- Create: `packages/web/src/pages/why-us.astro`

**Steps:**
1. "Built for Builders, by a Builder" narrative
2. Key differentiators:
   - Lives in your codebase (REPOLORE.md)
   - Has your diff context (not generic AI)
   - Remembers your brand voice
   - Outputs ready-to-publish content (frontmatter, social formats)
   - No vendor lock-in (BYO-AI option)
3. Comparison with alternatives: "ChatGPT + paste diff", "Write it yourself", "Hire a writer"
4. The "Lore" concept explained — your project's evolving story

### Task 3.5: Contact Page

**Files:**
- Create: `packages/web/src/pages/contact.astro`

**Steps:**
1. Simple contact form: Name, Email, Message
2. Form submits client-side to Formspark.io (external, no backend needed)
3. Formspark form ID hardcoded in the Astro component (it's a public form endpoint, not a secret)
4. Success/error states
5. Alternative contact: "Or reach out on X @repolore"
6. Commit: `feat: public website — landing, pricing, why-us, contact`

---

## Phase 4: Dashboard Core

**Goal:** Build the authenticated dashboard: overview page, project list, project detail (content list), generation viewer, and settings.

### Task 4.1: Dashboard Layout

**Files:**
- Create: `packages/web/src/layouts/DashboardLayout.astro`
- Create: `packages/web/src/components/dashboard/Sidebar.astro`
- Create: `packages/web/src/components/dashboard/DashboardHeader.astro`
- Create: `packages/web/src/components/dashboard/NotificationBell.tsx` (React island)

**Steps:**
1. Sidebar navigation: Overview, Projects, Settings, (Billing)
2. Header: breadcrumb, user avatar dropdown (settings, logout), notification bell
3. Layout: sidebar (collapsible on mobile) + main content area
4. Use `bg-base` for sidebar, `bg-surface` for content area
5. Notification bell shows unread count (generations completed) — placeholder for now

### Task 4.2: Dashboard Overview Page

**Files:**
- Modify: `packages/web/src/pages/dashboard/index.astro`

**Steps:**
1. Welcome message with user name
2. Stats cards (bento grid):
   - Projects count
   - Content generated this month
   - Storage used / limit
   - Latest generation status
3. Recent activity feed (latest 5 outlines/generations across all projects)
4. Quick action: "Create New Project" button
5. If no projects yet: onboarding checklist (see Task 4.2b)

### Task 4.2b: Onboarding Flow

**Files:**
- Create: `packages/web/src/components/dashboard/OnboardingChecklist.tsx` (React island)

**Steps:**
1. Show a checklist component when user has no projects or incomplete setup:
   - [ ] Create your first project
   - [ ] Install the GitHub App
   - [ ] Connect a repository
   - [ ] Configure your brand voice
   - [ ] Generate your first content
2. Each step links to the relevant page/action
3. Track completion state: derive from DB (has projects? has installations? has repos? has config? has generations?)
4. Dismiss option: user can hide the checklist permanently (stored in `users.preferences_json` as `{ "onboarding_dismissed": true }`)
5. Re-show on dashboard overview until all steps complete
6. Design: use a card with green checkmarks for completed steps, gold highlights for the next action

### Task 4.3: Projects List & CRUD API

**Files:**
- Create: `packages/web/src/pages/dashboard/projects/index.astro`
- Create: `packages/web/src/pages/dashboard/projects/new.astro`
- Create: `packages/web/src/pages/dashboard/projects/[id].astro`
- Create: `packages/web/src/lib/api/routes/projects.ts`
- Create: `packages/web/src/lib/db/projects.ts`

**Steps:**
1. `GET /api/projects` — list user's projects (with repo count, generation count)
2. `POST /api/projects` — create project (name, description)
3. `GET /api/projects/:id` — get project detail (with repos, recent outlines, generations)
4. `PATCH /api/projects/:id` — update project config (name, description, config_json)
5. `DELETE /api/projects/:id` — soft delete (or hard delete with cascade)
6. Projects list page: cards showing project name, connected repos, content count
7. New project page: name, description form (repo connection comes in Phase 5)
8. Project detail page: shows connected repos, project config/brand voice, content list (outlines + generations)

### Task 4.4: Project Configuration (Brand Voice & REPOLORE.md)

**Files:**
- Create: `packages/web/src/components/dashboard/ProjectConfig.tsx` (React island)
- Modify: `packages/web/src/pages/dashboard/projects/[id].astro`

**Steps:**
1. Config editor: tone, audience, SEO pillars (comma-separated), brand voice description
2. Frontmatter template config: layout, author, format (md/mdx), output directory
3. Social config: twitter handle, default hashtags
4. "REPOLORE.md" viewer: shows the cached cloud copy (read-only on free, editable on Hacker)
5. Character count for brand voice (enforced by tier limit: 500 free, 2000 hacker)
6. Save config → updates `projects.config_json` in D1

### Task 4.5: Content Browser (Outlines & Generations)

**Files:**
- Create: `packages/web/src/pages/dashboard/projects/[id]/content.astro`
- Create: `packages/web/src/components/dashboard/OutlineCard.tsx`
- Create: `packages/web/src/components/dashboard/GenerationViewer.tsx` (React island)
- Create: `packages/web/src/components/dashboard/ContentEditor.tsx` (React island)
- Create: `packages/web/src/lib/api/routes/generations.ts`
- Create: `packages/web/src/lib/db/generations.ts`

**Steps:**
1. Content list: tabbed view (All | Outlines | Blog | Changelog | Tweet | LinkedIn)
2. Each item shows: type badge, title/excerpt, source ref (PR/commit), status badge, date
3. Outline card: shows outline content, status, approve/reject/save-for-later buttons
4. **Saved-for-later outlines:** Outlines with `saved_for_later` status appear in a separate "Saved" tab. Users can re-open them and approve to trigger content generation.
5. Generation viewer: full content display with:
   - Markdown rendered preview (for blog/changelog)
   - Raw text view (for social posts)
   - Copy-to-clipboard button (one click)
   - "Export as .md" download (with frontmatter for blog posts)
   - Status management (draft → published → archived)
6. **Content editing (ContentEditor.tsx):** Users can edit generated content before publishing:
   - Textarea with the raw markdown/text content
   - Live markdown preview panel (side-by-side on desktop, tabbed on mobile)
   - Save edits → `PATCH /api/generations/:id` with updated `content` field
   - Editing is available on all tiers (users should always be able to fix AI output)
7. API routes:
   - `GET /api/projects/:id/outlines` — list outlines (filterable by status)
   - `PATCH /api/outlines/:id` — update outline status (approve/reject/save_for_later) OR re-approve a saved_for_later outline
   - `GET /api/projects/:id/generations` — list generations (filterable by type, status)
   - `GET /api/generations/:id` — get single generation with full content
   - `PATCH /api/generations/:id` — update status OR update content (for editing)

### Task 4.5b: Dashboard Content Generation UI

**Files:**
- Create: `packages/web/src/pages/dashboard/projects/[id]/generate.astro`
- Create: `packages/web/src/components/dashboard/GenerateForm.tsx` (React island)

**Steps:**
1. "Generate Content" page accessible from project detail page (prominent gold CTA button)
2. **Source selection:**
   - List recent merged PRs from connected repo(s) via GitHub API (see Phase 5 `listRecentPRs`)
   - Option to enter a specific commit SHA or PR number manually
   - Each PR shows: title, merge date, files changed count
3. **Content type selection:** Checkboxes for blog, changelog, tweet, linkedin (multi-select)
4. **Additional context:** Textarea for optional user context ("This PR fixes a race condition we've been chasing for weeks")
5. **Submit:** Calls `POST /api/projects/:id/generate` → creates outline, sends to queue
6. **After submit:** Redirect to content list with toast "Outline is being generated..."
7. This is the core cloud product flow — users who don't use MCP generate content from here
8. Requires at least one connected repo with GitHub App installed (show helpful error if not)
9. Requires AI provider configured: Hacker tier users get RepoLore AI (nanoGPT) by default, free tier users must configure BYOK in Settings first. Show contextual message: "Configure your AI provider in Settings to generate content" with link to settings page.

### Task 4.6: Settings Page

**Files:**
- Create: `packages/web/src/pages/dashboard/settings.astro`
- Create: `packages/web/src/lib/api/routes/settings.ts`

**Steps:**
1. Account section: name, email (read-only from OAuth), avatar
2. Connected accounts: show linked Google/GitHub accounts, option to link additional provider
3. GitHub App: installation status, connected repos (managed via GitHub)
4. Subscription: current plan, usage stats, upgrade/manage link (Polar.sh customer portal)
5. AI Provider section (BYOK):
   - Endpoint URL input (placeholder: "https://api.openai.com/v1")
   - Model ID input (placeholder: "gpt-4o-mini")
   - API Key input (password field, stored encrypted)
   - "Test Connection" button → calls `POST /api/settings/test-ai` which sends a minimal completion request to verify credentials
   - Save → `PATCH /api/settings/ai-config` stores encrypted key + endpoint + model in users table
   - Clear/Remove button to delete BYOK config
   - Helper text: "Provide any OpenAI-compatible API endpoint. Your key is encrypted at rest."
   - If user is on Hacker tier: show "Using RepoLore AI (default)" with option to override with BYOK
6. API key management section: "Generate API Key" button, shows key once, revoke button (uses `POST /api/settings/api-key` and `DELETE /api/settings/api-key` from Task 7.7)
7. Danger zone: delete account (with confirmation) → `DELETE /api/auth/account` — deletes user row (cascades to all data via ON DELETE CASCADE), clears session, redirects to `/`
8. Commit: `feat: dashboard core — overview, projects, content browser, settings`

---

## Phase 5: GitHub App Integration

**Goal:** Create a GitHub App for repo access, handle installation webhooks, enable users to connect repos to projects, and fetch PR diffs via GitHub API.

### Task 5.1: GitHub App Setup

**Documentation steps (not code):**
1. Create GitHub App at `github.com/settings/apps/new`:
   - Name: "RepoLore"
   - Homepage: `https://repolore.com`
   - Callback URL: `https://repolore.com/api/github/callback`
   - Setup URL: `https://repolore.com/api/github/setup` (post-installation redirect)
   - Webhook URL: `https://repolore.com/api/github/webhook`
   - Permissions: `Contents: Read`, `Pull requests: Read`, `Metadata: Read`
   - Subscribe to events: `installation`, `pull_request` (for future webhook drafts)
   - Install only on user accounts (not orgs) initially
2. Store: `GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY`, `GITHUB_APP_WEBHOOK_SECRET` as Wrangler secrets

### Task 5.2: GitHub App Webhook Handler

**Files:**
- Create: `packages/web/src/lib/api/routes/github.ts`
- Create: `packages/web/src/lib/github/app.ts` (GitHub App API client)

**Steps:**
1. `POST /api/github/webhook` — receives GitHub webhook events
2. Verify webhook signature using `GITHUB_APP_WEBHOOK_SECRET`
3. Handle `installation.created`: store installation in `github_installations` table with `user_id = NULL` (the webhook fires before the setup redirect, so user context is not yet available)
4. Handle `installation.deleted`: remove installation from D1
5. `GET /api/github/setup` — post-installation redirect. Receives `installation_id` query param from GitHub. Links the pending installation to the logged-in user's account by updating `user_id` in the `github_installations` row. If the webhook hasn't fired yet (race condition), create the row here instead.
6. `github/app.ts`: Functions to generate JWT from App private key, get installation access token, list repos for installation, get PR diff, get commit diff

### Task 5.3: Repo Connection UI

**Files:**
- Modify: `packages/web/src/pages/dashboard/projects/[id].astro`
- Create: `packages/web/src/components/dashboard/RepoConnector.tsx` (React island)
- Create: `packages/web/src/lib/api/routes/repos.ts`

**Steps:**
1. "Connect Repository" button on project detail page
2. If no GitHub App installed: redirect to GitHub App installation page
3. If installed: show list of accessible repos from installation, let user select. API route: `GET /api/github/installations/:installationId/repos` — calls GitHub API `listReposForInstallation()` and returns filtered list
4. `POST /api/projects/:id/repos` — link a repo to a project
5. `DELETE /api/projects/:id/repos/:repoId` — unlink a repo
6. Enforce tier limits: free = 2 repos total across all projects, hacker = 5

### Task 5.4: Diff Fetching

**Files:**
- Create: `packages/web/src/lib/github/diff.ts`

**Steps:**
1. `getPRDiff(installationId, owner, repo, prNumber)` — fetches PR diff via GitHub API using installation access token
2. `getCommitDiff(installationId, owner, repo, sha)` — fetches commit diff
3. `listRecentPRs(installationId, owner, repo, limit)` — lists recent merged PRs (for user to select from in dashboard)
4. Diff size handling: if diff > 50KB, summarize (truncate to most changed files, include file list)
5. Commit: `feat: GitHub App integration — install, webhook, repo connection, diff fetching`

---

## Phase 6: AI Content Generation Pipeline

**Goal:** Implement the two-queue pipeline: diff → outline (Queue 1) → approved outline → full content (Queue 2). Uses nanoGPT API with DeepSeek v3.2.

### Task 6.1: AI Client (OpenAI-Compatible)

**Files:**
- Create: `packages/web/src/lib/ai/client.ts`

**Steps:**
1. Generic OpenAI-compatible client that accepts configurable endpoint, model, and API key
2. Default (nanoGPT): endpoint `https://nano-gpt.com/api/v1/chat/completions`, model `deepseek/deepseek-chat-v3-0324`, key from `NANOGPT_API_KEY` secret
3. BYOK mode: reads user's `ai_endpoint`, `ai_model`, `ai_api_key` (decrypted) from DB
4. Function: `createAIClient(config: { endpoint: string, model: string, apiKey: string })` → returns client
5. Client method: `generateCompletion(systemPrompt, userPrompt, options?)` → returns string content
6. Helper: `getAIConfigForUser(user, env)` → returns config from BYOK settings or nanoGPT defaults (Hacker tier)
7. Non-streaming mode (queue consumer doesn't need streaming)
8. Error handling: retry once on 5xx, throw on 4xx. For BYOK, surface clear error messages (invalid key, model not found, quota exceeded)
9. Timeout: 60 seconds (long content generation)
10. Queue consumers call `getAIConfigForUser()` to determine which AI backend to use

### Task 6.2: Prompt Engineering — System Prompts

**Files:**
- Create: `packages/web/src/lib/ai/prompts/outline.ts`
- Create: `packages/web/src/lib/ai/prompts/blog.ts`
- Create: `packages/web/src/lib/ai/prompts/changelog.ts`
- Create: `packages/web/src/lib/ai/prompts/tweet.ts`
- Create: `packages/web/src/lib/ai/prompts/linkedin.ts`

**Steps:**
See [System Prompts Reference](#system-prompts-reference) section for full prompt contents.
Each prompt builder is a function that takes project config + outline/diff context and returns `{ system: string, user: string }`.

### Task 6.3: Queue Producers

**Files:**
- Create: `packages/web/src/lib/queue/producers.ts`
- Modify: `packages/web/src/lib/api/routes/generations.ts`

**Steps:**
1. `enqueueOutline(queue, data)` — sends to `OUTLINE_QUEUE`
2. `enqueueContent(queue, data)` — sends to `CONTENT_QUEUE`
3. API route: `POST /api/projects/:id/generate` — creates outline row in D1 (status: `queued`), sends to outline queue
4. Request body: `{ sourceType, sourceRef, contentTypes[], userContext? }`
5. Outline approval uses `PATCH /api/outlines/:id` with body `{ status: 'approved' }` — this triggers sending to content queue (same endpoint handles all status transitions: approve, reject, save_for_later, re-approve)
6. Enforce tier limits before queueing: check effective usage `(cloud_outlines_count * 0.1) + cloud_generations_count` against tier limit
7. Increment `usage.cloud_outlines_count` when outline is created (in the `POST /api/projects/:id/generate` handler)

### Task 6.4: Queue Consumer — Outline Generation

**Files:**
- Create: `packages/web/src/lib/queue/consumers/outline.ts`
- Modify: `packages/web/wrangler.toml` (queue consumer config)

**Steps:**
1. Consumer receives message from `OUTLINE_QUEUE`
2. Load project config from D1
3. Load project memories from D1 (recent topics covered, style notes)
4. Fetch diff from GitHub API (using installation access token)
5. Build outline prompt using `prompts/outline.ts` + project config + diff + memories
6. Call nanoGPT
7. Update outline row in D1: `outline_content = result`, `diff_content = diff`, `status = 'pending_approval'` (diff is cached so the content-queue consumer can access it for blog/changelog prompts without re-fetching from GitHub)
8. Send push notification to user (if subscribed): "Your outline is ready for review"

### Task 6.5: Queue Consumer — Content Generation

**Files:**
- Create: `packages/web/src/lib/queue/consumers/content.ts`

**Steps:**
1. Consumer receives message from `CONTENT_QUEUE`
2. Load approved outline from D1 (includes `diff_content` cached during outline generation)
3. Load project config from D1
4. For each content type in `content_types_json`:
   - Build type-specific prompt using the appropriate prompt builder
   - Call nanoGPT
   - Create `generation` row in D1 with generated content, status `draft`
   - Extract metadata (title, slug, tags, seo_description) from generated content
5. Update outline status to `completed`
6. Auto-create memory entries: "topic_covered" with title + summary
7. Send push notification: "Your content is ready!"
8. Increment `usage.cloud_generations_count` for current period (one per generation row created)

### Task 6.6: Wrangler Queue Bindings

**Files:**
- Modify: `packages/web/wrangler.toml`

**Steps:**
1. Add queue bindings:
   ```toml
   [[queues.producers]]
   binding = "OUTLINE_QUEUE"
   queue = "repolore-outline-queue"

   [[queues.producers]]
   binding = "CONTENT_QUEUE"
   queue = "repolore-content-queue"

   [[queues.consumers]]
   queue = "repolore-outline-queue"
   max_batch_size = 1
   max_retries = 2

   [[queues.consumers]]
   queue = "repolore-content-queue"
   max_batch_size = 1
   max_retries = 2
   ```
2. Queue consumer entry point handled by the custom `worker.ts` entry (see Architecture section and Task 1.4b spike)
3. Commit: `feat: AI content generation pipeline — queues, nanoGPT, outline + content generation`

---

## Phase 7: MCP Server Package

**Goal:** Build the local MCP server as an npm package. It reads git history locally, uses the IDE's AI (BYO) or optionally calls the cloud API, and manages REPOLORE.md.

### Task 7.1: MCP Package Setup

**Files:**
- Create: `packages/mcp/package.json`
- Create: `packages/mcp/tsconfig.json`
- Create: `packages/mcp/src/index.ts`

**Steps:**
1. Package name: `repolore` (published to npm as `repolore`)
2. Dependencies: `@modelcontextprotocol/sdk`, `zod`
3. Binary entry: `bin: { "repolore": "./dist/index.js" }` (for `npx repolore`)
4. MCP server using stdio transport (standard for IDE integration)
5. Entry point creates MCP server, registers tools, starts listening

### Task 7.2: Local Git Operations

**Files:**
- Create: `packages/mcp/src/git/index.ts`

**Steps:**
1. `getRecentCommits(cwd, count)` — shells out to `git log --oneline -n {count}`
2. `getCommitDiff(cwd, sha)` — `git show {sha} --stat --patch`
3. `getDiffSince(cwd, ref)` — `git diff {ref}..HEAD`
4. `getCurrentBranch(cwd)` — `git branch --show-current`
5. `getRecentMergedPRs(cwd)` — parse git log for merge commits
6. `getStagedDiff(cwd)` — `git diff --staged`
7. `getRemoteUrl(cwd)` — `git remote get-url origin`, parsed to `owner/repo` format (used for cloud project auto-resolution)
8. All functions use `child_process.execSync` with `cwd` parameter
9. Diff truncation: if > 30KB, summarize to file list + most changed files

### Task 7.3: REPOLORE.md Management

**Files:**
- Create: `packages/mcp/src/config/index.ts`
- Create: `packages/mcp/src/config/template.ts`

**Steps:**
1. `readRepoloreMd(cwd)` — reads and parses `REPOLORE.md` from repo root (YAML frontmatter + markdown body)
2. `writeRepoloreMd(cwd, config)` — writes/updates `REPOLORE.md`
3. `template.ts` — default REPOLORE.md template:
   ```yaml
   ---
   project:
     name: ""
     description: ""
     url: ""
   voice:
     tone: "casual, technical"
     audience: ""
   seo:
     pillars: []
   blog:
     frontmatter:
       layout: "post"
       author: ""
     format: "md"
     output_dir: "content/blog"
   social:
     twitter_handle: ""
     hashtags: []
   cloud:
     project_id: ""  # Auto-filled on first push/sync via repo remote URL matching
   ---
   # Project Context
   <!-- Add additional context about your project here -->
   ```
4. Parse function extracts config object from YAML frontmatter

### Task 7.3b: MCP Local Storage

**Files:**
- Create: `packages/mcp/src/storage/index.ts`

**Steps:**
1. Local storage directory: `.repolore/` in repo root
2. Structure:
   ```
   .repolore/
   ├── outlines/           ← Generated outlines (JSON files)
   │   ├── 2026-02-14-auth-fix.json
   │   └── 2026-02-15-api-update.json
   ├── generations/        ← Generated content (Markdown/text files)
   │   ├── blog/
   │   │   └── fixing-race-conditions.md
   │   ├── changelog/
   │   │   └── 2026-02-14-auth-fix.md
   │   ├── tweets/
   │   │   └── 2026-02-14-auth-fix.txt
   │   └── linkedin/
   │       └── 2026-02-14-auth-fix.txt
   └── config.json         ← Local MCP state (last sync, API key ref)
   ```
3. `repolore_init` tool should add `.repolore/` to `.gitignore` (generated content should NOT be committed — it goes to the blog repo or is copy-pasted)
4. Functions: `saveOutline(cwd, outline)`, `saveGeneration(cwd, type, content, slug)`, `listOutlines(cwd)`, `listGenerations(cwd)`, `getOutline(cwd, id)`
5. Outline JSON format: `{ id, contentTypes, sourceRef, outline, status, createdAt }`
6. Local storage has no limits (no tier enforcement locally)

### Task 7.4: MCP Tools — Init & Config

**Files:**
- Create: `packages/mcp/src/tools/init.ts`
- Create: `packages/mcp/src/tools/config.ts`
- Create: `packages/mcp/src/tools/status.ts`

**Steps:**
1. **`repolore_init`** tool:
   - Creates `REPOLORE.md` in repo root with template
   - Creates `.repolore/` directory structure
   - Adds `.repolore/` to `.gitignore` if not already present
   - Prompts user (via tool response) to fill in project name, description, tone
   - Returns: "REPOLORE.md created. Edit it to configure your brand voice."

2. **`repolore_config`** tool:
   - Reads and displays current REPOLORE.md config
   - Parameters: optional `set` to update specific fields
   - Returns: current config as formatted text

3. **`repolore_status`** tool:
   - Shows: current project config summary, local storage stats (N outlines, N generations), cloud sync status (if API key configured), cloud storage usage (if connected)
   - Parameters: none
   - Calls cloud API `GET /api/mcp/config/:projectId` if API key is set (to show cloud usage)
   - Returns: formatted status overview

### Task 7.5: MCP Tools — Outline & Generate

**Files:**
- Create: `packages/mcp/src/tools/outline.ts`
- Create: `packages/mcp/src/tools/generate.ts`
- Create: `packages/mcp/src/prompts/index.ts`

**Steps:**
1. **`repolore_outline`** tool:
   - Parameters: `type` (blog, changelog, tweet, linkedin — multi-select), `source` (auto-detect recent commits, or specific SHA/range), `context` (optional user message)
   - Reads: git diff (local), REPOLORE.md config
   - Returns: A structured prompt response that the IDE's AI uses to generate the outline
   - The tool does NOT call AI — it constructs the prompt and returns it as a resource/prompt for the agent to process
   - This is the BYO-AI approach: RepoLore provides the prompt, the user's AI provides the intelligence

2. **`repolore_generate`** tool:
   - Parameters: `type` (single content type), `outline` (the approved outline text)
   - Reads: REPOLORE.md config
   - Returns: A structured prompt for full content generation
   - The IDE's AI generates the content
   - Save destination: blog posts save to `blog.output_dir` from REPOLORE.md config (e.g., `content/blog/fixing-race-conditions.md`). All other types (changelog, tweet, linkedin) save to `.repolore/generations/{type}/`. If `output_dir` is not configured, blog posts also fall back to `.repolore/generations/blog/`.

3. **Prompt construction** (`prompts/index.ts`):
   - Prompts are duplicated between web and MCP packages (not shared via `@repolore/shared`) because they serve different purposes: cloud prompts are sent directly to nanoGPT/BYOK API, MCP prompts are returned as agent instructions for the IDE's AI
   - MCP prompts adapt the same content strategy but formatted as "instructions for the agent" rather than direct system prompts
   - Prompt templates are internal implementation details, not exposed to users as configurable

### Task 7.6: MCP Tools — Cloud Sync (Optional)

**Files:**
- Create: `packages/mcp/src/tools/push.ts`
- Create: `packages/mcp/src/tools/sync.ts`
- Create: `packages/mcp/src/cloud/client.ts`

**Steps:**
1. **`repolore_push`** tool:
   - Parameters: `type` ('outline' | 'blog' | 'changelog' | 'tweet' | 'linkedin'), `content` (the content to push)
   - Calls: `POST /api/mcp/push` on `repolore.com` with user's API key
   - `projectId` is optional in the request body. If omitted, the API matches by the user's git remote URL (parsed from local repo) against `project_repos.repo_full_name` for the authenticated user's projects. If exactly one match, use it. If zero or multiple matches, return 400 with a list of the user's projects so they can set `cloud.project_id` in REPOLORE.md.
   - Response includes `projectId`. If `cloud.project_id` in REPOLORE.md is empty, the MCP client writes the returned `projectId` back to REPOLORE.md (auto-fill on first push).
   - Stores content in cloud D1
   - Returns: confirmation with cloud URL

2. **`repolore_sync`** tool:
   - Pushes current REPOLORE.md content to cloud
   - Calls: `POST /api/mcp/sync-config`
   - Same `projectId` auto-resolution as `repolore_push` (optional in request, resolved by repo remote URL if missing)
   - Requires Hacker tier

3. **Cloud client** (`cloud/client.ts`):
   - Base URL: `https://repolore.com/api/mcp`
   - Auth: API key from env var `REPOLORE_API_KEY` or from REPOLORE.md config
   - Simple fetch wrapper

4. **API key generation**: Added to dashboard settings — user generates an API key, stores it locally as env var

### Task 7.7: MCP Cloud API Endpoints (moved from Phase 9 — needed for MCP push/sync tools)

**Files:**
- Create: `packages/web/src/lib/api/routes/mcp.ts`

**Steps:**
1. `POST /api/mcp/push` — receive content from MCP, store in D1
   - Auth: API key in header (`X-RepoLore-Key`)
   - Body: `{ projectId?, repoFullName?, type, content, sourceRef }` where `type` is `'outline' | 'blog' | 'changelog' | 'tweet' | 'linkedin'` — `'outline'` creates an outline row, all others create generation rows
   - `projectId` is optional. If omitted, resolve by matching `repoFullName` (from git remote) against `project_repos.repo_full_name` for the API key's user. Return 400 if zero or multiple matches (with user's project list for disambiguation).
   - Response always includes `projectId` so MCP client can auto-fill REPOLORE.md.
   - Creates outline or generation row
2. `POST /api/mcp/sync-config` — receive REPOLORE.md content, store in project
   - Same `projectId` auto-resolution as push endpoint
   - Requires Hacker tier
3. `GET /api/mcp/config/:projectId` — return project config (for MCP to fetch cloud config)
4. API key management: `POST /api/settings/api-key` (generate), `DELETE /api/settings/api-key` (revoke)
5. API key management:
   - Generate: create random 32-byte key via `crypto.getRandomValues(new Uint8Array(32))`, hex-encode, prefix with `rl_` (total: `rl_` + 64 hex chars), store SHA-256 hash in `users.api_key_hash`
   - Show key to user ONCE on creation (cannot be retrieved later)
   - Verify on MCP requests: hash incoming key with SHA-256, compare against stored hash
   - Revoke: set `api_key_hash = NULL`

### Task 7.8: MCP Server Registration & Publishing

**Files:**
- Modify: `packages/mcp/src/index.ts`
- Create: `packages/mcp/README.md`

**Steps:**
1. Register all tools in MCP server
2. Add MCP prompts (reusable prompt templates the IDE can invoke)
3. README with installation instructions:
   ```json
   // In Cursor/Claude Code MCP config:
   {
     "mcpServers": {
       "repolore": {
         "command": "npx",
         "args": ["-y", "repolore"]
       }
     }
   }
   ```
4. Publish to npm: `npm publish` from `packages/mcp`
5. Submit to Anthropic's MCP directory, Cursor's MCP registry
6. Commit: `feat: MCP server — local git analysis, outline/generate tools, cloud sync`

---

## Phase 8: Billing Integration (Polar.sh)

**Goal:** Integrate Polar.sh for Hacker tier subscriptions. Same pattern as gdprmetrics.

### Task 8.1: Polar.sh Webhook Handler

**Files:**
- Create: `packages/web/src/lib/api/routes/billing.ts`
- Create: `packages/web/src/lib/billing/polar.ts`

**Steps:**
1. `POST /api/billing/webhook` — receives Polar.sh webhook events
2. Verify webhook signature using `POLAR_WEBHOOK_SECRET`
3. Handle events:
   - `subscription.created` → create `subscriptions` row, update user tier
   - `subscription.updated` → update subscription status/period
   - `subscription.canceled` → mark canceled, user keeps access until period end
   - `subscription.revoked` → immediate downgrade to free
4. Map Polar product IDs to plans using `POLAR_HACKER_PRODUCT_ID` secret

### Task 8.2: Billing UI & Checkout

**Files:**
- Modify: `packages/web/src/pages/dashboard/settings.astro`
- Create: `packages/web/src/lib/api/routes/checkout.ts`

**Steps:**
1. `GET /api/checkout/hacker` — generates Polar.sh checkout URL with user's email pre-filled, redirects
2. Settings page "Subscription" section:
   - Current plan display
   - Usage stats (items used / limit)
   - Upgrade button (free → hacker) → redirects to Polar checkout
   - Manage button (hacker) → redirects to Polar customer portal
3. Polar customer portal URL generated via Polar API using `POLAR_ACCESS_TOKEN`

### Task 8.3: Tier Enforcement

**Files:**
- Create: `packages/web/src/lib/billing/limits.ts`
- Modify: various API routes

**Steps:**
1. `getUserTier(userId)` — reads subscription status from D1, returns `'free' | 'hacker'`
2. `checkLimit(userId, limitType)` — checks current usage against tier limits. Effective usage = `(cloud_outlines_count * 0.1) + cloud_generations_count`
3. `getUserAIConfig(userId, env)` — returns BYOK config or nanoGPT config (Hacker only). Free users without BYOK configured cannot generate.
4. Enforce in API routes:
   - `POST /api/projects/:id/repos` → check repo count limit
   - `POST /api/projects/:id/generate` → check effective cloud items limit + verify AI config available (BYOK or Hacker tier)
   - `PATCH /api/projects/:id` → check brand voice character limit
   - `POST /api/mcp/sync-config` → require hacker tier
   - `POST /api/mcp/push` → check effective cloud items limit (increment outlines or generations count accordingly)
5. Return `402 Payment Required` with upgrade URL when limit hit
6. Return `400 Bad Request` with "Configure your AI provider in Settings" when free user has no BYOK and tries to generate
7. Commit: `feat: Polar.sh billing — webhook, checkout, tier enforcement`

---

## Phase 9: Push Notifications & Polish

**Goal:** Web Push notifications for generation completion, final UI polish, SEO meta, and launch readiness.

### Task 9.1: Web Push Notifications

**Files:**
- Create: `packages/web/src/lib/push/index.ts`
- Create: `packages/web/src/lib/api/routes/push.ts`
- Create: `packages/web/src/components/dashboard/PushOptIn.tsx` (React island)
- Create: `packages/web/public/sw.js` (service worker for push)

**Steps:**
1. Generate VAPID keys: use `openssl` or a local Node.js script (one-time). Store `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` as Wrangler secrets.
2. **⚠️ Note:** The `web-push` npm library does NOT work in Cloudflare Workers (requires Node.js crypto). Implement Web Push protocol manually using Web Crypto API — sign the JWT with ES256 (P-256), construct the `Authorization: vapid` header, and encrypt the payload with AES-128-GCM per RFC 8291. Alternatively, use a lightweight library compatible with Workers (e.g., `web-push-api` or inline implementation). If this proves too complex, defer push notifications to post-MVP and use polling/toast on dashboard instead.
3. Service worker (`sw.js`): listens for push events, shows notification with title and body
4. `POST /api/push/subscribe` — stores push subscription in D1
5. `DELETE /api/push/unsubscribe` — removes subscription
6. `sendPushNotification(userId, title, body, url)` — sends push to all user's subscriptions
7. Opt-in component: "Enable notifications for content updates" toggle in dashboard settings
8. Trigger notifications from queue consumers on outline ready + content ready

### Task 9.2: SEO & Meta

**Files:**
- Create: `packages/web/src/components/SEO.astro`

**Steps:**
1. SEO component: `<SEO title description image url />` — renders all meta tags
2. OpenGraph tags (title, description, image, type) for all public pages
3. Twitter card tags (summary_large_image)
4. OG image: static image for now (design with green/gold brand colors)
5. `robots.txt` and `sitemap.xml` (Astro built-in sitemap integration)
6. Canonical URLs on all pages

### ~~Task 9.3: MCP Cloud API Endpoints~~ → Moved to Task 7.7

### ~~Task 9.4: CSRF Protection~~ → Moved to Task 2.1b

### Task 9.5: Error Handling & Edge Cases

**Files:**
- Create: `packages/web/src/pages/404.astro`
- Create: `packages/web/src/pages/500.astro`

**Steps:**
1. **404 page:** Brand-styled "Page not found" with link to home. Use Neon Velocity design. Fun copy: "This page got lost in the git history."
2. **500 page:** Brand-styled "Something went wrong" with link to home and contact.
3. API error responses: consistent JSON format `{ error: string, code: string }`
4. Rate limiting on public/unauthenticated API routes: D1-based counter (same pattern as repatch project — track by IP hash with time window). Authenticated routes are rate-limited implicitly by tier usage limits.
5. Queue dead letter handling: after max retries, update outline/generation status to `failed`
6. GitHub installation access tokens: cache token + expiry in `github_installations` table (add `access_token TEXT` and `token_expires_at TEXT` columns). Before each GitHub API call, check if cached token is still valid (with 5-minute buffer). If expired, request new token via App JWT and update the cached values. This avoids redundant GitHub API calls for token generation.
7. Session cleanup: scheduled cron (optional) to delete expired sessions. Note: requires adding a `scheduled` export to the custom `worker.ts` entry (same pattern as the `queue` export)

### Task 9.6: Legal Pages

**Files:**
- Create: `packages/web/src/pages/privacy.astro`
- Create: `packages/web/src/pages/terms.astro`

**Steps:**
1. **Privacy Policy (`/privacy`):**
   - What data we collect: email, name, avatar (from OAuth), GitHub repo metadata, generated content
   - What data we store temporarily: diffs are cached in the outlines table during the generation pipeline (needed for content generation). They are associated with the outline, not stored independently.
   - What data we DON'T store: full source code. Only diffs relevant to specific outlines are cached.
   - Third-party services: GitHub (OAuth + App), Google (OAuth), Polar.sh (billing), nanoGPT (AI generation — diffs are sent to their API for processing)
   - Data retention: content stored until user deletes, account deletion removes all data
   - Cookies: session cookie only (HTTP-only, secure, no tracking)
   - No analytics tracking (or specify if added later)
   - GDPR: right to access, delete, export data
   - Contact: your email for privacy inquiries
2. **Terms of Service (`/terms`):**
   - Service description
   - User responsibilities (don't use for illegal content, don't abuse API)
   - Content ownership: user owns all generated content, RepoLore claims no rights
   - AI disclaimer: generated content may contain inaccuracies, user is responsible for reviewing
   - BYO-AI disclaimer: when using local AI models, output quality depends on the user's model — RepoLore is not responsible for quality of BYO-AI output
   - Service availability: best-effort, no SLA
   - Billing terms: refer to Polar.sh terms for subscription management
   - Termination: either party can terminate, data deleted on account deletion
3. Both pages use `PublicLayout.astro`, plain markdown content, no interactive components
4. Link from Footer (already set up in Phase 3)

### Task 9.7: Documentation Page

**Files:**
- Create: `packages/web/src/pages/docs.astro`

**Steps:**
1. Single-page docs covering:
   - **Getting Started:** Create account → create project → connect repo → generate content
   - **MCP Installation:** How to install in Cursor, Claude Code, Windsurf (with JSON config snippets)
   - **REPOLORE.md:** Full spec, all fields explained, example configurations
   - **Content Types:** What each type generates, example output for blog/changelog/tweet/linkedin
   - **Cloud Sync:** How to push content from MCP to cloud, API key setup
   - **Pricing & Limits:** What's included in each tier
   - **FAQ:** Common questions
2. Use anchor links for navigation (table of contents at top)
3. Code blocks with copy buttons for config snippets
4. Design: content-focused, monospace for config examples, gold accent for important callouts

### Task 9.8: Final Polish

**Steps:**
1. Loading states for all async operations (skeleton loaders, not spinners)
2. Empty states for all list views (projects, outlines, generations)
3. Toast notifications for actions (copy, save, delete, push)
4. Responsive design verification (mobile dashboard should be usable)
5. Accessibility basics (focus styles, aria labels, semantic HTML)
6. Commit: `feat: error pages, legal pages, docs, polish`

---

## System Prompts Reference

These are the system prompts used by both the cloud (nanoGPT) and MCP (BYO-AI) for content generation. They should be detailed and structured enough that even a weaker model produces usable output.

### Outline Generation Prompt

```typescript
// packages/web/src/lib/ai/prompts/outline.ts
// Also mirrored in packages/mcp/src/prompts/outline.ts

export function buildOutlinePrompt(params: {
  projectName: string;
  projectDescription: string;
  tone: string;
  audience: string;
  seoPillars: string[];
  contentTypes: string[];
  diff: string;
  userContext?: string;
  recentTopics?: string[]; // from memories, to avoid repetition
}): { system: string; user: string } {
  return {
    system: `You are RepoLore, an expert technical content strategist for software developers.

Your job is to analyze code changes (diffs) and propose content outlines that are:
1. Genuinely useful to developers (not AI slop)
2. SEO-optimized around the project's pillars
3. Based on REAL code changes with specific technical details
4. Written in the project's brand voice

PROJECT CONTEXT:
- Name: ${params.projectName}
- Description: ${params.projectDescription}
- Tone: ${params.tone}
- Target Audience: ${params.audience}
- SEO Pillars: ${params.seoPillars.join(', ')}

CONTENT TYPES REQUESTED: ${params.contentTypes.join(', ')}

${params.recentTopics?.length ? `RECENTLY COVERED TOPICS (avoid repetition):\n${params.recentTopics.map(t => `- ${t}`).join('\n')}` : ''}

RULES:
- Extract SPECIFIC technical details from the diff: function names, error messages, before/after comparisons
- Every outline must reference concrete code changes, not generic advice
- For blog posts: propose H2 sections, a compelling hook, and a target keyword
- For tweets: propose a punchy hook under 200 chars + a thread structure if relevant
- For LinkedIn: propose a professional narrative angle with a personal takeaway
- For changelogs: extract features/fixes/breaking changes in structured format
- Do NOT generate the full content — only the outline/proposal
- Respond with a structured outline for EACH requested content type`,

    user: `Here is the code diff to analyze:

\`\`\`diff
${params.diff}
\`\`\`

${params.userContext ? `ADDITIONAL CONTEXT FROM THE DEVELOPER:\n"${params.userContext}"\n` : ''}

Generate a content outline for each requested type: ${params.contentTypes.join(', ')}.

For each outline, provide:
1. **Proposed Title** (compelling, SEO-aware)
2. **Target Keyword** (from SEO pillars if relevant)
3. **Hook** (first sentence that grabs attention)
4. **Structure** (sections for blog, bullet points for social)
5. **Key Technical Details to Include** (specific from the diff)
6. **Estimated Length** (word count for blog, character count for social)`
  };
}
```

### Blog Post Generation Prompt

```typescript
// packages/web/src/lib/ai/prompts/blog.ts

export function buildBlogPrompt(params: {
  projectName: string;
  tone: string;
  audience: string;
  seoPillars: string[];
  outline: string;
  diff: string;
  frontmatterTemplate: Record<string, string>;
  format: 'md' | 'mdx' | 'html';
}): { system: string; user: string } {
  return {
    system: `You are RepoLore, an expert technical blog writer for indie developers.

You write blog posts that:
1. Are genuinely helpful and technically accurate
2. Include real code examples from the actual changes
3. Tell a story — why this change was made, what problem it solves, what was tried first
4. Are SEO-optimized with natural keyword usage (not stuffed)
5. Sound like a developer writing for developers, not a marketing team

WRITING STYLE:
- Tone: ${params.tone}
- Audience: ${params.audience}
- Use short paragraphs (2-3 sentences max)
- Include code blocks with actual code from the diff
- Use H2 and H3 headers for structure (critical for SEO)
- Include a TL;DR at the top for scanners
- End with a clear takeaway or call to action
- Target 800-1500 words (quality over length)

SEO GUIDELINES:
- Target keyword should appear in: title, first paragraph, one H2, meta description
- SEO Pillars for context: ${params.seoPillars.join(', ')}
- Include internal context that generic AI tools wouldn't know (specific error messages, function names, architectural decisions)

OUTPUT FORMAT:
Return the blog post as a complete ${params.format} file with frontmatter:
\`\`\`
---
${Object.entries(params.frontmatterTemplate).map(([k, v]) => `${k}: "${v}"`).join('\n')}
title: "[Generated Title]"
description: "[SEO meta description, 150-160 chars]"
date: "${new Date().toISOString().split('T')[0]}"
tags: [relevant, tags, here]
---

[Blog post content here]
\`\`\``,

    user: `APPROVED OUTLINE:
${params.outline}

FULL DIFF FOR REFERENCE:
\`\`\`diff
${params.diff}
\`\`\`

Write the complete blog post based on the approved outline. Include real code examples from the diff. Make it genuinely useful and technically accurate.`
  };
}
```

### Tweet/X Post Prompt

```typescript
// packages/web/src/lib/ai/prompts/tweet.ts

export function buildTweetPrompt(params: {
  projectName: string;
  tone: string;
  outline: string;
  twitterHandle?: string;
  hashtags?: string[];
}): { system: string; user: string } {
  return {
    system: `You are RepoLore, writing X/Twitter posts for indie developers sharing what they've shipped.

RULES:
- Main tweet: max 280 characters, punchy hook
- If the topic warrants it, suggest a 3-5 tweet thread
- Sound like a developer sharing genuine progress, NOT a marketing bot
- Use specific details ("fixed a race condition in the auth flow" > "made improvements")
- Include one relevant emoji max (don't overdo it)
- Tone: ${params.tone}
${params.twitterHandle ? `- Include ${params.twitterHandle} mention where natural` : ''}
${params.hashtags?.length ? `- Suggested hashtags (use 1-2 max): ${params.hashtags.join(', ')}` : ''}

OUTPUT FORMAT:
**Main Tweet:**
[tweet text]

**Thread (if applicable):**
1/ [first tweet]
2/ [second tweet]
...`,

    user: `OUTLINE:\n${params.outline}\n\nWrite the X/Twitter post(s).`
  };
}
```

### LinkedIn Post Prompt

```typescript
// packages/web/src/lib/ai/prompts/linkedin.ts

export function buildLinkedInPrompt(params: {
  projectName: string;
  tone: string;
  audience: string;
  outline: string;
}): { system: string; user: string } {
  return {
    system: `You are RepoLore, writing LinkedIn posts for developers sharing technical achievements.

RULES:
- Optimal length: 1000-1300 characters (LinkedIn sweet spot for engagement)
- Start with a hook line that stands alone (LinkedIn truncates after ~210 chars)
- Use line breaks between paragraphs (LinkedIn formatting)
- Include a personal/professional takeaway
- End with a soft CTA (question, or invite to check it out)
- Sound professional but human — NOT corporate jargon
- Tone: ${params.tone}
- No hashtag spam (3 max, at the end)

STRUCTURE:
1. Hook (standalone first line, curiosity-driven)
2. Context (what you were working on, 2-3 lines)
3. The technical detail (what you shipped, specific)
4. The takeaway (what you learned or why it matters)
5. CTA (question or link)

OUTPUT FORMAT:
[Complete LinkedIn post text, ready to paste]`,

    user: `OUTLINE:\n${params.outline}\n\nWrite the LinkedIn post.`
  };
}
```

### Changelog Entry Prompt

```typescript
// packages/web/src/lib/ai/prompts/changelog.ts

export function buildChangelogPrompt(params: {
  projectName: string;
  outline: string;
  diff: string;
}): { system: string; user: string } {
  return {
    system: `You are RepoLore, writing changelog entries for developer tools.

FORMAT (Keep Changelog convention):
## [Version or Date]

### Added
- New feature descriptions

### Changed
- Change descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions

RULES:
- Use imperative mood ("Add support for..." not "Added support for...")
- Be specific: include function names, API endpoints, config options
- Each entry is one line, concise but descriptive
- Group by category (Added/Changed/Fixed/Removed)
- Reference PR/commit if available`,

    user: `OUTLINE:\n${params.outline}\n\nDIFF:\n\`\`\`diff\n${params.diff}\n\`\`\`\n\nWrite the changelog entry.`
  };
}
```

---

## REPOLORE.md Specification

The `REPOLORE.md` file lives in the repository root and serves as the local configuration for RepoLore. It's the single source of truth for project context when using the MCP server.

### Full Template

```yaml
---
# RepoLore Configuration
# Docs: https://repolore.com/docs/config

project:
  name: "My Project"
  description: "A brief description of what this project does and who it's for"
  url: "https://myproject.dev"

voice:
  tone: "casual, technical, witty"  # How your content should sound
  audience: "indie developers, Next.js developers"  # Who reads your content
  guidelines: |
    - Use first person ("I" not "we") unless it's a team project
    - Reference specific technical details, not generic advice
    - Keep paragraphs short, use code examples liberally
    - Be honest about trade-offs and limitations

seo:
  pillars:  # 3-5 core topics your content should focus on
    - "nextjs authentication"
    - "open source security"
    - "developer experience"

blog:
  frontmatter:  # Custom frontmatter fields added to every blog post
    layout: "post"
    author: "Your Name"
  format: "md"  # md | mdx | html
  output_dir: "content/blog"  # Where blog posts are saved (relative to repo root)

social:
  twitter_handle: "@yourproject"
  hashtags:
    - "nextjs"
    - "opensource"
    - "buildinpublic"

cloud:
  project_id: ""  # Your cloud project ID (auto-filled on first push/sync via repo remote URL matching)
  # API key: set via REPOLORE_API_KEY environment variable (never store in this file)
---

# Project Context

Add any additional context about your project here. This section is included
in every AI prompt to give the model deeper understanding of your project.

## What makes this project unique

<!-- Describe your project's differentiators -->

## Technical architecture

<!-- Brief overview of your tech stack and architecture -->

## Content history

<!-- This section is auto-updated by RepoLore after each generation -->
<!-- It helps the AI avoid repeating topics and maintain consistency -->
```

### Parsing Rules
1. YAML frontmatter between `---` delimiters is parsed as config
2. Markdown body after second `---` is included as raw context in prompts
3. Missing fields use defaults (defined in `packages/mcp/src/config/template.ts`)
4. API key is read from `REPOLORE_API_KEY` environment variable, NOT from REPOLORE.md (to prevent accidental commits of secrets). The MCP cloud client checks `process.env.REPOLORE_API_KEY` first, then falls back to `.repolore/config.json` (local, gitignored).

---

## API Reference

### Public API Routes (no auth required)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/health` | Health check |

### Auth Routes

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/auth/google` | Initiate Google OAuth |
| `GET` | `/api/auth/google/callback` | Google OAuth callback |
| `GET` | `/api/auth/github` | Initiate GitHub OAuth |
| `GET` | `/api/auth/github/callback` | GitHub OAuth callback |
| `GET` | `/api/auth/me` | Get current user |
| `POST` | `/api/auth/logout` | Logout |
| `DELETE` | `/api/auth/account` | Delete account (cascades all data) |

### GitHub App Routes

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/github/webhook` | GitHub App webhook receiver |
| `GET` | `/api/github/setup` | Post-installation redirect |
| `GET` | `/api/github/installations/:id/repos` | List repos for installation |

### Project Routes (auth required)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/projects` | List user's projects |
| `POST` | `/api/projects` | Create project |
| `GET` | `/api/projects/:id` | Get project detail |
| `PATCH` | `/api/projects/:id` | Update project |
| `DELETE` | `/api/projects/:id` | Delete project |
| `POST` | `/api/projects/:id/repos` | Link repo to project |
| `DELETE` | `/api/projects/:id/repos/:repoId` | Unlink repo |

### Content Routes (auth required)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/projects/:id/generate` | Start outline generation |
| `GET` | `/api/projects/:id/outlines` | List outlines |
| `PATCH` | `/api/outlines/:id` | Update outline status |
| `GET` | `/api/projects/:id/generations` | List generations |
| `GET` | `/api/generations/:id` | Get generation detail |
| `PATCH` | `/api/generations/:id` | Update generation status |

### MCP Cloud Routes (API key auth)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/mcp/push` | Push content from MCP to cloud |
| `POST` | `/api/mcp/sync-config` | Sync REPOLORE.md to cloud |
| `GET` | `/api/mcp/config/:projectId` | Get project config |

### Billing Routes

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/billing/webhook` | Polar.sh webhook |
| `GET` | `/api/checkout/hacker` | Redirect to Polar checkout |

### Settings Routes (auth required)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/settings/api-key` | Generate API key |
| `DELETE` | `/api/settings/api-key` | Revoke API key |
| `PATCH` | `/api/settings/ai-config` | Update BYOK AI provider config |
| `POST` | `/api/settings/test-ai` | Test BYOK AI provider connection |
| `DELETE` | `/api/settings/ai-config` | Remove BYOK AI provider config |

### Push Notification Routes (auth required)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/push/subscribe` | Register push subscription |
| `DELETE` | `/api/push/unsubscribe` | Remove push subscription |

---

## Implementation Order Summary

| Phase | Focus | Estimated Effort |
|-------|-------|-----------------|
| **Phase 1** | Scaffold, Astro, Hono, D1, queue spike, deploy | 1-2 sessions |
| **Phase 2** | Google + GitHub OAuth, sessions, CSRF groundwork | 1 session |
| **Phase 3** | Landing page, pricing, why-us, contact | 1-2 sessions |
| **Phase 4** | Dashboard: overview, onboarding, projects, content browser + editor, generation UI | 3-4 sessions |
| **Phase 5** | GitHub App, repo connection, diff fetching | 1-2 sessions |
| **Phase 6** | AI pipeline: queues, nanoGPT, prompts | 2-3 sessions |
| **Phase 7** | MCP server package (with local storage + status) | 2-3 sessions |
| **Phase 8** | Polar.sh billing | 1 session |
| **Phase 9** | Push notifications, SEO, legal, docs, error pages, polish | 2-3 sessions |

**Total: ~14-21 coding sessions (weekend project pace: 4-6 weekends)**

---

## Notes for the Coding Agent

1. **Always check `packages/web/wrangler.toml`** before adding bindings — all CF bindings go there.
2. **D1 queries are raw SQL** — no ORM. Use parameterized queries. Follow the same pattern as gdprmetrics.
3. **No KV.** Sessions are in D1. All state is in D1.
4. **Hono routes** should be thin controllers — business logic lives in `lib/` modules.
5. **React islands** are used sparingly — only for interactive dashboard components. Public pages are pure Astro.
6. **Test deployment** after each phase — `wrangler deploy` from `packages/web`.
7. **Secrets** are never committed. Use `wrangler secret put` for production, `.dev.vars` for local.
8. **The design system** (Section 3) should be applied consistently from Phase 3 onward. Every page uses the same color palette, fonts, and component patterns.
9. **shadcn/ui components** should be installed as needed per phase, not all upfront. Use `components.json` with the Astro + React setup.
10. **Queue consumers** use the custom `worker.ts` entry file (see Architecture section). Astro's CF adapter does NOT support queue handlers natively. The spike in Task 1.4b MUST be completed before Phase 6.
11. **CSRF** is implemented in Phase 2 (Task 2.1b), not Phase 9. Use `SameSite=Lax` cookies + Origin header check on mutating API routes. No CSRF tokens needed. Webhooks are exempt (signature-verified).
12. **API keys** for MCP cloud auth use SHA-256 hashing. Never store plaintext keys. Show to user once on creation.
13. **Content editing** is available on all tiers. Users must be able to fix AI output regardless of plan.
14. **Tailwind v4** uses CSS-first config via `@theme` in `global.css`. Do NOT use `tailwind.config.mjs` or `@astrojs/tailwind`. Use `@tailwindcss/vite` plugin instead.
15. **Diff caching:** The outline queue consumer stores the diff in `outlines.diff_content` so the content queue consumer can access it without re-fetching from GitHub.
16. **MCP cloud endpoints** are implemented in Phase 7 (Task 7.7), not Phase 9, because the MCP server tools need them.
17. **GitHub App installation race:** The webhook stores installation with `user_id = NULL`. The setup redirect links it to the user. Handle both orderings.
18. **BYOK (Bring Your Own Key):** Free tier users must configure their own OpenAI-compatible AI provider (endpoint + model + key) in Settings to use dashboard generation. Hacker tier users get nanoGPT by default but can override with BYOK. The AI client (`packages/web/src/lib/ai/client.ts`) is generic OpenAI-compatible, not nanoGPT-specific.
19. **Usage counting:** Outlines count as 0.1 effective items, generations count as 1.0. Track `cloud_outlines_count` and `cloud_generations_count` separately in the `usage` table. Effective usage = `(outlines * 0.1) + generations`.
20. **Session refresh:** Only update `expires_at` if less than 15 days remain on the 30-day session. This avoids a D1 write on every authenticated request.
21. **GitHub installation tokens:** Cached in `github_installations` table with expiry. Check before each API call, refresh if expired (5-minute buffer).
22. **MCP cloud `projectId` auto-resolution:** `POST /api/mcp/push` and `POST /api/mcp/sync-config` accept optional `projectId`. If omitted, resolve by matching `repoFullName` (from MCP's `getRemoteUrl()`) against `project_repos.repo_full_name` for the API key's user. Response always includes `projectId` so MCP auto-fills `cloud.project_id` in REPOLORE.md on first interaction.
23. **Display font is Space Grotesk** (not Plus Jakarta Sans). Chosen for its monospace-derived DNA (variant of Space Mono) which matches the "Neon Velocity" terminal aesthetic. Pairs naturally with Geist Mono. Variable font, self-hosted in `public/fonts/`.
