# Repolore

> Git Commits to Content

Repolore is a collection of [Agentic skills](https://agentskills.io) that transform your git history into blog posts, tweets, LinkedIn updates, changelogs, and more.

## Quick Start

```bash
# Install all Repolore skills
curl -fsSL repolore.com/install | bash

# Or install specific skills
curl -fsSL repolore.com/install | bash -s -- blog x linkedin
```

Then in Claude Code:

```
/load skill repolore-blog
analyze my last 3 commits
```

## Available Skills

| Skill | Description |
|-------|-------------|
| `repolore-blog` | Long-form technical blog posts (800-1500 words) |
| `repolore-x` | X/Twitter posts & threads |
| `repolore-linkedin` | Professional LinkedIn posts |
| `repolore-reddit` | Discussion-focused Reddit posts |
| `repolore-changelog` | Keep a Changelog format entries |
| `repolore-devto` | dev.to articles with frontmatter |
| `repolore-newsletter` | Email newsletters with subject/preview |

## How It Works

1. **Load a skill** - `/load skill repolore-blog`
2. **Point at commits** - "analyze my last 3 commits"
3. **Get content** - Review the outline, approve it, receive your content

## Configuration

Create a `REPOLORE.md` in your repository root for better results:

```yaml
---
project: MyProject
tone: technical_but_accessible
audience: developers
seo_pillars:
  - developer productivity
  - open source tools
---

# Project Context
Brief description of what this project does...

# Key Features
- Feature 1
- Feature 2
```

See [REPOLORE.md.example](REPOLORE.md.example) for the full template.

## Installation Methods

```bash
# All skills
curl -fsSL repolore.com/install | bash

# Specific skills
curl -fsSL repolore.com/install | bash -s -- blog
curl -fsSL repolore.com/install | bash -s -- x
curl -fsSL repolore.com/install | bash -s -- linkedin

# Multiple skills
curl -fsSL repolore.com/install | bash -s -- blog x linkedin
```

## Website

Visit [repolore.com](https://repolore.com) for documentation and examples.

## Contributing

Contributions welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE) file.
