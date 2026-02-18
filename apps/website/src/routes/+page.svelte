<script>
  const skills = [
    { name: 'repolore-blog', desc: 'Long-form blog posts', icon: '📝' },
    { name: 'repolore-x', desc: 'X/Twitter posts & threads', icon: '🐦' },
    { name: 'repolore-linkedin', desc: 'Professional LinkedIn posts', icon: '💼' },
    { name: 'repolore-reddit', desc: 'Discussion-focused posts', icon: '🔴' },
    { name: 'repolore-changelog', desc: 'Keep a Changelog entries', icon: '📋' },
    { name: 'repolore-devto', desc: 'dev.to articles', icon: '💻' },
    { name: 'repolore-newsletter', desc: 'Email newsletters', icon: '📧' },
  ];

  let copied = false;

  function copyInstall() {
    navigator.clipboard.writeText('curl -fsSL repolore.com/install | bash');
    copied = true;
    setTimeout(() => copied = false, 2000);
  }
</script>

<!-- Hero Section -->
<section class="relative overflow-hidden bg-slate-900 px-6 py-24 sm:py-32">
  <div class="mx-auto max-w-5xl text-center">
    <div class="mb-8 inline-flex items-center gap-2 rounded-full bg-indigo-500/10 px-4 py-1.5 text-sm font-medium text-indigo-400 ring-1 ring-inset ring-indigo-500/20">
      <span>Claude Code Skills</span>
    </div>

    <h1 class="text-4xl font-bold tracking-tight text-white sm:text-6xl">
      Turn Git Commits into
      <span class="text-indigo-400">Compelling Content</span>
    </h1>

    <p class="mx-auto mt-6 max-w-2xl text-lg leading-8 text-slate-300">
      Repolore is a collection of Claude Code skills that transform your git history
      into blog posts, tweets, LinkedIn updates, changelogs, and more.
    </p>

    <div class="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
      <button
        on:click={copyInstall}
        class="group relative flex w-full max-w-md items-center gap-3 rounded-lg bg-slate-800 px-4 py-3 font-mono text-sm text-slate-300 ring-1 ring-slate-700 transition-all hover:bg-slate-750 hover:ring-slate-600 sm:w-auto"
      >
        <span class="text-indigo-400">$</span>
        <span>curl -fsSL repolore.com/install | bash</span>
        <span class="ml-auto text-xs text-slate-500">
          {copied ? 'Copied!' : 'Click to copy'}
        </span>
      </button>
      <a
        href="https://github.com/yourusername/repolore"
        class="flex items-center gap-2 rounded-lg bg-indigo-600 px-6 py-3 text-sm font-semibold text-white transition-colors hover:bg-indigo-500"
      >
        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path fill-rule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clip-rule="evenodd" />
        </svg>
        View on GitHub
      </a>
    </div>
  </div>

  <!-- Decorative grid -->
  <div class="absolute inset-0 -z-10 h-full w-full bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"></div>
</section>

