<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  function stars(v) {
    const full = Math.floor(v);
    const half = v % 1 >= 0.5;
    const empty = 5 - full - (half ? 1 : 0);
    return { full, half, empty, label: v.toFixed(1) };
  }

  const rows = [
    {
      cap: 'Dictation accuracy & natural phrasing',
      note: 'Aggregated across accents & natural phrasing',
      typie: stars(4.5),
      mac: stars(3.5),
      other: stars(4.5),
      kind: 'stars',
    },
    {
      cap: 'Types into any app with a cursor',
      typie: '✓',
      mac: '✓',
      other: '✓',
    },
    {
      cap: 'Voice notes & sticky wall',
      typie: '✓',
      mac: '–',
      other: '–',
    },
    {
      cap: 'Meeting capture without a bot joining',
      typie: '✓',
      mac: '–',
      other: '–',
    },
    {
      cap: 'File transcription, diarization & AI summary',
      typie: '✓',
      mac: '–',
      other: '✓',
    },
    {
      cap: 'On-device · zero network egress',
      typie: '✓',
      mac: '✓',
      other: '✗',
    },
    {
      cap: 'Open source (MIT)',
      typie: '✓',
      mac: '–',
      other: '–',
    },
    {
      cap: 'Price',
      typie: '$0 forever',
      mac: '$0',
      other: '$10–30/mo',
      kind: 'price',
    },
  ];
</script>

<section
  class="compare-section"
  id="compare"
