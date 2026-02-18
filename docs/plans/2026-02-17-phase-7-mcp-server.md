# Phase 7: MCP Server Package Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the local MCP server as an npm package. It reads git history locally, uses the IDE's AI (BYO) or optionally calls the cloud API, and manages REPOLORE.md.

**Architecture:** The MCP server is a standalone npm package (`repolore`) that runs as a stdio transport server, integrating with IDEs like Cursor, Claude Code, and Windsurf. It provides tools for initializing projects, generating outlines/content using local AI, and optionally syncing with the cloud API.

**Tech Stack:** TypeScript, @modelcontextprotocol/sdk, zod, simple-git (or child_process for git commands), yaml (for REPOLORE.md parsing)

---

## Task 7.1: MCP Package Setup

**Files:**
- Create: `packages/mcp/package.json`
- Create: `packages/mcp/tsconfig.json`
- Create: `packages/mcp/src/index.ts`

**Step 1: Create MCP package.json**

```json
{
  "name": "repolore",
  "version": "0.1.0",
  "description": "MCP server for RepoLore - transforms code changes into content",
  "type": "module",
  "main": "./dist/index.js",
  "bin": {
    "repolore": "./dist/index.js"
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "zod": "^3.24.1",
    "yaml": "^2.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "typescript": "^5.7.2"
  },
  "engines": {
    "node": ">=20"
  },
  "keywords": ["mcp", "model-context-protocol", "github", "content-generation"],
  "homepage": "https://repolore.com",
  "repository": {
    "type": "git",
    "url": "https://github.com/repolore/repolore"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

**Step 2: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Step 3: Create basic MCP server entry point**

```typescript
// packages/mcp/src/index.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

class RepoloreServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: 'repolore',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      return {
        content: [
          {
            type: 'text',
            text: 'Tool not implemented yet',
          },
        ],
      };
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new RepoloreServer();
server.run().catch(console.error);
```

**Step 4: Build and verify**

Run: `cd packages/mcp && pnpm install && pnpm build`
Expected: Build succeeds, dist/index.js created

**Step 5: Test basic run**

Run: `node packages/mcp/dist/index.js` (should not error on startup)
Expected: Server initializes without errors (stdio transport requires IDE connection)

---

## Task 7.2: Local Git Operations

**Files:**
- Create: `packages/mcp/src/git/index.ts`

**Step 1: Write failing test**

```typescript
// packages/mcp/src/git/index.test.ts
import { describe, it, expect } from 'vitest';
import { getRecentCommits, getCommitDiff, getCurrentBranch, getRemoteUrl } from './index.js';
import * as path from 'path';
import * as fs from 'fs';

const testRepoPath = path.join(process.cwd(), 'packages/mcp/test-repo');

describe('git operations', () => {
  beforeAll(() => {
    // Create a test repo with some commits
    const { execSync } = require('child_process');
    fs.mkdirSync(testRepoPath, { recursive: true });
    execSync('git init', { cwd: testRepoPath });
    execSync('git config user.email "test@test.com"', { cwd: testRepoPath });
    execSync('git config user.name "Test"', { cwd: testRepoPath });
    fs.writeFileSync(path.join(testRepoPath, 'test.txt'), 'hello');
    execSync('git add .', { cwd: testRepoPath });
    execSync('git commit -m "Initial commit"', { cwd: testRepoPath });
  });

  it('should get recent commits', async () => {
    const commits = await getRecentCommits(testRepoPath, 5);
    expect(commits).toBeDefined();
    expect(Array.isArray(commits)).toBe(true);
  });

  it('should get current branch', async () => {
    const branch = await getCurrentBranch(testRepoPath);
    expect(branch).toBe('main');
  });

  it('should get remote URL', async () => {
    const { execSync } = require('child_process');
    execSync('git remote add origin https://github.com/test/repo.git', { cwd: testRepoPath });
    const url = await getRemoteUrl(testRepoPath);
    expect(url).toBe('test/repo');
  });
});
```

**Step 2: Run test to verify it fails**

Run: `cd packages/mcp && pnpm vitest run src/git/index.test.ts`
Expected: FAIL - functions not defined

**Step 3: Write implementation**

```typescript
// packages/mcp/src/git/index.ts
import { execSync } from 'child_process';
import * as fs from 'fs';

export interface Commit {
  sha: string;
  message: string;
  date: string;
  author: string;
}

export interface DiffResult {
  sha: string;
  diff: string;
  stats: {
    filesChanged: number;
    insertions: number;
    deletions: number;
  };
}

function execGit(cwd: string, command: string): string {
  try {
    return execSync(command, { cwd, encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });
  } catch (error) {
    throw new Error(`Git command failed: ${command}\n${error}`);
  }
}

export function getRecentCommits(cwd: string, count: number = 10): Commit[] {
  const output = execGit(cwd, `git log --oneline -n ${count} --format="%H|%s|%ad|%an"`);

  if (!output.trim()) return [];

  return output.trim().split('\n').map(line => {
    const [sha, message, date, author] = line.split('|');
    return { sha: sha.trim(), message: message.trim(), date: date.trim(), author: author.trim() };
  });
}

export function getCommitDiff(cwd: string, sha: string): DiffResult {
  const diff = execGit(cwd, `git show ${sha} --stat --patch`);
  const statLine = execGit(cwd, `git show ${sha} --stat --oneline`).trim().split('\n').pop() || '';

  const filesMatch = statLine.match(/(\d+)\s+file/);
  const insMatch = statLine.match(/(\d+)\s+insertion/);
  const delMatch = statLine.match(/(\d+)\s+deletion/);

  return {
    sha,
    diff,
    stats: {
      filesChanged: filesMatch ? parseInt(filesMatch[1]) : 0,
      insertions: insMatch ? parseInt(insMatch[1]) : 0,
      deletions: delMatch ? parseInt(delMatch[1]) : 0,
    },
  };
}

export function getDiffSince(cwd: string, ref: string): string {
  return execGit(cwd, `git diff ${ref}..HEAD`);
}

export function getCurrentBranch(cwd: string): string {
  return execGit(cwd, 'git branch --show-current').trim();
}

export function getRecentMergedPRs(cwd: string, count: number = 10): Commit[] {
  // Parse merge commits that follow conventional commit format
  const output = execGit(cwd, `git log --merges --oneline -n ${count} --format="%H|%s|%ad|%an"`);

  if (!output.trim()) return [];

  return output.trim().split('\n').map(line => {
    const [sha, message, date, author] = line.split('|');
    return { sha: sha.trim(), message: message.trim(), date: date.trim(), author: author.trim() };
  });
}

export function getStagedDiff(cwd: string): string {
  return execGit(cwd, 'git diff --staged');
}

export function getRemoteUrl(cwd: string): string | null {
  try {
    const url = execGit(cwd, 'git remote get-url origin').trim();
    // Convert https://github.com/owner/repo.git or git@github.com:owner/repo.git to owner/repo
    let match = url.match(/github\.com[/:]([^/]+)\/([^/.]+)(\.git)?$/);
    if (match) {
      return `${match[1]}/${match[2]}`;
    }
    return null;
  } catch {
    return null;
  }
}

