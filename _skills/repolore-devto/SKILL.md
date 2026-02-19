---
name: repolore-devto
description: Generate dev.to formatted articles from git commits. Use when the user asks to create a dev.to post, tutorial, or show-dev article based on their code changes.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore Dev.to

Load the `using-repolore` skill first for project context and voice rules.

## What This Produces

A dev.to article (800-1500 words) with dev.to-specific frontmatter, code examples from actual diffs, and a discussion prompt that invites genuine conversation.

## Workflow

1. Load REPOLORE.md — use `devto_tags` from frontmatter if available
2. Analyze commits with `git log` and `git diff`
3. Generate an outline, present for approval
4. Write the full article
5. Present for review, then save to `.repolore/devto/`

## Dev.to Frontmatter

```yaml
---
title: "[Article title]"
description: "[SEO description, 150-160 characters]"
published: false
tags: [tag1, tag2, tag3, tag4]
canonical_url:
cover_image:
series:
---
```

- Always set `published: false` — the user publishes when ready
- Maximum 4 tags (dev.to limit)
- Leave `canonical_url` empty unless the user specifies a cross-posting source
- Leave `cover_image` empty with a reminder to add one before publishing

## Platform Conventions

- Use dev.to liquid tags where they add value: `{% github user/repo %}`, `{% codepen %}`, etc.
- Format all code blocks with language specifiers
- End with a discussion prompt — ask something specific about the technical decision, not a generic "what do you think?"
- Dev.to readers value honesty about what didn't work, not just success stories

## Writing Direction

Dev.to posts that perform well are ones where the author shares something they actually learned. Not tutorials that read like documentation. Write about the problem first, the dead ends, then the solution. Include the code. Be specific.

Remind the user after saving:
- Set `published: true` when ready
- Add a cover image URL
- Set `canonical_url` if cross-posting from their own blog
