<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';

  /* one app, four jobs. if it needs a paragraph to explain, it doesn't ship */
</script>

<section class="field pop-b" id="features">
  <div class="container">
    <p class="mono kicker" style="text-align:center">chapter 02 · what it does</p>
    <h2 class="subhead" use:reveal>
      One app. <span class="accent">Four tricks.</span> Zero cloud.
    </h2>

    <div class="grid">
      <!-- dictate -->
      <article class="card c-pink" use:reveal>
        <div class="head">
          <span class="bot"><Robot size={46} mood="listening" /></span>
          <h3>Talk to your Mac</h3>
        </div>
        <p>
          Hold option, mumble, ramble, talk too fast — the sentence you
          <em>meant</em> lands wherever your cursor is, in about 80&nbsp;ms.
        </p>
        <div class="art" aria-hidden="true">
          <span class="keycap">⌥</span>
          <span class="wave"><TalkWave n={9} color="#fc5681" /></span>
          <span class="arrowline">→</span>
          <span class="outtext">it's typed.</span>
        </div>
      </article>

      <!-- notes -->
      <article class="card c-lavender" use:reveal={{ delay: 70 }}>
        <div class="head">
          <span class="bot"><Robot size={46} mood="idle" /></span>
          <h3>Notes that file themselves</h3>
        </div>
        <p>
          Quick thoughts become searchable voice notes. Pin the good ones,
          export as markdown, find anything later.
        </p>
        <div class="art notes" aria-hidden="true">
          <span class="note n1">podcast idea ✦</span>
          <span class="note n2">grandma's recipe</span>
          <span class="note n3">standup rant 🫠</span>
        </div>
      </article>

      <!-- calls -->
      <article class="card c-blue" use:reveal={{ delay: 140 }}>
        <div class="head">
          <span class="bot"><Robot size={46} mood="thinking" /></span>
          <h3>Capture any call</h3>
        </div>
        <p>
          Zoom, Meet, phone calls — recorded straight off your Mac's audio,
          transcribed and split by speaker. No bot crashes the party.
        </p>
        <div class="art call" aria-hidden="true">
          <span class="speaker s1">maya</span>
          <span class="speaker s2">sam</span>
          <span class="rec mono">● rec</span>
        </div>
      </article>

      <!-- summaries -->
      <article class="card c-mint" use:reveal={{ delay: 210 }}>
        <div class="head">
          <span class="bot"><Robot size={46} mood="done" /></span>
          <h3>Summaries from Apple Intelligence</h3>
        </div>
        <p>
          When the call ends, your Mac writes the title, summary and key
          points. On-device AI. Works even if the wifi is a rumor.
        </p>
        <div class="art summary" aria-hidden="true">
          <span class="pill p1">✦ title</span>
          <span class="pill p2">3 key points</span>
          <span class="pill p3">verbatim quotes</span>
        </div>
      </article>
    </div>
  </div>
</section>

<style>
  .subhead {
    margin-bottom: clamp(28px, 4vh, 44px);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: clamp(16px, 2.4vw, 28px);
  }

  .card {
    border-radius: var(--radius-card);
    padding: clamp(22px, 3vw, 34px);
    border: 2px solid rgba(19, 23, 34, 0.85);
    box-shadow: 4px 4px 0 rgba(19, 23, 34, 0.85);
    transition:
      transform 0.25s var(--spring),
      box-shadow 0.25s var(--spring);
  }

  .card:hover {
    transform: translate(-2px, -3px);
    box-shadow: 7px 8px 0 rgba(19, 23, 34, 0.85);
  }

  .c-pink { background: var(--pink); }
  .c-lavender { background: var(--lavender); }
  .c-blue { background: var(--sky); }
  .c-mint { background: var(--mint); }

  .head {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 12px;
  }

  .bot {
    line-height: 0;
    color: var(--ink);
    flex-shrink: 0;
  }

  h3 {
    font-size: clamp(20px, 2.1vw, 26px);
    letter-spacing: -0.02em;
    color: var(--ink);
  }

  .card p {
    font-size: clamp(15px, 1.5vw, 17px);
    line-height: 1.6;
    color: rgba(19, 23, 34, 0.78);
    max-width: 44ch;
  }

  .art {
    margin-top: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  /* dictate */
  .keycap {
    display: inline-grid;
    place-items: center;
    width: 42px;
    height: 40px;
    background: #1d1d1f;
    color: #f5f5f7;
    border-radius: 7px;
    box-shadow: 0 3px 0 #050505;
    animation: press 2.6s ease-in-out infinite;
  }

  @keyframes press {
    0%, 18% { transform: translateY(0); }
    8% { transform: translateY(3px); box-shadow: 0 0 0 #050505; }
    13% { transform: translateY(0); }
  }

  .wave {
    width: 56px;
  }

  .wave :global(.talkwave) { height: 24px; gap: 3px; }

  .arrowline {
    color: var(--ink);
    font-weight: 800;
  }

  .outtext {
    font-weight: 700;
    color: var(--ink);
    border-bottom: 2px solid var(--hotpink);
  }

  /* notes */
  .notes {
    position: relative;
    min-height: 74px;
    display: block;
  }

  .note {
    position: absolute;
    padding: 7px 14px;
    border-radius: 10px;
    font-family: var(--hand);
    font-size: 17px;
    color: var(--ink);
    background: #fffdf7;
    box-shadow: 2px 3px 0 rgba(19, 23, 34, 0.2);
    white-space: nowrap;
  }

  .n1 { top: 0; left: 0; transform: rotate(-3deg); }
  .n2 { top: 34px; left: 34%; transform: rotate(2deg); background: var(--butter); }
  .n3 { top: 6px; left: 66%; transform: rotate(-1deg); }

  /* calls */
  .speaker {
    padding: 6px 14px;
    border-radius: 999px;
    font-weight: 700;
    font-size: 14px;
  }

  .s1 { background: #fffdf7; transform: rotate(-2deg); }
  .s2 { background: var(--lavender); transform: rotate(1.5deg); }

  .rec {
    color: #d61f4c;
    animation: recblink 1.2s steps(1) infinite;
  }

  @keyframes recblink {
    50% { opacity: 0.35; }
  }

  /* summaries */
  .pill {
    padding: 6px 14px;
    border-radius: 999px;
    background: #fffdf7;
    border: 1.5px solid rgba(19, 23, 34, 0.3);
    font-weight: 600;
    font-size: 13.5px;
    color: var(--green-deep);
  }

  .p1 { transform: rotate(-1deg); }
  .p2 { transform: rotate(1deg); }
  .p3 { transform: rotate(-0.5deg); }

  @media (max-width: 860px) {
    .grid {
      grid-template-columns: 1fr;
    }

    .n3 { left: 50%; }
  }
</style>
