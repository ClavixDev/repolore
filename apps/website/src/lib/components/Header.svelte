<script lang="ts">
  import { page } from '$app/stores';

  let scrolled = $state(false);
  let mobileMenuOpen = $state(false);

  const navItems = [
    { href: '/', label: 'HOME' },
    { href: '/#features', label: 'FEATURES' },
    { href: '/#examples', label: 'EXAMPLES' },
    { href: '/contact', label: 'COMMUNITY' }
  ];

  $effect(() => {
    const handleScroll = () => {
      scrolled = window.scrollY > 20;
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  });
</script>

<header
  class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b {scrolled ? 'bg-bg-card border-neon-green/30 backdrop-blur-md' : 'bg-void/80 border-transparent'}"
>
  <nav class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
    <!-- Logo -->
    <a href="/" class="text-xl font-bold flex items-center gap-2 font-display tracking-widest">
      <span class="text-neon-green text-glow">◈</span>
      <span class="text-fg-primary">REPOLORE</span>
    </a>

    <!-- Desktop Nav -->
    <div class="hidden md:flex items-center gap-8">
      {#each navItems as item}
        <a
          href={item.href}
          class="text-sm font-mono tracking-wider transition-all duration-150 hover:text-neon-green text-glow"
          class:text-neon-green={$page.url.pathname === item.href}
          class:text-fg-muted={$page.url.pathname !== item.href}
        >
          {item.label}
        </a>
      {/each}
    </div>

    <!-- CTA -->
    <div class="flex items-center gap-4">
      <a
        href="https://github.com/ClavixDev/repolore"
        class="text-sm font-mono text-fg-muted hover:text-neon-cyan transition-colors"
      >
        // GITHUB
      </a>
    </div>
  </nav>
</header>
