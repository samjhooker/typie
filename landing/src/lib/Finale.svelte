<script>
  import Logo from './Logo.svelte';
  import Robot from './Robot.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import { reveal } from './reveal.js';

  const WORD = 'TYPIE.';
  let typed = $state(0);
  let inView = $state(false);

  function onView(node) {
    const io = new IntersectionObserver(([e]) => {
      if (!e.isIntersecting) return;
      io.disconnect();
      inView = true;
      if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
        typed = WORD.length;
        return;
      }
      let i = 0;
      const step = () => {
        typed = ++i;
        if (i < WORD.length) setTimeout(step, 80);
      };
      setTimeout(step, 350);
    }, { threshold: 0.3 });
    io.observe(node);
    return { destroy() { io.disconnect(); } };
  }
</script>

<section id="get" class="field field-mint finale" use:onView>
  <div class="container inner">
    <div class="mascot-wrap glyph" use:reveal>
      <Robot mood="done" size={120} />
    </div>

    <h2 class="giant">
      <span class="get" use:reveal>GET</span>
      <span class="grad">{WORD.slice(0, typed)}</span>
    </h2>

    <p class="hand aside" use:reveal={{ delay: 120 }}>it's free. it was always going to be free.</p>

    <div class="ctas" use:reveal={{ delay: 200 }}>
      <DownloadCta big />
      <a href="#top" class="btn btn-ghost">Still unsure? Scroll up ↑</a>
    </div>

    <ul class="chips" use:reveal={{ delay: 280 }}>
      <li class="mono">macOS 14+</li>
      <li class="mono">~500 mb model, once</li>
      <li class="mono">&lt;100 ms</li>
      <li class="mono">zero accounts</li>
    </ul>
  </div>

  <footer>
    <div class="foot">
      <Logo size={17} />
      <p>voice dictation for mac · a tiny robot with one job · © 2026 · no clouds were involved</p>
      <nav class="links">
        <a href="/about">about</a>
        <a href="/privacy">privacy</a>
      </nav>
    </div>
    <span class="wm" aria-hidden="true">typie</span>
  </footer>
</section>

<style>
  .finale {
    display: flex;
    flex-direction: column;
    overflow: hidden;
    text-align: center;
  }

  .inner {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex: 1;
  }

  .mascot-wrap :global(.robot) {
    color: var(--hotpink);
    margin-bottom: 8px;
  }

  .giant {
    font-family: var(--display);
    font-weight: 800;
    text-transform: uppercase;
    font-size: clamp(60px, 12vw, 156px);
    line-height: 0.9;
    letter-spacing: -0.015em;
    color: var(--green-deep);
    display: flex;
    gap: 0.18em;
    flex-wrap: wrap;
    justify-content: center;
  }

  .grad {
    font-style: italic;
    color: var(--hotpink);
    text-shadow: 4px 4px 0 rgba(19, 23, 34, 0.18);
    min-width: 1em;
    text-align: left;
  }

  .aside {
    margin-top: 18px;
    font-size: clamp(19px, 2.2vw, 25px);
    color: var(--green-deep);
    transform: rotate(-2deg);
  }

  .ctas {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    justify-content: center;
    margin-top: 32px;
  }

  .big {
    padding: 18px 34px;
    font-size: 16px;
    box-shadow: 0 6px 0 rgba(19, 23, 34, 0.85);
  }

  .chips {
    list-style: none;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    justify-content: center;
    margin-top: 26px;
  }

  .chips li {
    padding: 8px 16px;
    border-radius: 999px;
    background: rgba(255, 253, 247, 0.75);
    border: 2px solid rgba(2, 89, 77, 0.14);
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--green-deep);
  }

  footer {
    margin-top: clamp(64px, 9vh, 110px);
    width: 100vw;
    background: var(--ink);
    color: var(--cream);
    padding: 44px 24px 30px;
    position: relative;
    overflow: hidden;
  }

  .foot {
    width: min(1180px, 100%);
    margin-inline: auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    font-size: 13.5px;
    position: relative;
    z-index: 1;
  }

  .foot p {
    opacity: 0.85;
  }

  .links {
    display: flex;
    gap: 18px;
  }

  .links a {
    font-family: var(--display);
    font-weight: 700;
  }

  .links a:hover {
    color: var(--mint);
  }

  .wm {
    position: absolute;
    left: 50%;
    bottom: -28px;
    transform: translateX(-50%);
    font-family: var(--display);
    font-weight: 900;
    font-style: italic;
    font-size: clamp(80px, 18vw, 220px);
    letter-spacing: -0.06em;
    color: rgba(249, 248, 244, 0.05);
    pointer-events: none;
    line-height: 0.8;
  }
</style>
