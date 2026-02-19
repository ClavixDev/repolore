---
name: using-repolore
description: Core Repolore skill loaded by all content-generating skills. Provides project context loading, voice enforcement, anti-AI-slop guardrails, git analysis patterns, and file saving conventions. Use when any repolore skill is active.
---

# Using Repolore

This skill provides shared context for all Repolore content-generation skills. Every other repolore skill depends on this one.

## Loading Project Context

Before generating any content, check for `REPOLORE.md` in the repository root:

```bash
cat REPOLORE.md 2>/dev/null
```

If present, parse:
- **Frontmatter**: project name, tone, audience, SEO pillars, platform-specific settings
- **Body sections**: Project Context, Key Features, Target Audience, Brand Voice

These settings are binding. All generated content must conform to the tone, audience, and voice described in REPOLORE.md. If no REPOLORE.md exists, suggest running `/repolore-init` first, but proceed with reasonable defaults if the user wants to continue.

## Git Analysis

Gather commit data using these patterns:

```bash
# Recent history
git log --oneline -n 10

# Detailed diff for specific range
git diff HEAD~3 HEAD

# Single commit details
git show --stat HEAD
```

Read the actual diffs. Do not guess what changed. Content must reference real function names, file paths, error messages, and architectural decisions from the code.

## Voice and Tone Rules

These rules apply to ALL generated content across every platform.

### Write Like a Person

The goal is content that reads like a developer wrote it on their own. Not content that reads like an AI generated it on request.

Good writing is specific. It names the function that broke. It mentions the error message. It describes what was tried first and why it failed. Generic statements ("improved performance", "enhanced user experience", "streamlined the workflow") are never acceptable.

### Banned Patterns

Do not use any of these. Ever.

**Filler openers:**
- "In today's fast-paced world..."
- "Let's dive in..."
- "In this article, we'll explore..."
- "Have you ever wondered..."
- "As developers, we all know..."
- "It's no secret that..."

**Hype words:**
- game-changer, revolutionary, cutting-edge, next-level, supercharge
- seamlessly, effortlessly, robust, elegant, powerful
- leverage (as a verb), utilize (use "use"), synergy
- unlock, empower, elevate, transform (when used as buzzwords)

**AI tells:**
- Starting sentences with "So," or "Now,"
- "Let me explain..."
- "Here's the thing..."
- "I'm excited to share..."
- Exclamation marks in technical writing (one per piece maximum, if any)
- Emoji in body text (unless platform convention demands it and REPOLORE.md permits it)
- "Happy coding!" or any sign-off catchphrase
- Lists where every item starts with the same word pattern
- Three adjectives in a row ("fast, reliable, and scalable")

**Structural cliches:**
- "TL;DR" followed by a generic summary (make the TL;DR actually useful and specific)
- "Without further ado..."
- "Wrapping up" / "In conclusion" / "Final thoughts"
- "What do you think? Let me know in the comments!"

### What Good Writing Looks Like

- Short paragraphs. Two to three sentences. White space is your friend.
- Specific details from the actual code changes. Function names, error messages, config values.
- Honest about tradeoffs. "This approach is slower but simpler to maintain."
- Admits what's not perfect. "This doesn't handle edge case X yet."
- Uses "I" naturally. "I spent an hour debugging this before realizing the issue was..."
- Conversational without being performative. Write like you're explaining something to a colleague, not presenting to an audience.

### Tone Mapping

When REPOLORE.md specifies a tone, interpret it as:

| Tone | Means | Does NOT Mean |
|------|-------|---------------|
| `technical_but_accessible` | Explain decisions, show code, avoid jargon without context | Dumbed down or oversimplified |
| `professional` | Clear, direct, confident | Corporate speak or marketing language |
| `casual` | Relaxed, first-person, informal | Sloppy or unprofessional |
| `enthusiastic` | Genuine excitement about solving problems | Hype, exclamation marks everywhere |
| `authoritative` | Deep expertise, opinionated, backed by evidence | Arrogant or dismissive |

## File Saving Conventions

All generated content saves to `.repolore/{platform}/`:

```bash
mkdir -p .repolore/{platform}
```

Filename pattern: `repolore-{platform}-{YYYYMMDD-HHMMSS}.md`

Check if `.repolore/` is in `.gitignore`. If not, add it:

```bash
grep -q "^\.repolore/" .gitignore 2>/dev/null || echo ".repolore/" >> .gitignore
```

Use `create_file` to write the output. There is no "Write" tool.

## Content Review Flow

Always present generated content for review before saving. Show the user what they'll get. Wait for approval or revision requests. Then save.

Do not ask "Would you like me to save this?" with a list of options. Just present the content, wait for feedback, and save when approved.
