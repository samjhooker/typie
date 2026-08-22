<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import { nsSvg } from './svgid.js';

  import gmail from 'thesvg/gmail';
  import slack from 'thesvg/slack';
  import notion from 'thesvg/notion';
  import figma from 'thesvg/figma';
  import chrome from 'thesvg/chrome';
  import github from 'thesvg/github';
  import discord from 'thesvg/discord';
  import whatsapp from 'thesvg/whatsapp';
  import spotify from 'thesvg/spotify';
  import telegram from 'thesvg/telegram';
  import linear from 'thesvg/linear';
  import safari from 'thesvg/safari';
  import vscode from 'thesvg/visual-studio-code';
  import trello from 'thesvg/trello';
  import obsidian from 'thesvg/obsidian';
  import xcode from 'thesvg/xcode';

  const rowA = [
    { n: 'Gmail', s: gmail.svg },
    { n: 'Slack', s: slack.svg },
    { n: 'Notion', s: notion.svg },
    { n: 'Figma', s: figma.svg },
    { n: 'Chrome', s: chrome },
    { n: 'GitHub', s: github.svg },
    { n: 'Discord', s: discord.svg },
    { n: 'WhatsApp', s: whatsapp.svg }
  ];

  const rowB = [
    { n: 'Spotify', s: spotify.svg },
    { n: 'Telegram', s: telegram.svg },
    { n: 'Linear', s: linear.svg },
    { n: 'Safari', s: safari.svg },
    { n: 'VS Code', s: vscode.svg },
    { n: 'Trello', s: trello.svg },
    { n: 'Obsidian', s: obsidian.svg },
    { n: 'Xcode', s: xcode.svg }
  ];
</script>

