import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// GitHub Pages serves the project at /typie/, so assets need that prefix.
// Locally and for other hosts, plain '/' is fine.
export default defineConfig(({ mode }) => ({
  base: process.env.PAGES_BASE ?? '/',
  plugins: [svelte()],
}))
