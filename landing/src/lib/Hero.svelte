<script>
  import HoldStage from './HoldStage.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import { app } from './state.svelte.js';
</script>

<section class="hero field" id="top" class:live={app.mood === 'listening'}>
  <div class="container grid">
    <div class="copy">
      <p class="kicker hand">voice dictation for mac</p>

      <h1>
        Press <span class="key" aria-label="the option key">&thinsp;&#8997;&thinsp;</span><span class="dot">.</span><br />
        <span class="talk">Talk.</span>
        <span class="typed">Typed.</span>
      </h1>

      <p class="lede">
        Super accurate transcription. Fully offline. Almost instant.
        Hold option anywhere on your Mac, say the thing, and your words
        land right where your cursor is — <strong>never on a server</strong>.
      </p>

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
    grid-template-columns: minmax(0, 0.95fr) minmax(0, 1fr);
    gap: clamp(36px, 5vw, 72px);
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
    font-size: clamp(42px, 4.8vw, 76px);
    font-weight: 800;
    line-height: 1.04;
    letter-spacing: -0.015em;
    color: var(--ink);
  }

  .key {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-family: var(--mono);
    font-weight: 500;
    font-size: 0.74em;
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

  h1:hover .key,
  .key:active {
    transform: translateY(0.02em);
    box-shadow: 0 0.03em 0 #0b1f1b;
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
    margin-top: 22px;
    max-width: 42ch;
    font-size: clamp(16.5px, 1.6vw, 19px);
    line-height: 1.6;
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
    max-width: 620px;
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
