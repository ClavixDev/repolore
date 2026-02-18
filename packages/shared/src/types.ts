// Content types
export type ContentType = 'blog' | 'changelog' | 'tweet' | 'linkedin';

// Outline statuses
export type OutlineStatus =
  | 'queued'
  | 'generating'
  | 'pending_approval'
  | 'approved'
  | 'rejected'
  | 'saved_for_later'
  | 'completed'
  | 'failed';

// Generation statuses
export type GenerationStatus =
  | 'queued'
  | 'generating'
  | 'draft'
  | 'published'
  | 'archived'
  | 'failed';

// User roles
export type UserRole = 'user' | 'admin';

// OAuth providers
export type OAuthProvider = 'google' | 'github';

// GitHub account types
export type GitHubAccountType = 'User' | 'Organization';

// Memory types
export type MemoryType = 'learning' | 'style_note' | 'topic_covered';

// Subscription plans
export type SubscriptionPlan = 'free' | 'hacker';

// Subscription statuses
export type SubscriptionStatus = 'active' | 'canceled' | 'past_due';

// Source types for outlines
export type SourceType = 'pr' | 'commit' | 'diff' | 'manual';

// Core User type
export interface User {
  id: string;
  email: string;
  name: string | null;
  avatarUrl: string | null;
  role: UserRole;
  apiKeyHash: string | null;
  aiEndpoint: string | null;
  aiModel: string | null;
  aiApiKey: string | null;
  preferencesJson: string;
  createdAt: string;
  updatedAt: string;
}

// OAuth Account type
export interface OAuthAccount {
  id: string;
  userId: string;
  provider: OAuthProvider;
  providerAccountId: string;
  accessToken: string | null;
  refreshToken: string | null;
  tokenExpiresAt: string | null;
  createdAt: string;
}

// Session type
export interface Session {
  id: string;
  userId: string;
  expiresAt: string;
  createdAt: string;
}

// GitHub Installation type
export interface GitHubInstallation {
  id: string;
  userId: string | null;
  installationId: number;
  accountLogin: string;
  accountType: GitHubAccountType;
  permissionsJson: string | null;
  accessToken: string | null;
  tokenExpiresAt: string | null;
  createdAt: string;
}

// Project type
export interface Project {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  configJson: string;
  repoloreMd: string | null;
  createdAt: string;
  updatedAt: string;
}

// Project Repository type
export interface ProjectRepo {
  id: string;
  projectId: string;
  installationId: number;
  repoFullName: string;
  isPrimary: boolean;
  createdAt: string;
}

// Memory type
export interface Memory {
  id: string;
  projectId: string;
  type: MemoryType;
  content: string;
  sourceGenerationId: string | null;
  createdAt: string;
}

// Outline type
export interface Outline {
  id: string;
  projectId: string;
  sourceType: SourceType;
  sourceRef: string | null;
  contentTypesJson: string;
  userContext: string | null;
  diffContent: string | null;
  outlineContent: string | null;
  status: OutlineStatus;
  createdAt: string;
  updatedAt: string;
}

// Generation type
export interface Generation {
  id: string;
  outlineId: string;
  projectId: string;
  type: ContentType;
  content: string | null;
  metadataJson: string;
  status: GenerationStatus;
  createdAt: string;
  updatedAt: string;
}

// Push Subscription type
export interface PushSubscription {
  id: string;
  userId: string;
  endpoint: string;
  keysJson: string;
  createdAt: string;
}

// Subscription type
export interface Subscription {
  id: string;
  userId: string;
  polarSubscriptionId: string;
  polarCustomerId: string | null;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  currentPeriodEnd: string | null;
  createdAt: string;
  updatedAt: string;
}

// Usage type
export interface Usage {
  id: string;
  userId: string;
  period: string;
  cloudOutlinesCount: number;
  cloudGenerationsCount: number;
}

// Tier limits
export interface TierLimits {
  maxRepos: number;
  maxEffectiveItemsPerMonth: number;
  maxBrandVoiceChars: number;
  hasCloudAi: boolean;
  hasCloudSync: boolean;
  hasPushNotifications: boolean;
  hasContentExport: boolean;
}

// API Response types
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

// Health check response
export interface HealthResponse {
  status: 'ok' | 'error';
  version: string;
  timestamp: string;
}
