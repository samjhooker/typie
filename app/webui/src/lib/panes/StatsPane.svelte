<script>
  import Robot from '../Robot.svelte'
  import { ui, timeSavedSeconds, formatDuration, formatAudio, formatLatency } from '../bridge.svelte.js'

  /** lifetime stats — the bragging pane */
  const saved = $derived(timeSavedSeconds(ui.stats))
</script>

{#if ui.stats.totalDictations === 0}
  <div class="empty">
    <Robot size={40} mood="idle" />
    <p class="hand">no stats yet.</p>
    <small>dictate something and watch this light up ✨</small>
  </div>
{:else}
  <div class="pane">
    <section class="hero">
      <span class="mono-kicker">✦ &nbsp;time saved</span>
      <mark>{formatDuration(saved)}</mark>
      <p>of finger-typing skipped — your keyboard can thank typie later</p>
    </section>

    <div class="grid">
      <div class="card">
        <span class="chip" style="background:var(--pink)">Aa</span>
        <strong>{ui.stats.totalWords.toLocaleString()}</strong>
        <span class="mono-kicker">words dictated</span>
      </div>
      <div class="card">
        <span class="chip" style="background:var(--lavender)">∿</span>
        <strong>{ui.stats.totalDictations.toLocaleString()}</strong>
        <span class="mono-kicker">dictations</span>
      </div>
      <div class="card">
        <span class="chip" style="background:var(--sky)">🎙</span>
        <strong>{formatAudio(ui.stats.totalAudioSeconds)}</strong>
        <span class="mono-kicker">time on mic</span>
      </div>
      <div class="card">
        <span class="chip" style="background:var(--butter)">⚡</span>
        <strong>{formatLatency(ui.stats.avgLatencyMs)}</strong>
        <span class="mono-kicker">avg response</span>
      </div>
    </div>

    <p class="foot">
      counted locally, one word at a time — typing estimate at 35 wpm
    </p>
  </div>
{/if}

<style>
  .pane {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 18px 20px;
    overflow-y: auto;
  }

  .empty {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    color: rgba(44, 51, 66, 0.55);
  }

  .empty .hand {
    font-size: 21px;
  }

  .hero {
    padding: 18px;
    border-radius: var(--radius-card);
    background: rgba(130, 237, 166, 0.35);
    border: 2px solid var(--mint-live);
    display: flex;
    flex-direction: column;
    gap: 7px;
  }

  .hero .mono-kicker {
    color: rgba(2, 69, 60, 0.75);
  }

  mark {
    font-family: var(--display);
    font-weight: 800;
    font-size: 40px;
    line-height: 1;
    letter-spacing: -0.03em;
    color: var(--ink);
    background: linear-gradient(transparent 42%, var(--butter) 42%, var(--butter) 92%, transparent 92%);
    width: fit-content;
    padding: 0 4px;
  }

  .hero p,
  .foot {
    font-size: 11.5px;
    color: rgba(2, 69, 60, 0.8);
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 11px;
  }

  .card {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 7px;
    padding: 15px;
  }

  .chip {
    display: inline-grid;
    place-items: center;
    width: 31px;
    height: 31px;
    border-radius: 9px;
    font-weight: 800;
    font-size: 13px;
    color: #2c3342;
  }

  .card strong {
    font-family: var(--display);
    font-weight: 800;
    font-size: 23px;
    letter-spacing: -0.02em;
    color: var(--ink);
    white-space: nowrap;
  }

  .foot {
    text-align: center;
    color: rgba(3, 89, 77, 0.6);
  }
</style>
