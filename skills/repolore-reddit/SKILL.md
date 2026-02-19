---
name: repolore-reddit
description: Generate discussion-focused Reddit posts from git commits. Use when the user asks to write a Reddit post, share a project, or create a technical discussion post for Reddit.
allowed-tools: Bash(git:*) Read create_file
---

# Repolore Reddit

Load the `using-repolore` skill first for project context and voice rules.

## What This Produces

A Reddit post that prioritizes technical discussion value over self-promotion. Includes a subreddit recommendation, descriptive title, and body with enough technical depth to invite real conversation.

## Workflow

1. Load REPOLORE.md — use `subreddits` from frontmatter if available
2. Analyze commits with `git log` and `git show`
3. Generate the post with subreddit recommendation
4. Present for review, then save to `.repolore/reddit/`

## Post Format

```
Suggested Subreddit: r/[subreddit]

Title: [Descriptive, not clickbait]

Body:
[Technical content with discussion prompt]
```

## Post Structure

1. **Title** — Descriptive and specific. Good: "I built a zero-dependency auth library in Go — here's how I handle token rotation without Redis." Bad: "Check out my new project!"
2. **Context** — What you built and the problem it solves. Keep it tight.
3. **Technical details** — Implementation decisions, tradeoffs, numbers. What technologies, why those over alternatives, what surprised you.
4. **Discussion prompt** — Ask something specific. "How do you handle X in your projects?" works. "What do you think?" does not.

## Platform Rules

- Reddit communities detect and punish self-promotion. Lead with the technical discussion, not the product pitch.
- No marketing language. No "I'm excited to announce..."
- Include code snippets when they support the discussion
- Be upfront about limitations — Reddit respects honesty, punishes hype
- Match the subreddit's culture: r/programming is different from r/webdev is different from r/rust
