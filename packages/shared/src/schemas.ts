import { z } from 'zod';
import { CONTENT_TYPES, OUTLINE_STATUSES, GENERATION_STATUSES } from './constants.js';

// Content type schema
export const ContentTypeSchema = z.enum(CONTENT_TYPES);

// Outline status schema
export const OutlineStatusSchema = z.enum(OUTLINE_STATUSES);

// Generation status schema
export const GenerationStatusSchema = z.enum(GENERATION_STATUSES);

// Health check response schema
export const HealthResponseSchema = z.object({
  status: z.enum(['ok', 'error']),
  version: z.string(),
  timestamp: z.string(),
});

// API error response schema
export const ApiErrorSchema = z.object({
  success: z.literal(false),
  error: z.string(),
});

// API success response schema (generic)
export function createApiSuccessSchema<T extends z.ZodType>(dataSchema: T) {
  return z.object({
    success: z.literal(true),
    data: dataSchema,
  });
}

// User preferences schema
export const UserPreferencesSchema = z
  .object({
    onboardingDismissed: z.boolean().default(false),
    defaultContentTypes: z.array(ContentTypeSchema).default(['blog']),
    theme: z.enum(['dark', 'light', 'system']).default('dark'),
  })
  .passthrough();

// Project config schema
export const ProjectConfigSchema = z
  .object({
    brandVoice: z.string().max(2000).default(''),
    tone: z.enum(['professional', 'casual', 'technical', 'friendly']).default('professional'),
    seoPillars: z.array(z.string()).default([]),
    frontmatterTemplate: z.string().default('---\ntitle: {{title}}\ndate: {{date}}\n---'),
    targetAudience: z.string().default('developers'),
  })
  .passthrough();

// Generation metadata schema
export const GenerationMetadataSchema = z
  .object({
    title: z.string().optional(),
    slug: z.string().optional(),
    tags: z.array(z.string()).default([]),
    frontmatter: z.string().optional(),
    seoDescription: z.string().optional(),
    characterCount: z.number().optional(),
  })
  .passthrough();
