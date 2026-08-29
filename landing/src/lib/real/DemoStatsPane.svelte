<script>
  const timeSaved = '14h 23m';
  const wordsDictated = 47832;
  const dictations = 312;
  const timeOnMic = '6h 12m';
  const avgLatency = '82ms';

  const barData = [3, 0, 5, 8, 12, 2, 0, 4, 7, 15, 9, 3, 0, 6];
  const barLabels = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];
  const maxCount = Math.max(...barData);
  const activeDays = barData.filter((v) => v > 0).length;

  const hours = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
    0, 0, 0,
  ];
  const hourBuckets = [
    0, 0, 0, 0, 0, 0, 0, 1, 3, 5, 12, 8, 6, 4, 11, 9, 7, 5, 3, 2, 1, 0, 0, 0,
  ];
  const maxHour = Math.max(...hourBuckets);
  const peakHour = hourBuckets.indexOf(Math.max(...hourBuckets));
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Stats</h2>
      <p>the receipts. <span class="hand hint-hand">look at you go!</span></p>
    </div>
    <span class="chip alltime">all time · on this mac only</span>
  </header>

  <div class="cards">
    <div class="stat card pink">
      <span class="mono">time saved</span>
      <strong>{timeSaved}</strong>
      <p>vs typing it all by hand at 35 wpm</p>
      <span class="doodle">✍️ → 🎙️</span>
    </div>
    <div class="stat card blue">
      <span class="mono">words dictated</span>
      <strong>{wordsDictated.toLocaleString()}</strong>
      <p>across {dictations.toLocaleString()} dictations</p>
    </div>
    <div class="stat card mint">
      <span class="mono">time on mic</span>
      <strong>{timeOnMic}</strong>
      <p>of pure talking</p>
    </div>
    <div class="stat card butter">
      <span class="mono">avg latency</span>
      <strong>{avgLatency}</strong>
      <p>key release → text on screen</p>
    </div>
  </div>

  <div class="grid2">
    <div class="panel card">
      <h3>last two weeks</h3>
      <div class="bars">
        {#each barData as count, i (i)}
          <div
            class="barcol"
            title="{count} dictation{count === 1 ? '' : 's'}"
          >
            <div
              class="bar"
              class:hot={count === maxCount && count > 0}
              style="height:{Math.max(3, (count / maxCount) * 100)}%"
            ></div>
            <span class="lbl mono">{barLabels[i]}</span>
          </div>
        {/each}
      </div>
      <p class="foot mono">
        {activeDays} active days · peak {maxCount} in a day
      </p>
    </div>

    <div class="panel card">
      <h3>your rhythm</h3>
      <div class="clockrow">
        {#each hourBuckets as v, h (h)}
          <div
            class="cell"
            title="{h}:00 · {v} dictations"
            style="--a:{v ? Math.min(1, v / Math.max(1, maxHour)) : 0}"
            class:on={v > 0}
          ></div>
        {/each}
      </div>
      <p class="foot mono">you're loudest around {peakHour}:00</p>
    </div>
  </div>

  <p class="hand closer">
    that's roughly 96 pages of text you didn't have to type.
  </p>
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
    color: var(--periwinkle);
    padding: 5px 14px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.06em;
    text-transform: uppercase;
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
    border-radius: var(--radius-card);
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
    border-radius: var(--radius-card);
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