export function truncateDiff(diff: string, maxSize: number = 30000): string {
  if (diff.length <= maxSize) return diff;

  // If too large, summarize to file list and most changed files
  const lines = diff.split('\n');
  const fileStats: string[] = [];
  let currentFile = '';
  let inPatch = false;

  for (const line of lines) {
    if (line.startsWith('diff ') || line.startsWith('--- ') || line.startsWith('+++ ')) {
      if (!inPatch) {
        currentFile = line;
        inPatch = true;
      }
    }
    if (line.startsWith('@@')) {
      fileStats.push(currentFile);
      inPatch = false;
    }
  }

  return `[Diff truncated - ${diff.length} chars]\n\nChanged files:\n${fileStats.slice(0, 20).join('\n')}`;
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/mcp && pnpm vitest run src/git/index.test.ts`
Expected: PASS

**Step 5: Commit**

Run: `git add packages/mcp/src/git/ && git commit -m "feat(mcp): add local git operations"`
Expected: Commit created

---

## Task 7.3: REPOLORE.md Management

**Files:**
- Create: `packages/mcp/src/config/index.ts`
- Create: `packages/mcp/src/config/template.ts`

**Step 1: Write failing test**

```typescript
// packages/mcp/src/config/index.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { readRepoloreMd, writeRepoloreMd, parseRepoloreMd } from './index.js';

const testDir = path.join(process.cwd(), 'packages/mcp/test-config');

describe('REPOLORE.md management', () => {
  beforeEach(() => {
    fs.mkdirSync(testDir, { recursive: true });
  });

  it('should read existing REPOLORE.md', async () => {
    const content = `---
project:
  name: "Test Project"
voice:
  tone: "casual"
---
# Context`;
    fs.writeFileSync(path.join(testDir, 'REPOLORE.md'), content);

    const result = await readRepoloreMd(testDir);
    expect(result.config.project.name).toBe('Test Project');
  });

  it('should create REPOLORE.md if not exists', async () => {
    await writeRepoloreMd(testDir, { project: { name: 'New Project' } });

    const exists = fs.existsSync(path.join(testDir, 'REPOLORE.md'));
    expect(exists).toBe(true);
  });

  it('should parse frontmatter correctly', () => {
    const content = `---
project:
  name: "Test"
  description: "A test project"
voice:
  tone: "technical"
  audience: "developers"
seo:
  pillars:
    - "testing"
    - "mcp"
---
# Additional context`;

    const result = parseRepoloreMd(content);
    expect(result.config.project.name).toBe('Test');
    expect(result.config.voice.tone).toBe('technical');
    expect(result.context).toBe('# Additional context');
  });
});
```

**Step 2: Run test to verify it fails**

Run: `cd packages/mcp && pnpm vitest run src/config/index.test.ts`
Expected: FAIL - functions not defined

**Step 3: Write template.ts**

```typescript
// packages/mcp/src/config/template.ts
export const DEFAULT_REPOLORE_MD = `---
# RepoLore Configuration
# Docs: https://repolore.com/docs/config

project:
  name: ""
  description: ""
  url: ""

voice:
  tone: "casual, technical"
  audience: ""
  guidelines: |
    - Use first person ("I" not "we") unless it's a team project
    - Reference specific technical details, not generic advice
    - Keep paragraphs short, use code examples liberally

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
  project_id: ""
---

# Project Context

<!-- Add additional context about your project here -->
`;

export const DEFAULT_CONFIG = {
  project: {
    name: '',
    description: '',
    url: '',
  },
  voice: {
    tone: 'casual, technical',
    audience: '',
    guidelines: '',
  },
  seo: {
    pillars: [],
  },
  blog: {
    frontmatter: {
      layout: 'post',
      author: '',
    },
    format: 'md',
    output_dir: 'content/blog',
  },
  social: {
    twitter_handle: '',
    hashtags: [],
  },
  cloud: {
    project_id: '',
  },
};
```

**Step 4: Write implementation**

```typescript
// packages/mcp/src/config/index.ts
import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'yaml';
import { DEFAULT_REPOLORE_MD, DEFAULT_CONFIG } from './template.js';

export interface RepoloreConfig {
  project: {
    name: string;
    description: string;
    url: string;
  };
  voice: {
    tone: string;
    audience: string;
    guidelines: string;
  };
  seo: {
    pillars: string[];
  };
  blog: {
    frontmatter: Record<string, string>;
    format: 'md' | 'mdx' | 'html';
    output_dir: string;
  };
  social: {
    twitter_handle: string;
    hashtags: string[];
  };
  cloud: {
    project_id: string;
  };
}

export interface ParsedRepoloreMd {
  config: RepoloreConfig;
  context: string;
  rawContent: string;
}

export function parseRepoloreMd(content: string): ParsedRepoloreMd {
  const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/;
  const match = content.match(frontmatterRegex);

  if (!match) {
    return {
      config: { ...DEFAULT_CONFIG },
      context: content,
      rawContent: content,
    };
  }

  const [, frontmatterStr, body] = match;

  try {
    const config = yaml.parse(frontmatterStr) || {};
    return {
      config: {
        project: { ...DEFAULT_CONFIG.project, ...config.project },
        voice: { ...DEFAULT_CONFIG.voice, ...config.voice },
        seo: { ...DEFAULT_CONFIG.seo, ...config.seo },
        blog: { ...DEFAULT_CONFIG.blog, ...config.blog },
        social: { ...DEFAULT_CONFIG.social, ...config.social },
        cloud: { ...DEFAULT_CONFIG.cloud, ...config.cloud },
      },
      context: body || '',
      rawContent: content,
    };
  } catch {
    return {
      config: { ...DEFAULT_CONFIG },
      context: body || '',
      rawContent: content,
    };
  }
}

export function readRepoloreMd(cwd: string): ParsedRepoloreMd {
  const filePath = path.join(cwd, 'REPOLORE.md');

  if (!fs.existsSync(filePath)) {
    return {
      config: { ...DEFAULT_CONFIG },
      context: '',
      rawContent: '',
    };
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  return parseRepoloreMd(content);
}

export function writeRepoloreMd(cwd: string, updates: Partial<RepoloreConfig>): void {
  const filePath = path.join(cwd, 'REPOLORE.md');
  let currentConfig: RepoloreConfig;
  let currentContext: string;

  if (fs.existsSync(filePath)) {
    const parsed = parseRepoloreMd(fs.readFileSync(filePath, 'utf-8'));
    currentConfig = parsed.config;
    currentContext = parsed.context;
  } else {
    currentConfig = { ...DEFAULT_CONFIG };
    currentContext = '';
  }

  const mergedConfig = deepMerge(currentConfig, updates);
  const frontmatter = yaml.stringify(mergedConfig).trim();

  const newContent = `---\n${frontmatter}\n---\n${currentContext}`;
  fs.writeFileSync(filePath, newContent, 'utf-8');
}

function deepMerge<T extends Record<string, unknown>>(target: T, source: Partial<T>): T {
  const result = { ...target };

  for (const key of Object.keys(source) as (keyof T)[]) {
    const sourceValue = source[key];
    const targetValue = target[key];

    if (
      sourceValue !== null &&
      typeof sourceValue === 'object' &&
      !Array.isArray(sourceValue) &&
      targetValue !== null &&
      typeof targetValue === 'object' &&
      !Array.isArray(targetValue)
    ) {
      (result as Record<string, unknown>)[key] = deepMerge(
        targetValue as Record<string, unknown>,
        sourceValue as Record<string, unknown>
      );
    } else if (sourceValue !== undefined) {
      (result as Record<string, unknown>)[key] = sourceValue;
    }
  }

  return result;
}
```

**Step 5: Run test to verify it passes**

Run: `cd packages/mcp && pnpm vitest run src/config/index.test.ts`
Expected: PASS

**Step 6: Commit**

Run: `git add packages/mcp/src/config/ && git commit -m "feat(mcp): add REPOLORE.md management"`
Expected: Commit created

---

## Task 7.3b: MCP Local Storage

**Files:**
- Create: `packages/mcp/src/storage/index.ts`

**Step 1: Write failing test**

```typescript
// packages/mcp/src/storage/index.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { saveOutline, saveGeneration, listOutlines, listGenerations, getOutline } from './index.js';

const testDir = path.join(process.cwd(), 'packages/mcp/test-storage');

describe('local storage', () => {
  beforeEach(() => {
    fs.rmSync(testDir, { recursive: true, force: true });
  });

  it('should save and retrieve outline', async () => {
    const outline = { id: 'test-1', contentTypes: ['blog'], sourceRef: 'abc123' };
    await saveOutline(testDir, outline);

    const outlines = await listOutlines(testDir);
    expect(outlines.length).toBe(1);
  });

  it('should save generation', async () => {
    await saveGeneration(testDir, 'blog', '# Test Post', 'test-post');

    const generations = await listGenerations(testDir, 'blog');
    expect(generations.length).toBe(1);
  });
});
```

**Step 2: Run test to verify it fails**

Run: `cd packages/mcp && pnpm vitest run src/storage/index.test.ts`
Expected: FAIL

**Step 3: Write implementation**

```typescript
// packages/mcp/src/storage/index.ts
import * as fs from 'fs';
import * as path from 'path';

const STORAGE_DIR = '.repolore';
const OUTLINES_DIR = 'outlines';
const GENERATIONS_DIR = 'generations';

export interface LocalOutline {
  id: string;
  contentTypes: string[];
  sourceRef: string;
  outline: string;
  status: 'pending' | 'approved' | 'rejected' | 'saved_for_later';
  createdAt: string;
}

export interface LocalGeneration {
  id: string;
  type: string;
  content: string;
  slug: string;
  createdAt: string;
}

function ensureDir(cwd: string, subdir: string): string {
  const dir = path.join(cwd, STORAGE_DIR, subdir);
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

export async function saveOutline(cwd: string, outline: LocalOutline): Promise<void> {
  const dir = ensureDir(cwd, OUTLINES_DIR);
  const fileName = `${outline.id}.json`;
  fs.writeFileSync(path.join(dir, fileName), JSON.stringify(outline, null, 2), 'utf-8');
}

export async function getOutline(cwd: string, id: string): Promise<LocalOutline | null> {
  const filePath = path.join(cwd, STORAGE_DIR, OUTLINES_DIR, `${id}.json`);

  if (!fs.existsSync(filePath)) {
    return null;
  }

  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

export async function listOutlines(cwd: string): Promise<LocalOutline[]> {
  const dir = path.join(cwd, STORAGE_DIR, OUTLINES_DIR);

  if (!fs.existsSync(dir)) {
    return [];
  }

  const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));

  return files.map(file => {
    const content = fs.readFileSync(path.join(dir, file), 'utf-8');
    return JSON.parse(content);
  }).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
}

export async function saveGeneration(
  cwd: string,
  type: string,
  content: string,
  slug: string
): Promise<string> {
  const dir = ensureDir(cwd, GENERATIONS_DIR);
  const typeDir = ensureDir(cwd, `${GENERATIONS_DIR}/${type}`);

  const id = `${slug}-${Date.now()}`;
  const ext = type === 'blog' ? '.md' : '.txt';
  const fileName = `${slug}${ext}`;

  fs.writeFileSync(path.join(typeDir, fileName), content, 'utf-8');

  // Save metadata
  const metadata: LocalGeneration = {
    id,
    type,
    content,
    slug,
    createdAt: new Date().toISOString(),
  };

  const metaDir = ensureDir(cwd, `${GENERATIONS_DIR}/.metadata`);
  fs.writeFileSync(path.join(metaDir, `${id}.json`), JSON.stringify(metadata, null, 2), 'utf-8');

  return id;
}

export async function listGenerations(
  cwd: string,
  type?: string
): Promise<LocalGeneration[]> {
  const baseDir = path.join(cwd, STORAGE_DIR, GENERATIONS_DIR);

  if (!fs.existsSync(baseDir)) {
    return [];
  }

  const metadataDir = path.join(baseDir, '.metadata');

  if (!fs.existsSync(metadataDir)) {
    return [];
  }

  let files = fs.readdirSync(metadataDir).filter(f => f.endsWith('.json'));

  if (type) {
    // Filter by type from metadata
    files = files.filter(file => {
      const meta = JSON.parse(fs.readFileSync(path.join(metadataDir, file), 'utf-8'));
      return meta.type === type;
    });
  }

  return files.map(file => {
    const content = fs.readFileSync(path.join(metadataDir, file), 'utf-8');
    return JSON.parse(content);
  }).sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
}

export function addToGitignore(cwd: string): void {
  const gitignorePath = path.join(cwd, '.gitignore');
  const content = fs.existsSync(gitignorePath) ? fs.readFileSync(gitignorePath, 'utf-8') : '';

  if (!content.includes(STORAGE_DIR)) {
    const newContent = content ? `${content}\n${STORAGE_DIR}/` : `${STORAGE_DIR}/`;
    fs.writeFileSync(gitignorePath, newContent, 'utf-8');
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/mcp && pnpm vitest run src/storage/index.test.ts`
Expected: PASS

**Step 5: Commit**

Run: `git add packages/mcp/src/storage/ && git commit -m "feat(mcp): add local storage for outlines and generations"`
Expected: Commit created

---

## Task 7.4: MCP Tools — Init & Config

**Files:**
- Create: `packages/mcp/src/tools/init.ts`
- Create: `packages/mcp/src/tools/config.ts`
- Create: `packages/mcp/src/tools/status.ts`

**Step 1: Write init tool**

```typescript
// packages/mcp/src/tools/init.ts
import * as fs from 'fs';
import * as path from 'path';
import { DEFAULT_REPOLORE_MD } from '../config/template.js';
import { addToGitignore } from '../storage/index.js';

export interface InitResult {
  success: boolean;
  message: string;
  repoUrl?: string;
}

export async function initRepolore(cwd: string): Promise<InitResult> {
  const repolorePath = path.join(cwd, 'REPOLORE.md');

  if (fs.existsSync(repolorePath)) {
    return {
      success: false,
      message: 'REPOLORE.md already exists. Use repolore_config to modify.',
    };
  }

  // Create REPOLORE.md
  fs.writeFileSync(repolorePath, DEFAULT_REPOLORE_MD, 'utf-8');

  // Create storage directory structure
  const storageDir = path.join(cwd, '.repolore');
  fs.mkdirSync(path.join(storageDir, 'outlines'), { recursive: true });
  fs.mkdirSync(path.join(storageDir, 'generations', 'blog'), { recursive: true });
  fs.mkdirSync(path.join(storageDir, 'generations', 'changelog'), { recursive: true });
  fs.mkdirSync(path.join(storageDir, 'generations', 'tweets'), { recursive: true });
  fs.mkdirSync(path.join(storageDir, 'generations', 'linkedin'), { recursive: true });

  // Add to gitignore
  addToGitignore(cwd);

  // Try to detect repo URL
  let repoUrl: string | undefined;
  try {
    const { execSync } = require('child_process');
    const url = execSync('git remote get-url origin', { cwd, encoding: 'utf-8' }).trim();
    const match = url.match(/github\.com[/:]([^/]+)\/([^/.]+)(\.git)?$/);
    if (match) {
      repoUrl = `${match[1]}/${match[2]}`;
    }
  } catch {
    // No remote configured
  }

  return {
    success: true,
    message: 'REPOLORE.md created. Edit it to configure your brand voice and project details.',
    repoUrl,
  };
}
```

**Step 2: Write config tool**

```typescript
// packages/mcp/src/tools/config.ts
import { readRepoloreMd, writeRepoloreMd, RepoloreConfig } from '../config/index.js';

export interface ConfigResult {
  success: boolean;
  message: string;
  config?: RepoloreConfig;
}

export async function getConfig(cwd: string): Promise<ConfigResult> {
  const parsed = readRepoloreMd(cwd);

  if (!parsed.rawContent) {
    return {
      success: false,
      message: 'REPOLORE.md not found. Run repolore_init first.',
    };
  }

  const lines = [
    `## Project`,
    `  Name: ${parsed.config.project.name || '(not set)'}`,
    `  Description: ${parsed.config.project.description || '(not set)'}`,
    `  URL: ${parsed.config.project.url || '(not set)'}`,
    ``,
    `## Voice`,
    `  Tone: ${parsed.config.voice.tone || 'casual, technical'}`,
    `  Audience: ${parsed.config.voice.audience || '(not set)'}`,
    ``,
    `## SEO`,
    `  Pillars: ${parsed.config.seo.pillars.join(', ') || '(none)'}`,
    ``,
    `## Blog`,
    `  Format: ${parsed.config.blog.format}`,
    `  Output Dir: ${parsed.config.blog.output_dir}`,
    ``,
    `## Social`,
    `  Twitter: ${parsed.config.social.twitter_handle || '(not set)'}`,
    `  Hashtags: ${parsed.config.social.hashtags.join(', ') || '(none)'}`,
    ``,
    `## Cloud`,
    `  Project ID: ${parsed.config.cloud.project_id || '(not set)'}`,
  ];

  return {
    success: true,
    message: lines.join('\n'),
    config: parsed.config,
  };
}

export async function setConfig(
  cwd: string,
  updates: Partial<RepoloreConfig>
): Promise<ConfigResult> {
  const parsed = readRepoloreMd(cwd);

  if (!parsed.rawContent) {
    return {
      success: false,
      message: 'REPOLORE.md not found. Run repolore_init first.',
    };
  }

  writeRepoloreMd(cwd, updates);

  return {
    success: true,
    message: 'Configuration updated.',
  };
}
```

**Step 3: Write status tool**

```typescript
// packages/mcp/src/tools/status.ts
import { readRepoloreMd } from '../config/index.js';
import { listOutlines, listGenerations } from '../storage/index.js';
import { getCloudConfig } from '../cloud/client.js';

export interface StatusResult {
  success: boolean;
  message: string;
}

export async function getStatus(cwd: string, apiKey?: string): Promise<StatusResult> {
  const config = readRepoloreMd(cwd);

  const outlines = await listOutlines(cwd);
  const blogGens = await listGenerations(cwd, 'blog');
  const changelogGens = await listGenerations(cwd, 'changelog');
  const tweetGens = await listGenerations(cwd, 'tweets');
  const linkedinGens = await listGenerations(cwd, 'linkedin');

  const lines = [
    `## RepoLore Status`,
    ``,
    `### Project`,
    `  Name: ${config.config.project.name || '(not set)'}`,
    `  URL: ${config.config.project.url || '(not set)'}`,
    ``,
    `### Local Storage`,
    `  Outlines: ${outlines.length}`,
    `  Blog Posts: ${blogGens.length}`,
    `  Changelogs: ${changelogGens.length}`,
    `  Tweets: ${tweetGens.length}`,
    `  LinkedIn Posts: ${linkedinGens.length}`,
  ];

  // Add cloud info if API key provided
  if (apiKey && config.config.cloud.project_id) {
    try {
      const cloudConfig = await getCloudConfig(config.config.cloud.project_id, apiKey);
      if (cloudConfig) {
        lines.push(``);
        lines.push(`### Cloud`);
        lines.push(`  Project ID: ${cloudConfig.id}`);
        lines.push(`  Cloud Sync: Enabled`);
      }
    } catch {
      lines.push(``);
      lines.push(`### Cloud`);
      lines.push(`  Status: API error (check key)`);
    }
  } else {
    lines.push(``);
    lines.push(`### Cloud`);
    lines.push(`  Status: Not configured (set API key in REPOLORE.md or REPOLORE_API_KEY env)`);
  }

  return {
    success: true,
    message: lines.join('\n'),
  };
}
```

**Step 4: Register tools in MCP server**

Modify `packages/mcp/src/index.ts` to register these tools:

```typescript
import { initRepolore } from './tools/init.js';
import { getConfig, setConfig } from './tools/config.js';
import { getStatus } from './tools/status.js';

// Add to tool handlers in setupHandlers():
this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'repolore_init':
      const initResult = await initRepolore(args.cwd || process.cwd());
      return {
        content: [{ type: 'text', text: initResult.message }],
        isError: !initResult.success,
      };

    case 'repolore_config':
      if (args.set) {
        const setResult = await setConfig(args.cwd || process.cwd(), args.set);
        return {
          content: [{ type: 'text', text: setResult.message }],
          isError: !setResult.success,
        };
      }
      const getResult = await getConfig(args.cwd || process.cwd());
      return {
        content: [{ type: 'text', text: getResult.message }],
        isError: !getResult.success,
      };

    case 'repolore_status':
      const statusResult = await getStatus(
        args.cwd || process.cwd(),
        args.apiKey || process.env.REPOLORE_API_KEY
      );
      return {
        content: [{ type: 'text', text: statusResult.message }],
        isError: !statusResult.success,
      };

    default:
      return {
        content: [{ type: 'text', text: `Unknown tool: ${name}` }],
        isError: true,
      };
  }
});
```

**Step 5: Add tool definitions to ListToolsRequestSchema handler**

```typescript
this.server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'repolore_init',
        description: 'Initialize RepoLore in the current directory. Creates REPOLORE.md and local storage.',
        inputSchema: {
          type: 'object',
          properties: {
            cwd: { type: 'string', description: 'Working directory (defaults to current)' },
          },
        },
      },
      {
        name: 'repolore_config',
        description: 'Get or set RepoLore configuration',
        inputSchema: {
          type: 'object',
          properties: {
            cwd: { type: 'string', description: 'Working directory' },
            set: { type: 'object', description: 'Configuration to update' },
          },
        },
      },
      {
        name: 'repolore_status',
        description: 'Show RepoLore status and local storage stats',
        inputSchema: {
          type: 'object',
          properties: {
            cwd: { type: 'string', description: 'Working directory' },
            apiKey: { type: 'string', description: 'API key for cloud status' },
          },
        },
      },
    ],
  };
});
```

**Step 6: Build and test**

Run: `cd packages/mcp && pnpm build`
Expected: Build succeeds

**Step 7: Commit**

Run: `git add packages/mcp/src/tools/ && git commit -m "feat(mcp): add init, config, and status tools"`
Expected: Commit created

---

## Task 7.5: MCP Tools — Outline & Generate

**Files:**
- Create: `packages/mcp/src/tools/outline.ts`
- Create: `packages/mcp/src/tools/generate.ts`
- Create: `packages/mcp/src/prompts/index.ts`

**Step 1: Create prompts module**

```typescript
// packages/mcp/src/prompts/index.ts
import type { RepoloreConfig } from '../config/index.js';

