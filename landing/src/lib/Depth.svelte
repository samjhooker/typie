<script>
  import { reveal } from './reveal.js';

  const STATS = [
    {
      n: '80',
      unit: 'ms',
      label: 'Keystroke Latency',
      color: '#fc5681',
      note: 'Faster than your finger lifts off the key',
    },
    {
      n: '25',
      unit: 'langs',
      label: 'European Languages',
      color: '#6f8ffb',
      note: 'Speech model running locally',
    },
    {
      n: '0',
      unit: 'bytes',
      label: 'Network Egress',
      color: '#0f9d6a',
      note: 'No server exists to receive your voice',
    },
    {
      n: '100',
      unit: '%',
      label: 'Free & Open Source',
      color: '#c88cfd',
      note: 'MIT license, no credit card or account',
    },
  ];
</script>

<section
  class="depth"
  id="engine"
>
  <div class="container">
    <div
      class="head"
      use:reveal
    >
      <h2>Engineered for physics, not <em>promises.</em></h2>
      <p class="sub">
        Local execution eliminates network round-trips, subscriptions, and
        privacy risk.
      </p>
    </div>

    <div class="stats">
      {#each STATS as s, i (s.label)}
        <div
          class="stat"
          use:reveal={{ delay: i * 90 }}
          style="--c:{s.color}"
        >
          <span class="num">{s.n}<i>{s.unit}</i></span>
          <span class="lab">{s.label}</span>
          <span class="note">{s.note}</span>
        </div>
      {/each}
    </div>

    <p
      class="meta foot mono"
      use:reveal={{ delay: 120 }}
    >
      On-device ASR · Apple Silicon FluidAudio · MIT License · Local Inference
    </p>
  </div>
</section>

<style>
  .depth {
    background: var(--surface);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
    padding: clamp(64px, 10vh, 100px) 0;
  }

  .head {
    text-align: center;
    max-width: 740px;
    margin: 0 auto;
  }

  h2 {
    font-size: clamp(30px, 3.8vw, 48px);
    font-weight: 800;
    line-height: 1.05;
    color: var(--ink);
  }
  h2 em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    letter-spacing: -0.02em;
    color: var(--hotpink);
  }

  .sub {
    margin-top: 14px;
    font-size: 16px;
    color: var(--text-2);
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0;
    margin: clamp(40px, 6vh, 60px) auto 0;
    max-width: 1080px;
  }

  .stat {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 12px 20px;
    border-left: 1px solid var(--line);
  }
  .stat:first-child {
    border-left: none;
  }

  .num {
    font-family: var(--display);
    font-weight: 800;
    letter-spacing: -0.05em;
    line-height: 0.9;
    font-size: clamp(48px, 5.8vw, 88px);
    color: var(--c);
    white-space: nowrap;
  }
  .num i {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    font-size: 0.34em;
    letter-spacing: -0.01em;
    margin-left: 0.12em;
    color: var(--ink);
    opacity: 0.75;
  }

  .lab {
    margin-top: 12px;
    font-family: var(--display);
    font-size: 14px;
    font-weight: 700;
    color: var(--ink);
  }
  .note {
    margin-top: 6px;
    font-size: 13px;
    line-height: 1.45;
    color: var(--text-3);
    max-width: 22ch;
  }

  .foot {
    text-align: center;
    margin-top: clamp(36px, 5vh, 52px);
    color: var(--text-3);
    font-size: 11.5px;
  }

  @media (max-width: 900px) {
    .stats {
      grid-template-columns: 1fr 1fr;
      gap: 36px 0;
    }
    .stat:nth-child(3) {
      border-left: none;
    }
  }
  @media (max-width: 540px) {
    .stats {
      grid-template-columns: 1fr;
      gap: 40px;
    }
    .stat {
      border-left: none;
    }
  }
</style>
