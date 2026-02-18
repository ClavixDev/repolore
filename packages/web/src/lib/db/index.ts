// D1 database query helpers
// Raw SQL with type assertions - no ORM

import type { User, Session, OAuthAccount } from '@repolore/shared';

// Database helper class
export class Database {
  constructor(private db: D1Database) {}

  // User queries
  async getUserById(id: string): Promise<User | null> {
    const result = await this.db
      .prepare('SELECT * FROM users WHERE id = ?')
      .bind(id)
      .first();
    return result ? (result as User) : null;
  }

  async getUserByEmail(email: string): Promise<User | null> {
    const result = await this.db
      .prepare('SELECT * FROM users WHERE email = ?')
      .bind(email)
      .first();
    return result ? (result as User) : null;
  }

  async createUser(user: Omit<User, 'createdAt' | 'updatedAt'>): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO users (id, email, name, avatar_url, role, api_key_hash, ai_endpoint, ai_model, ai_api_key, preferences_json)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
      )
      .bind(
        user.id,
        user.email,
        user.name,
        user.avatarUrl,
        user.role,
        user.apiKeyHash,
        user.aiEndpoint,
        user.aiModel,
        user.aiApiKey,
        user.preferencesJson
      )
      .run();
  }

  // Session queries
  async getSessionById(id: string): Promise<Session | null> {
    const result = await this.db
      .prepare('SELECT * FROM sessions WHERE id = ?')
      .bind(id)
      .first();
    return result ? (result as Session) : null;
  }

  async createSession(session: Omit<Session, 'createdAt'>): Promise<void> {
    await this.db
      .prepare('INSERT INTO sessions (id, user_id, expires_at) VALUES (?, ?, ?)')
      .bind(session.id, session.userId, session.expiresAt)
      .run();
  }

  async deleteSession(id: string): Promise<void> {
    await this.db.prepare('DELETE FROM sessions WHERE id = ?').bind(id).run();
  }

  async deleteUserSessions(userId: string): Promise<void> {
    await this.db.prepare('DELETE FROM sessions WHERE user_id = ?').bind(userId).run();
  }

  async cleanExpiredSessions(): Promise<void> {
    await this.db
      .prepare("DELETE FROM sessions WHERE expires_at < datetime('now')")
      .run();
  }

  // OAuth account queries
  async getOAuthAccount(
    provider: string,
    providerAccountId: string
  ): Promise<OAuthAccount | null> {
    const result = await this.db
      .prepare(
        'SELECT * FROM oauth_accounts WHERE provider = ? AND provider_account_id = ?'
      )
      .bind(provider, providerAccountId)
      .first();
    return result ? (result as OAuthAccount) : null;
  }

  async createOAuthAccount(account: Omit<OAuthAccount, 'createdAt'>): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO oauth_accounts (id, user_id, provider, provider_account_id, access_token, refresh_token, token_expires_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`
      )
      .bind(
        account.id,
        account.userId,
        account.provider,
        account.providerAccountId,
        account.accessToken,
        account.refreshToken,
        account.tokenExpiresAt
      )
      .run();
  }

  // Health check
  async healthCheck(): Promise<boolean> {
    try {
      await this.db.prepare('SELECT 1').first();
      return true;
    } catch {
      return false;
    }
  }
}

// Factory function
export function createDatabase(db: D1Database): Database {
  return new Database(db);
}
