<script>
  import { ui, timeSavedSeconds, formatDuration, formatLatency } from '../bridge.svelte.js';

  const stats = $derived(ui.stats);

  const timeSaved = $derived(timeSavedSeconds(stats));
  const dictations = $derived(stats.totalDictations);
  const words = $derived(stats.totalWords);

  // real activity from history — last 14 days of dictation counts
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

  // per-hour heat: when do you talk to typie?
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
      <h2>Stats</h2>
      <p>the receipts. <span class="hand hint-hand">look at you go!</span></p>
    </div>
    <span class="chip alltime">all time · on this mac only</span>
  </header>

  {#if dictations === 0}
    <div class="empty">
      <span class="hand big">no stats yet — start dictating!</span>
      <p>this page fills itself in as you talk.</p>
    </div>
  {:else}
    <!-- headline numbers -->
    <div class="cards">
      <div class="stat card pink">
        <span class="mono-kicker">time saved</span>
        <strong>{formatDuration(timeSaved)}</strong>
        <p>vs typing it all by hand at 35 wpm</p>
        <span class="doodle">✍️ → 🎙️</span>
      </div>
      <div class="stat card blue">
        <span class="mono-kicker">words dictated</span>
        <strong>{words.toLocaleString()}</strong>
        <p>across {dictations.toLocaleString()} dictations</p>
      </div>
      <div class="stat card mint">
        <span class="mono-kicker">time on mic</span>
        <strong>{formatDuration(stats.totalAudioSeconds)}</strong>
        <p>of pure talking</p>
      </div>
      <div class="stat card butter">
        <span class="mono-kicker">avg latency</span>
        <strong>{formatLatency(stats.avgLatencyMs)}</strong>
        <p>key release → text on screen</p>
      </div>
    </div>

    <div class="grid2">
      <!-- daily bars -->
      <div class="panel card">
        <h3>last two weeks</h3>
        <div class="bars">
          {#each days as d, i (i)}
            <div
              class="barcol"
              title="{d.date.toLocaleDateString()} · {d.count} dictation{d.count === 1 ? '' : 's'}"
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
          {activeDays} active day{activeDays === 1 ? '' : 's'} · peak {maxCount} in a day
        </p>
      </div>

      <!-- rhythm -->
      <div class="panel card">
        <h3>your rhythm</h3>
        <div class="clockrow">
          {#each hours as v, h (h)}
            <div
              class="cell"
              title="{h}:00 · {v} dictations"
              style="--a:{v ? Math.min(1, v / Math.max(1, Math.max(...hours))) : 0}"
              class:on={v > 0}
            ></div>
          {/each}
        </div>
        <p class="foot mono-kicker">
          {hours.some((v) => v > 0) ? `you're loudest around ${peakHour}:00` : 'no pattern yet'}
        </p>
      </div>
    </div>

    <p class="hand closer">
      {words > 0
        ? `that's roughly ${Math.max(1, Math.round(words / 500))} page${words >= 1000 ? 's' : ''} of text you didn't have to type.`
        : ''}
    </p>
  {/if}
</div>

<style>
  .wrap {
    padding: 28px 32px 48px;
    max-width: 1100px;
    margin: 0 auto;
  }

  .head {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 24px;
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
    color: var(--hotpink);
    margin-left: 8px;
  }
  .alltime {
    background: var(--card-blue);
    color: var(--peri-ink);
  }

  .empty {
    padding: 90px 20px;
    text-align: center;
  }
  .big {
    font-size: 30px;
    color: var(--ink);
  }
  .empty p {
    margin-top: 10px;
    font-size: 13px;
    color: var(--text-3);
  }

  .cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 14px;
  }
  .stat {
    position: relative;
    overflow: hidden;
    padding: 20px 22px;
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
    font-size: 30px;
    letter-spacing: -0.03em;
    color: var(--ink);
    line-height: 1.05;
  }
  .stat p {
    font-size: 12px;
    color: rgba(19, 23, 34, 0.6);
  }
  .doodle {
    position: absolute;
    right: 12px;
    bottom: 8px;
    font-size: 22px;
    opacity: 0.75;
    transform: rotate(-6deg);
  }

  .grid2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    margin-top: 14px;
  }
  @media (max-width: 900px) {
    .grid2 {
      grid-template-columns: 1fr;
    }
  }

  .panel {
    padding: 20px 22px;
  }
  .panel h3 {
    font-size: 15px;
    margin-bottom: 16px;
  }

  .bars {
    display: flex;
    align-items: flex-end;
    gap: 6px;
    height: 130px;
  }
  .barcol {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    height: 100%;
  }
  .bar {
    width: 100%;
    max-width: 26px;
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
    margin-top: 14px;
  }

  .clockrow {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    gap: 5px;
  }
  .cell {
    aspect-ratio: 1;
    border-radius: 6px;
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
    margin-top: 26px;
    font-size: 24px;
    color: var(--ink);
    transform: rotate(-1deg);
    display: inline-block;
  }
</style>
