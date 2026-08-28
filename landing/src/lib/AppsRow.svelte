<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import { nsSvg } from './svgid.js';
  import { APPS } from './apps.js';

  // one marquee row — it earns its place, it doesn't get three
  const loop = [...APPS, ...APPS, ...APPS, ...APPS];
</script>

<section class="apps" id="use-cases">
  <div class="container">
    <h2 class="subhead" use:reveal>
      If your cursor <em>blinks</em> there,<br />Typie types there
    </h2>
  </div>

  <div class="container marquee" use:reveal={{ delay: 80 }}>
    <span class="peekbot" aria-hidden="true"><Robot size={48} mood="idle" /></span>
    <div class="viewport">
      <ul class="track">
        {#each loop as app, j}
          <li class="card" aria-hidden={j >= loop.length / 4}>
            <i class="ic">{@html nsSvg(app.s, `app-${j}-${app.n}`)}</i>
            <span>{app.n}</span>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>

<style>
  /* fast section — the rhythm lives between the slow beats */
  .apps {
    padding: clamp(80px, 12vh, 132px) 0;
    overflow: visible;
    background: transparent;
  }

  .subhead {
    text-align: center;
    font-size: clamp(30px, 4.2vw, 52px);
    font-weight: 800;
    line-height: 1.08;
    letter-spacing: -0.035em;
    color: #0a0a0a;
    font-family: var(--display);
    max-width: 760px;
    margin: 0 auto;
  }
  .subhead em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    letter-spacing: -0.02em;
    color: var(--hotpink);
  }

  .marquee {
    position: relative;
    margin-top: clamp(44px, 6vh, 68px);
  }

  .peekbot {
    position: absolute;
    top: -42px;
    right: clamp(16px, 8vw, 120px);
    z-index: 2;
    line-height: 0;
    color: var(--hotpink);
    transform: rotate(10deg);
    animation: peeksneak 5s var(--ease-inout) infinite;
  }

  @keyframes peeksneak {
    0%, 100% { transform: rotate(10deg) translateY(0); }
    50% { transform: rotate(6deg) translateY(6px); }
  }

  .viewport {
    overflow: hidden;
    padding-block: 12px;
    margin-block: -12px;
    mask-image: linear-gradient(90deg, transparent, #000 5%, #000 95%, transparent);
    -webkit-mask-image: linear-gradient(90deg, transparent, #000 5%, #000 95%, transparent);
  }

  .track {
    list-style: none;
    display: flex;
    gap: 12px;
    width: max-content;
    padding-inline: 12px;
    animation: marquee 56s linear infinite;
  }

  @keyframes marquee {
    to { transform: translateX(-25%); }
  }

  .card {
    position: relative;
    z-index: 0;
    flex: 0 0 auto;
    width: 118px;
    background: #fff;
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.05);
    padding: 18px 10px 14px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    font-size: 12.5px;
    font-weight: 600;
    color: var(--ink);
    white-space: nowrap;
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.3s var(--ease-out);
  }

  .card:hover {
    z-index: 3;
    transform: translateY(-6px) scale(1.07) rotate(-1.2deg);
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.12);
  }

  .ic {
    width: 36px;
    height: 36px;
    line-height: 0;
  }

  .ic :global(svg) {
    width: 100%;
    height: 100%;
  }

  @media (max-width: 560px) {
    .card {
      width: 100px;
      padding: 14px 8px 12px;
    }

    .track {
      gap: 10px;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .track {
      animation: none;
    }

    .viewport {
      overflow-x: auto;
    }
  }
</style>
