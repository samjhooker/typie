<script>
  import HoldStage from './HoldStage.svelte';
  import { app } from './state.svelte.js';
  import { hold } from './hold.svelte.js';
  import { magnetic } from './magnetic.js';
  import { untrack } from 'svelte';

  let keyDown = $state(false);
  let interacted = $state(false);
  let nudge = $state(true);
  let inView = $state(true);
  let keyEl;
  let heroEl = $state(null);

  /* "It's typed." types itself after landing - the headline demonstrates
     the product before anything else moves */
  const TYPED = 'It’s typed.';
  let chars = $state(0);
  let typeDone = $state(false);

  $effect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
      chars = TYPED.length;
      typeDone = true;
      return;
    }
    let iv;
    const start = setTimeout(() => {
      iv = setInterval(() => {
        chars += 1;
        if (chars >= TYPED.length) {
          clearInterval(iv);
          typeDone = true;
        }
      }, 58);
    }, 780);
    return () => {
      clearTimeout(start);
      if (iv) clearInterval(iv);
    };
  });

  function markInteracted() {
    interacted = true;
    nudge = false;
  }

  function tap() {
    markInteracted();
    keyDown = true;
    setTimeout(() => (keyDown = false), 200);
    /* starts live dictation; releasing anywhere stops it (HoldStage listens globally).
       user-initiated: plays the blah word pops while held */
    hold.press(true);
  }

  function onUserKey(e) {
    if (!e.isTrusted) return;
    if (e.key === 'Alt' || e.key === 'Meta' || e.key === 'Shift' || e.key === 'Control') {
      markInteracted();
    }
  }

  function onHeroPointer(e) {
    if (!e.isTrusted) return;
    if (e.button !== 0 && e.button !== -1) return;
    const t = e.target;
    /* nav/download live outside the hero. leave scene-dock + real controls alone. */
    if (t?.closest?.('a, input, textarea, select, .dock-item')) return;
    /* the key and the in-laptop mini key already call press() themselves */
    if (t?.closest?.('.key, .minikey')) {
      markInteracted();
      return;
    }
    tap();
  }

  /* a couple of pulses off the option key so the eye lands there first */
  $effect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
      nudge = false;
      return;
    }
    const t = setTimeout(() => (nudge = false), 2600);
    return () => clearTimeout(t);
  });

  /* "blah blah blah" streaming out of the word "talk." and arcing into
     the macbook demo - plays on any live hold, user-initiated or the
     auto demo.
     all state writes run untracked: blahs.push() reads the array's
     length, and tracking that here would make the effect re-trigger
     itself (effect_update_depth_exceeded) and kill page reactivity */
  let blahs = $state([]);
  let talkEl = $state(null);
  let laptopEl = $state(null);

  $effect(() => {
    const active =
      app.mood === 'listening' &&
      !matchMedia('(prefers-reduced-motion: reduce)').matches;

    return untrack(() => {
      if (!active) {
        blahs = [];
        return;
      }

      let seq = 0;
      let timer;
      const spawn = () => {
        const talk = talkEl?.getBoundingClientRect?.();
        const mac = laptopEl?.getBoundingClientRect?.();
        if (!talk || !mac || !mac.width) return;

        /* take off from somewhere on the word "talk." */
        const cx = talk.left + talk.width / 2;
        const cy = talk.top + talk.height / 2;
        const sx = (Math.random() - 0.5) * talk.width * 1.1;
        const sy = (Math.random() - 0.5) * talk.height * 1.6;

        /* land on a random spot on the macbook screen */
        const tx =
          mac.left + mac.width * (0.2 + Math.random() * 0.6) - cx;
        const ty =
          mac.top + mac.height * (0.12 + Math.random() * 0.52) - cy;

        const dist = Math.hypot(tx - sx, ty - sy);
        /* leisurely flight: big words travel visibly, ~1.4-2.3s */
        const dur = Math.round(
          Math.min(2300, Math.max(1400, dist * 0.9 + 700 + Math.random() * 350))
        );
        const side = Math.random() < 0.5 ? -1 : 1;
        const id = `${seq++}-${Math.random().toString(36).slice(2, 7)}`;

        blahs.push({
          id,
          sx: Math.round(sx),
          sy: Math.round(sy),
          tx: Math.round(tx),
          ty: Math.round(ty),
          /* projectile-ish wobble: launch lift then gravity sag */
          lift: -Math.round(18 + Math.random() * 46),
          rot: Math.round(side * (5 + Math.random() * 14)),
          fs: Math.round(17 + Math.random() * 16),
          dur,
          alt: seq % 2 === 0,
          txt: Math.random() > 0.82 ? 'blah blah' : 'blah'
        });
        setTimeout(() => {
          blahs = blahs.filter((b) => b.id !== id);
        }, dur + 140);
        /* relaxed speech cadence */
        timer = setTimeout(spawn, 220 + Math.random() * 260);
      };
      spawn();
      return () => {
        clearTimeout(timer);
        blahs = []; /* never let words from an aborted hold pile up */
      };
    });
  });

  /* demo the option key only while the hero is actually on screen */
  $effect(() => {
    if (!heroEl) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        inView = entry.isIntersecting && entry.intersectionRatio >= 0.2;
      },
      { threshold: [0, 0.2, 0.45] }
    );
    io.observe(heroEl);
    return () => io.disconnect();
  });

  $effect(() => {
    if (interacted || matchMedia('(prefers-reduced-motion: reduce)').matches || !inView) {
      return;
    }
    const holdMs = 2200;
    let autoHolding = false;
    let loop;
    const timers = [];
    const beat = () => {
      if (interacted || !inView || document.visibilityState !== 'visible') return;
      autoHolding = true;
      hold.press();
      timers.push(
        setTimeout(() => {
          autoHolding = false;
          if (!interacted && inView) hold.press();
        }, holdMs)
      );
    };
    /* let visitors land first - the option key demos itself after ~2s */
    const kickoff = setTimeout(() => {
      beat();
      loop = setInterval(beat, 5000);
    }, 2000);
    return () => {
      clearTimeout(kickoff);
      clearInterval(loop);
      timers.forEach(clearTimeout);
      /* only ever cancel a hold the AUTO DEMO started - never one the
         user just began, otherwise their first click silently kills itself */
      if (autoHolding) {
        autoHolding = false;
        hold.press();
      }
    };
  });
