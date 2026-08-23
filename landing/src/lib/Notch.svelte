<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  /* cycles the three notch states so the band demos itself */
  let active = $state(0);
  const STATES = ['Idle', 'Listening', 'Typed'];

  $effect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const t = setInterval(() => (active = (active + 1) % 3), 2600);
    return () => clearInterval(t);
  });
</script>

<section class="notchband field">
  <div class="container">
    <div class="panel" use:reveal>
      <div class="copy">
        <h2>It lives in your notch</h2>
        <p>Always there when you need it, never in your way.</p>
      </div>

      <div class="states">
        {#each STATES as label, i}
          <div class="state" class:on={active === i}>
            <div class="pill">
              {#if i === 0}
                <span class="bot"><Robot size={20} mood="idle" /></span>
                <span class="name">typie</span>
              {:else if i === 1}
                <span class="mono k">&#8997;</span>
                <span class="listen mono">listening…</span>
                <span class="weq" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><i></i><i></i></span>
              {:else}
                <span class="mono k">&#8997;</span>
                <span class="typed">“I’ll send it over tonight.”</span>
              {/if}
            </div>
            <span class="label">{label}</span>
          </div>
        {/each}
      </div>
    </div>
  </div>
</section>

<style>
  .panel {
    background: var(--pink-band);
    border-radius: 28px;
    padding: clamp(32px, 4.5vw, 60px);
    display: grid;
    grid-template-columns: 1fr 1.3fr;
    gap: clamp(28px, 4vw, 64px);
    align-items: center;
  }

  h2 {
    font-size: clamp(24px, 2.6vw, 34px);
    letter-spacing: -0.03em;
    margin-bottom: 10px;
    color: var(--ink);
  }

  .copy p {
    color: rgba(19, 23, 34, 0.7);
    max-width: 26ch;
  }

  .states {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .state {
    display: flex;
    align-items: center;
    gap: 16px;
    opacity: 0.45;
    transform: translateX(-6px);
    transition: opacity 0.5s ease, transform 0.5s var(--ease-out);
  }

  .state.on {
    opacity: 1;
    transform: none;
  }

  .pill {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 12px;
    background: #10131a;
    border-radius: 999px;
    padding: 12px 22px;
    min-height: 52px;
    box-shadow: 0 6px 18px rgba(19, 23, 34, 0.25);
  }

  .label {
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: rgba(19, 23, 34, 0.55);
    width: 76px;
  }

  .state.on .label {
    color: var(--ink);
  }

  .bot {
    line-height: 0;
  }

  .name {
    color: #fffdf7;
    font-weight: 700;
    font-size: 15px;
    margin-inline: auto;
  }

  .k {
    color: rgba(255, 253, 247, 0.55);
    text-transform: none;
    letter-spacing: 0;
  }

  .listen {
    color: var(--hotpink);
  }

  .weq {
    display: inline-flex;
    align-items: center;
    gap: 3px;
    height: 18px;
    margin-inline: auto;
  }

  .weq i {
    width: 3px;
    border-radius: 2px;
    background: var(--hotpink);
    animation: eq 0.9s ease-in-out infinite alternate;
  }

  .weq i:nth-child(1) { height: 30%; }
  .weq i:nth-child(2) { height: 70%; animation-delay: 0.1s; }
  .weq i:nth-child(3) { height: 100%; animation-delay: 0.2s; }
  .weq i:nth-child(4) { height: 55%; animation-delay: 0.3s; }
  .weq i:nth-child(5) { height: 90%; animation-delay: 0.15s; }
  .weq i:nth-child(6) { height: 40%; animation-delay: 0.35s; }
  .weq i:nth-child(7) { height: 65%; animation-delay: 0.05s; }

  @keyframes eq {
    from { transform: scaleY(0.4); }
    to { transform: scaleY(1); }
  }

  .typed {
    color: #fffdf7;
    font-size: 14.5px;
    font-weight: 500;
    margin-inline: auto;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  @media (max-width: 860px) {
    .panel {
      grid-template-columns: 1fr;
    }

    .copy p {
      max-width: none;
    }

    .typed {
      white-space: normal;
    }
  }

  @media (max-width: 520px) {
    .label {
      display: none;
    }
  }
</style>
