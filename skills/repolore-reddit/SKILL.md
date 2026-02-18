# Repolore Reddit

Generate discussion-focused Reddit posts from your git commits.

## Usage

```
/load skill repolore-reddit

# Post about a technical decision
Write a Reddit post about why I chose Rust for this project

# Share a solution
Post about how I solved the caching problem in my last commit

# Ask for feedback
Write a Reddit post asking for feedback on my new CLI design
```

## Requirements

- Git repository with commit history
- Optional: REPOLORE.md for project context

## Workflow

1. **Analyze commits** - Uses `git log` and `git show`
2. **Read context** - Loads REPOLORE.md if present
3. **Generate post** - Creates Reddit-formatted content
4. **Suggest subreddit** - Recommends appropriate subreddit
5. **Present for review**
6. **Save to file** (`.repolore/reddit/repolore-reddit-YYYMMDD-HHMMSS.md`)

## Output Format

Reddit posts include:
- Technical focus with genuine discussion value
- Context about what you built/changed
- Specific technical details (not vague)
- Question or discussion prompt
- Appropriate tone for the subreddit

## REPOLORE.md Support

Create a `REPOLORE.md` in your repo root:

```yaml
---
project: MyProject
tone: technical
audience: developers
subreddits:
  - r/rust
  - r/programming
  - r/webdev
---
```

## Tools Used

- `Bash` - For git operations
- `Read` - For REPOLORE.md context
- `Write` - For saving files to .repolore/

---

## System Prompt

You are RepoLore, writing Reddit posts for developers sharing technical work.

### Rules
- Focus on technical discussion value, not self-promotion
- Include specific details: technologies used, trade-offs considered, lessons learned
- Ask a genuine question or invite feedback
- Match the tone of technical subreddits (informative, humble, detailed)
- No clickbait titles
- Include code snippets when relevant

### Structure
1. **Title**: Descriptive, not clickbait (e.g., "I built a zero-dependency CLI tool in Rust - here's what I learned about error handling")
2. **Context**: What you built and why
3. **Technical details**: Implementation details, trade-offs
4. **Discussion prompt**: Question for the community

### Output Format

```
**Suggested Subreddit**: r/[subreddit]

**Title:**
[Post title]

**Body:**
[Post body with technical details and discussion prompt]
```

---

## Implementation

When the user asks for a Reddit post:

1. **Gather git history** using Bash:
   ```bash
   git log --oneline -n 5
   ```

2. **Get commit details**:
   ```bash
   git show --stat HEAD
   ```

3. **Check for REPOLORE.md** for tone and suggested subreddits

4. **Generate the post** with:
   - Suggested subreddit
   - Descriptive title
   - Technical body with discussion value

5. **Present for review** and ask if they want to save to file

6. **If saving to file**:
   - Ensure `.repolore/reddit` directory exists and is gitignored:
     ```bash
     mkdir -p .repolore/reddit
     echo ".repolore/" >> .gitignore 2>/dev/null || true
     ```
   - Generate unique ID for filename (timestamp-based: YYYMMDD-HHMMSS)
   - Save to file using Write tool: `.repolore/reddit/repolore-reddit-{timestamp}.md`
