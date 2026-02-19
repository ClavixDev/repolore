---
name: repolore-linkedin
description: Generate professional LinkedIn posts from git commits. Use when the user asks to write a LinkedIn post, update, or professional announcement about their development work.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore LinkedIn

Load the `using-repolore` skill first for project context and voice rules.

## What This Produces

A LinkedIn post (1000-1300 characters) ready to paste. Professional but not corporate. Specific about what was built, not vague about "exciting developments."

## Workflow

1. Load REPOLORE.md for project context and tone
2. Analyze commits with `git log` and `git show`
3. Generate the post
4. Show character count (target: 1000-1300)
5. Present for review, then save to `.repolore/linkedin/`

## Post Structure

1. **Hook** — First line stands alone. LinkedIn truncates after roughly 210 characters (the "...see more" cutoff). This line must create enough curiosity to click through. No questions. No cliches. State something specific and interesting.
2. **Context** — What you were working on and why. Two to three lines.
3. **The technical detail** — What you shipped. Be specific. Name the feature, the metric, the before/after.
4. **Takeaway** — What you learned or why it matters to others in your field.
5. **Soft CTA** — A question or invitation. Keep it genuine.

## Platform Rules

- Line breaks between every paragraph — LinkedIn collapses text without them
- Maximum 3 hashtags, at the end, lowercase
- No corporate jargon: "synergies," "learnings," "ecosystem," "stakeholders"
- No humblebrags: "So grateful for the opportunity to..." — just say what you did
- Sound like a person talking about their work, not a press release about a product launch
