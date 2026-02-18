<script lang="ts">
  import { fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import Features from '$lib/components/Features.svelte';

  let visible = $state(false);

  onMount(() => {
    visible = true;
  });
</script>

<svelte:head>
  <title>RepoLore // Open Source SEO Skills</title>
  <meta name="description" content="Open-source SEO content generation skills for AI agents. Transform PRs and commits into compelling content." />
</svelte:head>

<section class="min-h-screen flex items-center justify-center pt-32 relative overflow-hidden cyber-grid">
  <!-- Neon orbs -->
  <div class="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-neon-green/5 rounded-full blur-[100px]"></div>
  <div class="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-neon-magenta/5 rounded-full blur-[80px]"></div>
  <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-neon-cyan/3 rounded-full blur-[120px]"></div>

  <!-- Corner decorations -->
  <div class="absolute top-0 left-0 w-32 h-32 border-l-2 border-t-2 border-neon-green/30"></div>
  <div class="absolute top-0 right-0 w-32 h-32 border-r-2 border-t-2 border-neon-magenta/30"></div>
  <div class="absolute bottom-0 left-0 w-32 h-32 border-l-2 border-b-2 border-neon-cyan/30"></div>
  <div class="absolute bottom-0 right-0 w-32 h-32 border-r-2 border-b-2 border-neon-green/30"></div>

  <div class="max-w-5xl mx-auto px-6 text-center relative z-10">
    {#if visible}
      <div in:fly={{ y: 30, duration: 800, delay: 0 }}>
        <span class="inline-flex items-center gap-2 px-4 py-2 border border-neon-green/30 text-neon-green text-sm font-mono mb-8 chamfer">
          <span class="w-2 h-2 rounded-full bg-neon-green animate-pulse"></span>
          > OPEN_SOURCE // SEO_SKILLS_V2.0
        </span>
      </div>

      <div in:fly={{ y: 30, duration: 800, delay: 150 }}>
        <h1 class="text-5xl md:text-7xl lg:text-8xl font-black font-display uppercase tracking-widest mb-6 leading-tight">
          <span class="text-fg-primary" data-text="SEO_CONTENT">SEO_CONTENT</span><br>
          <span
            class="text-neon-green text-glow glitch"
            data-text="FOR_AGENTS"
          >
            FOR_AGENTS
          </span>
        </h1>
      </div>

      <div in:fly={{ y: 30, duration: 800, delay: 300 }}>
        <p class="text-xl text-fg-muted max-w-2xl mx-auto mb-10 font-mono">
          <span class="text-neon-cyan">></span> Open-source SEO content generation skills for AI agents. Transform PRs and commits into compelling blog posts, changelogs, and social content.
          <span class="text-neon-green cursor-blink"></span>
        </p>
      </div>

      <div in:fly={{ y: 30, duration: 800, delay: 450 }} class="flex flex-col sm:flex-row gap-4 justify-center">
        <a
          href="https://github.com/ClavixDev/repolore"
          class="px-8 py-4 bg-neon-green text-gray-900 font-bold font-mono uppercase tracking-wider chamfer hover:brightness-110 transition-all hover:scale-105 neon-glow"
        >
          View_on_GitHub
        </a>
        <a
          href="/#features"
          class="px-8 py-4 border-2 border-neon-magenta/50 text-neon-magenta font-mono uppercase tracking-wider chamfer-sm hover:bg-neon-magenta hover:text-void transition-all duration-150"
        >
          View_Features
        </a>
      </div>

      <div in:fly={{ y: 30, duration: 800, delay: 600 }} class="mt-20 flex flex-wrap items-center justify-center gap-8 text-fg-muted text-sm font-mono">
        <span class="flex items-center gap-2">
          <span class="text-neon-green">✓</span>
          100%_OPEN_SOURCE
        </span>
        <span class="flex items-center gap-2">
          <span class="text-neon-green">✓</span>
          FREE_FOREVER
        </span>
        <span class="flex items-center gap-2">
          <span class="text-neon-green">✓</span>
          SELF_HOSTED
        </span>
      </div>
    {/if}
  </div>
</section>

<Features />
