<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import { nsSvg } from './svgid.js';
  import { APPS } from './apps.js';

  const loop = [...APPS, ...APPS, ...APPS, ...APPS];
</script>

<section
  class="apps"
  id="apps"
>
  <div class="container">
    <div
      class="head"
      use:reveal
    >
      <h2 class="subhead">
        If your cursor <em>blinks</em> there,<br />Typie types there.
      </h2>
      <p class="sub">
        Synthetic keyboard events straight into the active window. No per-app
        plugins or clipboard hacks.
      </p>
    </div>
  </div>

  <div
    class="container marquee"
    use:reveal={{ delay: 80 }}
  >
    <span
      class="peekbot"
      aria-hidden="true"
      ><Robot
        size={46}
        mood="listening"
      /></span
    >
    <div class="viewport">
      <ul class="track">
        {#each loop as app, j}
          <li
            class="card"
            aria-hidden={j >= loop.length / 4}
          >
            <i class="ic">{@html nsSvg(app.s, `app-${j}-${app.n}`)}</i>
            <span>{app.n}</span>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>

<style>
  .apps {
    padding: clamp(70px, 10vh, 110px) 0;
    overflow: visible;
  }

  .head {
    text-align: center;
    max-width: 760px;
    margin: 0 auto;
  }

  .subhead {
    font-size: clamp(32px, 4.4vw, 54px);
    font-weight: 800;
    line-height: 1.05;
    letter-spacing: -0.035em;
    color: var(--ink);
  }
  .subhead em {
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

  .marquee {
    position: relative;
    margin-top: clamp(40px, 5vh, 60px);
  }

  .peekbot {
    position: absolute;
    top: -38px;
    right: clamp(20px, 8vw, 120px);
    z-index: 2;
    line-height: 0;
    color: var(--hotpink);
    transform: rotate(10deg);
    animation: peeksneak 5s var(--ease-inout) infinite;
  }

  @keyframes peeksneak {
    0%,
    100% {
      transform: rotate(10deg) translateY(0);
    }
    50% {
      transform: rotate(6deg) translateY(6px);
    }
  }

  .viewport {
    overflow: hidden;
    padding-block: 14px;
    margin-block: -14px;
    mask-image: linear-gradient(
      90deg,
      transparent,
      #000 6%,
      #000 94%,
      transparent
    );
    -webkit-mask-image: linear-gradient(
      90deg,
      transparent,
      #000 6%,
      #000 94%,
      transparent
    );
  }

  .track {
    list-style: none;
    display: flex;
    gap: 14px;
    width: max-content;
    padding-inline: 14px;
    animation: marquee 50s linear infinite;
  }

  @keyframes marquee {
    to {
      transform: translateX(-25%);
    }
  }

  .card {
    position: relative;
    z-index: 0;
    flex: 0 0 auto;
    width: 124px;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.04);
    padding: 20px 12px 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    font-size: 13px;
    font-weight: 700;
    color: var(--ink);
    white-space: nowrap;
    transition:
      transform 0.25s var(--spring),
      box-shadow 0.25s var(--ease-out),
      border-color 0.2s ease;
  }

  .card:hover {
    z-index: 3;
    transform: translateY(-6px) scale(1.06);
    border-color: var(--hotpink);
    box-shadow: 0 16px 32px rgba(0, 0, 0, 0.08);
  }

  .ic {
    width: 38px;
    height: 38px;
    line-height: 0;
  }

  .ic :global(svg) {
    width: 100%;
    height: 100%;
  }

  @media (max-width: 560px) {
    .card {
      width: 106px;
      padding: 16px 8px 14px;
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
