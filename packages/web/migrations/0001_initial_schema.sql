-- Users (authenticated via Google or GitHub OAuth)
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  api_key_hash TEXT,
  ai_endpoint TEXT,
  ai_model TEXT,
  ai_api_key TEXT,
  preferences_json TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- OAuth accounts (linked to users, supports multiple providers)
CREATE TABLE oauth_accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  provider_account_id TEXT NOT NULL,
  access_token TEXT,
  refresh_token TEXT,
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

-- GitHub App installations
CREATE TABLE github_installations (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  installation_id INTEGER NOT NULL UNIQUE,
  account_login TEXT NOT NULL,
  account_type TEXT NOT NULL,
  permissions_json TEXT,
  access_token TEXT,
  token_expires_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Projects (1 project = 1+ repos)
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  config_json TEXT NOT NULL DEFAULT '{}',
  repolore_md TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Project repositories (join table, supports multi-repo projects on paid plans)
CREATE TABLE project_repos (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  installation_id INTEGER NOT NULL REFERENCES github_installations(installation_id) ON DELETE CASCADE,
  repo_full_name TEXT NOT NULL,
  is_primary INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(project_id, repo_full_name)
);

-- Project memories
CREATE TABLE memories (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  source_generation_id TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Outlines
CREATE TABLE outlines (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  source_type TEXT NOT NULL,
  source_ref TEXT,
  content_types_json TEXT NOT NULL,
  user_context TEXT,
  diff_content TEXT,
  outline_content TEXT,
  status TEXT NOT NULL DEFAULT 'queued',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Generations
CREATE TABLE generations (
  id TEXT PRIMARY KEY,
  outline_id TEXT NOT NULL REFERENCES outlines(id) ON DELETE CASCADE,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  content TEXT,
  metadata_json TEXT DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'queued',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Push notification subscriptions
CREATE TABLE push_subscriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  endpoint TEXT NOT NULL,
  keys_json TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(user_id, endpoint)
);

-- Billing (Polar.sh subscription tracking)
CREATE TABLE subscriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  polar_subscription_id TEXT NOT NULL UNIQUE,
  polar_customer_id TEXT,
  plan TEXT NOT NULL,
  status TEXT NOT NULL,
  current_period_end TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Usage tracking
CREATE TABLE usage (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  period TEXT NOT NULL,
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
