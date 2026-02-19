---
name: repolore-blog
description: Generate SEO-optimized technical blog posts from git commits. Use when the user asks to write a blog post, article, or long-form content based on their recent code changes or commit history.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore Blog

Load the `using-repolore` skill first. It provides project context loading, voice rules, and file saving conventions that apply here.

## What This Produces

A markdown blog post (800-1500 words) with YAML frontmatter, structured for SEO and technical depth. Content comes from actual git diffs, not generic advice.

## Workflow

1. Load REPOLORE.md for project context (see `using-repolore`)
2. Analyze the relevant commits with `git log` and `git diff`
3. Generate an outline and present it:
   - Proposed title with target keyword
   - Opening hook (first sentence)
   - H2 section plan
   - Key technical details to include from the diff
4. Wait for approval of the outline
5. Write the full post
6. Present for review, then save to `.repolore/blog/`

## Blog Post Structure

```yaml
---
title: "[Title with target keyword]"
description: "[Meta description, 150-160 characters]"
date: "YYYY-MM-DD"
tags: [relevant, tags]
---
```

- **TL;DR**: One to two sentences. Specific. Not a restatement of the title.
- **H2 sections**: Each covers one distinct aspect of the change. Use H3 sparingly for sub-points.
- **Code blocks**: Pull real code from the diff. Annotate what changed and why.
- **Closing**: A concrete takeaway. What the reader can apply. No "happy coding" sign-offs.

## SEO Guidelines

- Target keyword appears in: title, first paragraph, one H2, meta description
- Use specific technical terms from the actual codebase (function names, error messages, config keys) — these are long-tail keywords that generic AI content never includes
- Internal context matters more than keyword density

## Writing Direction

Write the way a developer would explain what they built to another developer over coffee. Start with the problem or the "why." Walk through what was tried and what worked. Show the actual code. Be honest about tradeoffs.

Do not write an introduction that restates the title. Jump into the story.
