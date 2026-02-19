---
name: repolore-x
description: Generate X/Twitter posts and threads from git commits. Use when the user asks to write a tweet, X post, or thread about their development work or code changes.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore X

Load the `using-repolore` skill first for project context and voice rules.

## What This Produces

An X/Twitter post (max 280 characters) or thread (3-5 posts). Specific about what was built. Reads like a developer sharing genuine progress, not a marketing account pushing a product.

## Workflow

1. Load REPOLORE.md — use `twitter_handle` if available
2. Analyze commits with `git log` and `git show`
3. Generate tweet or thread
4. Show character count for each post (hard limit: 280)
5. Present for review, then save to `.repolore/x/`

## Single Post

Max 280 characters. Every character counts. Be specific — "fixed a race condition in the WebSocket reconnection logic" beats "made some improvements to the backend."

No emoji unless REPOLORE.md tone is `casual` and even then, one maximum.

## Thread Format

```
1/ [First post — the hook, stands alone]
2/ [Context or the problem]
3/ [What you built or how you solved it]
4/ [Code snippet or technical detail]
5/ [Takeaway or link]
```

Each post must be under 280 characters and make sense on its own if someone only sees that one in their feed.

## Platform Rules

- Specificity wins. Name the technology, the function, the metric.
- No hashtag spam. One or two relevant hashtags maximum, only if they add discoverability.
- No thread where a single post would do. Only suggest a thread if there's genuinely enough to say.
- "Shipped X" or "Just pushed Y" is fine as a thread opener. "I'm thrilled to announce..." is not.
