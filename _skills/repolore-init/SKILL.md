---
name: repolore-init
description: Initialize Repolore for a project by creating REPOLORE.md configuration. Use when setting up Repolore for the first time, creating or updating REPOLORE.md, or changing project branding and tone settings.
allowed-tools: Bash(git:*) Bash(ls:*) Bash(cat:*) Read create_file
---

# Repolore Init

Create a `REPOLORE.md` configuration file that other Repolore skills use to generate content that sounds like the project, not like an AI.

## Why This Matters

REPOLORE.md is the single source of truth for tone, audience, and voice. Without it, every content skill guesses. With it, content is consistent across blog posts, tweets, LinkedIn, newsletters, and everything else.

## Workflow

### 1. Auto-Detect Project Information

Gather what you can before asking questions:

```bash
# Project name from package files
[ -f package.json ] && grep '"name"' package.json | head -1
[ -f Cargo.toml ] && grep '^name' Cargo.toml | head -1
[ -f pyproject.toml ] && grep '^name' pyproject.toml | head -1
[ -f go.mod ] && head -1 go.mod
```

```bash
# Language/framework detection
ls package.json Cargo.toml pyproject.toml go.mod requirements.txt 2>/dev/null
```

```bash
# Existing README for context
cat README.md 2>/dev/null | head -50
```

```bash
# Git remote and recent history
git remote -v 2>/dev/null | head -1
git log --oneline -5 2>/dev/null
```

### 2. Ask Only What's Missing

Do not ask for information you already detected. Only ask for:

**Required** (if not detected):
- Project name
- What the project does (one to two sentences)
- Tone — offer these options: `technical_but_accessible`, `professional`, `casual`, `enthusiastic`, `authoritative`
- Target audience: developers, end users, technical founders, open source community, or something specific
- Three to five SEO pillars (key topics for content)

**Optional** (ask, but accept "skip"):
- Twitter/X handle
- dev.to tags
- Newsletter author name
- Brand voice description (how they want to sound — suggest they use a comparison like "like [X] but [Y]")

### 3. Generate REPOLORE.md

```yaml
---
project: [Name]
tone: [selected_tone]
audience: [selected_audience]
seo_pillars:
  - [pillar_1]
  - [pillar_2]
  - [pillar_3]
twitter_handle: "[handle]"
devto_tags:
  - [tag1]
  - [tag2]
newsletter_from: "[name]"
---

# Project Context

[Description from user or README]

# Key Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

# Target Audience

[Who reads this content and what they care about]

# Brand Voice

[How the project should sound — concrete, not abstract]
```

### 4. Present and Save

Show the generated content. Wait for approval or edits. Save to `REPOLORE.md` in the repository root using `create_file`.

## Guidance for Brand Voice Section

Push the user toward specificity. "Professional" means nothing. "Like the Stripe docs but less formal" means something. "A senior engineer explaining something to a junior — patient but not condescending" means something.

Bad: "We want to sound professional and approachable."
Good: "Technical but accessible. We explain complex topics simply without dumbing them down. We sound like a smart colleague explaining something over coffee, not a textbook."