export interface OutlinePromptParams {
  projectName: string;
  projectDescription: string;
  tone: string;
  audience: string;
  seoPillars: string[];
  contentTypes: string[];
  diff: string;
  userContext?: string;
}

export interface GeneratePromptParams {
  projectName: string;
  tone: string;
  audience: string;
  seoPillars: string[];
  outline: string;
  diff: string;
  contentType: string;
  frontmatter?: Record<string, string>;
  format: string;
}

export function buildOutlinePrompt(params: OutlinePromptParams): string {
  return `# RepoLore Outline Generation

You are an expert technical content strategist. Analyze the following code diff and generate content outlines.

## Project Context
- Name: ${params.projectName}
- Description: ${params.projectDescription}
- Tone: ${params.tone}
- Audience: ${params.audience}
- SEO Pillars: ${params.seoPillars.join(', ')}

## Content Types Requested
${params.contentTypes.join(', ')}

${params.userContext ? `## Additional Context\n${params.userContext}\n` : ''}

## Code Diff
\`\`\`diff
${params.diff}
\`\`\`

Generate a structured outline for each requested content type. For each, provide:
1. **Proposed Title** (compelling, SEO-aware)
2. **Target Keyword** (from SEO pillars)
3. **Hook** (first sentence that grabs attention)
4. **Key Points** (3-5 main points to cover)
5. **Target Length** (word/character count)

IMPORTANT: Only generate the outline, not the full content.`;
}

