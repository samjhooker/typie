<script>
  /* the dock: three tiles, one job each */
  import Robot from './Robot.svelte';
  import { blip } from './sound.svelte.js';
  import { ripple } from './ripple.js';

  const tiles = [
    { href: '#top', label: 'typie home', kind: 'bot' },
    { href: '#versus', label: 'the comparison', kind: 'vs' },
    { href: '#pricing', label: 'the price', kind: '$' }
  ];
</script>

<div class="dock" role="navigation" aria-label="quick jumps">
  {#each tiles as t}
    <a
      href={t.href}
      class="tile"
      aria-label={t.label}
      onclick={() => blip(500, 0.06, 'square', 0.03)}
    >
      {#if t.kind === 'bot'}
        <span class="bot"><Robot size={26} mood="idle" /></span>
      {:else}
        <b>{t.kind}</b>
      {/if}
    </a>
  {/each}

  <span class="divider" aria-hidden="true"></span>

  <a
    href="https://github.com/samjhooker/typie/releases/latest"
    class="tile dl"
    use:ripple
    aria-label="download typie"
  >
    <svg viewBox="0 0 384 512" aria-hidden="true"><path fill="currentColor" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
  </a>
</div>

<style>
  .dock {
    position: fixed;
    bottom: 10px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 210;
    display: flex;
    align-items: flex-end;
    gap: 8px;
    padding: 7px 10px;
    border-radius: 22px;
    background: color-mix(in srgb, var(--page) 72%, transparent);
    backdrop-filter: blur(18px) saturate(160%);
    -webkit-backdrop-filter: blur(18px) saturate(160%);
    border: 1px solid rgba(19, 23, 34, 0.1);
    box-shadow: 0 14px 34px rgba(19, 23, 34, 0.18);
  }

  .tile {
    display: grid;
    place-items: center;
    width: 44px;
    height: 44px;
    border-radius: 11px;
    background: #fffdf7;
    border: 1.5px solid rgba(19, 23, 34, 0.35);
    color: var(--ink);
    transition:
      transform 0.28s var(--spring),
      box-shadow 0.28s var(--ease-out);
    transform-origin: bottom center;
  }

  .tile:hover {
    transform: translateY(-9px) scale(1.14);
    box-shadow: 0 10px 18px rgba(19, 23, 34, 0.22);
  }

  .bot {
    line-height: 0;
    color: var(--hotpink);
  }

  b {
    font-family: var(--display);
    font-size: 17px;
    font-weight: 800;
  }

  .divider {
    width: 1.5px;
    align-self: stretch;
    margin-block: 4px;
    background: rgba(19, 23, 34, 0.15);
    border-radius: 999px;
  }

  .dl {
    background: var(--ink);
    border-color: var(--ink);
    color: #fffdf7;
  }

  .dl svg {
    width: 19px;
    height: 22px;
    margin-top: -2px;
  }

  @media (max-width: 720px), (pointer: coarse) {
    .dock {
      display: none;
    }
  }
</style>
