<script>
  import HoldStage from './HoldStage.svelte';
  import DownloadCta from './DownloadCta.svelte';
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

<section class="hero field" id="top" class:live={app.mood === 'listening'}>
  <div class="container grid">
    <div class="copy">
      <p class="kicker hand">voice dictation for mac</p>

      <h1>
        Press <span class="keywrap">
          <button
            bind:this={keyEl}
            class="key"
            class:down={keyDown || app.mood === 'listening'}
            class:pulse={!interacted}
            onpointerdown={(e) => { e.preventDefault(); tap(); }}
            aria-label="the option key - press and hold to try it"
          >&thinsp;&#8997;&thinsp;</button>
          {#if !interacted}
            <span class="tag hand" aria-hidden="true">hold me!</span>
          {/if}
        </span>
        <span class="talk">Talk</span><br />
        <span class="typed">Typed</span>
      </h1>

      <div class="ctas">
        <DownloadCta />
      </div>

      <p class="specs mono">macOS 14+ · apple silicon · ~8 mb app · offline forever · $0</p>
    </div>

    <div class="demo-col">
      <div class="demo" id="how">
        <HoldStage />
      </div>
    </div>
  </div>

  <p class="lede">
    Super accurate transcription. Fully offline. Almost instant.
  </p>
</section>

<style>
  .hero {
    padding: clamp(120px, 14vh, 160px) 0 clamp(48px, 7vh, 88px);
    text-align: left;
    background: var(--paper);
    transition: background-color 0.45s ease;
    overflow: hidden;
  }

  .hero.live { background: #eef9f2; }

  .grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(0, 1.618fr);
    gap: clamp(32px, 4vw, 56px);
    align-items: center;
  }

  /* ---- left: copy ---- */
  .copy {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }

  .kicker {
    font-size: clamp(19px, 2vw, 24px);
    color: var(--green-deep);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  h1 {
    margin: 0;
    font-size: clamp(52px, 6vw, 100px);
    font-weight: 800;
    line-height: 1.02;
    letter-spacing: -0.015em;
    color: var(--ink);
  }

  .key {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-family: var(--mono);
    font-weight: 500;
    font-size: 0.72em;
    line-height: 1;
    background: var(--green-deep);
    color: var(--cream);
    border-radius: 0.16em;
    padding: 0.12em 0.3em 0.16em;
    box-shadow: 0 0.13em 0 #0b1f1b;
    transform: translateY(-0.08em);
    transition: transform 0.12s ease, box-shadow 0.12s ease, background 0.15s ease;
    cursor: pointer;
    user-select: none;
  }

  .keywrap {
    position: relative;
    display: inline-block;
  }

  .tag {
    position: absolute;
    top: -0.55em;
    right: -1.1em;
    font-size: clamp(18px, 1.8vw, 24px);
    color: var(--hotpink);
    transform: rotate(8deg);
    pointer-events: none;
    white-space: nowrap;
    animation: tagbob 2.2s ease-in-out infinite;
  }

  @keyframes tagbob {
    0%, 100% { transform: rotate(8deg) translateY(0); }
    50% { transform: rotate(4deg) translateY(-0.12em); }
  }

  .key.pulse {
    position: relative;
    animation: none;
  }

  .key.pulse::after {
    content: '';
    position: absolute;
    inset: -6px -10px;
    border-radius: inherit;
    border: 3px solid rgba(252, 86, 129, 0.65);
    animation: haloring 1.5s ease-out infinite;
  }

  @keyframes haloring {
    0% { opacity: 0.9; transform: scale(1); }
    100% { opacity: 0; transform: scale(1.35); }
  }

  .key.down {
    animation: none;
    transform: translateY(0.08em);
    box-shadow: 0 0.02em 0 #0b1f1b;
    background: var(--hotpink);
  }

  .key:hover {
    background: #06473c;
    transform: translateY(-0.04em) rotate(-2deg);
  }

  .key.down {
    transform: translateY(0.08em);
    box-shadow: 0 0.02em 0 #0b1f1b;
    background: var(--hotpink);
  }

  .dot { color: var(--ink); }

  .talk { color: var(--periwinkle); }
  .typed {
    color: var(--butter);
    text-shadow: 0.055em 0.055em 0 var(--ink);
    font-style: italic;
  }

  .lede {
    margin-top: clamp(36px, 5vh, 56px);
    max-width: 58ch;
    margin-inline: auto;
    text-align: center;
    font-size: clamp(17px, 1.7vw, 20px);
    line-height: 1.65;
    color: rgba(19, 23, 34, 0.72);
  }

  .lede strong {
    color: var(--ink);
    background: linear-gradient(transparent 70%, rgba(252, 86, 129, 0.35) 70%);
  }

  .ctas {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    margin-top: 30px;
  }

  .specs {
    margin-top: 18px;
  }

  /* ---- right: demo ---- */
  .demo-col {
    display: flex;
    justify-content: center;
  }

  .demo {
    width: 100%;
    max-width: 760px;
    scroll-margin-top: 120px;
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

    .h1, h1 { text-align: center; }
  }
</style>