export function buildGeneratePrompt(params: GeneratePromptParams): string {
  const formatInstructions = params.contentType === 'blog'
    ? `\n## Blog Format\nWrite as markdown with frontmatter:\n---\n${Object.entries(params.frontmatter || {}).map(([k, v]) => `${k}: "${v}"`).join('\n')}\ntitle: "[Generated Title]"\ndescription: "[SEO description]"\ndate: "${new Date().toISOString().split('T')[0]}"\n---\n\n`
    : '';

  return `# RepoLore Content Generation

You are an expert technical writer. Generate content based on the approved outline.

## Project
- Name: ${params.projectName}
- Tone: ${params.tone}
- Audience: ${params.audience}

## Content Type
${params.contentType}

## Approved Outline
${params.outline}

## Full Diff for Reference
\`\`\`diff
${params.diff}
\`\`\`
${formatInstructions}
Generate the complete ${params.contentType} content. Be specific, include real code examples, and write for developers.`;
}
```

**Step 2: Write outline tool**

```typescript
// packages/mcp/src/tools/outline.ts
import { readRepoloreMd } from '../config/index.js';
import { saveOutline, LocalOutline } from '../storage/index.js';
import { getRecentCommits, getCommitDiff, getCurrentBranch, truncateDiff } from '../git/index.js';
import { buildOutlinePrompt } from '../prompts/index.js';

