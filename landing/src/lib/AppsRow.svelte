<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import { nsSvg } from './svgid.js';
  import { APP_ROWS } from './apps.js';

  const loops = APP_ROWS.map((row) => [...row, ...row, ...row, ...row]);
</script>

<section class="apps field" id="use-cases">
  <div class="container">
    <p class="hand kicker" use:reveal>works wherever you type</p>
    <h2 class="subhead" use:reveal>
      If your cursor blinks there, Typie types there
    </h2>
    <p class="lede" use:reveal={{ delay: 40 }}>
      No window to switch to. No pasting. Just real keystrokes — in any app, any field.
    </p>
  </div>

  <div class="container marquee" use:reveal={{ delay: 80 }}>
    <span class="peekbot" aria-hidden="true"><Robot size={48} mood="idle" /></span>
    {#each loops as loop, i}
      <div class="viewport">
        <ul class="track" class:reverse={i === 1} aria-hidden={false}>
          {#each loop as app, j}
            <li class="card" aria-hidden={j >= loop.length / 4}>
              <i class="ic">{@html nsSvg(app.s, `app-${i}-${j}-${app.n}`)}</i>
              <span>{app.n}</span>
            </li>
          {/each}
        </ul>
      </div>
    {/each}
  </div>
</section>

<style>
  .apps {
    padding-bottom: clamp(52px, 7vh, 84px);
    overflow: visible;
    background: transparent;
  }

  .kicker {
    text-align: center;
    font-size: clamp(20px, 2vw, 24px);
    color: var(--hotpink);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  .subhead {
    text-align: center;
    font-size: clamp(28px, 4vw, 44px);
    font-weight: 800;
    line-height: 1.1;
    letter-spacing: -0.03em;
    color: #0a0a0a;
    font-family: var(--display);
    max-width: 700px;
    margin: 0 auto;
  }

  .lede {
    margin: 16px auto 0;
    max-width: 44rem;
    text-align: center;
    color: rgba(19, 23, 34, 0.68);
    line-height: 1.6;
    font-size: clamp(16px, 1.5vw, 18px);
  }

  .marquee {
    position: relative;
    margin-top: clamp(44px, 6vh, 68px);
    display: flex;
    flex-direction: column;
    gap: 16px;
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

  .track.reverse {
    animation-duration: 72s;
    animation-direction: reverse;
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
    border-radius: var(--radius-card);
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.06);
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
    .track,
    .track.reverse {
      animation: none;
    }

    .viewport {
      overflow-x: auto;
    }
  }
</style>