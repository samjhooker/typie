<script>
  import HoldStage from './HoldStage.svelte';
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

<section class="hero field field-mint" id="top" class:live={app.mood === 'listening'}>
  <div class="sticker s1 hand" aria-hidden="true">no cloud, ever ↓</div>
  <div class="sticker s2 hand" aria-hidden="true">under 100 ms ⚡</div>

  <div class="container intro">
    <h1>
      <span class="w c-green" class:in={press}>PRESS.</span>
      <button
        class="w c-pink hold-key"
        class:in={holdWord}
        class:down={app.mood === 'listening'}
        aria-label="Press option to try Typie"
        onclick={tap}
      >HOLD.</button>
      <br />
      <span class="w hl" class:in={say}>SAY IT.</span>
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
      <a href="#get" class="btn btn-green">Download free for Mac</a>
    </div>

    <p class="specs mono" class:in={ctas}>
      macOS 14+ · apple silicon · ~8 mb app · offline forever · $0
    </p>
  </div>

  <div class="demo" id="how" class:in={stage}>
    <HoldStage />
  </div>
</section>

<style>
  .hero {
    padding: 148px 0 48px;
    text-align: center;
    transition: background-color 0.45s ease;
    overflow: hidden;
  }

  .hero.live { background: var(--mint-live); }

  .intro {
    max-width: 980px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  h1 {
    font-size: clamp(46px, 8.6vw, 108px);
    font-weight: 900;
    text-transform: uppercase;
    letter-spacing: -0.04em;
    line-height: 0.92;
    color: var(--green);
  }

  .w {
    display: inline-block;
    position: relative;
    opacity: 0;
  }

  .w.in { animation: stamp 0.45s var(--spring) forwards; }

  .c-green { color: var(--green); }

  .c-pink {
    color: var(--hotpink);
    transition: transform 0.15s ease;
  }

  .hl {
    background: linear-gradient(transparent 12%, var(--butter) 12%, var(--butter) 90%, transparent 90%);
    padding-inline: 0.08em;
    color: var(--green);
  }

  .outline,
  .outline.in {
    color: var(--cream);
    -webkit-text-stroke: 2.5px var(--green-deep);
    text-shadow: 4px 4px 0 rgba(2, 89, 77, 0.22);
    font-style: italic;
    animation: none;
    opacity: 1;
  }

  .hold-key {
    cursor: pointer;
    font: inherit;
    font-weight: 900;
    letter-spacing: inherit;
    line-height: inherit;
    text-transform: inherit;
  }

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
    color: var(--green-deep);
    opacity: 0;
    transform: translateY(8px);
    transition: opacity 0.5s ease, transform 0.5s var(--ease-out);
  }

  .lede strong {
    color: var(--green);
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
    margin-top: 40px;
    scroll-margin-top: 120px;
    opacity: 0;
    transform: translateY(18px);
    transition: opacity 0.7s ease, transform 0.7s var(--ease-out);
  }

  .demo.in { opacity: 1; transform: none; }

  .sticker {
    position: absolute;
    font-size: clamp(15px, 1.7vw, 20px);
    color: var(--green-deep);
    z-index: 2;
    pointer-events: none;
    opacity: 0;
    animation: stamp 0.5s var(--spring) 1.7s forwards;
  }

  .sticker.s1 {
    top: 190px;
    left: max(2vw, 16px);
    transform: rotate(-9deg);
  }

  .sticker.s2 {
    top: 240px;
    right: max(3vw, 20px);
    transform: rotate(7deg);
    color: var(--hotpink);
  }

  @media (max-width: 900px) {
    .sticker { display: none; }
    .hero { padding-top: 124px; }
  }
</style>