export interface OutlineResult {
  success: boolean;
  message: string;
  prompt?: string;
  outlineId?: string;
}

export async function generateOutline(
  cwd: string,
  options: {
    type?: string[];
    source?: string;
    context?: string;
  }
): Promise<OutlineResult> {
  const config = readRepoloreMd(cwd);

  if (!config.rawContent) {
    return {
      success: false,
      message: 'REPOLORE.md not found. Run repolore_init first.',
    };
  }

  const contentTypes = options.type || ['blog'];
  const branch = await getCurrentBranch(cwd);

  // Get diff based on source
  let diff: string;
  let sourceRef: string;

  if (options.source) {
    // Use specific commit/PR
    const diffResult = await getCommitDiff(cwd, options.source);
    diff = truncateDiff(diffResult.diff);
    sourceRef = options.source;
  } else {
    // Use uncommitted changes or last commit
    try {
      diff = (await import('../git/index.js')).getStagedDiff(cwd);
      sourceRef = 'staged';
    } catch {
      const commits = await getRecentCommits(cwd, 1);
      if (commits.length === 0) {
        return {
          success: false,
          message: 'No commits found. Create a commit first or specify a source.',
        };
      }
      const diffResult = await getCommitDiff(cwd, commits[0].sha);
      diff = truncateDiff(diffResult.diff);
      sourceRef = commits[0].sha;
    }
  }

  const prompt = buildOutlinePrompt({
    projectName: config.config.project.name,
    projectDescription: config.config.project.description || '',
    tone: config.config.voice.tone,
    audience: config.config.voice.audience,
    seoPillars: config.config.seo.pillars,
    contentTypes,
    diff,
    userContext: options.context,
  });

  // Save outline locally
  const outline: LocalOutline = {
    id: `outline-${Date.now()}`,
    contentTypes,
    sourceRef,
    outline: prompt,
    status: 'pending',
    createdAt: new Date().toISOString(),
  };

  await saveOutline(cwd, outline);

  return {
    success: true,
    message: `Outline generated for ${contentTypes.join(', ')}. The AI will use this prompt to create the outline.`,
    prompt,
    outlineId: outline.id,
  };
}
```

**Step 3: Write generate tool**

```typescript
// packages/mcp/src/tools/generate.ts
import { readRepoloreMd } from '../config/index.js';
import { saveGeneration } from '../storage/index.js';
import { getCommitDiff, truncateDiff } from '../git/index.js';
import { buildGeneratePrompt } from '../prompts/index.js';

export interface GenerateResult {
  success: boolean;
  message: string;
  prompt?: string;
  savedTo?: string;
}

