<script>
  import PageShell from './PageShell.svelte';
  import Robot from './Robot.svelte';
  import { reveal } from './reveal.js';
</script>

<svelte:head>
  <title>About - Typie</title>
  <meta
    name="description"
    content="Typie is voice dictation for Mac. Hold a key, talk, and your words appear - on-device, free, no cloud."
  />
</svelte:head>

<PageShell>
  <p
    class="hand kicker"
    use:reveal
  >
    one robot. one job.
  </p>
  <h1
    class="subhead"
    use:reveal
  >
    About Typie
  </h1>

  <div class="grid">
    <div
      class="col"
      use:reveal={{ delay: 80 }}
    >
      <p class="lede">
        Saying a sentence is fast. Typing it is slow. Every other dictation tool
        wanted to ship your voice to a server first.
      </p>
      <p>
        Typie doesn’t. It runs on your Mac, in the notch, and nowhere else. Hold
        option, speak, release. Your words land in whatever you were already
        typing - Mail, Slack, Notes, the cursed CRM.
      </p>
      <p>
        It’s free because charging for a key you already own felt rude. It’s
        private because the audio never leaves the machine. That’s the whole
        company.
      </p>
    </div>

    <aside
      class="side"
      use:reveal={{ delay: 140 }}
    >
      <span class="glyph"
        ><Robot
          mood="idle"
          size={120}
        /></span
      >
      <ul class="facts">
        <li><strong>&lt;100 ms</strong><span>lips to letters</span></li>
        <li><strong>0 bytes</strong><span>leave this Mac</span></li>
        <li><strong>$0</strong><span>forever, really</span></li>
      </ul>
    </aside>
  </div>
</PageShell>

<style>
  .kicker {
    text-align: left;
    font-size: clamp(20px, 2.2vw, 26px);
    color: var(--hotpink);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  .subhead {
    text-align: left;
  }

  .grid {
    display: grid;
    grid-template-columns: 1.45fr 0.9fr;
    gap: clamp(28px, 4vw, 56px);
    margin-top: 40px;
    align-items: start;
  }

  .lede {
    font-family: var(--display);
    font-weight: 700;
    font-size: clamp(18px, 2vw, 23px);
    line-height: 1.4;
    letter-spacing: -0.02em;
    color: var(--ink);
    margin-bottom: 16px;
  }

  .col p:not(.lede) {
    margin-bottom: 14px;
    color: var(--text-2);
    line-height: 1.65;
  }

  .glyph {
    display: grid;
    place-items: center;
    color: var(--hotpink);
    background: var(--card-lavender);
    border-radius: 24px;
    padding: 32px;
    line-height: 0;
  }

  .facts {
    list-style: none;
    display: grid;
    gap: 10px;
    margin-top: 16px;
  }

  .facts li {
    display: flex;
    align-items: baseline;
    gap: 12px;
    background: #fff;
    border: 1px solid rgba(19, 23, 34, 0.07);
    border-radius: 16px;
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.05);
    padding: 12px 18px;
  }

  .facts strong {
    font-family: var(--display);
    font-weight: 800;
    font-size: 18px;
    color: var(--ink);
    min-width: 82px;
  }

  .facts span {
    color: rgba(19, 23, 34, 0.62);
    font-size: 14px;
  }

  @media (max-width: 800px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }
</style>
