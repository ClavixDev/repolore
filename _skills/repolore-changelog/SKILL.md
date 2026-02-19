---
name: repolore-changelog
description: Generate Keep a Changelog formatted entries from git commits. Use when the user asks for changelog entries, version release notes, or wants to update CHANGELOG.md based on recent commits.
allowed-tools: Bash(git:*) Read create_file edit_file
---

# Repolore Changelog

Load the `using-repolore` skill first for project context and conventions.

## What This Produces

A changelog entry following [Keep a Changelog](https://keepachangelog.com/) format. Grouped by category, written in imperative mood, with specific references to what actually changed.

## Workflow

1. Load REPOLORE.md for project context
2. Analyze commits with `git log` and `git diff`
3. Check for an existing `CHANGELOG.md` to match its style and version scheme
4. Ask for the version number (or use date-based if no versioning scheme exists)
5. Generate the entry, present for review
6. On approval: append to `CHANGELOG.md` or save to `.repolore/changelog/`

## Entry Format

```markdown
## [VERSION] - YYYY-MM-DD

### Added
- Add support for WebSocket connections in the auth module

### Changed
- Switch token validation from symmetric to asymmetric keys

### Fixed
- Fix race condition in session cleanup on concurrent logouts

### Removed
- Remove deprecated v1 API endpoints

### Deprecated
- Deprecate `legacy_auth()` in favor of `authenticate()`

### Security
- Upgrade bcrypt from 5.0.0 to 5.1.0 to patch CVE-2024-XXXXX
```

## Rules

- Imperative mood: "Add support for..." not "Added support for..."
- Be specific: name functions, endpoints, config options, error codes
- One line per entry, concise but descriptive
- Only include categories that have actual changes — omit empty sections
- Reference PR or commit hash when available
- Do not editorialize. State what changed, not why it's great.