export async function generateContent(
  cwd: string,
  options: {
    type: string;
    outline: string;
    sourceRef?: string;
  }
): Promise<GenerateResult> {
  const config = readRepoloreMd(cwd);

  if (!config.rawContent) {
    return {
      success: false,
      message: 'REPOLORE.md not found. Run repolore_init first.',
    };
  }

  // Get diff if sourceRef provided
  let diff = '';
  if (options.sourceRef) {
    try {
      const diffResult = await getCommitDiff(cwd, options.sourceRef);
      diff = truncateDiff(diffResult.diff);
    } catch {
      diff = '(Diff not available)';
    }
  }

  const prompt = buildGeneratePrompt({
    projectName: config.config.project.name,
    tone: config.config.voice.tone,
    audience: config.config.voice.audience,
    seoPillars: config.config.seo.pillars,
    outline: options.outline,
    diff,
    contentType: options.type,
    frontmatter: config.config.blog.frontmatter,
    format: config.config.blog.format,
  });

  // Generate slug from outline title
  const titleMatch = options.outline.match(/^#\s+(.+)$/m) || options.outline.match(/\*\*Title\*\*:?\s*(.+)/i);
  const slug = titleMatch
    ? titleMatch[1].toLowerCase().replace(/[^a-z0-9]+/g, '-').slice(0, 50)
    : `generated-${Date.now()}`;

  const typeDir = options.type === 'blog' ? 'blog' : options.type === 'changelog' ? 'changelog' : options.type === 'tweet' ? 'tweets' : 'linkedin';

  return {
    success: true,
    message: `Content generation prompt ready for ${options.type}. The AI will generate the full content.`,
    prompt,
    savedTo: `${typeDir}/${slug}`,
  };
}
```

**Step 4: Register tools in MCP server**

Add to `packages/mcp/src/index.ts`:

```typescript
// Add imports
import { generateOutline } from './tools/outline.js';
import { generateContent } from './tools/generate.js';

// Add to tool definitions in ListToolsRequestSchema:
{
  name: 'repolore_outline',
  description: 'Generate an outline prompt from git diff for content types',
  inputSchema: {
    type: 'object',
    properties: {
      cwd: { type: 'string', description: 'Working directory' },
      type: {
        type: 'array',
        items: { type: 'string', enum: ['blog', 'changelog', 'tweet', 'linkedin'] },
        description: 'Content types to generate outlines for'
      },
      source: { type: 'string', description: 'Commit SHA or PR reference (optional)' },
      context: { type: 'string', description: 'Additional context for the AI' },
    },
  },
},
{
  name: 'repolore_generate',
  description: 'Generate full content from an approved outline',
  inputSchema: {
    type: 'object',
    properties: {
      cwd: { type: 'string', description: 'Working directory' },
      type: { type: 'string', enum: ['blog', 'changelog', 'tweet', 'linkedin'], description: 'Content type' },
      outline: { type: 'string', description: 'The approved outline text' },
      sourceRef: { type: 'string', description: 'Commit SHA for diff reference (optional)' },
    },
    required: ['type', 'outline'],
  },
},

// Add to CallToolRequestSchema handler:
case 'repolore_outline':
  const outlineResult = await generateOutline(args.cwd || process.cwd(), {
    type: args.type,
    source: args.source,
    context: args.context,
  });
  return {
    content: [{ type: 'text', text: outlineResult.message + (outlineResult.prompt ? `\n\n${outlineResult.prompt}` : '') }],
    isError: !outlineResult.success,
  };

case 'repolore_generate':
  const genResult = await generateContent(args.cwd || process.cwd(), {
    type: args.type,
    outline: args.outline,
    sourceRef: args.sourceRef,
  });
  return {
    content: [{ type: 'text', text: genResult.message + (genResult.prompt ? `\n\n${genResult.prompt}` : '') }],
    isError: !genResult.success,
  };
```

**Step 5: Build and test**

Run: `cd packages/mcp && pnpm build`
Expected: Build succeeds

**Step 6: Commit**

Run: `git add packages/mcp/src/tools/ packages/mcp/src/prompts/ && git commit -m "feat(mcp): add outline and generate tools"`
Expected: Commit created

---

## Task 7.6: MCP Tools — Cloud Sync

**Files:**
- Create: `packages/mcp/src/cloud/client.ts`
- Create: `packages/mcp/src/tools/push.ts`
- Create: `packages/mcp/src/tools/sync.ts`

**Step 1: Write cloud client**

```typescript
// packages/mcp/src/cloud/client.ts
const API_BASE = 'https://repolore.com/api/mcp';

export interface CloudConfig {
  id: string;
  name: string;
  configJson: string;
}

export interface PushResponse {
  success: boolean;
  projectId: string;
  message: string;
}

export async function getCloudConfig(projectId: string, apiKey: string): Promise<CloudConfig | null> {
  const response = await fetch(`${API_BASE}/config/${projectId}`, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
    },
  });

  if (!response.ok) {
    return null;
  }

  return response.json();
}

export async function pushToCloud(
  apiKey: string,
  options: {
    projectId?: string;
    repoFullName?: string;
    type: string;
    content: string;
    sourceRef?: string;
  }
): Promise<PushResponse> {
  const response = await fetch(`${API_BASE}/push`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify(options),
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: 'Unknown error' }));
    return {
      success: false,
      projectId: '',
      message: error.error || 'Push failed',
    };
  }

  return response.json();
}

export async function syncConfigToCloud(
  apiKey: string,
  options: {
    projectId?: string;
    repoFullName?: string;
    content: string;
  }
): Promise<{ success: boolean; message: string }> {
  const response = await fetch(`${API_BASE}/sync-config`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify(options),
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: 'Unknown error' }));
    return {
      success: false,
      message: error.error || 'Sync failed',
    };
  }

  return {
    success: true,
    message: 'Configuration synced to cloud',
  };
}

export function getApiKey(envKey?: string): string | null {
  return envKey || process.env.REPOLORE_API_KEY || null;
}
```

**Step 2: Write push tool**

```typescript
// packages/mcp/src/tools/push.ts
import { pushToCloud, getApiKey } from '../cloud/client.js';
import { getRemoteUrl } from '../git/index.js';

export interface PushResult {
  success: boolean;
  message: string;
  projectId?: string;
}

export async function pushContent(
  cwd: string,
  options: {
    type: string;
    content: string;
    projectId?: string;
    sourceRef?: string;
    apiKey?: string;
  }
): Promise<PushResult> {
  const apiKey = getApiKey(options.apiKey);

  if (!apiKey) {
    return {
      success: false,
      message: 'No API key. Set REPOLORE_API_KEY env var or pass apiKey parameter.',
    };
  }

  const repoFullName = await getRemoteUrl(cwd);

  const result = await pushToCloud(apiKey, {
    projectId: options.projectId,
    repoFullName: repoFullName || undefined,
    type: options.type,
    content: options.content,
    sourceRef: options.sourceRef,
  });

  if (!result.success) {
    return {
      success: false,
      message: result.message,
    };
  }

  // If projectId was not provided and cloud returned one, inform user
  if (!options.projectId && result.projectId) {
    return {
      success: true,
      message: `Content pushed to cloud. Project ID: ${result.projectId}. Add to REPOLORE.md: cloud.project_id = "${result.projectId}"`,
      projectId: result.projectId,
    };
  }

  return {
    success: true,
    message: `Content pushed to cloud successfully.`,
    projectId: result.projectId,
  };
}
```

**Step 3: Write sync tool**

```typescript
// packages/mcp/src/tools/sync.ts
import { readRepoloreMd } from '../config/index.js';
import { syncConfigToCloud, getApiKey } from '../cloud/client.js';
import { getRemoteUrl } from '../git/index.js';

