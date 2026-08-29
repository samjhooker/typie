import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import tailwindcss from '@tailwindcss/vite';

// relative base so the built dist/ works when loaded via file URLs
// inside typie's WKWebView
export default defineConfig({
  plugins: [svelte(), tailwindcss()],
  base: './',
});
