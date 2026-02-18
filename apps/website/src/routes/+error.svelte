<script lang="ts">
  import { page } from '$app/stores';
</script>

<svelte:head>
  <title>ERROR_404 // PAGE_NOT_FOUND</title>
</svelte:head>

<section class="min-h-[70vh] flex items-center justify-center relative cyber-grid">
  <!-- Glitchy 404 -->
  <div class="text-center relative">
    <div class="absolute inset-0 bg-neon-green/5 blur-[100px]"></div>

    <h1 class="text-8xl md:text-9xl font-black font-display uppercase tracking-widest text-neon-green text-glow glitch" data-text="404">
      404
    </h1>

    <div class="mt-4 mb-8 font-mono">
      <p class="text-xl text-fg-primary">
        > <span class="text-neon-red">ERROR</span>: PAGE_NOT_FOUND
      </p>
      <p class="text-fg-muted mt-2">
        The requested resource does not exist in this system.
      </p>
    </div>

    <a
      href="/"
      class="inline-flex items-center gap-2 px-6 py-3 bg-neon-green text-void font-mono font-bold uppercase tracking-wider chamfer hover:brightness-110 transition-all neon-glow"
    >
      > RETURN_HOME
    </a>
  </div>
</section>
