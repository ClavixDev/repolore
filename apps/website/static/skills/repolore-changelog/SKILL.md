# Repolore Changelog

Generate Keep a Changelog formatted entries from your git commits.

## Usage

```
/load skill repolore-changelog

# Generate for recent commits
Write a changelog entry for my last 5 commits

# Generate for a version
Create changelog entry for v1.2.0

# Preview before release
What would the changelog look like for changes since v1.0?
```

## Requirements

- Git repository with commit history
- Optional: REPOLORE.md for project context

## Workflow

1. **Analyze commits** - Uses `git log` and `git diff`
2. **Categorize changes** - Groups into Added/Changed/Fixed/Removed/Deprecated/Security
3. **Generate entry** - Creates Keep a Changelog format
4. **Present for review**
5. **Append to CHANGELOG.md** or save to file

## Output Format

Follows [Keep a Changelog](https://keepachangelog.com/) convention:

```markdown
## [1.2.0] - 2024-01-15

### Added
- New feature descriptions

### Changed
- Change descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions

### Deprecated
- Deprecated feature descriptions

### Security
- Security-related changes
```

### Rules
- Use imperative mood ("Add support for..." not "Added support for...")
- Be specific: include function names, API endpoints, config options
- Each entry is one line, concise but descriptive
- Group by category (Added/Changed/Fixed/Removed/Deprecated/Security)
- Reference PR/commit if available
- Omit empty sections

## REPOLORE.md Support

Create a `REPOLORE.md` in your repo root:

```yaml
---
project: MyProject
---
```

## Tools Used

- `Bash` - For git operations
- `Read` - For existing CHANGELOG.md and REPOLORE.md
- `Write` - For appending to CHANGELOG.md

---

## System Prompt

You are RepoLore, writing changelog entries for developer tools.

### Format (Keep Changelog convention)
```
## [VERSION] - YYYY-MM-DD

### Added
- New feature descriptions

### Changed
- Change descriptions

### Fixed
- Bug fix descriptions

### Removed
- Removed feature descriptions

### Deprecated
- Deprecated feature descriptions

### Security
- Security-related changes
```

### Rules
- Use imperative mood ("Add support for..." not "Added support for...")
- Be specific: include function names, API endpoints, config options
- Each entry is one line, concise but descriptive
- Group by category (Added/Changed/Fixed/Removed/Deprecated/Security)
- Reference PR/commit if available
- Omit empty sections
- Only include categories that have actual changes

---

## Implementation

When the user asks for a changelog entry:

1. **Gather git history** using Bash:
   ```bash
   git log --oneline -n 10
   ```

2. **Get the diff** for the relevant commits:
   ```bash
   git diff HEAD~5 HEAD
   ```

3. **Check for existing CHANGELOG.md** to understand format

4. **Ask for version number** (or use date-based version)

5. **Generate the changelog entry** following Keep a Changelog format

6. **Present for review**

7. **Ask user**:
   - Append to CHANGELOG.md
   - Save to new file
   - Copy to clipboard

8. **If appending**, read existing CHANGELOG.md first, then write updated version
