---
name: repolore-newsletter
description: Generate email newsletter content from git commits. Use when the user asks to write a newsletter, email update, or subscriber communication about their development work.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore Newsletter

Load the `using-repolore` skill first for project context and voice rules.

## What This Produces

An email newsletter with subject line, preview text, and body content. Written in first person, as if the developer is writing directly to their subscribers about what they've been building.

## Workflow

1. Load REPOLORE.md — use `newsletter_from` for the sign-off name if available
2. Analyze commits with `git log` (default to last week's changes unless specified)
3. Generate the newsletter
4. Show character counts for subject and preview
5. Present for review, then save to `.repolore/newsletter/`

## Newsletter Format

**Subject line**: Under 50 characters. Specific enough to open. No clickbait, no ALL CAPS, no emoji.

**Preview text**: Under 100 characters. Supports the subject — gives a reason to open.

**Body structure**:
- Personal opening — what you've been working on, in one or two sentences
- Main content — what shipped, with specific details and code snippets where relevant
- Technical depth — architecture decisions, interesting problems solved
- What's next — a genuine teaser for upcoming work, not a cliffhanger
- Sign-off — use `newsletter_from` name from REPOLORE.md, or ask the user

## Writing Direction

Newsletters are the most personal content format. Write like you're emailing a friend who happens to care about your project. First person. Conversational. Specific.

Do not structure it like a marketing email. No bullet-point feature lists with bold headers. No "Here's what's new!" openings. Tell the story of what you built this week.