export interface SyncResult {
  success: boolean;
  message: string;
}

export async function syncConfig(
  cwd: string,
  options: {
    projectId?: string;
    apiKey?: string;
  }
): Promise<SyncResult> {
  const apiKey = getApiKey(options.apiKey);

  if (!apiKey) {
    return {
      success: false,
      message: 'No API key. Set REPOLORE_API_KEY env var or pass apiKey parameter.',
    };
  }

  const config = readRepoloreMd(cwd);

  if (!config.rawContent) {
    return {
      success: false,
      message: 'REPOLORE.md not found. Run repolore_init first.',
    };
  }

  const repoFullName = await getRemoteUrl(cwd);

  const result = await syncConfigToCloud(apiKey, {
    projectId: options.projectId,
    repoFullName: repoFullName || undefined,
    content: config.rawContent,
  });

  return result;
}
```

**Step 4: Register tools in MCP server**

Add to `packages/mcp/src/index.ts`:

```typescript
import { pushContent } from './tools/push.js';
import { syncConfig } from './tools/sync.js';

// Add to tool definitions:
{
  name: 'repolore_push',
  description: 'Push content to RepoLore cloud',
  inputSchema: {
    type: 'object',
    properties: {
      cwd: { type: 'string', description: 'Working directory' },
      type: { type: 'string', enum: ['outline', 'blog', 'changelog', 'tweet', 'linkedin'], description: 'Content type' },
      content: { type: 'string', description: 'The content to push' },
      projectId: { type: 'string', description: 'Cloud project ID (optional, auto-detected from git remote)' },
      sourceRef: { type: 'string', description: 'Source reference' },
      apiKey: { type: 'string', description: 'API key (optional, uses REPOLORE_API_KEY env)' },
    },
    required: ['type', 'content'],
  },
},
{
  name: 'repolore_sync',
  description: 'Sync REPOLORE.md configuration to cloud',
  inputSchema: {
    type: 'object',
    properties: {
      cwd: { type: 'string', description: 'Working directory' },
      projectId: { type: 'string', description: 'Cloud project ID (optional)' },
      apiKey: { type: 'string', description: 'API key (optional)' },
    },
  },
},

// Add to CallToolRequestSchema handler:
case 'repolore_push':
  const pushResult = await pushContent(args.cwd || process.cwd(), {
    type: args.type,
    content: args.content,
    projectId: args.projectId,
    sourceRef: args.sourceRef,
    apiKey: args.apiKey,
  });
  return {
    content: [{ type: 'text', text: pushResult.message }],
    isError: !pushResult.success,
  };

case 'repolore_sync':
  const syncResult = await syncConfig(args.cwd || process.cwd(), {
    projectId: args.projectId,
    apiKey: args.apiKey,
  });
  return {
    content: [{ type: 'text', text: syncResult.message }],
    isError: !syncResult.success,
  };
```

**Step 5: Build**

Run: `cd packages/mcp && pnpm build`
Expected: Build succeeds

**Step 6: Commit**

Run: `git add packages/mcp/src/cloud/ packages/mcp/src/tools/push.ts packages/mcp/src/tools/sync.ts && git commit -m "feat(mcp): add cloud push and sync tools"`
Expected: Commit created

---

## Task 7.7: MCP Cloud API Endpoints (web package)

**Files:**
- Create: `packages/web/src/lib/api/routes/mcp.ts`
- Create: `packages/web/src/lib/db/mcp.ts`

**Step 1: Write MCP database queries**

```typescript
// packages/web/src/lib/db/mcp.ts
import { getDb } from './index.js';

export async function findUserByApiKeyHash(apiKeyHash: string): Promise<{ id: string } | null> {
  const db = getDb();
  const result = await db.prepare(
    'SELECT id FROM users WHERE api_key_hash = ?'
  ).bind(apiKeyHash).first<{ id: string }>();
  return result || null;
}

export async function findProjectByRepoFullName(
  userId: string,
  repoFullName: string
): Promise<{ id: string; name: string } | null> {
  const db = getDb();
  const result = await db.prepare(`
    SELECT p.id, p.name
    FROM projects p
    JOIN project_repos pr ON pr.project_id = p.id
    JOIN github_installations gi ON gi.installation_id = pr.installation_id
    WHERE p.user_id = ? AND pr.repo_full_name = ?
  `).bind(userId, repoFullName).first<{ id: string; name: string }>();
  return result || null;
}

export async function createOutlineFromMcp(data: {
  projectId: string;
  sourceRef: string;
  content: string;
  contentTypes: string[];
}): Promise<string> {
  const db = getDb();
  const id = crypto.randomUUID();

  await db.prepare(`
    INSERT INTO outlines (id, project_id, source_type, source_ref, outline_content, content_types_json, status, created_at, updated_at)
    VALUES (?, ?, 'manual', ?, ?, ?, 'pending_approval', datetime('now'), datetime('now'))
  `).bind(id, data.projectId, data.sourceRef, data.content, JSON.stringify(data.contentTypes));

  return id;
}

export async function createGenerationFromMcp(data: {
  outlineId: string;
  projectId: string;
  type: string;
  content: string;
}): Promise<string> {
  const db = getDb();
  const id = crypto.randomUUID();

  await db.prepare(`
    INSERT INTO generations (id, outline_id, project_id, type, content, status, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, 'draft', datetime('now'), datetime('now'))
  `).bind(id, data.outlineId, data.projectId, data.type, data.content);

  return id;
}

export async function updateProjectRepoloreMd(projectId: string, repoloreMd: string): Promise<void> {
  const db = getDb();
  await db.prepare(`
    UPDATE projects SET repolore_md = ?, updated_at = datetime('now')
    WHERE id = ?
  `).bind(repoloreMd, projectId);
}
```

**Step 2: Write MCP API routes**

```typescript
// packages/web/src/lib/api/routes/mcp.ts
import { Hono } from 'hono';
import { crypto } from 'cloudflare Workers';
import { findUserByApiKeyHash, findProjectByRepoFullName, createOutlineFromMcp, createGenerationFromMcp, updateProjectRepoloreMd } from '../../db/mcp.js';
import { getProjectById } from '../../db/projects.js';

const mcp = new Hono();

// Helper to hash API key
async function hashApiKey(key: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(key);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Auth middleware for MCP routes
async function authenticateMcp(c: any, next: () => Promise<void>) {
  const authHeader = c.req.header('Authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Missing or invalid Authorization header' }, 401);
  }

  const apiKey = authHeader.slice(7);
  const apiKeyHash = await hashApiKey(apiKey);
  const user = await findUserByApiKeyHash(apiKeyHash);

  if (!user) {
    return c.json({ error: 'Invalid API key' }, 401);
  }

  c.set('userId', user.id);
  await next();
}