</script>

<svelte:window onkeydown={onUserKey} />

<section
  class="hero field pop-a"
  id="top"
  bind:this={heroEl}
  class:live={app.mood === 'listening'}
  class:nudge
  onpointerdown={onHeroPointer}
>
  <div class="container grid">
    <div class="copy">
      <h1 class="kinetic">
        <span class="press">Just <span class="talk">talk.</span></span>
        <span class="typed" class:caret={!typeDone}>{TYPED.slice(0, chars)}</span>
      </h1>

      <p
        class="value enter-up"
        style="--stagger: 180ms"
      >
        Dictation, voice notes, call capture and meeting summaries — the
        whole thing lives on your Mac. No account. No cloud. No subscription.
        Ever.
      </p>

      <ul class="promises enter-up" style="--stagger: 250ms" aria-label="the three promises">
        <li><b>100%</b> offline</li>
        <li><b>$0</b> forever</li>
        <li><b>0 bytes</b> uploaded</li>
      </ul>

      <div class="holdline enter-up" style="--stagger: 320ms">
        <p>
          try it right here: hold
          <span class="keywrap" use:magnetic>
            <span class="talkpulse" aria-hidden="true"><i></i><i></i><i></i></span>
            <span class="rings" aria-hidden="true"><i></i><i></i><i></i></span>
            <button
              bind:this={keyEl}
              class="key"
              class:down={keyDown || app.mood === 'listening'}
              onpointerdown={(e) => { e.preventDefault(); tap(); }}
              aria-label="the option key - press and hold to try it"
            >
              <span class="ksym" aria-hidden="true">&#8997;</span>
              <span class="klbl">option</span>
            </button>
          </span>
          <span class="talkend" bind:this={talkEl}>and talk{#if app.mood === 'listening'}
              <span class="blahs" aria-hidden="true">
                {#each blahs as b (b.id)}
                  <span
                    class="blah hand"
                    class:alt={b.alt}
                    style="--sx:{b.sx}px; --sy:{b.sy}px; --tx:{b.tx}px; --ty:{b.ty}px; --bump:{b.bump}px; --rot:{b.rot}deg; --fs:{b.fs}px; --dur:{b.dur}ms"
                  ><i>{b.txt}</i></span>
                {/each}
              </span>{/if}</span>
        </p>
      </div>
    </div>

    <div class="demo-col">
      <div class="demo">
        <span class="macglow" aria-hidden="true"><b></b><i></i><i></i></span>
        <div class="laptop" bind:this={laptopEl}>
          <div class="lid">
            <HoldStage />
          </div>
          <div class="base" aria-hidden="true">
            <i class="chin"></i>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<style>
  .hero {
    padding: clamp(120px, 15vh, 170px) 0 clamp(44px, 6vh, 68px);
    background: transparent;
    overflow: visible;
  }

  .grid {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: none;
    margin: 0;
    padding-left: max(24px, calc((100vw - 1180px) / 2));
    padding-right: 0;
    display: grid;
    grid-template-columns: minmax(280px, 42vw) minmax(0, 1fr);
    gap: clamp(20px, 2.4vw, 36px);
    align-items: center;
  }

  /* ---- left: copy ---- */
  .copy {
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    z-index: 1;
  }

  .kicker,
  h1 {
    position: relative;
    z-index: 3;
  }

  .talkpulse {
    position: absolute;
    left: 50%;
    top: 50%;
    width: min(62vw, 640px);
    aspect-ratio: 1;
    transform: translate(-50%, -50%);
    pointer-events: none;
    z-index: 0;
  }

  .talkpulse i {
    position: absolute;
    inset: 0;
    border-radius: 50%;
    background: radial-gradient(
      circle,
      rgba(252, 86, 129, 0.28) 0%,
      rgba(252, 86, 129, 0.1) 42%,
      transparent 68%
    );
    opacity: 0;
  }

  .hero.live .talkpulse i {
    animation: talkwave 1.7s ease-out infinite;
  }

  .hero.live .talkpulse i:nth-child(2) { animation-delay: 0.45s; }
  .hero.live .talkpulse i:nth-child(3) { animation-delay: 0.9s; }

  @keyframes talkwave {
    0% { transform: scale(0.42); opacity: 0.8; }
    100% { transform: scale(1.12); opacity: 0; }
  }

  .kicker {
    font-size: clamp(20px, 2vw, 25px);
    color: var(--hotpink);
    transform: rotate(-3deg);
    margin-bottom: 14px;
  }

  h1 {
    margin: 0;
    font-size: clamp(60px, 6.6vw, 104px);
    font-weight: 800;
    line-height: 0.98;
    letter-spacing: -0.04em;
    color: var(--ink);
    display: flex;
    flex-direction: column;
  }

  .press {
    display: block;
    animation: line-up 0.9s var(--spring-snappy) both;
  }

  .typed {
    display: block;
    color: var(--hotpink);
    min-height: 1em;
  }

  /* blinking bar while the headline is still typing itself */
  .typed.caret::after {
    content: '';
    display: inline-block;
    width: 0.08em;
    height: 0.82em;
    margin-left: 0.06em;
    background: var(--hotpink);
    vertical-align: -0.04em;
    animation: caret 0.8s steps(1) infinite;
  }

  @keyframes caret {
    50% { opacity: 0; }
  }

  /* masked line reveal: each line rises out of its own clip window */
  @keyframes line-up {
    from {
      opacity: 0;
      transform: translateY(55%);
      clip-path: inset(-10% 0 58% 0);
      filter: blur(6px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
      clip-path: inset(-10% 0 -12% 0);
      filter: blur(0);
    }
  }

  .talk { color: var(--periwinkle); }

  .talkend {
    position: relative;
    white-space: nowrap;
  }
  .typed { color: var(--hotpink); }

  .value {
    margin-top: clamp(24px, 3.5vh, 34px);
    max-width: 32ch;
    font-size: clamp(17px, 1.7vw, 21px);
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.78);
  }

  .micro {
    letter-spacing: 0.06em;
  }

  /* the three promises: pill badges that each get their own color */
  .promises {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: clamp(20px, 3vh, 28px);
    padding: 0;
    list-style: none;
    font-size: clamp(14px, 1.35vw, 16.5px);
    font-weight: 600;
    color: var(--ink);
  }

  .promises li {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 8px 16px;
    border-radius: 999px;
    border: 2px solid var(--ink);
    background: var(--card-mint);
    box-shadow: 2px 2px 0 rgba(19, 23, 34, 0.9);
    transform: rotate(-1deg);
    transition: transform 0.25s var(--spring), box-shadow 0.25s var(--spring);
  }

  .promises li:nth-child(2) {
    background: var(--butter);
    transform: rotate(1.2deg);
  }

  .promises li:nth-child(3) {
    background: var(--pink);
    transform: rotate(-0.8deg);
  }

  .promises li:hover {
    transform: rotate(0deg) translateY(-2px);
    box-shadow: 3px 4px 0 rgba(19, 23, 34, 0.9);
  }

  .promises b {
    font-weight: 800;
    letter-spacing: -0.02em;
  }

  .holdline {
    position: relative;
    z-index: 1;
    margin-top: clamp(32px, 4.5vh, 48px);
  }

  .holdline p {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    font-size: clamp(17px, 1.6vw, 20px);
    font-weight: 600;
    color: rgba(19, 23, 34, 0.72);
  }

  .key {
    display: inline-grid;
    grid-template-rows: 1fr auto;
    width: 54px;
    height: 54px;
    padding: 6px 6px 5px;
    font-family: var(--sans);
    font-weight: 500;
    line-height: 1;
    background: #1d1d1f;
    color: #f5f5f7;
    border-radius: 7px;
    box-shadow:
      0 3px 0 #050505,
      inset 0 1px 0 rgba(255, 255, 255, 0.14);
    transition: transform 0.12s var(--snap), box-shadow 0.12s var(--snap), background 0.15s var(--ease-out);
    cursor: pointer;
    user-select: none;
    position: relative;
    z-index: 2;
    vertical-align: middle;
  }

  .ksym {
    justify-self: end;
    font-size: 14px;
    font-weight: 400;
    line-height: 1;
    opacity: 0.95;
  }

  .klbl {
    justify-self: center;
    width: 100%;
    text-align: center;
    font-size: 9px;
    font-weight: 500;
    letter-spacing: 0.01em;
    line-height: 1;
  }

  .key:hover {
    background: #2a2a2d;
    transform: translateY(-1px);
  }

  .key.down {
    transform: translateY(3px);
    box-shadow: 0 0 0 #050505, inset 0 2px 5px rgba(0, 0, 0, 0.45);
    background: #111;
  }

  .keywrap {
    position: relative;
    z-index: 1;
    display: inline-block;
  }

  /* blah words streaming from "talk." into the macbook while talking.
     physics split across two layers: the outer span owns horizontal
     travel - a gentle ease-in-out so the whole journey stays readable,
     no burst-and-crawl - plus opacity; the inner owns vertical motion
     (launch lift, gravity sag) plus the rotation drift */
  .blahs {
    position: absolute;
    inset: 0;
    z-index: 3;
    pointer-events: none;
  }

  .blah {
    position: absolute;
    left: 50%;
    top: 50%;
    white-space: nowrap;
    font-weight: 700;
    line-height: 1;
    font-size: var(--fs, 22px);
    color: var(--hotpink);
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.6);
    opacity: 0;
    will-change: transform, opacity;
    animation: blah-fly var(--dur, 1800ms) cubic-bezier(0.45, 0.05, 0.55, 0.95) forwards;
  }

  .blah i {
    display: inline-block;
    font-style: normal;
    will-change: transform;
    animation: blah-toss var(--dur, 1800ms) cubic-bezier(0.45, 0.05, 0.55, 0.95) forwards;
  }

  .blah.alt {
    color: var(--periwinkle);
  }

  @keyframes blah-fly {
    0% {
      opacity: 0;
      transform: translate(calc(-50% + var(--sx)), calc(-50% + var(--sy))) scale(0.55);
    }
    9% {
      opacity: 1;
    }
    68% {
      opacity: 0.9;
    }
    100% {
      opacity: 0;
      transform: translate(calc(-50% + var(--tx)), calc(-50% + var(--ty))) scale(0.96);
    }
  }

  @keyframes blah-toss {
    0% {
      transform: translateY(0) rotate(calc(var(--rot) * 0.25));
    }
    /* launch: spoken words pop upward off the mouth */
    26% {
      transform: translateY(var(--lift)) rotate(calc(var(--rot) * 0.7));
    }
    /* gravity wins: sag back through the flight line */
    68% {
      transform: translateY(calc(var(--lift) * -0.22)) rotate(calc(var(--rot) * 1.05));
    }
    100% {
      transform: translateY(calc(var(--lift) * -0.05)) rotate(var(--rot));
    }
  }

  .rings {
    position: absolute;
    inset: -7px;
    pointer-events: none;
    opacity: 0;
  }

  .hero.live .rings,
  .hero.nudge .rings {
    opacity: 1;
  }

  .rings i {
    position: absolute;
    inset: 0;
    border: 2px solid var(--hotpink);
    border-radius: 10px;
    opacity: 0;
  }

  .hero.live .rings i {
    animation: ping 1.55s ease-out infinite;
  }

  .hero.live .rings i:nth-child(2) { animation-delay: 0.5s; }
  .hero.live .rings i:nth-child(3) { animation-delay: 1s; }

  .hero.nudge .rings i {
    animation: ping 1.15s ease-out 2;
  }

  .hero.nudge .rings i:nth-child(2) { animation-delay: 0.38s; }
  .hero.nudge .rings i:nth-child(3) { animation-delay: 0.76s; }

  .hero.nudge .key:not(.down) {
    animation: keyflash 1.15s ease-out 2;
  }

  @keyframes ping {
    0% { transform: scale(1); opacity: 0.55; }
    100% { transform: scale(1.9); opacity: 0; }
  }

  @keyframes keyflash {
    0%, 100% { box-shadow: 0 3px 0 #050505, 0 0 0 0 rgba(252, 86, 129, 0); }
    35% { box-shadow: 0 3px 0 #050505, 0 0 18px 4px rgba(252, 86, 129, 0.45); }
  }

  /* ---- right: laptop demo ---- */
  .demo-col {
    display: block;
    min-width: 0;
    animation: enter-up 0.9s var(--spring-snappy) 0.4s both;
  }

  .demo {
    position: relative;
    width: 62vw;
    max-width: none;
    transform: translateX(-100px);
  }

  .macglow {
    position: absolute;
    left: 50%;
    top: -6%;
    width: min(58vw, 620px);
    aspect-ratio: 1;
    transform: translate(-50%, -22%);
    pointer-events: none;
    z-index: 0;
  }

  .macglow b,
  .macglow i {
    position: absolute;
    inset: 0;
    border-radius: 50%;
  }

  .macglow b {
    inset: 6%;
    background: radial-gradient(
      circle,
      rgba(252, 86, 129, 0.78) 0%,
      rgba(252, 86, 129, 0.38) 34%,
      rgba(252, 86, 129, 0.12) 62%,
      transparent 76%
    );
    filter: blur(6px);
    opacity: 0;
    transition: opacity 0.35s var(--ease-out);
  }

  .macglow i {
    background: radial-gradient(
      circle,
      rgba(252, 86, 129, 0.55) 0%,
      rgba(252, 86, 129, 0.22) 40%,
      transparent 70%
    );
    opacity: 0;
  }

  .hero.live .macglow b {
    opacity: 1;
  }

  .hero.live .macglow i {
    animation: macpulse 1.7s ease-out infinite;
  }

  .hero.live .macglow i:nth-child(3) {
    animation-delay: 0.55s;
  }

  @keyframes macpulse {
    0% { transform: scale(0.38); opacity: 0.95; }
    100% { transform: scale(1.28); opacity: 0; }
  }

  .laptop {
    --lid-r: clamp(22px, 3.7cqi, 36px);
    --bezel: clamp(8px, 1.15cqi, 12px);
    --glass-r: clamp(14px, 2.55cqi, 26px);
    container-type: inline-size;
    position: relative;
    z-index: 1;
    padding-bottom: 28px;
    filter: drop-shadow(0 28px 52px rgba(19, 23, 34, 0.22));
    transition: filter 0.45s var(--ease-out);
  }

  .laptop::after {
    content: "";
    position: absolute;
    left: 8%;
    right: 8%;
    bottom: 2px;
    height: 22px;
    background: radial-gradient(ellipse, rgba(19, 23, 34, 0.24), transparent 70%);
    pointer-events: none;
  }

  .lid {
    position: relative;
    z-index: 2;
    width: 100%;
    aspect-ratio: 16 / 10;
    height: auto;
    display: flex;
    flex-direction: column;
    background: #1a1c22;
    border-radius: var(--lid-r) var(--lid-r) 0 0;
    padding: var(--bezel) var(--bezel) 0;
    overflow: hidden;
  }

  /* the hero copy explains the interaction; keep the stage clean */
  .lid :global(.tryhint) {
    display: none;
  }

  .lid :global(.stage) {
    width: 100%;
    height: 100%;
    flex: 1;
    min-height: 0;
    gap: 0;
    overflow: hidden;
    border-radius: var(--glass-r) var(--glass-r) 0 0;
  }

  .lid :global(.mac) {
    width: 100%;
    height: 100%;
    flex: 1;
    min-height: 0;
    border: 0;
    border-radius: var(--glass-r) var(--glass-r) 0 0;
    overflow: hidden;
    box-shadow: none;
  }

  .lid :global(.smenubar) {
    border-radius: var(--glass-r) var(--glass-r) 0 0;
  }

  .base {
    position: relative;
    z-index: 1;
    height: 24px;
    margin: -1px -5.4% 0;
    background:
      linear-gradient(180deg, rgba(255, 255, 255, 0.55), transparent 40%),
      linear-gradient(90deg, #9aa0ac 0%, #e4e7ee 10%, #f5f6f9 50%, #e4e7ee 90%, #9aa0ac 100%);
    border-radius: 0 0 10px 10px;
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.9),
      inset 0 -2px 0 rgba(70, 74, 86, 0.12);
  }

  .base::before {
    content: "";
    position: absolute;
    left: 10px;
    right: 10px;
    top: 100%;
    height: 14px;
    background: linear-gradient(180deg, #c5c9d2 0%, #9aa0ac 50%, #6f7480 100%);
    border-radius: 0 0 14px 14px;
    clip-path: polygon(0 0, 100% 0, 96.8% 100%, 3.2% 100%);
  }

  .base .chin {
    position: absolute;
    left: 50%;
    top: 1px;
    transform: translateX(-50%);
    width: 18%;
    min-width: 100px;
    max-width: 168px;
    height: 10px;
    background: linear-gradient(180deg, #7e8490, #5a5f6a);
    border-radius: 0 0 9px 9px;
  }

  @media (max-width: 980px) {
    .grid {
      grid-template-columns: 1fr;
      gap: clamp(36px, 5vh, 48px);
    }

    .copy {
      align-items: center;
      text-align: center;
    }

    h1 {
      align-items: center;
    }

    .holdline {
      padding-left: 0;
    }

    .grid {
      padding-left: 20px;
      padding-right: 20px;
    }

    .demo {
      width: 100%;
      transform: none;
    }

    .base {
      margin-inline: -14px;
    }
  }
</style>
