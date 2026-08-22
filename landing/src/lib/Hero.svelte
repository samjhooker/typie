<script>
  import HoldStage from './HoldStage.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import { app } from './state.svelte.js';
  import { hold } from './hold.svelte.js';

  const TYPED = 'TYPED.';

  let reduced = false;
  let press = $state(false);
  let holdWord = $state(false);
  let say = $state(false);
  let typedN = $state(0);
  let sub = $state(false);
  let ctas = $state(false);
  let stage = $state(false);

  $effect(() => {
    reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) {
      press = holdWord = say = stage = sub = ctas = true;
      typedN = TYPED.length;
      return;
    }
    const t = [];
    t.push(setTimeout(() => (press = true), 140));
    t.push(setTimeout(() => (holdWord = true), 400));
    t.push(setTimeout(() => (say = true), 540));
    t.push(setTimeout(() => {
      let i = 0;
      const step = () => {
        typedN = ++i;
        if (i < TYPED.length) t.push(setTimeout(step, 50));
      };
      step();
    }, 700));
    t.push(setTimeout(() => (sub = true), 1150));
    t.push(setTimeout(() => (ctas = true), 1300));
    t.push(setTimeout(() => (stage = true), 1450));
    return () => t.forEach(clearTimeout);
  });

  function tap(e) {
    if (e?.button != null && e.button !== 0) return;
    hold.press();
  }
</script>

<section class="hero field" id="top" class:live={app.mood === 'listening'}>
  <div class="demo" id="how" class:in={stage}>
    <HoldStage />
  </div>

  <div class="container intro">
    <h1>
      <span class="w c-ink" class:in={press}>PRESS.</span>{' '}
      <button
        class="w hold-key"
        class:in={holdWord}
        class:down={app.mood === 'listening'}
        aria-label="Press option to try Typie"
        onclick={tap}
      >HOLD.</button>
      <br />
      <span class="w c-pink" class:in={say}>SAY IT.</span>{' '}
      <span class="w outline" class:in={typedN > 0}>
        {TYPED.slice(0, typedN)}{#if typedN > 0 && typedN < TYPED.length}<span class="caret"></span>{/if}
      </span>
    </h1>

    <p class="lede" class:in={sub}>
      Hold option. Speak. Voice dictation that just works - your words appear in
      whatever app you're in, <strong>in under 100 milliseconds</strong>, entirely
      on this Mac. Never on a server.
    </p>

    <div class="ctas" class:in={ctas}>
      <DownloadCta />
    </div>

    <p class="specs mono" class:in={ctas}>
      macOS 14+ · apple silicon · ~8 mb app · offline forever · $0
    </p>
  </div>
</section>

<style>
  .hero {
    padding: 148px 0 48px;
    text-align: center;
    background: var(--paper);
    transition: background-color 0.45s ease;
    overflow: hidden;
  }

  .hero.live { background: #eef9f2; }

  .intro {
    max-width: 980px;
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: clamp(40px, 6vh, 64px);
  }

  h1 {
    font-size: clamp(48px, 9vw, 122px);
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: -0.015em;
    line-height: 0.94;
    color: var(--ink);
    position: relative;
    z-index: 1;
  }

  .w {
    display: inline-block;
    position: relative;
    opacity: 0;
  }

  .w.in { animation: stamp 0.45s var(--spring) forwards; }

  .c-ink { color: var(--ink); }

  .c-pink {
    color: var(--periwinkle);
  }

  .outline,
  .outline.in {
    color: var(--butter);
    text-shadow: 0.055em 0.055em 0 var(--ink);
    font-style: italic;
    animation: none;
    opacity: 1;
  }

  .hold-key {
    cursor: pointer;
    font: inherit;
    font-weight: 800;
    letter-spacing: inherit;
    line-height: inherit;
    text-transform: inherit;
    color: var(--hotpink);
    transition: transform 0.15s ease, color 0.15s ease;
  }

  .hold-key:hover { color: #e63a67; }

  .hold-key.down { transform: translateY(3px) scale(0.98); }

  .caret {
    display: inline-block;
    width: 0.07em;
    height: 0.78em;
    background: var(--hotpink);
    margin-left: 2px;
    vertical-align: -0.02em;
    animation: caret 0.85s steps(1) infinite;
  }

  @keyframes caret {
    50% { opacity: 0; }
  }

  .lede {
    margin-top: 26px;
    max-width: 52ch;
    font-size: clamp(17px, 1.9vw, 21px);
    line-height: 1.5;
    color: rgba(19, 23, 34, 0.68);
    opacity: 0;
    transform: translateY(8px);
    transition: opacity 0.5s ease, transform 0.5s var(--ease-out);
  }

  .lede strong {
    color: var(--ink);
    background: linear-gradient(transparent 70%, rgba(252, 86, 129, 0.35) 70%);
  }

  .lede.in { opacity: 1; transform: none; }

  .ctas {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    justify-content: center;
    margin-top: 30px;
    opacity: 0;
    transform: translateY(10px);
    transition: opacity 0.5s ease, transform 0.5s var(--ease-out);
  }

  .ctas.in { opacity: 1; transform: none; }

  .specs {
    margin-top: 20px;
    opacity: 0;
    transition: opacity 0.6s ease 0.15s;
  }

  .specs.in { opacity: 1; }

  .demo {
    margin-top: 8px;
    position: relative;
    z-index: 1;
    scroll-margin-top: 120px;
    opacity: 0;
    transform: translateY(18px);
    transition: opacity 0.7s ease, transform 0.7s var(--ease-out);
  }

  .demo.in { opacity: 1; transform: none; }

  @media (max-width: 900px) {
    .hero { padding-top: 124px; }
  }
</style>
