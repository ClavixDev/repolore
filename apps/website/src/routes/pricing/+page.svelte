<script lang="ts">
  import { fly } from 'svelte/transition';

  const plans = [
    {
      name: 'FREE',
      price: '$0',
      description: '> Perfect for side projects',
      features: [
        '3 repositories',
        '100 generations/month',
        'Blog posts & changelogs',
        'Community support'
      ],
      cta: 'INITIALIZE_FREE',
      highlight: false,
      border: 'neon-cyan'
    },
    {
      name: 'HACKER',
      price: '$19',
      description: '> For serious developers',
      features: [
        'Unlimited repositories',
        '1,000 generations/month',
        'All content types',
        'Priority support',
        'Custom AI model',
        'API access'
      ],
      cta: 'START_TRIAL',
      highlight: true,
      border: 'neon-green'
    },
    {
      name: 'TEAM',
      price: '$49',
      description: '> For teams and companies',
      features: [
        'Everything in Hacker',
        'Unlimited generations',
        'Team collaboration',
        'SSO & admin controls',
        'Dedicated support',
        'Custom integrations'
      ],
      cta: 'CONTACT_SALES',
      highlight: false,
      border: 'neon-magenta'
    }
  ];
</script>

<svelte:head>
  <title>PRICING // REPOLORE</title>
</svelte:head>

<section class="pt-32 pb-24 relative cyber-grid">
  <div class="max-w-7xl mx-auto px-6">
    <div class="text-center mb-20">
      <div class="inline-block px-4 py-1 border border-neon-green/30 text-neon-green font-mono text-sm mb-6">
        // PRICING_TIER
      </div>
      <h1 class="text-4xl md:text-5xl font-black font-display uppercase tracking-wider mb-4">
        <span class="text-fg-primary">SIMPLE_TRANSPARENT</span><br>
        <span class="text-neon-magenta text-glow">PRICING</span>
      </h1>
      <p class="text-xl text-fg-muted font-mono">
        > Start free, upgrade when you're ready<span class="text-neon-green cursor-blink"></span>
      </p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
      {#each plans as plan, i}
        <div
          class="relative p-8 bg-bg-void border transition-all duration-200 hover:-translate-y-2 group border-neon-green/20"
          class:border-neon-green={plan.highlight}
          class:neon-glow={plan.highlight && plan.border === 'neon-green'}
          in:fly={{ y: 20, duration: 500, delay: i * 150 }}
        >
          <!-- Corner decorations -->
          <div class="absolute top-0 left-0 w-8 h-8 border-l-2 border-t-2 border-{plan.border}/50"></div>
          <div class="absolute bottom-0 right-0 w-8 h-8 border-r-2 border-b-2 border-{plan.border}/50"></div>

          {#if plan.highlight}
            <span class="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 bg-neon-green text-void text-sm font-mono font-bold chamfer">
              [ MOST_POPULAR ]
            </span>
          {/if}

          <h3 class="text-xl font-bold font-display uppercase tracking-wider mb-2 text-fg-primary">
            {plan.name}
          </h3>
          <div class="flex items-baseline gap-1 mb-2">
            <span class="text-4xl font-black font-display text-neon-green">{plan.price}</span>
            <span class="text-fg-muted font-mono">/mo</span>
          </div>
          <p class="text-fg-muted text-sm mb-6 font-mono">{plan.description}</p>

          <ul class="space-y-3 mb-8">
            {#each plan.features as feature}
              <li class="flex items-center gap-2 text-sm font-mono text-fg-primary">
                <span class="text-neon-green">▸</span>
                {feature}
              </li>
            {/each}
          </ul>

          <a
            href="/login"
            class="block w-full py-3 text-center font-mono uppercase tracking-wider transition-all duration-150 chamfer bg-neon-green text-void hover:brightness-110"
          >
            {plan.cta}
          </a>
        </div>
      {/each}
    </div>
  </div>
</section>