mcp.use('/*', authenticateMcp);

// POST /api/mcp/push - Push content from MCP to cloud
mcp.post('/push', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json<{
    projectId?: string;
    repoFullName?: string;
    type: string;
    content: string;
    sourceRef?: string;
  }>();

  let projectId = body.projectId;

  // If no projectId, resolve by repoFullName
  if (!projectId && body.repoFullName) {
    const project = await findProjectByRepoFullName(userId, body.repoFullName);
    if (!project) {
      return c.json({
        error: `No project found for repo ${body.repoFullName}. Create a project and connect a repo first.`,
        availableRepos: []
      }, 400);
    }
    projectId = project.id;
  }

  if (!projectId) {
    return c.json({ error: 'projectId or repoFullName required' }, 400);
  }

  // Verify user owns project
  const project = await getProjectById(projectId);
  if (!project || project.user_id !== userId) {
    return c.json({ error: 'Project not found' }, 404);
  }

  if (body.type === 'outline') {
    const outlineId = await createOutlineFromMcp({
      projectId,
      sourceRef: body.sourceRef || 'mcp-push',
      content: body.content,
      contentTypes: ['blog', 'changelog', 'tweet', 'linkedin'],
    });
    return c.json({ success: true, projectId, outlineId });
  }

  // Create generation for content types
  const generationId = await createGenerationFromMcp({
    outlineId: '', // MCP push creates standalone generation
    projectId,
    type: body.type,
    content: body.content,
  });

  return c.json({ success: true, projectId, generationId });
});

// POST /api/mcp/sync-config - Sync REPOLORE.md to cloud
mcp.post('/sync-config', async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json<{
    projectId?: string;
    repoFullName?: string;
    content: string;
  }>();

  let projectId = body.projectId;

  if (!projectId && body.repoFullName) {
    const project = await findProjectByRepoFullName(userId, body.repoFullName);
    if (!project) {
      return c.json({ error: `No project found for repo ${body.repoFullName}` }, 400);
    }
    projectId = project.id;
  }

  if (!projectId) {
    return c.json({ error: 'projectId or repoFullName required' }, 400);
  }

  const project = await getProjectById(projectId);
  if (!project || project.user_id !== userId) {
    return c.json({ error: 'Project not found' }, 404);
  }

  await updateProjectRepoloreMd(projectId, body.content);

  return c.json({ success: true, projectId });
});

// GET /api/mcp/config/:projectId - Get project config
mcp.get('/config/:projectId', async (c) => {
  const userId = c.get('userId');
  const projectId = c.req.param('projectId');

  const project = await getProjectById(projectId);
  if (!project || project.user_id !== userId) {
    return c.json({ error: 'Project not found' }, 404);
  }

  return c.json({
    id: project.id,
    name: project.name,
    configJson: project.config_json,
  });
});

export { mcp };
```

**Step 3: Mount MCP routes in main API**

Modify `packages/web/src/lib/api/index.ts` to mount MCP routes:

```typescript
import { mcp } from './routes/mcp.js';

// Mount at /api/mcp
app.route('/mcp', mcp);
```

**Step 4: Commit**

Run: `git add packages/web/src/lib/api/routes/mcp.ts packages/web/src/lib/db/mcp.ts && git commit -m "feat(api): add MCP cloud endpoints"`
Expected: Commit created

---

## Task 7.8: MCP Server Registration & Publishing

**Files:**
- Modify: `packages/mcp/package.json`
- Create: `packages/mcp/README.md`

**Step 1: Update package.json for publishing**

Add to `packages/mcp/package.json`:

```json
{
  "bin": {
    "repolore": "./dist/index.js"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

**Step 2: Create README**

```markdown
# RepoLore MCP Server

MCP server for RepoLore - transforms code changes into blog posts, changelogs, and social content.

## Installation

### As npm package
```bash
npm install -g repolore
```

### Via npx (for Cursor, Claude Code, Windsurf)
Add to your MCP configuration:

```json
{
  "mcpServers": {
    "repolore": {
      "command": "npx",
      "args": ["-y", "repolore"]
    }
  }
}
```

## Usage

### Initialize a project
```bash
npx repolore
# or
repolore init
```

### Configure your project
Edit `REPOLORE.md` in your project root:
```yaml
---
project:
  name: "My Project"
  description: "A cool project"
voice:
  tone: "casual, technical"
  audience: "developers"
seo:
  pillars:
    - "typescript"
    - "react"
---
```

### Available Tools

- `repolore_init` - Initialize RepoLore in current directory
- `repolore_config` - Get or set configuration
- `repolore_status` - Show status and storage stats
- `repolore_outline` - Generate outline from git diff
- `repolore_generate` - Generate content from outline
- `repolore_push` - Push content to cloud (requires API key)
- `repolore_sync` - Sync REPOLORE.md to cloud

## Cloud Sync

To sync with RepoLore cloud:

1. Generate an API key from your RepoLore dashboard
2. Set environment variable: `export REPOLORE_API_KEY=your-key`
3. Or pass `apiKey` parameter to tools

## Development

```bash
pnpm install
pnpm build
pnpm start
```

## License

MIT
```

**Step 3: Test build and verify**

Run: `cd packages/mcp && pnpm build && ls -la dist/`
Expected: dist/index.js and type definitions created

**Step 4: Tag version and publish (simulated - would require npm login)**

```bash
cd packages/mcp
npm login
npm publish
```

**Step 5: Commit final phase work**

Run: `git add packages/mcp/ && git commit -m "feat: MCP server package - local git ops, outline/generate, cloud sync"`
Expected: Commit created

---

## Summary

This implementation plan covers:

| Task | Description | Key Files |
|------|-------------|------------|
| 7.1 | MCP Package Setup | `package.json`, `tsconfig.json`, `index.ts` |
| 7.2 | Local Git Operations | `src/git/index.ts` |
| 7.3 | REPOLORE.md Management | `src/config/index.ts`, `src/config/template.ts` |
| 7.3b | MCP Local Storage | `src/storage/index.ts` |
| 7.4 | Init/Config/Status Tools | `src/tools/init.ts`, `src/tools/config.ts`, `src/tools/status.ts` |
| 7.5 | Outline/Generate Tools | `src/tools/outline.ts`, `src/tools/generate.ts`, `src/prompts/index.ts` |
| 7.6 | Cloud Sync Tools | `src/cloud/client.ts`, `src/tools/push.ts`, `src/tools/sync.ts` |
| 7.7 | MCP Cloud API Endpoints | `packages/web/src/lib/api/routes/mcp.ts` |
| 7.8 | Registration & Publishing | `README.md`, package.json updates |

**Dependencies to add to MCP package.json:**
- `@modelcontextprotocol/sdk`: MCP protocol implementation
- `zod`: Input validation
- `yaml`: YAML parsing for REPOLORE.md

**Dependencies to add to devDependencies:**
- `@types/node`: TypeScript types
- `vitest`: Testing framework

**Estimated implementation time:** 2-3 sessions
