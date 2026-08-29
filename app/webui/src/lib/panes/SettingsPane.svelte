<script>
  import {
    ui,
    send,
    timeSavedSeconds,
    formatDuration,
    formatLatency,
  } from '../bridge.svelte.js';
  import Keycap from '../Keycap.svelte';
  import TriggerPicker from '../TriggerPicker.svelte';
  import Toggle from '../Toggle.svelte';
  import {
    FolderOpen,
    Mic,
    History,
    Rocket,
    Lock,
    AudioLines,
    BarChart3,
  } from 'lucide-svelte';

  function fmtBytes(b) {
    if (!b) return '0 mb';
    const gb = b / 1024 ** 3;
    return gb >= 1 ? `${gb.toFixed(1)} gb` : `${Math.round(b / 1024 ** 2)} mb`;
  }

  // ── stats — re-implanted from StatsPane so Settings owns the receipts ──
  const stats = $derived(ui.stats);
  const timeSaved = $derived(timeSavedSeconds(stats));
  const dictations = $derived(stats.totalDictations);
  const words = $derived(stats.totalWords);

  const days = $derived.by(() => {
    const out = [];
    const now = new Date();
    for (let i = 13; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i);
      out.push({
        date: d,
        label: d.toLocaleDateString(undefined, { weekday: 'narrow' }),
        count: 0,
      });
    }
    for (const h of ui.history) {
      const d = new Date(h.date);
      const slot = out.find(
        (o) =>
          o.date.getFullYear() === d.getFullYear() &&
          o.date.getMonth() === d.getMonth() &&
          o.date.getDate() === d.getDate()
      );
      if (slot) slot.count++;
    }
    return out;
  });
  const maxCount = $derived(Math.max(1, ...days.map((d) => d.count)));
  const activeDays = $derived(days.filter((d) => d.count > 0).length);

  const hours = $derived.by(() => {
    const buckets = Array(24).fill(0);
    for (const h of ui.history) buckets[new Date(h.date).getHours()]++;
    return buckets;
  });
  const peakHour = $derived(hours.indexOf(Math.max(...hours)));
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Settings</h2>
      <p>
        a few switches, no account, no cloud. <span class="hand hint-hand"
          >set it and forget it</span
        >
      </p>
    </div>
  </header>

  <!-- dictation -->
  <section class="card">
    <h3>
      <span
        class="ico"
        style="background:var(--pink); color:var(--hotpink)"
        ><Mic size={15} /></span
      > dictation
    </h3>
    <div class="keyblock">
      <Keycap />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>trigger style</strong>
        <span>how your key behaves when you press it</span>
      </div>
      <TriggerPicker />
    </div>
    <div class="row">
      <div class="rowtxt">
        <History size={14} />
        <strong>save history</strong>
        <span>keep past dictations in the history pane</span>
      </div>
      <Toggle setting="historyEnabled" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <Rocket size={14} />
        <strong>launch at login</strong>
        <span>typie waits in the menu bar from boot</span>
      </div>
      <Toggle setting="launchAtLogin" />
    </div>
  </section>

  <!-- audio -->
  <section class="card">
    <h3>
      <span
        class="ico"
        style="background:var(--lavender); color:var(--violet-ink)"
        ><AudioLines size={15} /></span
      > audio
    </h3>
    <div class="row">
      <div class="rowtxt">
        <strong>keep voice note audio</strong>
        <span>store the raw wav alongside each note (uses more disk)</span>
      </div>
      <Toggle setting="notesKeepAudio" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>mix mic into meetings</strong>
        <span>record your voice too, not just the call</span>
      </div>
      <Toggle setting="meetingMixMic" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>save transcript audio</strong>
        <span>keep recordings so you can scrub transcripts word-by-word</span>
      </div>
      <Toggle setting="transcriptsKeepAudio" />
    </div>
  </section>

  <!-- storage -->
  <section class="card">
    <h3>
      <span
        class="ico"
        style="background:var(--card-mint); color:var(--green-deep)"
        ><FolderOpen size={15} /></span
      > storage
    </h3>
    <div class="row">
      <div class="rowtxt">
        <strong>{fmtBytes(ui.storage.usedBytes)} used</strong>
        <span>notes, transcripts and models, all under typie's folder</span>
      </div>
      <button
        class="btn btn-ghost small"
        onclick={() => send({ type: 'revealStorage' })}
      >
        <FolderOpen size={13} /> reveal in finder
      </button>
    </div>
  </section>

  <!-- stats — formerly its own pane, now lives in Settings -->
  <section class="card stats-sec">
    <h3>
      <span
        class="ico"
        style="background:var(--card-blue); color:var(--peri-ink)"
        ><BarChart3 size={15} /></span
      > stats
    </h3>
    {#if dictations === 0}
      <div class="stats-empty">
        <span class="hand big">no stats yet — start dictating!</span>
        <p>this page fills itself in as you talk.</p>
      </div>
    {:else}
      <div class="stats-cards">
        <div class="stat pink">
          <span class="mono-kicker">time saved</span>
          <strong>{formatDuration(timeSaved)}</strong>
          <p>vs typing it all by hand at 35 wpm</p>
        </div>
        <div class="stat blue">
          <span class="mono-kicker">words dictated</span>
          <strong>{words.toLocaleString()}</strong>
          <p>across {dictations.toLocaleString()} dictations</p>
        </div>
        <div class="stat mint">
          <span class="mono-kicker">time on mic</span>
          <strong>{formatDuration(stats.totalAudioSeconds)}</strong>
          <p>of pure talking</p>
        </div>
        <div class="stat butter">
          <span class="mono-kicker">avg latency</span>
          <strong>{formatLatency(stats.avgLatencyMs)}</strong>
          <p>key release → text on screen</p>
        </div>
      </div>
      <div class="stats-grid2">
        <div class="panel">
          <h4>last two weeks</h4>
          <div class="bars">
            {#each days as d, i (i)}
              <div
                class="barcol"
                title="{d.date.toLocaleDateString()} · {d.count} dictation{d.count ===
                1
                  ? ''
                  : 's'}"
              >
                <div
                  class="bar"
                  class:hot={d.count === maxCount && d.count > 0}
                  style="height:{Math.max(3, (d.count / maxCount) * 100)}%"
                ></div>
                <span class="lbl mono-kicker">{d.label}</span>
              </div>
            {/each}
          </div>
          <p class="foot mono-kicker">
            {activeDays} active day{activeDays === 1 ? '' : 's'} · peak {maxCount}
            in a day
          </p>
        </div>
        <div class="panel">
          <h4>your rhythm</h4>
          <div class="clockrow">
            {#each hours as v, h (h)}
              <div
                class="cell"
                title="{h}:00 · {v} dictations"
                style="--a:{v
                  ? Math.min(1, v / Math.max(1, Math.max(...hours)))
                  : 0}"
                class:on={v > 0}
              ></div>
            {/each}
          </div>
          <p class="foot mono-kicker">
            {hours.some((v) => v > 0)
              ? `you're loudest around ${peakHour}:00`
              : 'no pattern yet'}
          </p>
        </div>
      </div>
      <p class="hand closer">
        {words > 0
          ? `that's roughly ${Math.max(1, Math.round(words / 500))} page${words >= 1000 ? 's' : ''} of text you didn't have to type.`
          : ''}
      </p>
    {/if}
  </section>

  <!-- privacy -->
  <section class="card privacy">
    <h3>
      <span
        class="ico"
        style="background:var(--mint); color:var(--green-deep)"
        ><Lock size={15} /></span
      > privacy
    </h3>
    <p class="pledge">
      audio goes mic → model → garbage collector. nothing is uploaded, ever.
      delete the app and nothing remains. that's not a policy — it's the
      architecture.
    </p>
  </section>
</div>

<style>
  .wrap {
    padding: 28px 32px 48px;
    max-width: 760px;
    margin: 0 auto;
  }

  .head {
    margin-bottom: 22px;
  }
  .head h2 {
    font-size: 26px;
  }
  .head p {
    font-size: 13px;
    color: var(--text-3);
    margin-top: 4px;
  }
  .hint-hand {
    font-size: 16px;
    color: var(--mint-live);
    margin-left: 8px;
  }

  section {
    padding: 22px 24px;
    margin-bottom: 16px;
    display: flex;
    flex-direction: column;
    gap: 18px;
  }

  h3 {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
    letter-spacing: -0.01em;
  }
  .ico {
    display: inline-grid;
    place-items: center;
    width: 28px;
    height: 28px;
    border-radius: 9px;
    flex-shrink: 0;
  }

  .keyblock {
    padding: 16px;
    background: var(--paper);
    border-radius: 16px;
    border: 1px solid var(--line);
  }

  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
  }
  .rowtxt {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
    font-size: 13.5px;
    color: var(--ink);
  }
  .rowtxt strong {
    font-weight: 700;
  }
  .rowtxt span {
    flex-basis: 100%;
    font-size: 11.5px;
    color: var(--text-3);
    margin-left: 22px;
  }
  .rowtxt svg {
    color: var(--text-3);
    flex-shrink: 0;
  }

  .privacy {
    background: var(--card-mint);
    border-color: transparent;
  }
  .pledge {
    font-size: 13.5px;
    line-height: 1.65;
    color: var(--green-deep);
  }

  /* stats — transplanted from StatsPane */
  .stats-sec {
    gap: 16px;
  }
  .alltime {
    background: var(--card-blue);
    color: var(--peri-ink);
    margin-left: 4px;
  }
  .stats-empty {
    padding: 24px 8px;
    text-align: center;
  }
  .stats-empty .big {
    font-size: 22px;
    color: var(--ink);
  }
  .stats-empty p {
    margin-top: 6px;
    font-size: 13px;
    color: var(--text-3);
  }
  .stats-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 12px;
  }
  .stat {
    position: relative;
    overflow: hidden;
    padding: 16px 18px;
    border-radius: 16px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .stat.pink {
    background: var(--pink-band);
  }
  .stat.blue {
    background: var(--card-blue);
  }
  .stat.mint {
    background: var(--card-mint);
  }
  .stat.butter {
    background: var(--card-cream);
  }
  .stat strong {
    font-size: 24px;
    letter-spacing: -0.03em;
    color: var(--ink);
    line-height: 1.05;
  }
  .stat p {
    font-size: 11.5px;
    color: rgba(19, 23, 34, 0.6);
  }
  .doodle {
    position: absolute;
    right: 10px;
    bottom: 6px;
    font-size: 18px;
    opacity: 0.7;
    transform: rotate(-6deg);
  }
  .stats-grid2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }
  @media (max-width: 700px) {
    .stats-grid2 {
      grid-template-columns: 1fr;
    }
  }
  .panel {
    padding: 16px 18px;
    border-radius: 16px;
    background: var(--paper);
    border: 1px solid var(--line);
  }
  .panel h4 {
    font-size: 13px;
    margin-bottom: 12px;
    color: var(--ink);
  }
  .bars {
    display: flex;
    align-items: flex-end;
    gap: 5px;
    height: 110px;
  }
  .barcol {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    height: 100%;
  }
  .bar {
    width: 100%;
    max-width: 22px;
    border-radius: 6px 6px 3px 3px;
    background: var(--sky);
    align-self: flex-end;
    margin-top: auto;
    transition: height 0.4s var(--spring);
  }
  .bar.hot {
    background: var(--hotpink);
  }
  .lbl {
    font-size: 9px;
    letter-spacing: 0;
  }
  .foot {
    margin-top: 12px;
    font-size: 10px;
  }
  .clockrow {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    gap: 4px;
  }
  .cell {
    aspect-ratio: 1;
    border-radius: 5px;
    background: rgba(3, 89, 77, 0.07);
  }
  .cell.on {
    background: color-mix(
      in srgb,
      var(--periwinkle) calc(var(--a) * 100%),
      rgba(111, 143, 251, 0.12)
    );
  }
  .closer {
    font-size: 18px;
    color: var(--ink);
    transform: rotate(-1deg);
    display: inline-block;
  }
</style>