<section class="features field field-cream" id="features">
  <div class="container head">
    <p class="hand kicker" use:reveal>the whole pitch, in six boxes</p>
    <h2 class="subhead" use:reveal={{ delay: 60 }}>
      Everything you need.
      <span class="accent">Nothing you don't.</span>
    </h2>
  </div>

  <div class="container grid">
    <article class="card c-butter tall" use:reveal={{ delay: 80 }}>
      <h3 class="title t-orange">&lt;100&nbsp;ms from lips to letters</h3>
      <p class="body">
        Faster than you can switch windows or find the mic icon. By the time
        your sentence ends, it's on screen.
      </p>
      <div class="marquee" aria-label="works in every app">
        <div class="mrow">
          {#each [...rowA, ...rowA] as app}
            <span class="tile"><i class="ic">{@html nsSvg(app.s, app.n)}</i>{app.n}</span>
          {/each}
        </div>
        <div class="mrow rev">
          {#each [...rowB, ...rowB] as app}
            <span class="tile"><i class="ic">{@html nsSvg(app.s, app.n)}</i>{app.n}</span>
          {/each}
        </div>
      </div>
      <span class="doodle d-hand hand">+ literally any text field ✦</span>
    </article>

    <article class="card c-periwinkle" use:reveal={{ delay: 140 }}>
      <h3 class="title t-blue">0 bytes leave this Mac</h3>
      <p class="body">
        Audio is processed on-device and thrown away. We can't hear you.
        There's nothing to leak, sell, or subpoena.
      </p>
      <ul class="chips" aria-label="privacy">
        <li>🔒 on-device only</li>
        <li>🚫 no training</li>
        <li>📴 offline forever</li>
      </ul>
    </article>

    <article class="card c-pink" use:reveal={{ delay: 120 }}>
      <h3 class="title t-magenta">Works on a plane ✈️</h3>
      <p class="body">
        No server to reach, so there's no server to miss. Subway, cabin mode,
        cabin in the woods - all fine.
      </p>
      <span class="doodle d-plane" aria-hidden="true">✈︎</span>
    </article>

    <article class="card c-sky" use:reveal={{ delay: 180 }}>
      <h3 class="title t-green">One key. Every app.</h3>
      <p class="body">
        Mail, Slack, Notes, that cursed CRM. Hold ⌥ anywhere and speak - the
        text lands where your cursor already is.
      </p>
      <ul class="chips" aria-label="everywhere">
        <li>⌥ hold + speak</li>
        <li>cursor stays put</li>
      </ul>
    </article>

    <article class="card c-mint" use:reveal={{ delay: 220 }}>
      <h3 class="title t-forest">$0. Forever. Really.</h3>
      <p class="body">
        It runs on your machine and never phones home, so charging monthly for
        it would be a bit strange.
      </p>
      <p class="hand aside">(we checked twice)</p>
    </article>

    <article class="card c-paper wide" use:reveal={{ delay: 260 }}>
      <div class="row">
        <div>
          <h3 class="title t-ink">Download. Hold ⌥. Done.</h3>
          <p class="body">
            ~8 MB app + ~500 MB model on first run, macOS 14+, Apple silicon.
            No account, no email,
            no onboarding carousel about your feelings.
          </p>
        </div>
        <ul class="ticks">
          <li>25 languages, zero settings</li>
          <li>No account, ever</li>
          <li>Free updates, also free</li>
        </ul>
      </div>
    </article>
  </div>

  <div class="container">
    <div class="banner" use:reveal>
      <div class="banner-copy">
        <h3 class="banner-title">Have fun typing.</h3>
        <p class="banner-sub">Get the app. Hold ⌥. Say the thing!</p>
      </div>
      <div class="banner-mascot" aria-hidden="true">
        <Robot mood="done" size={64} />
      </div>
      <DownloadCta />
    </div>
  </div>
</section>

<style>
  .head {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .kicker {
    font-size: clamp(17px, 2vw, 23px);
    color: var(--hotpink);
    transform: rotate(-3deg);
  }

  .subhead {
    margin-top: 14px;
    max-width: 20ch;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 24px;
    margin-top: 56px;
  }

  .card {
    position: relative;
    border-radius: var(--radius);
    padding: clamp(28px, 3.2vw, 44px);
    display: flex;
    flex-direction: column;
    gap: 14px;
    text-align: left;
    overflow: hidden;
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.35s ease;
  }

  .card:hover {
    transform: translateY(-8px) rotate(-0.6deg);
    box-shadow: 0 24px 48px rgba(19, 23, 34, 0.14);
  }

  .tall { grid-row: span 2; }
  .wide { grid-column: span 2; }

  .c-butter { background: var(--butter); }
  .c-periwinkle { background: var(--lavender); }
  .c-pink { background: var(--pink); }
  .c-sky { background: var(--sky); }
  .c-mint { background: var(--mint); }
  .c-paper {
    background: var(--cream);
    border: 2px solid rgba(19, 23, 34, 0.1);
  }

  .title {
    margin: 0;
    font-size: clamp(28px, 3.2vw, 44px);
    line-height: 1.04;
    letter-spacing: -0.01em;
  }

  .t-orange { color: #e06b00; }
  .t-blue { color: var(--periwinkle); }
  .t-magenta { color: #d6336c; }
  .t-green { color: #03594d; }
  .t-forest { color: #02453c; }
  .t-ink { color: var(--ink); }

  .body {
    font-size: 15.5px;
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.72);
    max-width: 46ch;
  }

  .chips {
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding: 0;
  }

  .chips li {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    background: rgba(255, 255, 255, 0.85);
    border-radius: 999px;
    padding: 8px 15px;
    font-family: var(--display);
    font-weight: 700;
    font-size: 13px;
    color: rgba(19, 23, 34, 0.78);
    box-shadow: 0 2px 8px rgba(19, 23, 34, 0.06);
  }

  /* app logo marquee */
  .marquee {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    gap: 14px;
    overflow: hidden;
    -webkit-mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
    mask-image: linear-gradient(90deg, transparent, #000 10%, #000 90%, transparent);
  }

  .mrow {
    display: flex;
    gap: 12px;
    width: max-content;
    animation: mscroll 26s linear infinite;
  }

  .mrow.rev {
    animation-direction: reverse;
    animation-duration: 32s;
  }

  .marquee:hover .mrow {
    animation-play-state: paused;
  }

  @keyframes mscroll {
    to { transform: translateX(-50%); }
  }

  .tile {
    display: inline-flex;
    align-items: center;
    gap: 11px;
    padding: 12px 22px 12px 15px;
    background: var(--cream);
    border-radius: 999px;
    font-family: var(--display);
    font-weight: 700;
    font-size: 17px;
    color: rgba(19, 23, 34, 0.82);
    white-space: nowrap;
    box-shadow: 0 3px 0 rgba(19, 23, 34, 0.18);
  }

  .tile .ic {
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
  }

  .tile .ic :global(svg) {
    width: 24px;
    height: 24px;
    display: block;
  }

  .aside {
    margin-top: auto;
    font-size: clamp(17px, 1.8vw, 20px);
    color: rgba(19, 23, 34, 0.65);
    transform: rotate(-3deg);
    align-self: flex-end;
  }

  .doodle {
    position: absolute;
    pointer-events: none;
    opacity: 0.85;
  }

  .d-hand {
    right: 22px;
    top: 20px;
    font-size: clamp(18px, 2vw, 24px);
    color: rgba(19, 23, 34, 0.55);
    transform: rotate(8deg);
  }

  .d-plane {
    right: 26px;
    bottom: 22px;
    font-size: clamp(34px, 4vw, 52px);
    color: rgba(214, 51, 108, 0.4);
    transform: rotate(12deg);
  }

  .row {
    display: grid;
    grid-template-columns: 1.4fr 1fr;
    gap: 32px;
    align-items: center;
  }

  .row .body { max-width: none; }

  .ticks {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 12px;
    font-family: var(--display);
    font-weight: 700;
    font-size: 15px;
    color: var(--ink);
  }

  .ticks li::before {
    content: '✓ ';
    color: var(--hotpink);
  }

  /* banner strip */
  .banner {
    margin-top: 24px;
    background: var(--butter);
    border-radius: var(--radius);
    padding: clamp(24px, 3vw, 36px) clamp(24px, 3.4vw, 44px);
    display: flex;
    align-items: center;
    gap: 24px;
    flex-wrap: wrap;
    box-shadow: 0 6px 0 rgba(19, 23, 34, 0.85);
  }

  .banner-copy {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-right: auto;
  }

  .banner-title {
    margin: 0;
    font-size: clamp(28px, 3.2vw, 42px);
    letter-spacing: -0.01em;
    text-transform: uppercase;
    color: var(--ink);
  }

  .banner-sub {
    font-size: 16px;
    color: rgba(19, 23, 34, 0.68);
  }

  .banner-mascot {
    color: var(--ink);
    line-height: 0;
    animation: wiggle 3.2s ease-in-out infinite;
  }

  @keyframes wiggle {
    0%, 100% { transform: rotate(-5deg); }
    50% { transform: rotate(6deg) translateY(-4px); }
  }

  @media (max-width: 900px) {
    .grid { grid-template-columns: 1fr; }
    .wide { grid-column: auto; }
    .row { grid-template-columns: 1fr; }
  }
</style>
