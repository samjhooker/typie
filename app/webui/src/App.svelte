<script>
  import Onboarding from './lib/Onboarding.svelte'
  import AppShell from './lib/AppShell.svelte'
  import { ui } from './lib/bridge.svelte.js'

  const route = $derived(ui.ready ? ui.route : null)
</script>

{#if route === 'onboarding'}
  <Onboarding />
{:else if route === 'app'}
  <AppShell />
{/if}

<style>
  :global(html, body) {
    height: 100%;
  }

  /* blank cream while the first snapshot is in flight — no white flash */
  :global(#app:empty) {
    background: var(--page);
  }
</style>
