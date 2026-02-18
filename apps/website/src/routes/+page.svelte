<script lang="ts">
  import { fly } from 'svelte/transition';
  import { onMount } from 'svelte';
  import Features from '$lib/components/Features.svelte';

  let visible = $state(false);

  onMount(() => {
    visible = true;
  });

  // Schema.org structured data
  const websiteSchema = {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "RepoLore",
    "url": "https://repolore.dev",
    "description": "Open-source SEO content generation skills for AI agents. Transform git commits into blog posts, changelogs, and social media.",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://repolore.dev/search?q={search_term_string}",
      "query-input": "required name=search_term_string"
    }
  };

  const softwareSchema = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "RepoLore",
    "applicationCategory": "DeveloperApplication",
    "operatingSystem": "Any",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD"
    },
    "description": "Open-source SEO content generation skills for Claude Code. Transform git commits into blog posts, changelogs, and social media content.",
    "url": "https://repolore.dev",
    "codeRepository": "https://github.com/ClavixDev/repolore",
    "programmingLanguage": ["TypeScript", "JavaScript", "Bash"],
    "license": "https://opensource.org/licenses/MIT",
    "featureList": [
      "Generate blog posts from git commits",
      "Create changelogs automatically",
      "Generate social media content for X, LinkedIn, Reddit",
      "Create dev.to articles",
      "Write newsletters",
      "Multi-platform content generation",
      "REPOLORE.md configuration",
      "Self-hosted with no external APIs"
    ],
    "author": {
      "@type": "Organization",
      "name": "ClavixDev"
    }
  };

  const orgSchema = {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "ClavixDev",
    "url": "https://clavix.dev",
    "logo": "https://repolore.dev/logo.png",
    "sameAs": [
      "https://github.com/ClavixDev"
    ]
  };

  // OpenGraph meta tags
  const ogTitle = "RepoLore - Open Source SEO Content Skills";
  const ogDescription = "Transform git commits into blog posts, changelogs, and social media content. 8 agentic skills for Claude Code.";
  const ogImage = "https://repolore.dev/og-image.png";
  const ogUrl = "https://repolore.dev";

  // Twitter Card meta tags
  const twitterCard = "summary_large_image";
  const twitterSite = "@repolore";
  const twitterCreator = "@clavixdev";
</script>

<svelte:head>
  <title>RepoLore // Open Source SEO Skills</title>
  <meta name="description" content="Open-source SEO content generation skills for AI agents. Transform PRs and commits into compelling content." />

  <!-- Canonical URL -->
  <link rel="canonical" href="https://repolore.dev" />

  <!-- OpenGraph -->
  <meta property="og:title" content={ogTitle} />
  <meta property="og:description" content={ogDescription} />
  <meta property="og:image" content={ogImage} />
  <meta property="og:url" content={ogUrl} />
  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="RepoLore" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content={twitterCard} />
  <meta name="twitter:site" content={twitterSite} />
  <meta name="twitter:creator" content={twitterCreator} />
  <meta name="twitter:title" content={ogTitle} />
  <meta name="twitter:description" content={ogDescription} />
  <meta name="twitter:image" content={ogImage} />

  <!-- Schema.org JSON-LD -->
  <script type="application/ld+json">
    {JSON.stringify(websiteSchema)}
  </script>
  <script type="application/ld+json">
    {JSON.stringify(softwareSchema)}
  </script>
  <script type="application/ld+json">
    {JSON.stringify(orgSchema)}
  </script>
</svelte:head>

<section class="min-h-screen flex items-center justify-center pt-32 relative overflow-hidden cyber-grid">
  <!-- Neon orbs -->
  <div class="absolute top-1/4 left-1/4 w-[200px] sm:w-[300px] md:w-[400px] lg:w-[500px] h-[200px] sm:h-[300px] md:h-[400px] lg:h-[500px] bg-neon-green/5 rounded-full blur-[100px]"></div>
  <div class="absolute bottom-1/4 right-1/4 w-[150px] sm:w-[300px] md:w-[400px] h-[150px] sm:h-[300px] md:h-[400px] bg-neon-magenta/5 rounded-full blur-[80px]"></div>
  <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[300px] sm:w-[500px] md:w-[800px] h-[300px] sm:h-[500px] md:h-[800px] bg-neon-cyan/3 rounded-full blur-[120px]"></div>

  <!-- Corner decorations -->
  <div class="absolute top-0 left-0 w-16 sm:w-32 h-16 sm:h-32 border-l-2 border-t-2 border-neon-green/30"></div>
  <div class="absolute top-0 right-0 w-16 sm:w-32 h-16 sm:h-32 border-r-2 border-t-2 border-neon-magenta/30"></div>
  <div class="absolute bottom-0 left-0 w-16 sm:w-32 h-16 sm:h-32 border-l-2 border-b-2 border-neon-cyan/30"></div>
  <div class="absolute bottom-0 right-0 w-16 sm:w-32 h-16 sm:h-32 border-r-2 border-b-2 border-neon-green/30"></div>

  <div class="max-w-5xl mx-auto px-6 text-center relative z-10">
    {#if visible}
      <div in:fly={{ y: 30, duration: 800, delay: 0 }}>
        <span class="inline-flex items-center gap-2 px-4 py-2 border border-neon-green/30 text-neon-green text-sm font-mono mb-8 chamfer">
          <span class="w-2 h-2 rounded-full bg-neon-green animate-pulse"></span>
          > OPEN_SOURCE // SEO_SKILLS_V2.0
        </span>
      </div>

      <div in:fly={{ y: 30, duration: 800, delay: 150 }}>
        <h1 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black font-display uppercase tracking-widest mb-6 leading-tight">
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