<!-- How It Works -->
<section class="bg-white px-6 py-24">
  <div class="mx-auto max-w-5xl">
    <div class="text-center">
      <h2 class="text-3xl font-bold tracking-tight text-slate-900">How It Works</h2>
      <p class="mt-4 text-lg text-slate-600">Three simple steps to content from your commits</p>
    </div>

    <div class="mt-16 grid gap-8 sm:grid-cols-3">
      <div class="relative rounded-2xl bg-slate-50 p-8">
        <div class="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-600 text-xl font-bold text-white">1</div>
        <h3 class="text-lg font-semibold text-slate-900">Install the Skill</h3>
        <p class="mt-2 text-slate-600">One command installs any Repolore skill directly into your Claude Code environment.</p>
        <div class="mt-4 rounded-lg bg-slate-900 p-3 font-mono text-xs text-slate-300">
          /load skill repolore-blog
        </div>
      </div>

      <div class="relative rounded-2xl bg-slate-50 p-8">
        <div class="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-600 text-xl font-bold text-white">2</div>
        <h3 class="text-lg font-semibold text-slate-900">Analyze Commits</h3>
        <p class="mt-2 text-slate-600">Point Repolore at your git history. It reads your commits and diffs automatically.</p>
        <div class="mt-4 rounded-lg bg-slate-900 p-3 font-mono text-xs text-slate-300">
          Analyze my last 3 commits
        </div>
      </div>

      <div class="relative rounded-2xl bg-slate-50 p-8">
        <div class="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-600 text-xl font-bold text-white">3</div>
        <h3 class="text-lg font-semibold text-slate-900">Get Content</h3>
        <p class="mt-2 text-slate-600">Review the generated outline, approve it, and get your ready-to-publish content.</p>
        <div class="mt-4 rounded-lg bg-slate-900 p-3 font-mono text-xs text-slate-300">
          Save to blog-post.md
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Skills Grid -->
<section class="bg-slate-50 px-6 py-24">
  <div class="mx-auto max-w-5xl">
    <div class="text-center">
      <h2 class="text-3xl font-bold tracking-tight text-slate-900">Seven Skills, One Goal</h2>
      <p class="mt-4 text-lg text-slate-600">Each skill optimized for a specific content format</p>
    </div>

    <div class="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
      {#each skills as skill}
        <div class="group rounded-xl bg-white p-6 shadow-sm ring-1 ring-slate-200 transition-all hover:shadow-md hover:ring-indigo-200">
          <div class="flex items-center gap-4">
            <span class="text-2xl">{skill.icon}</span>
            <div>
              <h3 class="font-semibold text-slate-900">{skill.name}</h3>
              <p class="text-sm text-slate-600">{skill.desc}</p>
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>
</section>

<!-- Example Output -->
<section class="bg-white px-6 py-24">
  <div class="mx-auto max-w-5xl">
    <div class="text-center">
      <h2 class="text-3xl font-bold tracking-tight text-slate-900">Example Output</h2>
      <p class="mt-4 text-lg text-slate-600">See what Repolore generates from real commits</p>
    </div>

    <div class="mt-12 overflow-hidden rounded-2xl bg-slate-900 shadow-2xl">
      <div class="flex items-center gap-2 border-b border-slate-800 px-4 py-3">
        <div class="h-3 w-3 rounded-full bg-red-500"></div>
        <div class="h-3 w-3 rounded-full bg-yellow-500"></div>
        <div class="h-3 w-3 rounded-full bg-green-500"></div>
        <span class="ml-4 text-xs text-slate-500">blog-post.md</span>
      </div>
      <div class="overflow-x-auto p-6 text-sm">
        <pre class="font-mono leading-relaxed text-slate-300"><span class="text-slate-500">---</span>
<span class="text-purple-400">title</span>: <span class="text-green-400">"Implementing Zero-Downtime Deployments with Docker Compose"</span>
<span class="text-purple-400">description</span>: <span class="text-green-400">"How we eliminated deployment downtime using blue-green deployments with Docker Compose and Traefik"</span>
<span class="text-purple-400">date</span>: <span class="text-green-400">"2024-01-15"</span>
<span class="text-purple-400">tags</span>: [<span class="text-green-400">docker</span>, <span class="text-green-400">devops</span>, <span class="text-green-400">deployment</span>]
<span class="text-slate-500">---</span>

<span class="text-slate-500">## TL;DR</span>

We eliminated deployment downtime by implementing blue-green deployments
with Docker Compose and Traefik. Here's the exact configuration and the
one gotcha that cost us 2 hours.

<span class="text-slate-500">## The Problem</span>

Our users were seeing 502 errors during deployments...

<span class="text-slate-500">[800 more words with code examples, architecture diagrams, and lessons learned]</span></pre>
      </div>
    </div>
  </div>
</section>

<!-- Installation -->
<section class="bg-indigo-600 px-6 py-24">
  <div class="mx-auto max-w-3xl text-center">
    <h2 class="text-3xl font-bold tracking-tight text-white">Ready to Try It?</h2>
    <p class="mt-4 text-lg text-indigo-100">Install Repolore skills with one command</p>

    <div class="mt-10 space-y-4">
      <div class="mx-auto max-w-xl overflow-hidden rounded-xl bg-slate-900 shadow-xl">
        <div class="flex items-center justify-between border-b border-slate-800 px-4 py-2">
          <span class="text-xs font-medium text-slate-400">INSTALL ALL SKILLS</span>
          <button on:click={() => {navigator.clipboard.writeText('curl -fsSL repolore.com/install | bash');}} class="text-xs text-indigo-400 hover:text-indigo-300">Copy</button>
        </div>
        <div class="p-4 font-mono text-sm text-slate-300">
          curl -fsSL repolore.com/install | bash
        </div>
      </div>

      <p class="text-sm text-indigo-200">Or install specific skills:</p>

      <div class="mx-auto max-w-xl overflow-hidden rounded-xl bg-slate-900/50 shadow-xl">
        <div class="p-4 font-mono text-sm text-slate-300">
          curl -fsSL repolore.com/install | bash -s -- blog<br/>
          curl -fsSL repolore.com/install | bash -s -- x linkedin
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Footer -->
<footer class="bg-slate-900 px-6 py-12">
  <div class="mx-auto max-w-5xl">
    <div class="flex flex-col items-center justify-between gap-4 sm:flex-row">
      <div class="flex items-center gap-2">
        <span class="text-xl font-bold text-white">Repolore</span>
        <span class="text-slate-500">|</span>
        <span class="text-slate-400">Git Commits to Content</span>
      </div>
      <div class="flex gap-6">
        <a href="https://github.com/yourusername/repolore" class="text-slate-400 hover:text-white">GitHub</a>
        <a href="/install.sh" class="text-slate-400 hover:text-white">Install Script</a>
      </div>
    </div>
    <div class="mt-8 text-center text-sm text-slate-500">
      Open source under MIT License. Built for Claude Code.
    </div>
  </div>
</footer>
