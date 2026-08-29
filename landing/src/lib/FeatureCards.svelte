<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import Notch from './Notch.svelte';
</script>

<section class="features field pop-b" id="features">
  <div class="container grid">
    <!-- Talk like you think -->
    <article class="card c-lavender" use:reveal>
      <h3>Talk like you think</h3>
      <div class="body">
        <p>
          No commands, no robot voice. Mumble, ramble, talk too fast, it still comes out as the
          sentence you meant.
        </p>
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
                <span class="bot bot-purple"
                  ><Robot size={92} mood="listening" bg="var(--card-lavender)" /></span
                >
              </span>
              <i class="ground g-bot"></i>
            </span>
          </span>
        </div>
      </div>
    </article>

    <!-- Privacy -->
    <article class="card c-blue" use:reveal={{ delay: 80 }}>
      <h3>Your voice never leaves your Mac</h3>
      <div class="body">
        <p>
          Transcribed on-device, then the audio is gone. No cloud, no uploads. We couldn’t hear you
          if we tried.
        </p>
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
                <span class="bot bot-navy"
                  ><Robot size={64} mood="idle" bg="var(--card-blue)" /></span
                >
              </span>
              <i class="ground g-bot"></i>
            </span>
          </span>
        </div>
      </div>
    </article>

    <!-- Ridiculously fast -->
    <article class="card c-cream" use:reveal>
      <h3>Ridiculously fast</h3>
      <div class="body">
        <p>
          No server round trip. Words land in about 100 milliseconds, roughly the pause between your
          own sentences.
        </p>
        <div class="art">
          <span class="speedscene" aria-hidden="true">
            <span class="hub mascot">
              <span class="tilt">
                <span class="spark s1">✦</span>
                <span class="bot bot-orange"
                  ><Robot size={78} mood="idle" bg="var(--card-cream)" /></span
                >
              </span>
              <i class="ground g-bot"></i>
            </span>
            <span class="chip ch-a"><b>&lt;100 ms</b> voice to text</span>
            <span class="chip ch-b"><b>0</b> uploads</span>
            <span class="chip ch-c"><b>100%</b> on-device</span>
          </span>
        </div>
      </div>
    </article>

    <!-- Hold. Speak. Release. -->
    <article class="card c-mint" use:reveal={{ delay: 80 }}>
      <h3>Hold. Speak. Release.</h3>
      <div class="body">
        <div class="copy">
          <p>
            One shortcut. That’s the whole interface. Hold ⌥, say the thing, let go, and you’re back
            in the sentence.
          </p>
          <p>And if you wanna go real crazy, you can even remap the key.</p>
        </div>
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

  .grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    grid-auto-rows: minmax(200px, auto);
    gap: clamp(20px, 2.8vw, 32px);
  }

  /* bento law: one cell dominates — wide, not comedically tall */
  .c-lavender {
    grid-column: span 2;
  }

  .c-lavender h3 {
    font-size: clamp(24px, 2.6vw, 34px);
  }

  .c-lavender p {
    max-width: 38ch;
    font-size: 17px;
  }

  .c-lavender .wave-icon {
    width: clamp(120px, 11vw, 160px);
  }

  .c-lavender .bot :global(svg) {
    width: 108px;
    height: 108px;
  }

  /* 1x1 cells: stack text over art so copy keeps full width at every breakpoint */
  .c-blue .body,
  .c-cream .body {
    flex-direction: column;
    align-items: flex-start;
    gap: 18px;
  }

  .c-blue p,
  .c-cream p {
    max-width: none;
  }

  .c-blue .art,
  .c-cream .art {
    align-self: center;
  }

  /* mint fills the second row as the wide band */
  .c-mint {
    grid-column: span 2;
  }

  .c-mint .body {
    align-items: center;
    justify-content: space-between;
  }

  .c-mint .copy {
    display: flex;
    flex-direction: column;
    gap: 10px;
    flex: 1;
  }

  .c-mint p {
    max-width: 44ch;
  }

  .c-mint .art {
    align-self: center;
  }

  .c-mint .flow-key {
    width: clamp(110px, 11vw, 150px);
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
      box-shadow 0.3s var(--ease-out);
  }

  .card:hover {
    transform: translateY(-6px) rotate(-0.5deg);
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.1);
  }

  .c-lavender {
    background: var(--card-lavender);
    color: var(--ink);
  }
  .c-blue {
    background: var(--card-blue);
    color: var(--ink);
  }
  .c-cream {
    background: var(--card-cream);
    color: var(--ink);
  }
  .c-mint {
    background: var(--card-mint);
    color: var(--ink);
  }

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
    font-size: 16px;
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.82);
    opacity: 1;
    max-width: 30ch;
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
    animation: wavebob 4.2s var(--ease-inout) infinite;
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
    0%,
    100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-3px);
    }
  }

  /* this card's robot should nod, not boogie */
  .botpair .bot :global(.listening svg) {
    animation: talksoft 2.8s var(--ease-inout) infinite;
  }

  .botpair .bot :global(.listening .ear-l),
  .botpair .bot :global(.listening .ear-r) {
    transform: none;
  }

  @keyframes talksoft {
    0%,
    100% {
      transform: rotate(-1.6deg) translateY(0);
    }
    50% {
      transform: rotate(1.6deg) translateY(-2px);
    }
  }

  .bot-purple {
    color: #8a5ff2; /* matches the talk-wave waveform graphic beside it */
  }

  .bot-navy {
    color: #2c3f9e;
  }

  .bot-orange {
    color: var(--orange);
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
    animation: twinkle 2.4s var(--ease-inout) infinite;
  }

  .s1 {
    top: -8px;
    right: -6px;
    transform: rotate(12deg);
  }
  .s2 {
    left: -10px;
    bottom: 22px;
    font-size: 13px;
    animation-delay: 0.7s;
  }

  @keyframes twinkle {
    0%,
    100% {
      opacity: 0.35;
      transform: scale(0.85) rotate(12deg);
    }
    50% {
      opacity: 1;
      transform: scale(1.1) rotate(18deg);
    }
  }

  /* speed scene: robot centred inside the dashed ring + floating proof chips */
  .speedscene {
    position: relative;
    width: 190px;
    height: 150px;
    display: flex;
    justify-content: center;
    align-items: center;
    padding-bottom: 6px;
  }

  .speedscene::before {
    content: '';
    position: absolute;
    inset: 6% 4% 10%;
    border: 1.6px dashed rgba(19, 23, 34, 0.26);
    border-radius: 50%;
  }

  .speedscene .hub {
    position: relative;
    z-index: 2;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .speedscene .hub .tilt {
    transform: rotate(-6deg);
    transform-origin: 50% 80%;
  }

  .chip {
    position: absolute;
    background: #fff;
    border-radius: 999px;
    padding: 7px 13px;
    font-size: 12.5px;
    font-weight: 500;
    color: rgba(19, 23, 34, 0.66);
    white-space: nowrap;
    box-shadow: 0 6px 14px rgba(19, 23, 34, 0.12);
  }

  .chip b {
    color: var(--ink);
    font-weight: 800;
    margin-right: 3px;
  }

  .ch-a {
    top: 4px;
    left: -6px;
    animation: drift-slack 6.4s var(--ease-inout) infinite;
  }

  .ch-b {
    top: 34px;
    right: -14px;
    animation: drift-mail 7.2s var(--ease-inout) infinite 0.35s;
  }

  .ch-c {
    bottom: 16px;
    right: -4px;
    animation: drift-notion 8s var(--ease-inout) infinite 0.8s;
  }

  @keyframes drift-slack {
    0%,
    100% {
      transform: rotate(-12deg) translate(0, 0);
    }
    33% {
      transform: rotate(-6deg) translate(5px, -6px);
    }
    66% {
      transform: rotate(-16deg) translate(-4px, 3px);
    }
  }

  @keyframes drift-mail {
    0%,
    100% {
      transform: rotate(14deg) translate(0, 0);
    }
    40% {
      transform: rotate(8deg) translate(-5px, 5px);
    }
    70% {
      transform: rotate(18deg) translate(3px, -4px);
    }
  }

  @keyframes drift-notion {
    0%,
    100% {
      transform: rotate(-8deg) translate(0, 0);
    }
    30% {
      transform: rotate(-3deg) translate(4px, 5px);
    }
    65% {
      transform: rotate(-13deg) translate(-5px, -3px);
    }
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

  @media (max-width: 1079px) {
    .grid {
      grid-template-columns: repeat(2, minmax(0, 1fr));
      grid-auto-rows: minmax(180px, auto);
    }

    .c-lavender {
      grid-column: span 2;
      grid-row: auto;
    }

    .c-mint {
      grid-column: span 2;
    }
  }

  @media (max-width: 700px) {
    .grid {
      grid-template-columns: 1fr;
      grid-auto-rows: auto;
    }

    .c-lavender,
    .c-mint {
      grid-column: auto;
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
