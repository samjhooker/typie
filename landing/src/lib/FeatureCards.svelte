<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import Notch from './Notch.svelte';
  import { nsSvg } from './svgid.js';
  import slack from 'thesvg/slack';
  import notion from 'thesvg/notion';

  const slackSvg = slack.svg ?? slack;
  const notionSvg = notion.svg ?? notion;
  const mailSvg =
    '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" fill="#3b82f6"/><path d="m4.5 7.5 7.5 6 7.5-6" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>';
</script>

<section class="features field pop-b" id="features">
  <div class="container">
    <p class="hand kicker" use:reveal>everything you need to know</p>
  </div>
  <div class="container grid">
    <!-- Talk naturally -->
    <article class="card c-lavender" use:reveal>
      <h3>Talk naturally</h3>
      <div class="body">
        <p>Mumble. Ramble. Talk too fast. It still becomes the sentence you meant.</p>
        <div class="art">
          <span class="botpair" aria-hidden="true">
            <span class="lift">
              <img
                class="wave-icon"
                src="{import.meta.env.BASE_URL}assets/talk-wave.webp"
                alt=""
                width="240"
                height="169"
              />
              <i class="ground g-wave"></i>
            </span>
            <span class="lift mascot">
              <span class="tilt">
                <span class="spark s1">✦</span>
                <span class="spark s2">✧</span>
                <span class="bot bot-ink"><Robot size={92} mood="listening" bg="var(--card-lavender)" /></span>
              </span>
              <i class="ground g-bot"></i>
            </span>
          </span>
        </div>
      </div>
    </article>

    <!-- Keep your words private -->
    <article class="card c-blue" use:reveal={{ delay: 80 }}>
      <h3>Keep your words private</h3>
      <div class="body">
        <p>On-device, then gone. Your voice never leaves this Mac. We couldn’t hear you if we tried.</p>
        <div class="art">
          <span class="lock-scene" aria-hidden="true">
            <img
              class="lock-icon"
              src="{import.meta.env.BASE_URL}assets/privacy-lock.webp"
              alt=""
              width="253"
              height="301"
            />
            <span class="lock-buddy mascot">
              <span class="tilt">
                <span class="spark s1">✦</span>
                <span class="spark s2">✧</span>
                <span class="bot bot-pink"><Robot size={64} mood="idle" bg="var(--card-blue)" /></span>
              </span>
              <i class="ground g-bot"></i>
            </span>
          </span>
        </div>
      </div>
    </article>

    <!-- Use it everywhere -->
    <article class="card c-cream" use:reveal>
      <h3>Use it everywhere</h3>
      <div class="body">
        <p>No special window. It types wherever your cursor already is. Slack, Mail, the cursed spreadsheet.</p>
        <div class="art">
          <span class="everywhere" aria-hidden="true">
            <svg class="links" viewBox="0 0 180 150" fill="none">
              <path d="M52 108 C 58 70 88 38 118 28" />
              <path d="M118 28 C 148 36 168 68 154 96" />
              <path d="M154 96 C 138 124 88 128 52 108" />
            </svg>
            <span class="hub mascot">
              <span class="tilt">
                <span class="spark s1">✦</span>
                <span class="bot bot-pink"><Robot size={78} mood="idle" bg="var(--card-cream)" /></span>
              </span>
              <i class="ground g-bot"></i>
            </span>
            <span class="app a-slack">{@html nsSvg(slackSvg, 'ew-slack')}</span>
            <span class="app a-mail">{@html nsSvg(mailSvg, 'ew-mail')}</span>
            <span class="app a-notion">{@html nsSvg(notionSvg, 'ew-notion')}</span>
          </span>
        </div>
      </div>
    </article>

    <!-- Never break your flow -->
    <article class="card c-mint" use:reveal={{ delay: 80 }}>
      <h3>Never break your flow</h3>
      <div class="body">
        <p>You were writing. You still are. One key, then straight back to the sentence.</p>
        <div class="art flow-art">
          <img
            class="flow-key"
            src="{import.meta.env.BASE_URL}assets/flow-key.webp"
            alt=""
            width="229"
            height="327"
          />
        </div>
      </div>
    </article>

    <div class="fifth">
      <Notch />
    </div>
  </div>
