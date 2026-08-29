<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';
  import { blip } from './sound.svelte.js';

  /* four real states of the shelf, replayed in a fake screen-top.
     auto-advances until the visitor picks a tab themselves */
  const scenes = [
    {
      id: 'dictate',
      label: 'Dictating',
      caption:
        'Hold option anywhere. Words land in any app — Slack, Mail, whatever has a cursor.',
      chip: 'listening',
    },
    {
      id: 'call',
      label: 'On a call',
      caption:
        'Hit record. Typie captures the whole call from system audio and splits it by speaker.',
      chip: 'recording',
    },
    {
      id: 'summarize',
      label: 'Summarizing',
      caption:
        'Apple Intelligence writes the title, summary and key points. Entirely on this Mac.',
      chip: 'thinking',
    },
    {
      id: 'done',
      label: 'Filed',
      caption:
        'Notes land in your library with timestamps and speaker labels. Audio never left the building.',
      chip: 'done',
    },
  ];

  let active = $state(0);
  let auto = $state(true);
  let reduced =
    typeof matchMedia !== 'undefined' &&
    matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- per-scene animation state ---- */
  const DICTATION_WORDS = [
    'okay',
    'so',
    'the',
    'plan',
    'is',
    'we',
    'ship',
    'the',
    'beta',
    'friday',
  ];
  const CALL_LINES = [
    { who: 'maya', txt: '…and the launch checklist is basically done?' },
    { who: 'sam', txt: 'two items left. pricing page and the demo video.' },
    { who: 'maya', txt: 'perfect. i can take the video this afternoon.' },
  ];

  let words = $state(0);
  let secs = $state(742);
  let lines = $state(0);
  let points = $state(3);

  function pick(i) {
    auto = false;
    active = i;
    blip(560 + i * 90, 0.07, 'square', 0.04);
  }

  $effect(() => {
    const scene = scenes[active].id;
    words = 0;
    lines = 0;
    secs = 742;
    points = reduced ? 3 : 0;

    if (reduced) {
      words = DICTATION_WORDS.length;
      lines = CALL_LINES.length;
      return;
    }

    const timers = [];

    if (scene === 'dictate') {
      const iv = setInterval(() => {
        words = words >= DICTATION_WORDS.length ? 0 : words + 1;
      }, 380);
      timers.push(iv);
    } else if (scene === 'call') {
      const tick = setInterval(() => (secs = secs + 1), 1000);
      const iv = setInterval(() => {
        lines = lines >= CALL_LINES.length ? 1 : lines + 1;
      }, 1500);
      lines = 1;
      timers.push(tick, iv);
    } else if (scene === 'done') {
      const iv = setInterval(() => {
        points = points >= 3 ? 3 : points + 1;
      }, 550);
      timers.push(iv);
    }

    /* auto-advance while untouched */
    let next;
    if (auto) {
      next = setTimeout(() => {
        active = (active + 1) % scenes.length;
      }, 5200);
    }

    return () => {
      timers.forEach(clearInterval);
      if (next) clearTimeout(next);
    };
  });
</script>

<section
  class="shelf field pop-a"
  id="notch"
