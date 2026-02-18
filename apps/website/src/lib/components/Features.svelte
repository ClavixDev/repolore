<script lang="ts">
  import { fly } from 'svelte/transition';

  const features = [
    {
      icon: '▸',
      title: 'BLOG_POSTS',
      description: '> AUTO_GENERATE detailed blog posts from PRs and commits using advanced AI models.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'CHANGELOGS',
      description: '> CREATE beautiful, readable changelogs for every release automatically.',
      color: 'neon-magenta'
    },
    {
      icon: '▸',
      title: 'SOCIAL_CONTENT',
      description: '> TRANSFORM technical updates into engaging tweets and LinkedIn posts.',
      color: 'neon-cyan'
    },
    {
      icon: '▸',
      title: 'GITHUB_INTEGRATION',
      description: '> CONNECT repositories and let AI handle your content pipeline.',
      color: 'neon-green'
    },
    {
      icon: '▸',
      title: 'LIGHTNING_FAST',
      description: '> GENERATE content in seconds, not hours. Focus on coding.',
      color: 'neon-magenta'
    },
    {
      icon: '▸',
      title: 'CUSTOMIZABLE',
      description: '> FINE-TUNE tone, style, and audience for every piece of content.',
      color: 'neon-cyan'
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

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each features as feature, i}
        <div
          class="p-6 bg-bg-void border border-neon-green/20 hover:border-neon-green/60 transition-all duration-200 hover:-translate-y-1 group"
          in:fly={{ y: 20, duration: 500, delay: i * 100 }}
        >
          <!-- Corner accent -->
          <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-neon-green/0 group-hover:border-neon-green/60 transition-colors"></div>

          <div class="flex items-start gap-4">
            <span class="text-{feature.color} text-2xl font-mono text-glow">{feature.icon}</span>
            <div>
              <h3 class="text-lg font-bold font-display uppercase tracking-wider mb-2 text-fg-primary group-hover:text-neon-green transition-colors">
                {feature.title}
              </h3>
              <p class="text-sm font-mono text-fg-muted">
                {feature.description}
              </p>
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>
</section>
