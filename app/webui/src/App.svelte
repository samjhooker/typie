<script>
  import Onboarding from './lib/Onboarding.svelte';
  import AppShell from './lib/AppShell.svelte';
  import { ui } from './lib/bridge.svelte.js';
  import { applyTheme } from './lib/theme.svelte.js';

  const route = $derived(ui.ready ? ui.route : null);

  // theme: system default (prefers-color-scheme) with a Settings override
  let systemDark = $state(
    matchMedia('(prefers-color-scheme: dark)').matches,
  );
  matchMedia('(prefers-color-scheme: dark)').addEventListener(
    'change',
    (e) => (systemDark = e.matches),
  );
  $effect(() => {
    void ui.settings.appearance;
    void systemDark;
    applyTheme();
  });
</script>

{#if route === null}
  <!-- loading -->
{:else if route === 'onboarding'}
  <!-- dedicated full-window onboarding — the main app doesn't exist yet -->
  <Onboarding />
{:else}
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