>
  <div class="container">
    <p
      class="mono kicker"
      style="text-align:center"
    >
      chapter 01 · watch it live
    </p>
    <h2
      class="subhead"
      use:reveal
    >
      It all lives in <span class="squiggle"
        >your notch
        <svg
          viewBox="0 0 120 14"
          aria-hidden="true"
        >
          <path
            d="M4 9c22-6 44-6 56-3s34 4 56-2"
            stroke="var(--periwinkle)"
          />
        </svg>
      </span>
    </h2>
    <p
      class="lede"
      use:reveal={{ delay: 60 }}
    >
      No window hunting. The shelf waits at the top of your screen and does
      everything from there.
    </p>

    <!-- the tabs -->
    <div
      class="tabs"
      role="tablist"
      aria-label="shelf scenarios"
      use:reveal={{ delay: 100 }}
    >
      {#each scenes as s, i}
        <button
          role="tab"
          aria-selected={active === i}
          class="tab {s.id}"
          class:on={active === i}
          onclick={() => pick(i)}
        >
          {s.label}
        </button>
      {/each}
    </div>

    <!-- fake top-of-display -->
    <div
      class="display s-{scenes[active].id}"
      use:reveal={{ delay: 160 }}
    >
      <div
        class="wallpaper"
        aria-hidden="true"
      ></div>

      <!-- mock app window behind the notch -->
      <div
        class="appwin"
        aria-hidden="true"
      >
        <div class="apptoolbar">
          <i></i><i></i><i></i><span class="apptitle">Messages</span>
        </div>
        <div class="appbody">
          {#if scenes[active].id === 'dictate'}
            <p class="typing">
              {#each DICTATION_WORDS.slice(0, words) as w}<span
                  >{w}
                </span>{/each}<span class="caret"></span>
            </p>
          {:else if scenes[active].id === 'call'}
            <div class="calllines">
              {#each CALL_LINES.slice(0, lines) as l}
                <p class="line {l.who}">
                  <b>{l.who}</b>
                  {l.txt}
                </p>
              {/each}
            </div>
          {:else if scenes[active].id === 'summarize'}
            <p class="ghost">
              writing your meeting notes<span class="dots"
                ><i>.</i><i>.</i><i>.</i></span
              >
            </p>
          {:else}
            <div class="notecard">
              <span class="ntitle">✦ Beta sync — Friday</span>
              <ul>
                <li
                  class:on={points >= 1}
                  style="--d: 0ms"
                >
                  Ship blockers cleared, two items left
                </li>
                <li
                  style="--d: 120ms"
                  class:on={points >= 2}
                >
                  Sam takes pricing page + demo video
                </li>
                <li
                  style="--d: 240ms"
                  class:on={points >= 3}
                >
                  Launch moved up to Friday
                </li>
              </ul>
              <p class="nmeta mono">
                2 speakers · 12 min · summarized on-device
              </p>
            </div>
          {/if}
        </div>
      </div>

      <!-- THE NOTCH -->
      <div class="notch">
        {#if scenes[active].id === 'dictate'}
          <span class="nbot"
            ><Robot
              size={22}
              mood="listening"
            /></span
          >
          <span class="ncam"></span>
          <span class="nwave"
            ><TalkWave
              n={5}
              color="#fc5681"
            /></span
          >
        {:else if scenes[active].id === 'call'}
          <span class="reddot"></span>
          <span class="ntime mono"
            >{Math.floor(secs / 60)}:{String(secs % 60).padStart(2, '0')}</span
          >
          <span class="ncam"></span>
          <span class="nlbl mono">recording · mic + call</span>
        {:else if scenes[active].id === 'summarize'}
          <span class="nbot breathe"
            ><Robot
              size={22}
              mood="thinking"
            /></span
          >
          <span class="ncam"></span>
          <span class="nlbl purple mono">✦ summarizing on-device</span>
        {:else}
          <span class="nbot"
            ><Robot
              size={22}
              mood="done"
            /></span
          >
          <span class="ncam"></span>
          <span class="nok mono">✓ filed · 80ms</span>
        {/if}
      </div>

      <!-- glow matching the scene -->
      <span
        class="glow"
        aria-hidden="true"
      ></span>
    </div>

    <p
      class="caption hand"
      use:reveal={{ delay: 200 }}
    >
      {scenes[active].caption}
    </p>
  </div>
</section>

<style>
  .shelf {
    background: transparent;
  }

  .lede {
    text-align: center;
    margin-top: 14px;
    font-weight: 600;
    color: rgba(19, 23, 34, 0.66);
  }

  .tabs {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: clamp(24px, 3.5vh, 36px);
  }

  .tab {
    padding: 9px 20px;
    border-radius: 999px;
    border: 2px solid rgba(19, 23, 34, 0.8);
    background: #fff;
    font-weight: 700;
    font-size: 14.5px;
    color: var(--ink);
    box-shadow: 2px 2px 0 rgba(19, 23, 34, 0.85);
    transition:
      transform 0.22s var(--spring),
      background 0.22s var(--ease-out),
      box-shadow 0.22s var(--spring),
      opacity 0.22s var(--ease-out);
    opacity: 0.72;
  }

  .tab:hover {
    transform: translateY(-2px);
    opacity: 1;
  }

  .tab.on {
    background: var(--ink);
    color: var(--cream);
    transform: translateY(-1px);
    box-shadow: none;
    opacity: 1;
  }

  /* ---------- the fake display ---------- */
  .display {
    --glow: rgba(252, 86, 129, 0.35);
    position: relative;
    max-width: 980px;
    margin: clamp(26px, 4vh, 40px) auto 0;
    border-radius: 26px 26px 18px 18px;
    background: #0c0e12;
    padding: clamp(10px, 1.6vw, 16px);
    box-shadow:
      inset 0 0 0 2px rgba(255, 255, 255, 0.06),
      0 34px 70px rgba(19, 23, 34, 0.28);
    overflow: hidden;
  }

  .display.s-call {
    --glow: rgba(252, 86, 129, 0.5);
  }
  .display.s-summarize {
    --glow: rgba(200, 140, 253, 0.45);
  }
  .display.s-done {
    --glow: rgba(130, 237, 166, 0.45);
  }

  .wallpaper {
    height: clamp(300px, 44vw, 480px);
    border-radius: 16px 16px 10px 10px;
    position: relative;
    overflow: hidden;
    background:
      radial-gradient(
        120% 150% at 12% -10%,
        rgba(130, 237, 166, 0.75) 0%,
        transparent 50%
      ),
      radial-gradient(
        110% 140% at 92% -6%,
        rgba(252, 86, 129, 0.42) 0%,
        transparent 46%
      ),
      linear-gradient(118deg, #bcd6ff 0%, #ddd8ff 46%, #82eda6 100%);
  }

  .appwin {
    position: absolute;
    left: 50%;
    top: clamp(38px, 6vw, 64px);
    transform: translateX(-50%);
    width: min(74%, 560px);
    border-radius: 14px;
    background: rgba(255, 253, 247, 0.94);
    backdrop-filter: blur(6px);
    box-shadow: 0 18px 40px rgba(19, 23, 34, 0.22);
    overflow: hidden;
  }

  .apptoolbar {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 9px 12px;
    background: rgba(19, 23, 34, 0.05);
    border-bottom: 1px solid rgba(19, 23, 34, 0.07);
  }

  .apptoolbar i {
    width: 9px;
    height: 9px;
    border-radius: 999px;
    background: rgba(19, 23, 34, 0.16);
  }

  .apptitle {
    margin-left: 6px;
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.08em;
    color: rgba(19, 23, 34, 0.45);
  }

  .appbody {
    min-height: clamp(96px, 13vw, 148px);
    padding: clamp(12px, 1.8vw, 20px);
    font-size: clamp(13px, 1.6vw, 15.5px);
    line-height: 1.65;
    color: var(--ink);
  }

  .typing span {
    animation: word-in 0.28s var(--ease-out) both;
  }

  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    vertical-align: -0.15em;
    background: var(--hotpink);
    animation: caret 0.85s steps(1) infinite;
  }

  @keyframes caret {
    50% {
      opacity: 0;
    }
  }

  @keyframes word-in {
    from {
      opacity: 0;
      transform: translateY(4px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .calllines .line {
    animation: word-in 0.4s var(--ease-out) both;
    margin-bottom: 6px;
  }

  .calllines b {
    display: inline-block;
    min-width: 44px;
    font-size: 11px;
    font-family: var(--mono);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 1px 8px;
    border-radius: 999px;
    margin-right: 6px;
  }

  .line.maya b {
    background: var(--card-lavender);
    color: #5a48c8;
  }
  .line.sam b {
    background: var(--card-mint);
    color: var(--green-deep);
  }

  .ghost {
    font-weight: 600;
    color: rgba(19, 23, 34, 0.55);
  }

  .ghost .dots i {
    font-style: normal;
    animation: dotpulse 1.2s ease-in-out infinite;
  }
  .ghost .dots i:nth-child(2) {
    animation-delay: 0.2s;
  }
  .ghost .dots i:nth-child(3) {
    animation-delay: 0.4s;
  }

  @keyframes dotpulse {
    0%,
    100% {
      opacity: 0.25;
    }
    40% {
      opacity: 1;
    }
  }

  .notecard ul {
    list-style: none;
    margin-top: 8px;
  }

  .notecard li {
    opacity: 0;
    transform: translateY(6px);
    transition:
      opacity 0.45s var(--ease-out),
      transform 0.45s var(--ease-out);
  }

  .notecard li.on {
    opacity: 1;
    transform: none;
  }

  .notecard li.on {
    opacity: 1;
    transform: none;
  }

  .ntitle {
    font-weight: 800;
    letter-spacing: -0.01em;
    color: #8a5cf6;
  }

  .nmeta {
    margin-top: 10px;
    font-size: 10.5px;
    color: rgba(19, 23, 34, 0.5);
  }

  /* ---------- the notch itself ---------- */
  .notch {
    position: absolute;
    top: clamp(10px, 1.6vw, 16px);
    left: 50%;
    transform: translateX(-50%);
    z-index: 3;
    display: flex;
    align-items: center;
    gap: 12px;
    height: clamp(30px, 3.4vw, 38px);
    padding: 0 clamp(14px, 2vw, 22px) 4px;
    background: #000;
    border-radius: 0 0 15px 15px;
    color: #fffdf7;
    white-space: nowrap;
    transition: width 0.4s var(--spring);
  }

  .ncam {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: radial-gradient(
      circle at 35% 32%,
      #4a5568 0 18%,
      #151a22 42%,
      #07080c 100%
    );
    box-shadow:
      inset 0 0 0 1px rgba(120, 130, 150, 0.4),
      0 0 0 2px #000;
  }

  .nbot {
    display: block;
    line-height: 0;
    color: var(--hotpink);
  }

  .s-summarize .nbot {
    color: var(--purple);
  }

  .breathe {
    animation: breathe 1.6s var(--ease-inout) infinite;
  }

  @keyframes breathe {
    0%,
    100% {
      transform: scale(1);
      opacity: 0.85;
    }
    50% {
      transform: scale(1.12);
      opacity: 1;
    }
  }

  .nwave {
    width: 34px;
  }

  .nwave :global(.talkwave) {
    height: 13px;
    gap: 2px;
  }

  .nwave :global(.talkwave i) {
    width: 2.5px;
  }

  .reddot {
    width: 9px;
    height: 9px;
    border-radius: 999px;
    background: var(--hotpink);
    animation: blinkdot 1.1s steps(1) infinite;
  }

  @keyframes blinkdot {
    50% {
      opacity: 0.25;
    }
  }

  .ntime {
    font-weight: 600;
  }

  .nlbl,
  .nok {
    font-size: clamp(10px, 1.2vw, 12px);
    letter-spacing: 0.04em;
  }

  .nlbl.purple {
    color: var(--purple);
  }
  .nok {
    color: var(--mint);
  }

  /* scene-colored halo bleeding out of the notch */
  .glow {
    position: absolute;
    top: calc(clamp(10px, 1.6vw, 16px) - 30px);
    left: 50%;
    width: min(60%, 420px);
    height: 90px;
    transform: translateX(-50%);
    background: radial-gradient(
      50% 60% at 50% 50%,
      var(--glow),
      transparent 70%
    );
    filter: blur(14px);
    pointer-events: none;
    z-index: 2;
    transition: background 0.5s var(--ease-out);
  }

  .caption {
    text-align: center;
    margin-top: clamp(20px, 3vh, 28px);
    font-size: clamp(21px, 2.2vw, 27px);
    color: rgba(19, 23, 34, 0.78);
    min-height: 1.6em;
  }

  @media (max-width: 720px) {
    .nlbl {
      display: none;
    }
  }
</style>