</section>

<style>
  .features {
    padding-bottom: clamp(40px, 6vh, 72px);
  }

  .kicker {
    text-align: center;
    font-size: clamp(20px, 2vw, 24px);
    color: var(--hotpink);
    transform: rotate(-1.5deg);
    margin-bottom: clamp(28px, 4vh, 48px);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: clamp(20px, 2.8vw, 32px);
  }

  .card {
    border-radius: var(--radius-card);
    padding: clamp(26px, 3vw, 36px) clamp(26px, 3vw, 36px) clamp(22px, 2.6vw, 30px);
    display: flex;
    flex-direction: column;
    align-items: stretch;
    gap: 14px;
    min-height: 0;
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.3s ease;
  }

  .card:hover {
    transform: translateY(-6px) rotate(-0.5deg);
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.1);
  }

  .c-lavender { background: var(--card-lavender); color: var(--ink); }
  .c-blue { background: var(--card-blue); color: var(--ink); }
  .c-cream { background: var(--card-cream); color: var(--ink); }
  .c-mint { background: var(--card-mint); color: var(--ink); }

  h3 {
    font-size: clamp(19px, 1.8vw, 23px);
    letter-spacing: -0.02em;
    color: inherit;
  }

  .body {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px 18px;
    width: 100%;
    flex: 1;
    min-height: 0;
  }

  p {
    font-size: 15px;
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.82);
    opacity: 1;
    max-width: 28ch;
    flex: 1 1 0;
    min-width: 0;
    align-self: flex-start;
    padding-top: 2px;
  }

  .art {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: flex-end;
    flex: 0 0 auto;
    min-height: 0;
  }

  .fifth {
    grid-column: 1 / -1;
  }

  .botpair {
    display: flex;
    align-items: flex-end;
    gap: 4px;
  }

  .botpair .mascot .tilt {
    display: block;
    transform: rotate(-12deg);
    transform-origin: 50% 80%;
  }

  .lift {
    display: flex;
    flex-direction: column;
    align-items: center;
    line-height: 0;
  }

  .wave-icon {
    display: block;
    width: clamp(92px, 9vw, 124px);
    height: auto;
    filter: drop-shadow(0 8px 6px rgba(252, 86, 129, 0.28));
    animation: wavebob 4.2s ease-in-out infinite;
  }

  .bot {
    display: block;
    line-height: 0;
  }

  .tilt {
    display: block;
    line-height: 0;
    position: relative;
  }

  .ground {
    display: block;
    height: 10px;
    margin-top: 0;
    border-radius: 50%;
    pointer-events: none;
    transform: none;
  }

  .g-wave {
    width: 72%;
    background: radial-gradient(ellipse at center, rgba(200, 140, 253, 0.32) 0%, transparent 72%);
  }

  .g-bot {
    width: 70%;
    background: radial-gradient(ellipse at center, rgba(19, 23, 34, 0.16) 0%, transparent 72%);
  }

  @keyframes wavebob {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-3px); }
  }

  /* this card's robot should nod, not boogie */
  .botpair .bot :global(.listening svg) {
    animation: talksoft 2.8s ease-in-out infinite;
  }

  .botpair .bot :global(.listening .ear-l),
  .botpair .bot :global(.listening .ear-r) {
    transform: none;
  }

  @keyframes talksoft {
    0%, 100% { transform: rotate(-1.6deg) translateY(0); }
    50% { transform: rotate(1.6deg) translateY(-2px); }
  }

  .bot-pink {
    color: var(--hotpink);
  }

  .bot-ink {
    color: var(--ink);
  }

  .bot-sun {
    color: var(--sun);
  }

  .mascot {
    position: relative;
  }

  .spark {
    position: absolute;
    color: var(--sun);
    font-size: 16px;
    line-height: 1;
    pointer-events: none;
    animation: twinkle 2.4s ease-in-out infinite;
  }

  .s1 { top: -8px; right: -6px; transform: rotate(12deg); }
  .s2 { left: -10px; bottom: 22px; font-size: 13px; animation-delay: 0.7s; }

  @keyframes twinkle {
    0%, 100% { opacity: 0.35; transform: scale(0.85) rotate(12deg); }
    50% { opacity: 1; transform: scale(1.1) rotate(18deg); }
  }

  .everywhere {
    position: relative;
    width: 180px;
    height: 150px;
  }

  .links {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
  }

  .links path {
    stroke: rgba(19, 23, 34, 0.28);
    stroke-width: 1.6;
    stroke-linecap: round;
    stroke-dasharray: 3 5;
  }

  .hub {
    position: absolute;
    left: 2px;
    bottom: 2px;
    z-index: 2;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .hub .tilt {
    transform: rotate(16deg);
    transform-origin: 70% 80%;
  }

  .app {
    position: absolute;
    z-index: 1;
    width: 38px;
    height: 38px;
    background: #fff;
    border-radius: 11px;
    box-shadow: 0 6px 14px rgba(19, 23, 34, 0.12);
    display: grid;
    place-items: center;
  }

  .app :global(svg) {
    width: 20px;
    height: 20px;
  }

  .a-slack {
    top: 8px;
    left: 98px;
    animation: drift-slack 6.4s ease-in-out infinite;
  }

  .a-mail {
    top: 42px;
    left: 138px;
    animation: drift-mail 7.2s ease-in-out infinite 0.35s;
  }

  .a-notion {
    top: 96px;
    left: 108px;
    animation: drift-notion 8s ease-in-out infinite 0.8s;
  }

  @keyframes drift-slack {
    0%, 100% { transform: rotate(-12deg) translate(0, 0); }
    33% { transform: rotate(-6deg) translate(5px, -6px); }
    66% { transform: rotate(-16deg) translate(-4px, 3px); }
  }

  @keyframes drift-mail {
    0%, 100% { transform: rotate(14deg) translate(0, 0); }
    40% { transform: rotate(8deg) translate(-5px, 5px); }
    70% { transform: rotate(18deg) translate(3px, -4px); }
  }

  @keyframes drift-notion {
    0%, 100% { transform: rotate(-8deg) translate(0, 0); }
    30% { transform: rotate(-3deg) translate(4px, 5px); }
    65% { transform: rotate(-13deg) translate(-5px, -3px); }
  }

  .lock-scene {
    position: relative;
    width: clamp(108px, 11vw, 148px);
    padding-left: 36px;
  }

  .lock-icon {
    display: block;
    width: 100%;
    height: auto;
    filter: drop-shadow(0 16px 14px rgba(111, 143, 251, 0.32));
  }

  .lock-buddy {
    position: absolute;
    left: 0;
    bottom: 4px;
    display: flex;
    flex-direction: column;
    align-items: center;
    z-index: 1;
  }

  .lock-buddy .tilt {
    transform: rotate(14deg);
    transform-origin: 80% 90%;
  }

  .flow-art {
    position: relative;
    justify-content: center;
  }

  .flow-key {
    display: block;
    width: clamp(86px, 9vw, 118px);
    height: auto;
    filter: drop-shadow(0 16px 14px rgba(19, 23, 34, 0.22));
  }

  @media (max-width: 860px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }

  @media (max-width: 520px) {
    .body {
      flex-direction: column;
      align-items: flex-start;
    }

    p {
      max-width: none;
    }

    .art {
      align-self: center;
      width: 100%;
    }
  }
</style>
