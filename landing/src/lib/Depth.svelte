<script>
  import { reveal } from './reveal.js';

  /* the engineering story, told in numerals — the depth competitors hide,
     typie can state as physics. every number is a fact you can verify. */
  const STATS = [
    { n: '80', unit: 'ms', label: 'keystroke to glyph', color: '#fc5681', note: 'faster than your finger lifts' },
    { n: '25', unit: 'langs', label: 'european languages', color: '#6f8ffb', note: 'nvidia parakeet, on-device' },
    { n: '0', unit: 'bytes', label: 'leave this mac', color: '#0ea86b', note: 'no server exists to receive them' },
    { n: '100', unit: '%', label: 'free, mit, forever', color: '#c88cfd', note: 'no account, no upgrade nudge' },
  ]
</script>

<section class="depth" id="engine">
  <div class="container">
    <h2 use:reveal>Numbers, not <em>promises.</em></h2>

    <div class="stats">
      {#each STATS as s, i (s.label)}
        <div class="stat" use:reveal={{ delay: i * 90 }} style="--c:{s.color}">
          <span class="num">{s.n}<i>{s.unit}</i></span>
          <span class="lab mono">{s.label}</span>
          <span class="note">{s.note}</span>
        </div>
      {/each}
    </div>

    <p class="meta foot" use:reveal={{ delay: 120 }}>
      nvidia parakeet · mlx · apple silicon · mit license · the pricing page is a 404
    </p>
  </div>
</section>

<style>
  .depth {
    background: #fff;
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
    padding: clamp(52px, 8vh, 88px) 0;
  }

  h2 {
    font-size: clamp(28px, 3.2vw, 44px);
    font-weight: 800;
    line-height: 1.05;
    text-align: center;
  }
  h2 em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    letter-spacing: -0.02em;
    color: var(--hotpink);
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0;
    margin: clamp(32px, 5vh, 52px) auto 0;
    max-width: 1060px;
  }

  .stat {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 8px 18px;
    border-left: 1px solid rgba(15, 17, 21, 0.1);
  }
  .stat:first-child { border-left: none; }

  .num {
    font-family: var(--display);
    font-weight: 800;
    letter-spacing: -0.05em;
    line-height: 0.9;
    font-size: clamp(44px, 5.4vw, 84px);
    color: var(--c);
    white-space: nowrap;
  }
  .num i {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    font-size: 0.32em;
    letter-spacing: -0.01em;
    margin-left: 0.12em;
    color: var(--ink);
    opacity: 0.75;
  }

  .lab { margin-top: 10px; color: var(--ink); opacity: 0.85; }
  .note {
    margin-top: 6px;
    font-size: 13px;
    line-height: 1.5;
    color: var(--ink);
    opacity: 0.55;
    max-width: 20ch;
  }

  .foot {
    text-align: center;
    margin-top: clamp(28px, 4vh, 44px);
    opacity: 0.7;
    text-transform: none;
    letter-spacing: 0.04em;
  }

  @media (max-width: 900px) {
    .stats { grid-template-columns: 1fr 1fr; gap: 36px 0; }
    .stat:nth-child(3) { border-left: none; }
  }
  @media (max-width: 540px) {
    .stats { grid-template-columns: 1fr; gap: 40px; }
    .stat { border-left: none; }
  }
</style>
