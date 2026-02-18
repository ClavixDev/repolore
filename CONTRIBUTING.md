# Contributing to Repolore

Thanks for your interest in contributing! Repolore is a collection of Claude Code skills that help developers create content from their git commits.

## How to Contribute

### Reporting Issues

- Use the [issue tracker](https://github.com/yourusername/repolore/issues)
- Check if the issue already exists before creating a new one
- Provide clear reproduction steps
- Include your OS and Claude Code version

### Suggesting Features

- Open an issue with the "feature request" label
- Describe the use case and expected behavior
- Explain why this would be valuable to users

### Contributing Skills

New skills should follow these guidelines:

1. **Single-purpose** - Each skill should do one thing well
2. **No dependencies** - Skills should be self-contained
3. **Clear documentation** - Include usage examples in SKILL.md
4. **REPOLORE.md support** - Read project context if available

#### Skill Structure

```
skills/repolore-myfeature/
└── SKILL.md
```

#### SKILL.md Template

```markdown
# Repolore MyFeature

Brief description of what this skill does.

## Usage

\`\`\`
/load skill repolore-myfeature
[example command]
\`\`\`

## Requirements

- List any prerequisites

## Workflow

1. Step one
2. Step two
3. Step three

## Output Format

Describe what the skill generates.

## Tools Used

- `Bash` - For git operations
- `Read` - For REPOLORE.md context
- `Write` - For saving output

---

## System Prompt

[The system prompt used for content generation]

---

## Implementation

[Detailed workflow for how the skill operates]
```

### Improving Existing Skills

1. Fork the repository
2. Make your changes to the relevant SKILL.md
3. Test the skill in Claude Code
4. Submit a pull request with a clear description

### Website Contributions

The website is in `apps/website/` and built with SvelteKit:

```bash
cd apps/website
npm install
npm run dev
```

### Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs where appropriate

## Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/repolore.git
cd repolore

# Skills are just markdown files - no build needed!
# To work on the website:
cd apps/website
npm install
npm run dev
```

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on what's best for the community

## Questions?

Open an issue or start a discussion. We're happy to help!
