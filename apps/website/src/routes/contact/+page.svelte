<svelte:head>
  <title>CONTACT // REPOLORE</title>
</svelte:head>

<section class="pt-32 pb-24 relative cyber-grid">
  <div class="max-w-2xl mx-auto px-6">
    <div class="text-center mb-12">
      <div class="inline-block px-4 py-1 border border-neon-cyan/30 text-neon-cyan font-mono text-sm mb-6">
        // COMMUNICATION_LINK
      </div>
      <h1 class="text-4xl font-black font-display uppercase tracking-wider mb-4">
        <span class="text-fg-primary">GET_IN</span>
        <span class="text-neon-cyan text-glow">TOUCH</span>
      </h1>
      <p class="text-xl text-fg-muted font-mono">
        > Have questions? We'd love to hear from you<span class="text-neon-green cursor-blink"></span>
      </p>
    </div>

    <!-- Terminal-style form -->
    <div class="bg-bg-card border border-neon-green/30 p-1 chamfer">
      <div class="bg-bg-void px-4 py-2 border-b border-neon-green/20 flex items-center gap-2">
        <span class="w-3 h-3 rounded-full bg-neon-red"></span>
        <span class="w-3 h-3 rounded-full bg-yellow-500"></span>
        <span class="w-3 h-3 rounded-full bg-neon-green"></span>
        <span class="ml-4 text-xs text-fg-muted font-mono">contact_form.sh</span>
      </div>

      <form class="p-6 space-y-6" action="https://formspree.io/f/your-form-id" method="POST">
        <div>
          <label for="name" class="block text-sm font-mono text-neon-cyan mb-2">
            > INPUT_NAME
          </label>
          <input
            type="text"
            id="name"
            name="name"
            required
            class="w-full px-4 py-3 bg-bg-void border border-neon-green/30 text-fg-primary font-mono focus:border-neon-green focus:outline-none focus:neon-glow transition-all chamfer-sm"
            placeholder="your_name"
          />
        </div>

        <div>
          <label for="email" class="block text-sm font-mono text-neon-magenta mb-2">
            > INPUT_EMAIL
          </label>
          <input
            type="email"
            id="email"
            name="email"
            required
            class="w-full px-4 py-3 bg-bg-void border border-neon-magenta/30 text-fg-primary font-mono focus:border-neon-magenta focus:outline-none focus:neon-glow-magenta transition-all chamfer-sm"
            placeholder="your@email.com"
          />
        </div>

        <div>
          <label for="message" class="block text-sm font-mono text-neon-cyan mb-2">
            > INPUT_MESSAGE
          </label>
          <textarea
            id="message"
            name="message"
            rows="5"
            required
            class="w-full px-4 py-3 bg-bg-void border border-neon-green/30 text-fg-primary font-mono focus:border-neon-green focus:outline-none focus:neon-glow transition-all chamfer-sm resize-none"
            placeholder="Type your message here..."
          ></textarea>
        </div>

        <button
          type="submit"
          class="w-full py-4 bg-neon-green text-void font-mono font-bold uppercase tracking-wider chamfer hover:brightness-110 transition-all neon-glow"
        >
          > EXECUTE_SEND
        </button>
      </form>
    </div>
  </div>
</section>
