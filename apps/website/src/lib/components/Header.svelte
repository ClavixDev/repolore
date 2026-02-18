<script lang="ts">
  import { page } from '$app/stores';

  let scrolled = $state(false);
  let mobileMenuOpen = $state(false);

  const navItems = [
    { href: '/', label: 'HOME' },
    { href: '/#features', label: 'FEATURES' },
    { href: '/pricing', label: 'PRICING' },
    { href: '/contact', label: 'CONTACT' }
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
  class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b"
  class:bg-bg-card={scrolled}
  class:bg-void/80={!scrolled}
  class:border-neon-green/30={scrolled}
  class:border-transparent={!scrolled}
  class:backdrop-blur-md={scrolled}
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
        href="/login"
        class="text-sm font-mono text-fg-muted hover:text-neon-cyan transition-colors"
      >
        // LOGIN
      </a>
      <a
        href="/pricing"
        class="px-4 py-2 border-2 border-neon-green text-neon-green font-mono text-sm uppercase tracking-wider chamfer-sm hover:bg-neon-green hover:text-void transition-all duration-150 neon-glow"
      >
        Get Started
      </a>
    </div>
  </nav>
</header>
