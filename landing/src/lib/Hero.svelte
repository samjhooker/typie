<script>
  import HoldStage from './HoldStage.svelte';
  import AssetSlot from './AssetSlot.svelte';
  import { app } from './state.svelte.js';
  import { hold } from './hold.svelte.js';
  import { intro } from './intro.svelte.js';

  let keyDown = $state(false);
  let interacted = $state(false);
  let keyEl;

  function tap() {
    interacted = true;
    intro.active = false;
    keyDown = true;
    setTimeout(() => (keyDown = false), 200);
    /* starts live dictation; releasing anywhere stops it (HoldStage listens globally) */
    hold.press();
  }

  /* intro veil: grayscale page + pink glow on the key, then color returns */
  $effect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
      intro.active = false;
      return;
    }
    const measure = requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (keyEl) {
          const r = keyEl.getBoundingClientRect();
          intro.glow = { x: r.left + r.width / 2, y: r.top + r.height / 2 };
        }
      });
    });
    const fade = setTimeout(() => (intro.active = false), 1700);
    return () => {
      cancelAnimationFrame(measure);
      clearTimeout(fade);
    };
  });

  /* if the visitor hasn't tried it, demo it for them once */
  $effect(() => {
    const t = setTimeout(() => {
      if (
        !interacted &&
        document.visibilityState === 'visible' &&
        !matchMedia('(prefers-reduced-motion: reduce)').matches
      ) {
        interacted = true;
        hold.press();
        setTimeout(() => hold.press(), 1800);
      }
    }, 5000);
    return () => clearTimeout(t);
  });
</script>

<section class="hero field" id="top">
  <div class="container grid">
    <div class="copy">
      <p class="kicker hand">voice dictation for Mac</p>

      <h1>
        <span class="press">Press</span>
        <span class="talk">Talk</span>
        <span class="typed">Typed</span>
      </h1>

      <div class="holdline">
        <svg class="arrowdoodle" viewBox="0 0 60 44" aria-hidden="true">
          <path
            d="M52 4C36 10 18 16 12 30"
            fill="none"
            stroke="rgba(19,23,34,.5)"
            stroke-width="2"
            stroke-linecap="round"
          />
          <path
            d="M19 24l-7 6-1-9"
            fill="none"
            stroke="rgba(19,23,34,.5)"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>

        <p>
          Hold
          <span class="keywrap">
            <button
              bind:this={keyEl}
              class="key"
              class:down={keyDown || app.mood === 'listening'}
              onpointerdown={(e) => { e.preventDefault(); tap(); }}
              aria-label="the option key - press and hold to try it"
            >&thinsp;&#8997;&thinsp;option</button>
          </span>
          and say something
        </p>

        <AssetSlot id="hero-doodle" width="220px">
          {#snippet fallback()}
            <svg class="squiggledoodle" viewBox="0 0 220 70" aria-hidden="true">
              <path
                d="M8 40c26-26 44-28 38-12-6 17 14 14 34 2s40-16 32 0-6 26 22 20 46-14 78-6"
                fill="none"
                stroke="var(--hotpink)"
                stroke-width="3"
                stroke-linecap="round"
                opacity="0.75"
              />
            </svg>
          {/snippet}
        </AssetSlot>
      </div>
    </div>

    <div class="demo-col">
      <div class="demo" id="how">
        <div class="laptop">
          <div class="lid">
            <HoldStage />
          </div>
          <div class="base" aria-hidden="true"><i></i></div>
        </div>
      </div>
    </div>
  </div>
</section>

<style>
  .hero {
    padding: clamp(120px, 15vh, 170px) 0 clamp(56px, 8vh, 96px);
    background: var(--cream);
    overflow: hidden;
  }

  .grid {
    display: grid;
    grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.35fr);
    gap: clamp(32px, 4vw, 64px);
    align-items: center;
  }

  /* ---- left: copy ---- */
  .copy {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }

  .kicker {
    font-size: clamp(20px, 2vw, 25px);
    color: var(--hotpink);
    transform: rotate(-3deg);
    margin-bottom: 14px;
  }

  h1 {
    margin: 0;
    font-size: clamp(64px, 7.5vw, 118px);
    font-weight: 800;
    line-height: 0.95;
    letter-spacing: -0.04em;
    color: var(--ink);
    display: flex;
    flex-direction: column;
  }

  .talk { color: var(--periwinkle); }
  .typed { color: var(--butter); }

  .holdline {
    position: relative;
    margin-top: clamp(28px, 3.5vh, 44px);
    padding-left: 54px;
  }

  .holdline p {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    font-size: clamp(15px, 1.5vw, 17.5px);
    font-weight: 600;
    color: var(--ink);
  }

  .arrowdoodle {
    position: absolute;
    left: -6px;
    top: -30px;
    width: 56px;
    height: 42px;
  }

  .key {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 2px;
    font-family: var(--mono);
    font-weight: 500;
    font-size: 13.5px;
    line-height: 1;
    background: var(--green-deep);
    color: var(--cream);
    border-radius: 8px;
    padding: 8px 12px;
    box-shadow: 0 3px 0 #0b1f1b;
    transition: transform 0.12s ease, box-shadow 0.12s ease, background 0.15s ease;
    cursor: pointer;
    user-select: none;
  }

  .key:hover {
    background: #06473c;
    transform: translateY(-1px) rotate(-2deg);
  }

  .key.down {
    transform: translateY(2px);
    box-shadow: 0 0 0 #0b1f1b;
    background: var(--hotpink);
  }

  .keywrap {
    position: relative;
    display: inline-block;
  }

  .squiggledoodle {
    width: 200px;
    height: auto;
    margin-top: 26px;
    transform: rotate(-4deg);
  }

  /* ---- right: laptop demo ---- */
  .demo-col {
    display: flex;
    justify-content: center;
    min-width: 0;
  }

  .demo {
    width: 100%;
    max-width: 780px;
    scroll-margin-top: 120px;
  }

  .laptop {
    filter: drop-shadow(0 24px 48px rgba(19, 23, 34, 0.18));
  }

  .lid {
    background: #10131a;
    border-radius: 22px 22px 0 0;
    padding: 14px 14px 0;
  }

  /* the hero copy explains the interaction; keep the stage clean */
  .lid :global(.tryhint) {
    display: none;
  }

  .lid :global(.stage) {
    width: 100%;
  }

  .base {
    height: 18px;
    background: linear-gradient(#e8ebf2, #c9cfdd);
    border-radius: 0 0 18px 18px;
    position: relative;
  }

  .base i {
    position: absolute;
    left: 50%;
    top: 0;
    transform: translateX(-50%);
    width: 120px;
    height: 8px;
    background: #aab2c5;
    border-radius: 0 0 10px 10px;
  }

  @media (max-width: 980px) {
    .grid {
      grid-template-columns: 1fr;
      gap: clamp(40px, 6vh, 56px);
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

    .arrowdoodle {
      display: none;
    }
  }
</style>
