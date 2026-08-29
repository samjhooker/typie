<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  /* stripped to the three differentiators that actually move people */
  const rows = [
    { label: 'Works fully offline', typie: 'yes', them: ['no', 'yes', 'no'] },
    { label: 'Price', typie: '$0 forever', them: ['$12/mo', 'from free*', '$$$'] },
    { label: 'Account required', typie: 'no', them: ['yes', 'no', 'yes'] },
  ];
</script>

<section class="verdict field pop-c" id="versus">
  <div class="container">
    <p class="mono kicker" style="text-align:center">chapter 04 · the receipts</p>
    <h2 class="subhead" use:reveal>
      Go ahead,
      <span class="squiggle"
        >comparison-shop
        <svg viewBox="0 0 120 14" aria-hidden="true">
          <path d="M4 9c22-6 44-6 56-3s34 4 56-2" stroke="var(--hotpink)" />
        </svg>
      </span>
    </h2>
    <p class="lede" use:reveal={{ delay: 60 }}>
      Screenshot this table. Send it to the group chat deciding for you. We'll wait.
    </p>

    <div class="tablewrap" use:reveal={{ delay: 120 }}>
      <table>
        <thead>
          <tr>
            <th class="rowlabel"><span class="mono">what matters</span></th>
            <th class="typie">
              <span class="sticker hand">← you, probably</span>
              <span class="bot"><Robot size={40} mood="idle" /></span>
              <span class="name">typie</span>
              <span class="tag hand">$0 · offline</span>
            </th>
            <th>wisprflow</th>
            <th>superwhisper*</th>
            <th>otter</th>
          </tr>
        </thead>
        <tbody>
          {#each rows as row}
            <tr>
              <td class="rowlabel">{row.label}</td>
              <td class="typie">
                {#if row.typie === 'yes'}
                  <span class="mark yes" aria-label="yes">✓</span>
                {:else if row.typie === 'no'}
                  <span class="mark no" aria-label="no">✗</span>
                {:else}
                  <span class="big">{row.typie}</span>
                {/if}
              </td>
              {#each row.them as cell}
                <td>
                  {#if cell === 'yes'}
                    <span class="mark yes dim" aria-label="yes">✓</span>
                  {:else if cell === 'no'}
                    <span class="mark no" aria-label="no">✗</span>
                  {:else if cell === '—'}
                    <span class="dash" aria-label="not available">—</span>
                  {:else}
                    <span class="small">{cell}</span>
                  {/if}
                </td>
              {/each}
            </tr>
          {/each}
        </tbody>
      </table>
    </div>

    <p class="fine mono" use:reveal>
      *superwhisper's free tier covers local models · competitor plans change, check their sites ·
      every ✓ in our column runs on your mac
    </p>
  </div>
</section>

<style>
  .verdict {
    background: var(--paper);
  }

  .lede {
    text-align: center;
    margin-top: 14px;
    font-weight: 600;
    color: rgba(19, 23, 34, 0.66);
  }

  .tablewrap {
    margin-top: clamp(28px, 4vh, 44px);
    overflow-x: auto;
    border-radius: var(--radius-card);
  }

  table {
    width: 100%;
    min-width: 720px;
    border-collapse: separate;
    border-spacing: 0;
    background: #fff;
    border: 2px solid rgba(19, 23, 34, 0.85);
    border-radius: var(--radius-card);
    overflow: hidden;
  }

  th,
  td {
    padding: 15px 18px;
    text-align: center;
    font-size: 15.5px;
    border-bottom: 1px solid rgba(19, 23, 34, 0.09);
    border-left: 1px solid rgba(19, 23, 34, 0.06);
    vertical-align: middle;
  }

  tbody tr:last-child th,
  tbody tr:last-child td {
    border-bottom: none;
  }

  thead th {
    padding-block: 20px;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-transform: lowercase;
    color: rgba(19, 23, 34, 0.62);
    background: rgba(19, 23, 34, 0.03);
  }

  .rowlabel {
    text-align: left;
    font-weight: 600;
    color: var(--ink);
    width: 30%;
    min-width: 220px;
  }

  /* typie's column: lifted, tinted, slightly too proud */
  .typie {
    background: var(--card-mint);
    position: relative;
  }

  thead .typie {
    background: var(--mint);
    color: var(--green-deep);
    display: grid;
    gap: 4px;
    justify-items: center;
    align-content: center;
    padding-block: 16px;
  }

  .sticker {
    position: absolute;
    top: -12px;
    right: -14px;
    font-size: 15px;
    color: var(--ink);
    background: var(--butter);
    border: 1.5px solid rgba(19, 23, 34, 0.8);
    border-radius: 999px;
    padding: 3px 11px;
    transform: rotate(7deg);
    box-shadow: 2px 2px 0 rgba(19, 23, 34, 0.5);
    white-space: nowrap;
    z-index: 2;
  }

  thead .typie .bot {
    line-height: 0;
    color: var(--ink);
  }

  thead .typie .name {
    font-family: var(--display);
    font-size: 19px;
    font-weight: 800;
    letter-spacing: -0.02em;
    text-transform: none;
  }

  thead .typie .tag {
    font-size: 17px;
    color: var(--green-deep);
    transform: rotate(-3deg);
  }

  tbody tr:hover td.rowlabel,
  tbody tr:hover td.typie {
    filter: brightness(0.985);
  }

  .mark {
    display: inline-grid;
    place-items: center;
    width: 28px;
    height: 28px;
    border-radius: 999px;
    font-weight: 800;
    font-size: 15px;
    line-height: 1;
  }

  .mark.yes {
    background: var(--green);
    color: #fff;
  }

  .mark.no {
    background: rgba(19, 23, 34, 0.1);
    color: rgba(19, 23, 34, 0.55);
  }

  .mark.dim {
    background: rgba(3, 89, 77, 0.14);
    color: var(--green-deep);
  }

  .big {
    font-family: var(--display);
    font-size: 21px;
    font-weight: 800;
    letter-spacing: -0.02em;
    color: var(--green-deep);
  }

  .small {
    font-weight: 600;
    color: rgba(19, 23, 34, 0.6);
    white-space: nowrap;
  }

  .dash {
    color: rgba(19, 23, 34, 0.3);
  }

  .fine {
    margin-top: 18px;
    text-align: center;
  }
</style>
