<script>
  import Robot from './Robot.svelte'
  import Tabs from './Tabs.svelte'
  import DevTag from './DevTag.svelte'
  import SettingsPane from './panes/SettingsPane.svelte'
  import StatsPane from './panes/StatsPane.svelte'
  import HistoryPane from './panes/HistoryPane.svelte'
  import TranscribePane from './panes/TranscribePane.svelte'
  import { ui, local } from './bridge.svelte.js'

  /** the one settings/stats/history window, web edition */
  const robotMood = $derived(
    ui.dictation.phase === 'listening'
      ? 'listening'
      : ui.dictation.phase === 'transcribing'
        ? 'thinking'
        : 'idle',
  )

  // Swift can steer the active pane (menu → Open Stats…)
  window.__typie.setPane = (p) => (local.pane = p)
</script>

<div class="shell">
  <header>
    <div class="brand">
      <Robot size={22} mood={robotMood} />
      <h1>typie{ui.variant === 'dev' ? ' dev' : ''}.</h1>
      <DevTag />
    </div>
    <Tabs />
  </header>

  {#if local.pane === 'settings'}
    <SettingsPane />
  {:else if local.pane === 'stats'}
    <StatsPane />
  {:else if local.pane === 'transcribe' && ui.variant === 'dev'}
    <TranscribePane />
  {:else}
    <HistoryPane />
  {/if}
</div>

<style>
  .shell {
    display: flex;
    flex-direction: column;
    height: 100vh;
  }

  header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 13px 20px;
    border-bottom: 1px solid rgba(3, 89, 77, 0.12);
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--ink);
  }

  h1 {
    font-size: 18px;
  }
</style>
