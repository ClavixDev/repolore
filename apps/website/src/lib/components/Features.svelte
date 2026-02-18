<script lang="ts">
  import { fly } from 'svelte/transition';

  const contentSkills = [
    {
      icon: '▸',
      title: 'BLOG_POSTS',
      description: '> Long-form technical posts (800-1500 words) with SEO optimization and code examples from your actual commits.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'CHANGELOGS',
      description: '> Keep a Changelog format with Added/Changed/Fixed/Deprecated categories.',
      color: 'neon-magenta'
    },
    {
      icon: '▸',
      title: 'X_POSTS',
      description: '> Twitter threads and single tweets optimized for 280 characters with hashtags.',
      color: 'neon-cyan'
    },
    {
      icon: '▸',
      title: 'LINKEDIN_POSTS',
      description: '> Professional network updates (1000-1300 chars) that engage your developer network.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'REDDIT_POSTS',
      description: '> Discussion-focused content with subreddit suggestions for maximum engagement.',
      color: 'neon-magenta'
    },
    {
      icon: '▸',
      title: 'DEVTO_ARTICLES',
      description: '> Dev.to optimized posts with YAML frontmatter and proper tagging.',
      color: 'neon-cyan'
    },
    {
      icon: '▸',
      title: 'NEWSLETTERS',
      description: '> Email-ready content with subject line, preview text, and body structure.',
      color: 'neon-green'
    }
  ];

  const platformFeatures = [
    {
      icon: '▸',
      title: 'MULTI_PLATFORM',
      description: '> Generate content for 7 platforms from a single git analysis.',
      color: 'neon-magenta'
    },
    {
      icon: '▸',
      title: 'GIT_INTEGRATION',
      description: '> Deep analysis of git log, diff, and commit history for accurate context.',
      color: 'neon-cyan'
    },
    {
      icon: '▸',
      title: 'PROJECT_CONTEXT',
      description: '> REPOLORE.md configuration for consistent tone, audience, and brand voice.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'ONE_COMMAND',
      description: '> Curl install for instant setup. No dependencies, no configuration files.',
      color: 'neon-magenta'
    }
  ];

  const technicalFeatures = [
    {
      icon: '▸',
      title: 'OPEN_SOURCE',
      description: '> 100% free and open source under MIT license. Community driven.',
      color: 'neon-cyan'
    },
    {
      icon: '▸',
      title: 'AGENTIC_SKILLS',
      description: '> Native Claude Code integration with structured skill definitions.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'SELF_HOSTED',
      description: '> Your data stays local. No external APIs or cloud dependencies.',
      color: 'neon-magenta'
    }
  ];
</script>

<section id="features" class="py-32 bg-bg-card relative cyber-grid">
  <!-- Decorative line -->
  <div class="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-neon-magenta/50 to-transparent"></div>

  <div class="max-w-7xl mx-auto px-6">
    <div class="text-center mb-20">
      <div class="inline-block px-4 py-1 border border-neon-cyan/30 text-neon-cyan font-mono text-sm mb-6">
        // SYSTEM_CAPABILITIES
      </div>
      <h2 class="text-4xl md:text-5xl font-black font-display uppercase tracking-wider mb-4">
        <span class="text-fg-primary">EVERYTHING_YOU_NEED_TO</span><br>
        <span class="text-neon-green text-glow">SCALE_YOUR_CONTENT</span>
      </h2>
      <p class="text-xl text-fg-muted max-w-2xl mx-auto font-mono">
        > Powerful features to automate your developer content workflow<span class="text-neon-green cursor-blink"></span>
      </p>
    </div>

    <!-- Content Skills Section -->
    <div class="mb-16">
      <div class="flex items-center gap-4 mb-8">
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-green/30 to-transparent"></div>
        <h3 class="text-lg font-mono text-neon-green uppercase tracking-wider">// Content_Skills</h3>
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-green/30 to-transparent"></div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {#each contentSkills as feature, i}
          <div
            class="p-6 bg-bg-void border border-neon-green/20 hover:border-neon-green/60 transition-all duration-200 hover:-translate-y-1 group relative"
            in:fly={{ y: 20, duration: 500, delay: i * 50 }}
          >
            <!-- Corner accent -->
            <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-green/0 group-hover:border-neon-green/60 transition-colors"></div>

            <div class="flex items-start gap-4">
              <span class="text-{feature.color} text-2xl font-mono text-glow">{feature.icon}</span>
              <div>
                <h4 class="text-base font-bold font-display uppercase tracking-wider mb-2 text-fg-primary group-hover:text-neon-green transition-colors">
                  {feature.title}
                </h4>
                <p class="text-sm font-mono text-fg-muted">
                  {feature.description}
                </p>
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- Platform & Workflow Section -->
    <div class="mb-16">
      <div class="flex items-center gap-4 mb-8">
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-magenta/30 to-transparent"></div>
        <h3 class="text-lg font-mono text-neon-magenta uppercase tracking-wider">// Platform_&_Workflow</h3>
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-magenta/30 to-transparent"></div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        {#each platformFeatures as feature, i}
          <div
            class="p-6 bg-bg-void border border-neon-magenta/20 hover:border-neon-magenta/60 transition-all duration-200 hover:-translate-y-1 group relative"
            in:fly={{ y: 20, duration: 500, delay: i * 100 }}
          >
            <!-- Corner accent -->
            <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-magenta/0 group-hover:border-neon-magenta/60 transition-colors"></div>

            <div class="flex items-start gap-4">
              <span class="text-{feature.color} text-2xl font-mono text-glow">{feature.icon}</span>
              <div>
                <h4 class="text-base font-bold font-display uppercase tracking-wider mb-2 text-fg-primary group-hover:text-neon-magenta transition-colors">
                  {feature.title}
                </h4>
                <p class="text-sm font-mono text-fg-muted">
                  {feature.description}
                </p>
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>

    <!-- Technical Section -->
    <div>
      <div class="flex items-center gap-4 mb-8">
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-cyan/30 to-transparent"></div>
        <h3 class="text-lg font-mono text-neon-cyan uppercase tracking-wider">// Technical</h3>
        <div class="h-px flex-1 bg-gradient-to-r from-transparent via-neon-cyan/30 to-transparent"></div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        {#each technicalFeatures as feature, i}
          <div
            class="p-6 bg-bg-void border border-neon-cyan/20 hover:border-neon-cyan/60 transition-all duration-200 hover:-translate-y-1 group relative"
            in:fly={{ y: 20, duration: 500, delay: i * 100 }}
          >
            <!-- Corner accent -->
            <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-cyan/0 group-hover:border-neon-cyan/60 transition-colors"></div>

            <div class="flex items-start gap-4">
              <span class="text-{feature.color} text-2xl font-mono text-glow">{feature.icon}</span>
              <div>
                <h4 class="text-base font-bold font-display uppercase tracking-wider mb-2 text-fg-primary group-hover:text-neon-cyan transition-colors">
                  {feature.title}
                </h4>
                <p class="text-sm font-mono text-fg-muted">
                  {feature.description}
                </p>
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </div>
</section>
