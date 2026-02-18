<script lang="ts">
  const links = {
    product: [
      { href: '/#features', label: '// FEATURES' }
    ],
    community: [
      { href: '/contact', label: '// COMMUNITY' },
      { href: 'https://github.com/ClavixDev/repolore', label: '> GITHUB' },
      { href: 'https://github.com/ClavixDev/repolore/discussions', label: '> DISCUSSIONS' }
    ],
    legal: [
      { href: '/privacy', label: '// PRIVACY' },
      { href: '/terms', label: '// TERMS' }
    ]
  };
</script>

<footer class="border-t-2 border-neon-green/20 bg-bg-card">
  <div class="max-w-7xl mx-auto px-6 py-12">
    <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
      <div>
        <div class="flex items-center gap-2 mb-4">
          <span class="text-neon-green text-xl text-glow">◈</span>
          <span class="font-display font-bold tracking-widest text-fg-primary">REPOLORE</span>
        </div>
        <p class="text-sm text-fg-muted font-mono">
          > TRANSFORM_YOUR_CODE_INTO_STORIES
        </p>
        <div class="mt-4 text-xs text-neon-green font-mono">
          v2.0.0_BUILD_20240218
        </div>
      </div>

      {#each Object.entries(links) as [category, items]}
        <div>
          <h4 class="font-mono font-bold text-neon-cyan text-sm tracking-wider mb-4 uppercase">
            [{category}]
          </h4>
          <ul class="space-y-2">
            {#each items as link}
              <li>
                <a
                  href={link.href}
                  class="text-sm font-mono text-fg-muted hover:text-neon-green transition-colors"
                >
                  {link.label}
                </a>
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>

    <div class="border-t border-neon-green/20 mt-12 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
      <p class="text-sm text-fg-muted font-mono">
        © 2024 REPOLORE // ALL_RIGHTS_RESERVED
      </p>
      <div class="text-xs font-mono text-fg-muted">
        <span class="text-neon-green">●</span> SYSTEM_ONLINE
      </div>
    </div>
  </div>
</footer>
