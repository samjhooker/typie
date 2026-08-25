<script>
  import Onboarding from './lib/Onboarding.svelte'
  import AppShell from './lib/AppShell.svelte'
  import { ui } from './lib/bridge.svelte.js'

  const route = $derived(ui.ready ? ui.route : null)
  const showOnboardingOverlay = $derived(route === 'onboarding')
</script>

{#if route === null}
  <!-- loading -->
{:else}
  <AppShell />
  {#if showOnboardingOverlay}
    <div class="onboard-overlay">
      <div class="onboard-card">
        <Onboarding />
      </div>
    </div>
  {/if}
{/if}

<style>
  :global(html, body) {
    height: 100%;
  }

  /* blank cream while the first snapshot is in flight — no white flash */
  :global(#app:empty) {
    background: var(--page);
  }

  .onboard-overlay{
    position:fixed; inset:0; background:rgba(255,253,247,.82); backdrop-filter:blur(8px);
    display:grid; place-items:center; z-index:50; padding:20px;
  }
  .onboard-card{
    width:min(680px, 92vw); max-height:92vh; overflow:auto; background:var(--cream);
    border:1px solid rgba(3,89,77,.12); border-radius:20px; box-shadow:0 20px 40px rgba(3,89,77,.18);
  }
</style>
