<script lang="ts">
  import { fly } from 'svelte/transition';

  const skills = [
    { name: 'repolore-blog', description: 'Long-form technical blog posts (800-1500 words)', color: 'neon-green' },
    { name: 'repolore-x', description: 'X/Twitter posts & threads', color: 'neon-magenta' },
    { name: 'repolore-linkedin', description: 'Professional LinkedIn posts', color: 'neon-cyan' },
    { name: 'repolore-reddit', description: 'Discussion-focused Reddit posts', color: 'neon-green' },
    { name: 'repolore-changelog', description: 'Keep a Changelog format entries', color: 'neon-magenta' },
    { name: 'repolore-devto', description: 'dev.to articles with frontmatter', color: 'neon-cyan' },
    { name: 'repolore-newsletter', description: 'Email newsletters with subject/preview', color: 'neon-green' }
  ];

  const installMethods = [
    {
      title: 'Claude Code (Default)',
      description: 'Skills install to ~/.claude/skills/ by default',
      code: 'curl -fsSL repolore.com/install | bash'
    },
    {
      title: 'Custom Directory',
      description: 'Use --dir flag for generic agents',
      code: 'curl -fsSL repolore.com/install | bash -s -- --dir ~/.config/agents/skills'
    }
  ];

  let copiedId = $state<string | null>(null);

  async function copyToClipboard(text: string, id: string) {
    try {
      await navigator.clipboard.writeText(text);
      copiedId = id;
      setTimeout(() => copiedId = null, 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  }
</script>

<section id="install" class="py-32 bg-bg-void relative">
  <!-- Decorative line -->
  <div class="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-neon-cyan/50 to-transparent"></div>

  <div class="max-w-5xl mx-auto px-6">
    <div class="text-center mb-16">
      <div class="inline-block px-4 py-1 border border-neon-green/30 text-neon-green font-mono text-sm mb-6">
        // INSTALLATION
      </div>
      <h2 class="flex flex-col sm:flex-row sm:items-center sm:justify-center gap-1 sm:gap-2 text-xl sm:text-3xl md:text-4xl font-black font-display uppercase tracking-wider mb-4">
        <span class="text-fg-primary">GET_STARTED_IN</span>
        <span class="text-neon-cyan text-glow">SECONDS</span>
      </h2>
      <p class="text-xl text-fg-muted max-w-2xl mx-auto font-mono">
        > One command to install. No dependencies, no configuration files.<span class="text-neon-cyan cursor-blink"></span>
      </p>
    </div>

    <!-- Quick Start -->
    <div class="mb-16" in:fly={{ y: 20, duration: 500 }}>
      <div class="bg-bg-card border border-neon-green/30 p-8 relative overflow-hidden">
        <!-- Corner accents -->
        <div class="absolute top-0 left-0 w-6 h-6 border-t-2 border-l-2 border-neon-green/60"></div>
        <div class="absolute top-0 right-0 w-6 h-6 border-t-2 border-r-2 border-neon-green/60"></div>
        <div class="absolute bottom-0 left-0 w-6 h-6 border-b-2 border-l-2 border-neon-green/60"></div>
        <div class="absolute bottom-0 right-0 w-6 h-6 border-b-2 border-r-2 border-neon-green/60"></div>

        <div class="font-mono text-sm text-fg-muted mb-4">$ Quick Start</div>
        <div class="relative group">
          <div class="bg-bg-void p-4 pr-12 font-mono text-sm overflow-x-auto">
            <span class="text-neon-magenta">curl</span> <span class="text-neon-cyan">-fsSL</span> <span class="text-neon-green">repolore.com/install</span> <span class="text-fg-primary">|</span> <span class="text-fg-muted">bash</span>
          </div>
          <button
            onclick={() => copyToClipboard('curl -fsSL repolore.com/install | bash', 'quickstart')}
            class="absolute right-2 top-1/2 -translate-y-1/2 p-2 bg-bg-card border border-neon-green/30 text-neon-green hover:border-neon-green hover:bg-neon-green/10 transition-all opacity-100 sm:opacity-0 sm:group-hover:opacity-100 focus:opacity-100"
            aria-label="Copy command"
          >
            {#if copiedId === 'quickstart'}
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            {:else}
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            {/if}
          </button>
        </div>

        <div class="mt-6 font-mono text-sm text-fg-muted mb-4">Then load a skill:</div>
        <div class="relative group">
          <div class="bg-bg-void p-4 pr-12 font-mono text-sm">
            <span class="text-neon-cyan">/load</span> <span class="text-fg-primary">skill</span> <span class="text-neon-green">repolore-blog</span>
          </div>
          <button
            onclick={() => copyToClipboard('/load skill repolore-blog', 'loadskill')}
            class="absolute right-2 top-1/2 -translate-y-1/2 p-2 bg-bg-card border border-neon-green/30 text-neon-green hover:border-neon-green hover:bg-neon-green/10 transition-all opacity-100 sm:opacity-0 sm:group-hover:opacity-100 focus:opacity-100"
            aria-label="Copy command"
          >
            {#if copiedId === 'loadskill'}
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            {:else}
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            {/if}
          </button>
        </div>
      </div>
    </div>

    <!-- Available Skills -->
    <div class="mb-16">
      <div class="flex flex-wrap items-center gap-x-4 gap-y-2 mb-8">
        <div class="h-px flex-1 min-w-[20px] bg-gradient-to-r from-transparent via-neon-magenta/30 to-transparent"></div>
        <h3 class="text-lg font-mono text-neon-magenta uppercase tracking-wider whitespace-nowrap">// Available_Skills</h3>
        <div class="h-px flex-1 min-w-[20px] bg-gradient-to-r from-transparent via-neon-magenta/30 to-transparent"></div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        {#each skills as skill, i}
          <div
            class="flex items-start gap-4 p-4 bg-bg-card border border-{skill.color}/20 hover:border-{skill.color}/60 transition-all duration-200 group"
            in:fly={{ y: 20, duration: 500, delay: i * 50 }}
          >
            <span class="text-{skill.color} font-mono text-glow">▸</span>
            <div>
              <code class="text-sm font-mono text-{skill.color}">{skill.name}</code>
              <p class="text-sm font-mono text-fg-muted mt-1">> {skill.description}</p>
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- Installation Methods -->
    <div>
      <div class="flex flex-wrap items-center gap-x-4 gap-y-2 mb-8">
        <div class="h-px flex-1 min-w-[20px] bg-gradient-to-r from-transparent via-neon-cyan/30 to-transparent"></div>
        <h3 class="text-lg font-mono text-neon-cyan uppercase tracking-wider whitespace-nowrap">// Installation_Methods</h3>
        <div class="h-px flex-1 min-w-[20px] bg-gradient-to-r from-transparent via-neon-cyan/30 to-transparent"></div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        {#each installMethods as method, i}
          <div
            class="p-6 bg-bg-card border border-neon-cyan/20 hover:border-neon-cyan/60 transition-all duration-200 group relative"
            in:fly={{ y: 20, duration: 500, delay: i * 100 }}
          >
            <!-- Corner accent -->
            <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-cyan/0 group-hover:border-neon-cyan/60 transition-colors"></div>

            <h4 class="text-base font-bold font-display uppercase tracking-wider mb-2 text-fg-primary group-hover:text-neon-cyan transition-colors">
              {method.title}
            </h4>
            <p class="text-sm font-mono text-fg-muted mb-4">> {method.description}</p>
            <div class="relative group/code">
              <div class="bg-bg-void p-3 pr-12 font-mono text-xs overflow-x-auto">
                <span class="text-fg-muted">{method.code}</span>
              </div>
              <button
                onclick={() => copyToClipboard(method.code, `method-${i}`)}
                class="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 bg-bg-card border border-neon-cyan/30 text-neon-cyan hover:border-neon-cyan hover:bg-neon-cyan/10 transition-all opacity-100 sm:opacity-0 sm:group-hover/code:opacity-100 focus:opacity-100"
                aria-label="Copy command"
              >
                {#if copiedId === `method-${i}`}
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                {:else}
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
                {/if}
              </button>
            </div>
          </div>
        {/each}
      </div>

      <!-- Specific skills note -->
      <div class="mt-6 p-4 bg-bg-card border border-neon-magenta/20 relative group" in:fly={{ y: 20, duration: 500, delay: 200 }}>
        <p class="text-sm font-mono text-fg-muted pr-12">
          <span class="text-neon-magenta">▸</span> Install specific skills:
          <code class="ml-2 text-neon-cyan">curl -fsSL repolore.com/install | bash -s -- blog x linkedin</code>
        </p>
        <button
          onclick={() => copyToClipboard('curl -fsSL repolore.com/install | bash -s -- blog x linkedin', 'specific')}
          class="absolute right-4 top-1/2 -translate-y-1/2 p-2 bg-bg-void border border-neon-magenta/30 text-neon-magenta hover:border-neon-magenta hover:bg-neon-magenta/10 transition-all opacity-100 sm:opacity-0 sm:group-hover:opacity-100 focus:opacity-100"
          aria-label="Copy command"
        >
          {#if copiedId === 'specific'}
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          {:else}
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
          {/if}
        </button>
      </div>
    </div>
  </div>
</section>
