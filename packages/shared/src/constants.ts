// Content types
export const CONTENT_TYPES = ['blog', 'changelog', 'tweet', 'linkedin'] as const;

// Outline statuses
export const OUTLINE_STATUSES = [
  'queued',
  'generating',
  'pending_approval',
  'approved',
  'rejected',
  'saved_for_later',
  'completed',
  'failed',
] as const;

// Generation statuses
export const GENERATION_STATUSES = [
  'queued',
  'generating',
  'draft',
  'published',
  'archived',
  'failed',
] as const;

// Tier limits configuration
export const TIER_LIMITS: Record<
  'free' | 'hacker',
  {
    maxRepos: number;
    maxEffectiveItemsPerMonth: number;
    maxBrandVoiceChars: number;
    hasCloudAi: boolean;
    hasCloudSync: boolean;
    hasPushNotifications: boolean;
    hasContentExport: boolean;
  }
> = {
  free: {
    maxRepos: 2,
    maxEffectiveItemsPerMonth: 20,
    maxBrandVoiceChars: 500,
    hasCloudAi: false,
    hasCloudSync: false,
    hasPushNotifications: false,
    hasContentExport: false,
  },
  hacker: {
    maxRepos: 5,
    maxEffectiveItemsPerMonth: 200,
    maxBrandVoiceChars: 2000,
    hasCloudAi: true,
    hasCloudSync: true,
    hasPushNotifications: true,
    hasContentExport: true,
  },
};

// Cookie names
export const COOKIE_NAMES = {
  SESSION: 'repolore_session',
  OAUTH_STATE: 'repolore_oauth_state',
} as const;

// Session expiry (30 days in seconds)
export const SESSION_EXPIRY_SECONDS = 30 * 24 * 60 * 60;

// Session refresh threshold (15 days in seconds)
export const SESSION_REFRESH_THRESHOLD_SECONDS = 15 * 24 * 60 * 60;

// API routes
export const API_ROUTES = {
  HEALTH: '/api/health',
  AUTH: {
    GOOGLE: '/api/auth/google',
    GITHUB: '/api/auth/github',
    GOOGLE_CALLBACK: '/api/auth/google/callback',
    GITHUB_CALLBACK: '/api/auth/github/callback',
    LOGOUT: '/api/auth/logout',
    ME: '/api/auth/me',
  },
} as const;

// Queue names
export const QUEUE_NAMES = {
  OUTLINE: 'repolore-outline-queue',
  CONTENT: 'repolore-content-queue',
} as const;

// App info
export const APP_INFO = {
  NAME: 'RepoLore',
  VERSION: '0.1.0',
  DOMAIN: 'repolore.com',
} as const;