>
  <div class="container">
    <div
      class="head"
      use:reveal
    >
      <h2>
        Typie vs Mac dictation<br /><em>vs the rest.</em>
      </h2>
      <p class="sub">
        Same 4.5★ accuracy as paid tools. Zero subscription. No cloud required.
      </p>
    </div>

    <div
      class="tablewrap"
      use:reveal={{ delay: 80 }}
    >
      <table>
        <thead>
          <tr>
            <th class="feature-col">Feature</th>
            <th class="us-col">
              <div class="us-badge">
                <Robot
                  size={22}
                  mood="idle"
                />
                <span>Typie</span>
                <span class="us-sub">4.5★ · free</span>
              </div>
            </th>
            <th>
              <div class="colhead">
                <span class="coltitle">Mac dictation</span>
                <span class="colsub mono">3.5★ · free</span>
              </div>
            </th>
            <th>
              <div class="colhead">
                <span class="coltitle">Other apps</span>
                <span class="colsub mono">4.5★ · paid</span>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          {#each rows as r}
            <tr>
              <td class="feature-col">
                <span class="cap">{r.cap}</span>
                {#if r.note}<span class="note mono">{r.note}</span>{/if}
              </td>
              <td class="us-col">
                {#if r.kind === 'stars'}
                  {@const s = r.typie}
                  <span class="stars us">
                    <span class="starRow" aria-label="{s.label} out of 5">
                      {#each Array(s.full) as _}<span class="star full">★</span>{/each}
                      {#if s.half}<span class="star half"><span class="halfBase">★</span><span class="halfFill">★</span></span>{/if}
                      {#each Array(s.empty) as _}<span class="star empty">★</span>{/each}
                    </span>
                    <span class="starNum">{s.label}★</span>
                  </span>
                {:else if r.typie === '✓'}
                  <span class="chk-us">✓</span>
                {:else if r.typie === '–' || r.typie === '✗'}
                  <span class="dash">–</span>
                {:else}
                  <strong class="price-us">{r.typie}</strong>
                {/if}
              </td>
              <td>
                {#if r.kind === 'stars'}
                  {@const s = r.mac}
                  <span class="stars">
                    <span class="starRow" aria-label="{s.label} out of 5">
                      {#each Array(s.full) as _}<span class="star full">★</span>{/each}
                      {#if s.half}<span class="star half"><span class="halfBase">★</span><span class="halfFill">★</span></span>{/if}
                      {#each Array(s.empty) as _}<span class="star empty">★</span>{/each}
                    </span>
                    <span class="starNum dim">{s.label}★</span>
                  </span>
                {:else if r.mac === '✓'}
                  <span class="chk">✓</span>
                {:else if r.mac === '–'}
                  <span class="dash">–</span>
                {:else if r.mac === '✗'}
                  <span class="cross">✗</span>
                {:else}
                  <span class="txt">{r.mac}</span>
                {/if}
              </td>
              <td>
                {#if r.kind === 'stars'}
                  {@const s = r.other}
                  <span class="stars">
                    <span class="starRow" aria-label="{s.label} out of 5">
                      {#each Array(s.full) as _}<span class="star full">★</span>{/each}
                      {#if s.half}<span class="star half"><span class="halfBase">★</span><span class="halfFill">★</span></span>{/if}
                      {#each Array(s.empty) as _}<span class="star empty">★</span>{/each}
                    </span>
                    <span class="starNum">{s.label}★</span>
                  </span>
                {:else if r.other === '✓'}
                  <span class="chk">✓</span>
                {:else if r.other === '–'}
                  <span class="dash">–</span>
                {:else if r.other === '✗'}
                  <span class="cross">✗</span>
                {:else}
                  <span class="txt">{r.other}</span>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <p
      class="footnote mono"
      use:reveal={{ delay: 120 }}
    >
      Ratings are illustrative, aggregated from public benchmarks & user feedback · Other apps typically $10–30/mo for comparable accuracy · Typie is $0 forever, MIT on GitHub.
    </p>
  </div>
</section>

<style>
  .compare-section {
    padding: clamp(70px, 10vh, 110px) 0;
    background: var(--surface-2);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
  }

  .head {
    text-align: center;
    max-width: 720px;
    margin: 0 auto 44px;
  }

  h2 {
    font-size: clamp(32px, 4.2vw, 52px);
    font-weight: 800;
  }
  h2 em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    color: var(--hotpink);
  }

  .sub {
    margin-top: 14px;
    font-size: 16px;
    color: var(--text-2);
  }

  .tablewrap {
    max-width: 1040px;
    margin: 0 auto;
    overflow-x: auto;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
  }

  table {
    width: 100%;
    border-collapse: collapse;
    min-width: 680px;
    font-size: 14.5px;
  }

  th,
  td {
    padding: 16px 20px;
    text-align: center;
    border-bottom: 1px solid var(--line);
    vertical-align: middle;
  }

  tbody tr:last-child td {
    border-bottom: none;
  }

  thead th {
    font-family: var(--display);
    font-size: 14px;
    font-weight: 700;
    color: var(--text-2);
    background: var(--surface-2);
    padding-block: 18px;
  }

  .feature-col {
    text-align: left;
    font-weight: 600;
    color: var(--ink);
    width: 38%;
  }
  .cap { display: block; }
  .note {
    display: block;
    margin-top: 3px;
    font-size: 11px;
    font-weight: 500;
    color: var(--text-3);
    text-transform: none;
    letter-spacing: 0;
  }

  .us-col {
    background: var(--card-mint);
    position: relative;
  }

  thead th.us-col {
    background: var(--mint);
    color: var(--teal-900);
    border-radius: 12px 12px 0 0;
  }

  .us-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 16px;
    font-weight: 800;
    color: var(--teal-900);
  }
  .us-sub {
    font-family: var(--mono);
    font-size: 10.5px;
    font-weight: 600;
    letter-spacing: 0.04em;
    opacity: 0.8;
    margin-left: 2px;
  }
  .colhead {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
  }
  .coltitle { font-weight: 700; color: var(--ink); }
  .colsub { font-size: 10.5px; color: var(--text-3); letter-spacing: 0.05em; }

  .chk-us {
    display: inline-grid;
    place-items: center;
    width: 26px;
    height: 26px;
    border-radius: 50%;
    background: #059669;
    color: #fff;
    font-size: 14px;
    font-weight: 800;
    margin: 0 auto;
  }

  .price-us {
    font-family: var(--display);
    font-size: 17px;
    font-weight: 800;
    color: #059669;
  }

  .chk {
    color: var(--ink);
    font-weight: 800;
    font-size: 16px;
  }

  .cross {
    color: var(--error);
    font-weight: 800;
    font-size: 16px;
  }

  .dash {
    color: var(--muted);
    font-size: 16px;
  }

  .txt {
    font-weight: 600;
    color: var(--text-2);
    font-size: 13.5px;
  }

  .stars {
    display: inline-flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
  }
  .starRow {
    display: inline-flex;
    gap: 1px;
    font-size: 15px;
    line-height: 1;
  }
  .star.full { color: #f59e0b; }
  /* true half star: empty glyph base + left half clipped fill */
  .star.half {
    position: relative;
    color: #e5e7eb;
  }
  .star.half :global(.halfFill) {
    position: absolute;
    top: 0;
    left: 0;
    width: 50%;
    overflow: hidden;
    white-space: nowrap;
    color: #f59e0b;
  }
  .star.empty { color: #e5e7eb; }
  :root[data-theme='dark'] .star.empty { color: #3f3f46; }
  :root[data-theme='dark'] .star.half { color: #3f3f46; }
  .stars.us .star.empty { color: rgba(2, 69, 60, 0.14); }
  .stars.us .star.half { color: rgba(2, 69, 60, 0.14); }
  .starNum {
    font-family: var(--mono);
    font-size: 10.5px;
    font-weight: 700;
    color: var(--ink);
    letter-spacing: 0.04em;
  }
  .starNum.dim { color: var(--text-2); }

  .footnote {
    text-align: center;
    margin-top: 22px;
    font-size: 11.5px;
    color: var(--text-3);
    max-width: 70ch;
    margin-inline: auto;
    line-height: 1.5;
  }
</style>
