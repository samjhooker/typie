<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  const rows = [
    {
      cap: 'Dictate into any active Mac app',
      typie: '✓',
      builtIn: '✓',
      superwhisper: '✓',
      cloud: '✓',
    },
    {
      cap: 'Quick voice notes & sticky wall',
      typie: '✓',
      builtIn: '—',
      superwhisper: '—',
      cloud: '—',
    },
    {
      cap: 'Meeting capture without joining bots',
      typie: '✓',
      builtIn: '—',
      superwhisper: '—',
      cloud: '—',
    },
    {
      cap: 'Audio file transcription & AI summary',
      typie: '✓',
      builtIn: '—',
      superwhisper: '✓',
      cloud: '✓',
    },
    {
      cap: '100% on-device (zero network egress)',
      typie: '✓',
      builtIn: '✓',
      superwhisper: '✓',
      cloud: '✗',
    },
    {
      cap: 'Sub-100ms keystroke response',
      typie: '✓',
      builtIn: '—',
      superwhisper: '✓',
      cloud: '—',
    },
    {
      cap: 'Price',
      typie: '$0 forever',
      builtIn: '$0',
      superwhisper: '$12/mo*',
      cloud: '$10–20/mo',
    },
    {
      cap: 'Open source (MIT, auditable)',
      typie: '✓',
      builtIn: '—',
      superwhisper: '—',
      cloud: '—',
    },
  ];
</script>

<section class="compare-section" id="compare">
  <div class="container">
    <div class="head" use:reveal>
      <h2>Built-in dictation types once.<br /><em>Typie is a full suite.</em></h2>
      <p class="sub">
        Compare Typie with built-in Apple dictation, cloud services, and paid utilities.
      </p>
    </div>

    <div class="tablewrap" use:reveal={{ delay: 80 }}>
      <table>
        <thead>
          <tr>
            <th class="feature-col">Feature</th>
            <th class="us-col">
              <div class="us-badge">
                <Robot size={24} mood="idle" />
                <span>Typie</span>
              </div>
            </th>
            <th>Built-in Dictation</th>
            <th>Superwhisper</th>
            <th>Cloud AI Apps</th>
          </tr>
        </thead>
        <tbody>
          {#each rows as r}
            <tr>
              <td class="feature-col">{r.cap}</td>
              <td class="us-col">
                {#if r.typie === '✓'}
                  <span class="chk-us">✓</span>
                {:else}
                  <strong class="price-us">{r.typie}</strong>
                {/if}
              </td>
              <td>
                {#if r.builtIn === '✓'}
                  <span class="chk">✓</span>
                {:else if r.builtIn === '—'}
                  <span class="dash">—</span>
                {:else}
                  <span class="txt">{r.builtIn}</span>
                {/if}
              </td>
              <td>
                {#if r.superwhisper === '✓'}
                  <span class="chk">✓</span>
                {:else if r.superwhisper === '—'}
                  <span class="dash">—</span>
                {:else}
                  <span class="txt">{r.superwhisper}</span>
                {/if}
              </td>
              <td>
                {#if r.cloud === '✓'}
                  <span class="chk">✓</span>
                {:else if r.cloud === '✗'}
                  <span class="cross">✗</span>
                {:else if r.cloud === '—'}
                  <span class="dash">—</span>
                {:else}
                  <span class="txt">{r.cloud}</span>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <p class="footnote mono" use:reveal={{ delay: 120 }}>
      *Superwhisper offers a basic local tier with paid pro features · All Typie features run on
      your Apple Silicon hardware at $0.
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
    padding-block: 20px;
  }

  .feature-col {
    text-align: left;
    font-weight: 600;
    color: var(--ink);
    width: 36%;
  }

  .us-col {
    background: var(--card-mint);
    position: relative;
  }

  thead th.us-col {
    background: var(--mint);
    color: #02453c;
    border-radius: 12px 12px 0 0;
  }

  .us-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 16px;
    font-weight: 800;
    color: #02453c;
  }

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
    color: #ef4444;
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

  .footnote {
    text-align: center;
    margin-top: 22px;
    font-size: 12px;
    color: var(--text-3);
  }
</style>
