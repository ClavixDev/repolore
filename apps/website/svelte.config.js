import adapter from '@sveltejs/adapter-static';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter({
			pages: '.svelte-kit/cloudflare',
			assets: '.svelte-kit/cloudflare',
			fallback: undefined,
			precompress: false,
			strict: true
		})
	}
};

export default config;
