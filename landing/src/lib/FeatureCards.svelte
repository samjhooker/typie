<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import Robot from './Robot.svelte';

  /* fallback art is inline svg / robot glyph until final illustrations land */
</script>

<section class="features field" id="features">
  <div class="container grid">
    <!-- Talk naturally -->
    <article class="card c-lavender" use:reveal>
      <div class="txt">
        <h3>Talk naturally</h3>
        <p>Speak like you do in real life. Typie handles the rest.</p>
      </div>
      <div class="art">
        <AssetSlot id="feature-talk" width="100%">
          {#snippet fallback()}
            <svg class="wave" viewBox="0 0 120 60" aria-hidden="true">
              <g stroke="var(--purple)" stroke-width="4" stroke-linecap="round">
                <line x1="8" y1="24" x2="8" y2="36" />
                <line x1="22" y1="16" x2="22" y2="44" />
                <line x1="36" y1="22" x2="36" y2="38" />
                <line x1="50" y1="8" x2="50" y2="52" />
                <line x1="64" y1="18" x2="64" y2="42" />
                <line x1="78" y1="12" x2="78" y2="48" />
                <line x1="92" y1="24" x2="92" y2="36" />
              </g>
            </svg>
            <Robot size={72} mood="listening" eye="#fc5681" />
          {/snippet}
        </AssetSlot>
      </div>
    </article>

    <!-- Keep your words private -->
    <article class="card c-blue" use:reveal={{ delay: 80 }}>
      <div class="txt">
        <h3>Keep your words private</h3>
        <p>100% offline. Your audio never leaves your Mac.</p>
      </div>
      <div class="art">
        <AssetSlot id="feature-privacy" width="100%">
          {#snippet fallback()}
            <svg class="lock" viewBox="0 0 64 64" aria-hidden="true">
              <rect x="10" y="26" width="44" height="32" rx="9" fill="#5b7cfa" />
              <path d="M20 26v-6a12 12 0 0 1 24 0v6" fill="none" stroke="#5b7cfa" stroke-width="7" stroke-linecap="round" />
              <circle cx="32" cy="40" r="5" fill="#fffdf7" />
              <rect x="30" y="42" width="4" height="8" rx="2" fill="#fffdf7" />
            </svg>
            <span class="sparkle" aria-hidden="true">✦</span>
          {/snippet}
        </AssetSlot>
      </div>
    </article>

    <!-- Use it everywhere -->
    <article class="card c-cream" use:reveal>
      <div class="txt">
        <h3>Use it everywhere</h3>
        <p>Any app, any field, any time.</p>
      </div>
      <div class="art">
        <AssetSlot id="feature-everywhere" width="100%">
          {#snippet fallback()}
            <Robot size={78} mood="idle" eye="#f5a623" />
            <span class="orbit o1" aria-hidden="true">💬</span>
            <span class="orbit o2" aria-hidden="true">📝</span>
            <span class="orbit o3" aria-hidden="true">✉️</span>
          {/snippet}
        </AssetSlot>
      </div>
    </article>

    <!-- Never break your flow -->
    <article class="card c-mint" use:reveal={{ delay: 80 }}>
      <div class="txt">
        <h3>Never break your flow</h3>
        <p>Hold <i class="keyhint mono">&#8997;</i>, speak, release. Back to what you were doing.</p>
      </div>
      <div class="art">
        <AssetSlot id="feature-flow" width="100%">
          {#snippet fallback()}
            <svg class="keycap" viewBox="0 0 90 70" aria-hidden="true">
              <rect x="14" y="38" width="62" height="20" rx="6" fill="#20242e" />
              <rect x="8" y="8" width="74" height="46" rx="10" fill="#2c3342" />
              <text x="45" y="38" text-anchor="middle" font-size="24" font-weight="600" fill="#fffdf7" font-family="monospace">&#8997;</text>
            </svg>
          {/snippet}
        </AssetSlot>
      </div>
    </article>
  </div>
</section>

<style>
  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: clamp(16px, 2.4vw, 28px);
  }

  .card {
    border-radius: var(--radius-card);
    padding: clamp(26px, 3vw, 40px);
    display: grid;
    grid-template-columns: 1.15fr 1fr;
    gap: 20px;
    align-items: center;
    min-height: 190px;
  }

  .c-lavender { background: var(--card-lavender); }
  .c-blue { background: var(--card-blue); }
  .c-cream { background: var(--card-cream); }
  .c-mint { background: var(--card-mint); }

  h3 {
    font-size: clamp(19px, 1.8vw, 23px);
    letter-spacing: -0.02em;
    margin-bottom: 10px;
    color: var(--ink);
  }

  p {
    font-size: 15px;
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.72);
    max-width: 24ch;
  }

  .keyhint {
    background: var(--ink);
    color: var(--cream);
    border-radius: 6px;
    padding: 2px 6px;
    letter-spacing: 0;
    text-transform: none;
    font-size: 12px;
  }

  .art {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 110px;
  }

  .wave {
    width: 110px;
    height: auto;
    margin-right: 8px;
  }

  .wave line {
    animation: bounce 1s ease-in-out infinite alternate;
  }
  .wave line:nth-child(2n) { animation-delay: 0.15s; }
  .wave line:nth-child(3n) { animation-delay: 0.3s; }

  @keyframes bounce {
    from { transform: scaleX(1); }
    to { transform: scaleX(1.35); }
  }

  .lock {
    width: 96px;
    height: auto;
  }

  .sparkle {
    position: absolute;
    left: 8%;
    bottom: 6%;
    color: #ffd66b;
    font-size: 26px;
    transform: rotate(-12deg);
  }

  .orbit {
    position: absolute;
    font-size: 22px;
    line-height: 1;
    animation: floaty 4s ease-in-out infinite;
  }

  .o1 { top: -4%; left: 4%; }
  .o2 { top: 12%; right: 0%; animation-delay: 0.7s; }
  .o3 { bottom: -2%; right: 12%; animation-delay: 1.3s; }

  @keyframes floaty {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
  }

  .keycap {
    width: 104px;
    height: auto;
    transform: rotate(-6deg);
  }

  @media (max-width: 860px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }

  @media (max-width: 480px) {
    .card {
      grid-template-columns: 1fr;
    }

    p {
      max-width: none;
    }
  }
</style>
