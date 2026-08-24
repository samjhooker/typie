<script>
  import Card from '../Card.svelte'
  import Keycap from '../Keycap.svelte'
  import TriggerPicker from '../TriggerPicker.svelte'
  import Toggle from '../Toggle.svelte'
  import { ui, formatDuration } from '../bridge.svelte.js'

  const teaser = $derived(
    ui.stats.totalDictations > 0
      ? `${ui.stats.totalWords.toLocaleString()} words dictated · ${formatDuration((ui.stats.totalWords / 35) * 60)} of typing saved`
      : '',
  )
</script>

<div class="pane">
  <Card icon="🎙" tint="var(--pink)" title="Trigger">
    <TriggerPicker />
  </Card>

  <Card icon="⌘" tint="var(--butter)" title="Keybinding">
    <Keycap />
  </Card>

  <Card icon="⇄" tint="var(--sky)" title="Preferences">
    <div class="row">
      <span class="ico">🗂</span>
      <div class="labels">
        <strong>Save previous transcriptions</strong>
        <small>kept locally on disk — never anywhere else</small>
      </div>
      <Toggle setting="historyEnabled" />
    </div>
    <hr />
    <div class="row">
      <span class="ico">☀️</span>
      <div class="labels">
        <strong>Launch at login</strong>
        <small>the robot wakes up when your Mac does</small>
      </div>
      <Toggle setting="launchAtLogin" />
    </div>
  </Card>

  {#if teaser}
    <p class="teaser">▮ {teaser}</p>
  {/if}

  <p class="foot">no account · no cloud · works offline · $0 forever</p>
</div>

<style>
  .pane {
    display: flex;
    flex-direction: column;
    gap: 14px;
    padding: 18px 20px;
    overflow-y: auto;
  }

  .row {
    display: flex;
    align-items: center;
    gap: 11px;
  }

  .ico {
    width: 20px;
    text-align: center;
    font-size: 13px;
    flex-shrink: 0;
  }

  .labels {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 1px;
  }

  .labels strong {
    font-size: 13.5px;
    font-weight: 600;
    color: #2c3342;
  }

  .labels small {
    font-size: 11px;
    color: rgba(44, 51, 66, 0.6);
  }

  hr {
    border: none;
    border-top: 1px solid rgba(3, 89, 77, 0.1);
  }

  .teaser {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.05em;
    color: rgba(252, 86, 129, 0.75);
    text-align: center;
  }

  .foot {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.05em;
    color: rgba(44, 51, 66, 0.45);
    text-align: center;
  }
</style>
