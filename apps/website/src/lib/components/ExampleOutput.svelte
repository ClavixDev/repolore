<script lang="ts">
  import { fly } from 'svelte/transition';

  const commitInput = `commit e66885f
Author: repolore <noreply@repolore.com>
Date:   Thu Feb 19 09:22:05 2026 +0100

Rewrite all skills to follow Agent Skills spec
and add using-repolore parent skill

 skills/repolore-blog/SKILL.md       | 175 ++++---
 skills/repolore-changelog/SKILL.md  | 162 +++---
 skills/repolore-devto/SKILL.md      | 165 +++---
 skills/repolore-linkedin/SKILL.md   | 140 +++--
 skills/repolore-newsletter/SKILL.md | 150 +++--
 skills/repolore-reddit/SKILL.md     | 139 +++--
 skills/repolore-x/SKILL.md          | 140 +++--
 skills/using-repolore/SKILL.md      | 129 +++++
 10 files changed, 377 insertions(+), 1005 deletions(-)`;

  const blogOutput = `---
title: "Why I Rewrote 8 Agentic Skills From Scratch"
description: "How adding a parent skill and removing
  1,005 lines of duplication made Repolore actually
  maintainable."
date: "2026-02-19"
tags: [agentic-skills, refactoring, claude-code]
---

Every skill had its own copy of the voice rules. Eight
files, eight copies of the same banned-words list, eight
slightly different versions of the file-saving logic.
Changing the tone mapping meant editing eight files and
hoping I didn't miss one.

The fix was a parent skill called \`using-repolore\`. It
owns voice enforcement, anti-AI-slop guardrails, git
analysis patterns, and file conventions. The content
skills reference it instead of reimplementing it.

## What Got Cut

The old skills carried a full System Prompt section with
persona framing ("You are RepoLore, an expert..."). The
Agent Skills spec doesn't need that — the YAML frontmatter
handles identity. Removing it from all 8 skills dropped
1,005 lines without losing any behavior.

The \`allowed-tools\` frontmatter replaced the old "Tools
Used" sections. Instead of documenting that a skill uses
\`git log\`, the frontmatter declares \`Bash(git:*)\` and
the agent runtime enforces it.`;
</script>

<section class="py-32 bg-bg-void relative">
  <div class="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-neon-green/50 to-transparent"></div>

  <div class="max-w-7xl mx-auto px-6">
    <div class="text-center mb-16">
      <div class="inline-block px-4 py-1 border border-neon-magenta/30 text-neon-magenta font-mono text-sm mb-6">
        // EXAMPLE_OUTPUT
      </div>
      <h2 class="flex flex-col items-center gap-1 text-xl sm:text-3xl md:text-4xl font-black font-display uppercase tracking-wider mb-4">
        <span class="text-fg-primary">FROM_COMMITS</span>
        <span class="text-neon-magenta text-glow">TO_CONTENT</span>
      </h2>
      <p class="text-xl text-fg-muted max-w-2xl mx-auto font-mono">
        > Real output from running <code class="text-neon-green">repolore-blog</code> against this repo<span class="text-neon-magenta cursor-blink"></span>
      </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6" in:fly={{ y: 20, duration: 500 }}>
      <!-- Input: Git Commit -->
      <div class="relative group">
        <div class="absolute -top-3 left-4 px-2 bg-bg-void font-mono text-xs text-neon-cyan uppercase tracking-wider z-10">
          // Input: git log
        </div>
        <div class="bg-bg-card border border-neon-cyan/30 p-6 h-full relative overflow-hidden">
          <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-neon-cyan/60"></div>
          <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-cyan/60"></div>
          <div class="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-neon-cyan/60"></div>
          <div class="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-neon-cyan/60"></div>

          <pre class="font-mono text-xs sm:text-sm text-fg-muted whitespace-pre-wrap leading-relaxed"><span class="text-neon-cyan">$</span> <span class="text-fg-primary">git log --stat -1</span>

<span class="text-neon-green">{commitInput}</span></pre>
        </div>
      </div>

      <!-- Output: Blog Post -->
      <div class="relative group">
        <div class="absolute -top-3 left-4 px-2 bg-bg-void font-mono text-xs text-neon-green uppercase tracking-wider z-10">
          // Output: repolore-blog
        </div>
        <div class="bg-bg-card border border-neon-green/30 p-6 h-full relative overflow-hidden">
          <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-neon-green/60"></div>
          <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-green/60"></div>
          <div class="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-neon-green/60"></div>
          <div class="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-neon-green/60"></div>

          <pre class="font-mono text-xs sm:text-sm text-fg-muted whitespace-pre-wrap leading-relaxed"><span class="text-neon-green">{blogOutput}</span></pre>
        </div>
      </div>
    </div>

    <div class="mt-8 text-center font-mono text-sm text-fg-muted" in:fly={{ y: 20, duration: 500, delay: 100 }}>
      <span class="text-neon-magenta">▸</span> Content follows voice rules from <code class="text-neon-cyan">REPOLORE.md</code> — no hype words, no AI tells, real code references
    </div>
  </div>
</section>
