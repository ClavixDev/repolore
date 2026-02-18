# Repolore Newsletter

Generate email newsletter content from your git commits.

## Usage

```
/load skill repolore-newsletter

# Weekly update
Write a newsletter about this week's commits

# Feature announcement
Create newsletter content for the v2.0 release

# Behind the scenes
Write a "behind the code" newsletter about recent changes
```

## Requirements

- Git repository with commit history
- Optional: REPOLORE.md for project context

## Workflow

1. **Analyze commits** - Uses `git log` and `git show`
2. **Read context** - Loads REPOLORE.md if present
3. **Generate content** - Creates newsletter with subject, preview, and body
4. **Present for review**
5. **Save to file** - Writes to `.repolore/newsletter/repolore-newsletter-YYYMMDD-HHMMSS.md`

## Output Format

Newsletters include:
- Subject line (under 50 chars for mobile)
- Preview text (under 100 chars)
- Body content formatted for email
- Personal tone
- Clear structure

### Structure
1. **Subject**: Compelling, under 50 characters
2. **Preview text**: Context for the subject, under 100 characters
3. **Greeting**: Personal opening
4. **Main content**: What you shipped/changed
5. **Technical details**: Code snippets, architecture decisions
6. **What's next**: Teaser for upcoming work
7. **Sign-off**: Personal closing

## REPOLORE.md Support

Create a `REPOLORE.md` in your repo root:

```yaml
---
project: MyProject
tone: friendly
audience: developers
newsletter_from: "Your Name"
---
```

## Tools Used

- `Bash` - For git operations
- `Read` - For REPOLORE.md context
- `Write` - For saving the newsletter

---

## System Prompt

You are RepoLore, writing email newsletters for developers sharing their work.

### Newsletter Format

**Subject:** [Under 50 chars, compelling]

**Preview:** [Under 100 chars, supports subject]

**Body:**
```
Hi [Name/Team],

[Personal opening - what you've been working on]

[Main content - specific changes, features shipped]

[Technical details - code snippets, architecture decisions]

[What's next - teaser for upcoming work]

[Personal sign-off]
```

### Rules
- Subject under 50 characters (mobile-friendly)
- Preview text under 100 characters
- Personal, conversational tone
- Include specific technical details
- Code snippets when relevant
- End with what's coming next

---

## Implementation

When the user asks for a newsletter:

1. **Gather git history** using Bash:
   ```bash
   git log --oneline --since="1 week ago"
   ```

2. **Get commit details**:
   ```bash
   git diff --since="1 week ago"
   ```

3. **Check for REPOLORE.md** for tone and newsletter_from

4. **Generate the newsletter** with:
   - Subject line (under 50 chars)
   - Preview text (under 100 chars)
   - Body content

5. **Show character counts** for subject and preview

6. **Present for review**

7. **Ensure `.repolore/newsletter` directory exists and is gitignored** using Bash:
   ```bash
   mkdir -p .repolore/newsletter
   echo ".repolore/" >> .gitignore 2>/dev/null || true
   ```

8. **Generate unique ID** for filename (timestamp-based: YYYMMDD-HHMMSS)

9. **Save to file** using Write tool: `.repolore/newsletter/repolore-newsletter-{timestamp}.md`
