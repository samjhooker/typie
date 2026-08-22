<script>
  import PageShell from './PageShell.svelte';
  import Robot from './Robot.svelte';
  import { reveal } from './reveal.js';
</script>

<svelte:head>
  <title>About - typie</title>
  <meta name="description" content="Typie is voice dictation that just works - a tiny robot in your Mac menu bar. Free, offline, no cloud." />
</svelte:head>

<PageShell>
  <h1 class="subhead" use:reveal>about typie</h1>
  <p class="hand tag" use:reveal={{ delay: 80 }}>one robot. one job.</p>

  <div class="grid">
    <div class="col" use:reveal={{ delay: 140 }}>
      <p class="lede">
        Typie started with a simple annoyance: saying a sentence is fast, but
        typing it is slow - and every dictation tool wanted to ship your voice
        to a server first.
      </p>
      <p>
        So there's no server. Typie runs a speech model entirely on your Mac.
        Hold a key, speak, and your words appear wherever your cursor is - in
        under 100 milliseconds. Mail, Slack, Notes, that cursed CRM. Anywhere
        text goes.
      </p>
      <p>
        It's free because payment infrastructure is expensive and we couldn't
        be bothered. It's private because your audio never leaves the machine,
        so there's nothing to protect except the off switch.
      </p>
    </div>

    <div class="side" use:reveal={{ delay: 220 }}>
      <span class="glyph"><Robot mood="idle" size={140} /></span>
      <ul class="facts">
        <li><strong>&lt;100 ms</strong><span>lips to letters</span></li>
        <li><strong>0 bytes</strong><span>leave this Mac</span></li>
        <li><strong>$0</strong><span>forever, really</span></li>
      </ul>
    </div>
  </div>
</PageShell>

<style>
  .tag {
    font-size: clamp(20px, 2.4vw, 27px);
    color: var(--green-deep);
    transform: rotate(-2deg);
    margin-top: 10px;
  }

  .grid {
    display: grid;
    grid-template-columns: 1.5fr 1fr;
    gap: 56px;
    margin-top: 44px;
    align-items: start;
  }

  .lede {
    font-family: var(--display);
    font-weight: 700;
    font-size: clamp(19px, 2vw, 24px);
    line-height: 1.4;
    letter-spacing: -0.02em;
    color: var(--green-deep);
    margin-bottom: 18px;
  }

  .col p:not(.lede) {
    margin-bottom: 14px;
    color: var(--green-deep);
    line-height: 1.6;
  }

  .glyph {
    display: grid;
    place-items: center;
    color: #f9f8f4;
    background: rgba(249, 248, 244, 0.35);
    border-radius: var(--radius);
    padding: 34px;
    line-height: 0;
  }

  .facts {
    list-style: none;
    display: grid;
    gap: 10px;
    margin-top: 18px;
  }

  .facts li {
    display: flex;
    align-items: baseline;
    gap: 12px;
    background: rgba(249, 248, 244, 0.65);
    border: 1px solid rgba(2, 89, 77, 0.12);
    border-radius: 16px;
    padding: 12px 18px;
  }

  .facts strong {
    font-family: var(--display);
    font-weight: 900;
    font-size: 20px;
    color: var(--green-deep);
    min-width: 86px;
  }

  .facts span {
    color: var(--green-deep);
    opacity: 0.75;
    font-size: 14px;
  }

  @media (max-width: 800px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }
</style>
