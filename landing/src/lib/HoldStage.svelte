<script>
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';
  import { app } from './state.svelte.js';
  import { hold } from './hold.svelte.js';
  import outlook from 'thesvg/microsoft-outlook';
  import messenger from 'thesvg/messenger';
  import slack from 'thesvg/slack';
  import gdocs from 'thesvg/google-docs';
  import vscode from 'thesvg/visual-studio-code';
  import chrome from 'thesvg/chrome';
  import appleNotes from '../assets/apple-notes-icon.svg?raw';
  import { nsSvg } from './svgid.js';

  const pressSfx =
    typeof Audio !== 'undefined' ? new Audio('/sounds/keypress.wav') : null;
  const releaseSfx =
    typeof Audio !== 'undefined' ? new Audio('/sounds/keyrelease.wav') : null;

  function playSfx(sfx) {
    if (!sfx) return;
    try {
      sfx.currentTime = 0;
      sfx.volume = 0.55;
      sfx.play();
    } catch {}
  }

  const scenes = [
    {
      id: 'mail',
      name: 'Outlook',
      wave: '#0f6cbd',
      brand: outlook.svg,
      icon: '✉️',
      title: 'New Message',
      meta: 'To: chad@',
      side: [['Inbox', '3'], ['Drafts'], ['Sent'], ['Junk'], ['Bin']],
      text: "hey I'll be about thirty minutes late the train is delayed again",
    },
    {
      id: 'notes',
      name: 'Notes',
      wave: '#e0912f',
      brand: appleNotes,
      icon: '📝',
      title: 'Notes',
      meta: 'iCloud',
      side: [
        ['All iCloud'],
        ['Notes', '12'],
        ['Shopping', '2'],
        ['Work', '4'],
        ['Ideas', '7'],
      ],
      text: 'oat milk, candles, call mum, ship the changelog',
    },
    {
      id: 'chat',
      name: 'Messenger',
      wave: '#0084ff',
      brand: messenger.svg,
      icon: '💬',
      title: 'Alex, Sam +1',
      meta: 'active now',
      side: [['Alex'], ['Sam'], ['Mum'], ['Chad'], ['Design group']],
      text: 'the deck is in the drive slides four through nine are yours',
    },
    {
      id: 'slack',
      name: 'Slack',
      wave: '#ecb22e',
      brand: slack.svg,
      icon: '💼',
      title: '#launch-week',
      meta: '4 members',
      side: [
        ['# launch-week'],
        ['# general'],
        ['# design'],
        ['# random'],
        ['# marketing'],
      ],
      text: 'just shipped the new build - feedback welcome!',
    },
    {
      id: 'docs',
      name: 'Google Docs',
      wave: '#1a73e8',
      brand: gdocs.svg,
      icon: '📄',
      title: 'launch notes',
      meta: 'saved to Drive',
      side: [
        ['launch notes', 'you'],
        ['roadmap', 'sam'],
        ['okrs q4', 'alex'],
        ['snack rota', 'mum'],
      ],
      text: 'launch is thursday - bring the good snacks',
    },
    {
      id: 'code',
      name: 'VS Code',
      wave: '#0098ff',
      brand: vscode.svg,
      icon: '🧑‍💻',
      title: 'main.ts · typie',
      meta: 'Visual Studio Code',
      side: [['main.ts'], ['index.ts'], ['styles.css'], ['README.md']],
      text: 'ship it, ship it now',
    },
  ];

  const KEYS = [
    { char: '⌥', name: 'option', code: 'Alt' },
    { char: '⌘', name: 'command', code: 'Meta' },
    { char: '⇧', name: 'shift', code: 'Shift' },
    { char: '^', name: 'control', code: 'Control' },
  ];

  let step = $state(0);
  let mode = $state('idle');
  let notchOpen = $state(false);
  let lastMs = $state(null);
  let keyI = $state(0);
  let armed = $state(false);
  let root = $state(null);
  let timers = [];

  const scene = $derived(scenes[step]);
  const key = $derived(KEYS[keyI]);

  function clearTimers() {
    timers.forEach(clearTimeout);
    timers = [];
  }

  function later(fn, ms) {
    timers.push(setTimeout(fn, ms));
  }

  const MIN_HOLD = 600;
  /* safety net: a demo hold should never outlive this, even if a
     release event gets lost somewhere */
  const MAX_HOLD = 12000;
  let pressStart = 0;

  function armWatchdog() {
    later(() => {
      if (mode === 'listening') release();
    }, MAX_HOLD);
  }

  function startListening(user = false) {
    mode = 'listening';
    app.mood = 'listening';
    notchOpen = true;
    pressStart = performance.now();
    playSfx(pressSfx);
    hold.demoing = user;
    armWatchdog();
    /* no auto-pop: hold as long as you like (min 600 ms) */
  }

  function release() {
    if (mode !== 'listening') return;
    const held = performance.now() - pressStart;
    /* short taps still get a quick transcription - never make people wait
       the full min-hold, and never let a re-press push it further away */
    later(popNow, Math.max(0, Math.min(320, MIN_HOLD - held)));
  }

  function popNow() {
    clearTimers();
    playSfx(releaseSfx);
    hold.demoing = false;
    lastMs = 58 + Math.round(Math.random() * 36);
    app.lastMs = lastMs;
    mode = 'done';
    app.mood = 'done';
    later(() => {
      notchOpen = false;
    }, 200);
    later(() => {
      step = (step + 1) % scenes.length;
      mode = 'idle';
      app.mood = 'idle';
    }, 3400);
  }

  function onPointerUp() {
    release();
  }

  function press(user = false) {
    if (!armed) return;
    clearTimers();
    if (mode === 'listening') {
      /* a user pressing mid-auto-demo takes over the live hold instead of
         killing it - otherwise their first clicks feel like no-ops */
      if (user && !hold.demoing) {
        hold.demoing = true;
        armWatchdog();
        return;
      }
      release();
    } else if (mode === 'done') {
      step = (step + 1) % scenes.length;
      startListening(user);
    } else {
      startListening(user);
    }
  }

  function cycleKey(e) {
    e.stopPropagation();
    if (mode !== 'idle') return;
    keyI = (keyI + 1) % KEYS.length;
  }

  let down = false;

  function onKey(e) {
    if (!armed || e.repeat || e.key !== key.code) return;
    e.preventDefault();
    down = true;
    press(true);
  }

  function onKeyUp(e) {
    /* release on ANY modifier keyup - an exact-match check can miss
       (cycled keys, AltGraph, layout quirks) and leave it stuck live */
    if (!KEYS.some((k) => k.code === e.key)) return;
    down = false;
    release();
  }

  function pick(i) {
    if (i === step && mode === 'idle') return;
    clearTimers();
    hold.demoing = false;
    step = i;
    lastMs = null;
    notchOpen = false;
    mode = 'idle';
    app.mood = 'idle';
  }

  $effect(() => {
    if (!root) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        armed = entry.isIntersecting && entry.intersectionRatio >= 0.15;
      },
      { threshold: [0, 0.15, 0.4] }
    );
    io.observe(root);
    return () => {
      io.disconnect();
      clearTimers();
    };
  });

  $effect(() => () => {
    if (app.mood !== 'idle') app.mood = 'idle';
    hold.demoing = false;
  });

  /* let the hero headline keycap drive the real demo.
     user=true only from real interactions (click / keypress); the
     auto-demo loop calls hold.press() bare, so it stays bloops-only */
  $effect(() => {
    hold.press = (user = false) => {
      armed = true;
      press(user);
    };
  });
</script>

<svelte:window
  onkeydown={onKey}
  onkeyup={onKeyUp}
  onpointerup={onPointerUp}
  onpointercancel={onPointerUp}
  onblur={() => release()}
/>

<div
  class="stage"
  bind:this={root}
>
  {#key scene.id}
    <p class="tryhint mono">
      <button
        class="minikey"
        class:down={mode === 'listening'}
        onpointerdown={(e) => {
          e.preventDefault();
          press(true);
        }}
        aria-label="Press to try Typie live"
      >
        <b>{key.char}</b>{key.name}
      </button>
      press & <b>hold</b> to try it live
    </p>

    <div
      class="mac"
      class:listening={mode === 'listening'}
      class:done={mode === 'done'}
    >
      <div class="smenubar">
        <span class="mbleft mono">
          <b class="apple"></b>
          <b>{scene.name}</b>
          <span>File</span><span>Edit</span><span>View</span><span>Help</span>
        </span>
        <div class="notchwrap">
          <div
            class="notch"
            class:open={notchOpen}
          >
            <span
              class="nleft"
              class:show={notchOpen}
              aria-hidden="true"
            >
              <Robot
                size={22}
                mood={mode === 'listening'
                  ? 'listening'
                  : mode === 'done'
                    ? 'done'
                    : 'idle'}
              />
            </span>
            <span
              class="cam"
              aria-hidden="true"
            ></span>
            <span
              class="nright"
              class:show={notchOpen}
              aria-hidden="true"
            >
              {#if mode === 'listening'}
                <span class="wave"
                  ><TalkWave
                    n={5}
                    color="#fc5681"
                  /></span
                >
              {:else if mode === 'done'}
                <span class="nok mono">✓ {lastMs} ms</span>
              {/if}
            </span>
          </div>
        </div>
        <span class="mbright mono">
          <svg
            class="wifi"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.2"
            stroke-linecap="round"
            aria-hidden="true"
          >
            <path d="M4.5 12.5a11 11 0 0 1 15 0" />
            <path d="M8.3 16.3a6 6 0 0 1 7.4 0" />
            <circle
              cx="12"
              cy="19.6"
              r="1.4"
              fill="currentColor"
              stroke="none"
            />
          </svg>
          <i class="bat"></i>
        </span>
      </div>

      <div class="desk">
        <div class="chromewrap">
          {#if scene.id === 'docs'}
            <div
              class="browser"
              aria-hidden="true"
            >
              <div class="btabs">
                <span class="btab on"
                  ><i class="bfav">{@html nsSvg(chrome, 'cfav')}</i>launch notes
                  - Google Docs<i class="bx">✕</i></span
                >
                <span class="btab new">+</span>
              </div>
              <div class="burl">
                <span class="bnav">‹ › ⟳</span>
                <span class="baddr"
                  >docs.google.com/document/d/launch-notes</span
                >
                <span class="bprof">S</span>
              </div>
            </div>
          {/if}
          <div
            class="window theme-{scene.id}"
            class:done={mode === 'done'}
          >
            {#if scene.id === 'docs'}
              <div class="docsbar">
                <i
                  class="dlogo"
                  aria-hidden="true">{@html nsSvg(gdocs.svg, 'dlog')}</i
                >
                <div class="dmeta">
                  <p class="dn">
                    <b>launch notes</b><span aria-hidden="true">☆</span>
                  </p>
                  <p class="dmenu mono">
                    File Edit View Insert Format Tools Help
                  </p>
                </div>
                <span class="dshare">Share</span>
              </div>
            {/if}
            <div class="titlebar">
              <span
                class="tl"
                aria-hidden="true"
                ><i class="r"></i><i class="y"></i><i class="g"></i></span
              >
              {#if scene.id === 'chat'}<span
                  class="tavatar"
                  aria-hidden="true">A</span
                >{/if}
              <span class="wtitle">{scene.title}</span>
              <span class="meta mono">{scene.meta}</span>
            </div>
            <div class="winbody">
              <aside class="side">
                <p class="side-h">
                  {#if scene.brand}<i
                      class="bmark"
                      aria-hidden="true"
                      >{@html nsSvg(scene.brand, 'sh' + scene.id)}</i
                    >{/if}
                  {scene.name}
                </p>
                <ul>
                  {#each scene.side as [label, count], i}
                    <li class:on={i === 0}>
                      <i
                        class="av"
                        aria-hidden="true">{label[0]}</i
                      >{label}{#if count}<b>{count}</b>{/if}
                    </li>
                  {/each}
                </ul>
              </aside>
              <div class="paper">
                {#if mode === 'listening'}
                  <div
                    class="talking"
                    aria-hidden="true"
                  >
                    <TalkWave
                      n={17}
                      color={scene.wave}
                    />
                    <p class="hint2 hand">say anything…</p>
                  </div>
                {:else if mode === 'done'}
                  {#key step}
                    <div class="popwrap">
                      <div
                        class="sparkles"
                        aria-hidden="true"
                      >
                        {#each Array(10) as _, i}
                          <span
                            style="--a:{i * 36}deg; animation-delay:{i * 30}ms"
                            >✦</span
                          >
                        {/each}
                      </div>
                      {#if scene.id === 'notes'}
                        <p class="note-title">Today</p>
                        <p class="note-date mono">just now</p>
                      {/if}
                      {#if scene.id === 'chat'}
                        <div class="bubble-in">did you send the deck?</div>
                        <div class="bubble-out">{scene.text}</div>
                      {:else if scene.id === 'slack'}
                        <div class="slack-msg">
                          <i
                            class="sava sa"
                            aria-hidden="true">A</i
                          >
                          <div class="sbody">
                            <p class="shead">
                              <b>alex</b><span class="mono">2h ago</span>
                            </p>
                            <p class="stext">
                              ok who wants to present tomorrow?
                            </p>
                          </div>
                        </div>
                        <div class="slack-msg">
                          <i
                            class="sava ss"
                            aria-hidden="true">S</i
                          >
                          <div class="sbody">
                            <p class="shead">
                              <b>sam</b><span class="mono">45m ago</span>
                            </p>
                            <p class="stext">i've got slides four to nine</p>
                          </div>
                        </div>
                        <div class="slack-msg">
                          <i
                            class="sava"
                            aria-hidden="true">Y</i
                          >
                          <div class="sbody">
                            <p class="shead">
                              <b>you</b><span class="mono">now</span>
                            </p>
                            <p class="stext">{scene.text}</p>
                          </div>
                        </div>
                      {:else if scene.id === 'docs'}
                        <p class="doc-title">launch notes</p>
                        <p class="doc-text">{scene.text}</p>
                      {:else if scene.id === 'notes'}
                        <p class="note-title">Today</p>
                        <p class="note-date mono">just now</p>
                        <p class="note-text">{scene.text}</p>
                      {:else if scene.id === 'code'}
                        <p class="code">
                          <span class="ckw">const</span>
                          <span class="cvar">note</span>
                          =
                          <span class="cstr">'{scene.text}'</span>
                        </p>
                      {:else}
                        <p class="mail-text">{scene.text}</p>
                      {/if}
                      <span class="badge mono">✓ typed in {lastMs} ms</span>
                    </div>
                  {/key}
                {:else}
                  {#if scene.id === 'mail'}
                    <div class="fields">
                      <span>To: chad@</span><span>Subject: tonight</span>
                    </div>
                  {:else if scene.id === 'notes'}
                    <p class="note-title">Today</p>
                    <p class="note-date mono">just now</p>
                  {:else if scene.id === 'chat'}
                    <div class="bubble-in">did you send the deck?</div>
                  {:else if scene.id === 'slack'}
                    <p class="chan"># launch-week</p>
                    <div class="slack-msg">
                      <i
                        class="sava sa"
                        aria-hidden="true">A</i
                      >
                      <div class="sbody">
                        <p class="shead">
                          <b>alex</b><span class="mono">2h ago</span>
                        </p>
                        <p class="stext">ok who wants to present tomorrow?</p>
                      </div>
                    </div>
                    <div class="slack-msg">
                      <i
                        class="sava ss"
                        aria-hidden="true">S</i
                      >
                      <div class="sbody">
                        <p class="shead">
                          <b>sam</b><span class="mono">45m ago</span>
                        </p>
                        <p class="stext">i've got slides four to nine</p>
                      </div>
                    </div>
                  {:else if scene.id === 'docs'}
                    <p class="doc-title">launch notes</p>
                  {/if}
                  <p class="ghost mono">
                    press {key.name} and speak - your words land here, whole, instantly.
                  </p>
                {/if}
                {#if scene.id === 'mail' && mode !== 'listening'}
                  <span class="sendbtn">Send</span>
                {/if}
              </div>
            </div>
          </div>
        </div>

        <nav class="dock">
          {#each scenes as s, i}
            <button
              class="dock-item"
              class:on={step === i}
              onclick={() => pick(i)}
              aria-label={s.name}
            >
              <span class="dicon">
                {#if s.id === 'docs'}<i class="dbmark"
                    >{@html nsSvg(chrome, 'dkdocs')}</i
                  >{:else if s.brand}<i class="dbmark"
                    >{@html nsSvg(s.brand, 'dk' + s.id)}</i
                  >{:else}{s.icon}{/if}
              </span>
              <i class="dot"></i>
            </button>
          {/each}
        </nav>
      </div>
    </div>
  {/key}
</div>

<style>
  /* impeccable-disable bounce-easing, layout-transition, side-tab — legacy HoldStage uses Theme.springy intentionally */
  .stage {
    width: 100%;
    height: 100%;
    min-height: 0;
    margin-inline: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 18px;
  }

  .tryhint {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-size: 12px !important;
    color: rgba(19, 23, 34, 0.5);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    order: 2;
  }

  .tryhint b {
    color: var(--hotpink);
    font-weight: 500;
  }

  .minikey {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    padding: 7px 14px 7px 11px;
    background: var(--green-deep);
    color: var(--cream);
    border-radius: 10px;
    font-family: var(--mono);
    font-size: 13px;
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.18),
      0 4px 0 #1a0a32;
    transition:
      transform 0.1s var(--snap),
      box-shadow 0.1s var(--snap),
      background 0.12s var(--ease-out);
    user-select: none;
    -webkit-user-select: none;
  }

  .minikey b {
    font-weight: 500;
    font-size: 15px;
  }

  .minikey:hover {
    background: var(--ink);
  }

  .minikey.down {
    transform: translateY(3px);
    box-shadow: 0 1px 0 #1a0a32;
    background: var(--hotpink);
  }

  /* idle nudge: the key taps itself so people get it */
  .minikey:not(.down) {
    animation: nudge 3.4s var(--ease-inout) infinite;
  }

  @keyframes nudge {
    0%,
    10%,
    100% {
      transform: translateY(0);
      box-shadow:
        inset 0 1px 0 rgba(255, 255, 255, 0.18),
        0 4px 0 #1a0a32;
    }
    5% {
      transform: translateY(3px);
      box-shadow:
        inset 0 1px 0 rgba(255, 255, 255, 0.18),
        0 1px 0 #1a0a32;
    }
  }

  .minikey.down {
    transform: translateY(3px);
    box-shadow: 0 1px 0 #1a0a32;
    background: var(--hotpink);
    animation: none;
  }

  .key {
    position: relative;
    width: 76px;
    height: 54px;
    border-radius: 12px;
    background: var(--green-deep);
    color: var(--cream);
    font-family: var(--mono);
    display: grid;
    place-items: center;
    grid-auto-flow: column;
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.18),
      0 5px 0 #1a0a32;
    transition:
      transform 0.1s var(--snap),
      box-shadow 0.1s var(--snap),
      background 0.12s var(--ease-out);
    cursor: pointer;
  }

  .kstack {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    line-height: 1;
  }

  .ksym {
    font-size: 18px;
  }

  .kname {
    font-size: 8px;
    letter-spacing: 0.06em;
    text-transform: lowercase;
    opacity: 0.7;
  }

  .key::after {
    content: '';
    position: absolute;
    inset: -6px;
    border-radius: 16px;
    border: 2px solid var(--hotpink);
    opacity: 0;
    transform: scale(0.8);
  }

  .opt-btn.down .key::after {
    animation: ring 0.55s var(--ease-out);
  }

  @keyframes ring {
    0% {
      opacity: 0.9;
      transform: scale(0.85);
    }
    100% {
      opacity: 0;
      transform: scale(1.35);
    }
  }

  .br {
    color: var(--hotpink);
    font-weight: 500;
    font-size: 15px;
  }

  .lbl {
    font-family: var(--display);
    font-weight: 800;
    font-size: 15px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
  }

  .window {
    width: 100%;
    background: var(--cream);
    border: 1px solid rgba(3, 43, 37, 0.12);
    border-radius: 28px;
    overflow: hidden;
    text-align: left;
    box-shadow:
      0 40px 90px rgba(3, 43, 37, 0.22),
      0 4px 14px rgba(3, 43, 37, 0.08);
    transition:
      box-shadow 0.3s var(--ease-out),
      transform 0.3s var(--spring);
  }

  .window.listening {
    box-shadow:
      0 40px 90px rgba(3, 43, 37, 0.26),
      0 0 0 3px var(--mint-live);
  }

  .window.done {
    animation: land 0.5s cubic-bezier(0.2, 1.4, 0.35, 1);
  }

  @keyframes land {
    0% {
      transform: scale(0.985);
    }
    55% {
      transform: scale(1.008);
    }
    100% {
      transform: none;
    }
  }

  /* mac screen frame */
  .mac {
    position: relative;
    width: 100%;
    height: 100%;
    min-height: 0;
    display: flex;
    flex-direction: column;
    border-radius: 22px 22px 0 0;
    overflow: hidden;
    border: 5px solid #0d0f0e;
    box-shadow:
      0 40px 90px rgba(3, 43, 37, 0.24),
      0 4px 14px rgba(3, 43, 37, 0.08),
      inset 0 0 0 1px rgba(255, 255, 255, 0.06);
    background:
      radial-gradient(
        120% 90% at 15% 0%,
        rgba(88, 232, 148, 0.9),
        transparent 62%
      ),
      radial-gradient(
        120% 110% at 90% 10%,
        rgba(140, 185, 255, 0.95),
        transparent 58%
      ),
      radial-gradient(
        110% 85% at 55% 105%,
        rgba(255, 158, 216, 0.65),
        transparent 60%
      ),
      linear-gradient(160deg, #cff2b4 0%, #bcc9ff 52%, #ffd0ec 100%);
    transition: box-shadow 0.3s var(--ease-out);
  }

  .mac.listening {
    box-shadow:
      0 40px 90px rgba(3, 43, 37, 0.28),
      0 0 0 3px var(--mint-live);
  }

  .smenubar {
    position: relative;
    z-index: 4;
    height: 26px;
    background: rgba(19, 23, 34, 0.07);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    overflow: visible;
  }

  .mbleft,
  .mbright {
    display: flex;
    align-items: center;
    gap: 12px;
    color: rgba(19, 23, 34, 0.65);
    font-size: 11px !important;
    letter-spacing: 0.02em;
    text-transform: none;
  }

  .mbleft b {
    font-weight: 700;
    color: var(--ink);
  }

  .apple {
    font-size: 13px;
    line-height: 1;
  }

  .wifi,
  .bat {
    display: inline-block;
    opacity: 0.8;
  }

  .wifi {
    width: 15px;
    height: 13px;
    display: block;
    opacity: 0.85;
  }

  .bat {
    width: 20px;
    height: 10px;
    border: 1px solid rgba(19, 23, 34, 0.7);
    border-radius: 3px;
    position: relative;
  }

  .bat::before {
    content: '';
    position: absolute;
    inset: 1.5px 30% 1.5px 1.5px;
    background: var(--mint-live);
    border-radius: 1px;
  }

  .bat::after {
    content: '';
    position: absolute;
    right: -3px;
    top: 2.5px;
    width: 2px;
    height: 5px;
    background: rgba(19, 23, 34, 0.7);
    border-radius: 0 2px 2px 0;
  }

  .notchwrap {
    position: absolute;
    left: 50%;
    top: 0;
    transform: translateX(-50%);
    z-index: 6;
    overflow: visible;
    pointer-events: none;
  }

  /* hardware camera notch idle → grows into the live island */
  .notch {
    position: relative;
    z-index: 1;
    width: 78px;
    height: 26px;
    background: #000;
    border-radius: 0 0 13px 13px;
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto minmax(0, 1fr);
    align-items: center;
    column-gap: 0;
    padding: 0 8px;
    pointer-events: auto;
    overflow: hidden;
    transform-origin: 50% 0;
    transition:
      width 0.58s cubic-bezier(0.22, 1.28, 0.36, 1),
      padding 0.5s cubic-bezier(0.22, 1.28, 0.36, 1),
      column-gap 0.5s cubic-bezier(0.22, 1.28, 0.36, 1);
  }

  .notch.open {
    width: 252px;
    height: 26px;
    padding: 0 14px;
    column-gap: 8px;
    animation: islandpop 0.58s cubic-bezier(0.22, 1.28, 0.36, 1);
  }

  @keyframes islandpop {
    0% {
      transform: scale(1, 1);
    }
    42% {
      transform: scale(1.045, 1.1);
    }
    100% {
      transform: scale(1, 1);
    }
  }

  .cam {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    justify-self: center;
    background: radial-gradient(
      circle at 35% 32%,
      #4a5568 0 18%,
      #151a22 42%,
      #07080c 100%
    );
    box-shadow:
      inset 0 0 0 1px rgba(120, 130, 150, 0.35),
      0 0 0 2px #000;
    flex-shrink: 0;
  }

  .nleft,
  .nright {
    min-width: 0;
    opacity: 0;
    display: flex;
    align-items: center;
    overflow: hidden;
    transform: translateY(2px) scale(0.84);
    transition:
      opacity 0.28s ease 0.16s,
      transform 0.4s cubic-bezier(0.22, 1.2, 0.36, 1) 0.12s;
  }

  .nleft {
    justify-content: flex-start;
    justify-self: start;
  }
  .nright {
    justify-content: flex-end;
    justify-self: end;
  }

  .notch.open .nleft,
  .notch.open .nright {
    opacity: 1;
    transform: none;
  }

  .nleft :global(.robot) {
    color: var(--hotpink);
  }

  .wave {
    display: block;
    width: 36px;
  }

  .wave :global(.talkwave) {
    height: 12px;
    gap: 2px;
  }

  .wave :global(.talkwave i) {
    width: 2.5px;
  }

  .nok {
    font-size: 9px !important;
    color: var(--hotpink);
    white-space: nowrap;
  }

  /* desktop wallpaper */
  .desk {
    position: relative;
    z-index: 1;
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: column;
    padding: clamp(18px, 3vw, 30px);
    padding-bottom: clamp(64px, 8vw, 76px);
    background:
      radial-gradient(
        120% 90% at 15% 0%,
        rgba(88, 232, 148, 0.9),
        transparent 62%
      ),
      radial-gradient(
        120% 110% at 90% 10%,
        rgba(140, 185, 255, 0.95),
        transparent 58%
      ),
      radial-gradient(
        110% 85% at 55% 105%,
        rgba(255, 158, 216, 0.65),
        transparent 60%
      ),
      linear-gradient(160deg, #cff2b4 0%, #bcc9ff 52%, #ffd0ec 100%);
  }

  .window {
    width: 100%;
    min-height: 0;
    margin-inline: auto;
    flex: 1;
    display: flex;
    flex-direction: column;
    background: var(--cream);
    border-radius: 12px;
    overflow: hidden;
    text-align: left;
    box-shadow:
      0 30px 60px rgba(19, 23, 34, 0.22),
      0 2px 8px rgba(19, 23, 34, 0.1);
    transition:
      box-shadow 0.3s var(--ease-out),
      transform 0.3s var(--spring);
  }

  .window.done {
    animation: land 0.5s cubic-bezier(0.2, 1.4, 0.35, 1);
  }

  @keyframes land {
    0% {
      transform: scale(0.985);
    }
    55% {
      transform: scale(1.008);
    }
    100% {
      transform: none;
    }
  }

  /* window chrome */
  .titlebar {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 10px 14px;
    background: #f4f1ea;
    border-bottom: 1px solid rgba(19, 23, 34, 0.07);
  }

  .tl {
    display: inline-flex;
    gap: 7px;
  }

  .tl i {
    width: 12px;
    height: 12px;
    border-radius: 50%;
  }

  .tl .r {
    background: #ff5f57;
  }
  .tl .y {
    background: #febc2e;
  }
  .tl .g {
    background: #28c840;
  }

  .wtitle {
    font-family: var(--display);
    font-weight: 700;
    font-size: 13.5px;
    color: rgba(19, 23, 34, 0.85);
  }

  .meta {
    margin-left: auto;
    opacity: 0.5;
    font-size: 10px !important;
  }

  /* app body: sidebar + paper */
  .winbody {
    display: grid;
    grid-template-columns: 158px 1fr;
    flex: 1;
    min-height: 0;
    animation: viewin 0.4s var(--ease-out);
  }

  @keyframes viewin {
    from {
      opacity: 0;
      transform: translateY(8px) scale(0.995);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .side {
    background: #efece3;
    border-right: 1px solid rgba(19, 23, 34, 0.06);
    padding: 12px 10px;
  }

  .side-h {
    font-family: var(--display);
    font-weight: 800;
    font-size: 13px;
    color: var(--ink);
    padding: 2px 10px 8px;
  }

  .side ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .side li {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 5px 10px;
    border-radius: 7px;
    font-size: 12.5px;
    font-weight: 500;
    color: rgba(19, 23, 34, 0.62);
  }

  .side li.on {
    background: var(--butter);
    color: var(--ink);
    font-weight: 700;
  }

  .side li b {
    margin-left: auto;
    font-size: 10px;
    opacity: 0.6;
  }

  .paper {
    padding: clamp(18px, 2.6vw, 26px) clamp(18px, 2.8vw, 30px);
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 8px;
    flex: 1;
    min-height: 0;
    overflow: hidden;
  }

  /* ---- per-app themes: make each one recognisable ---- */
  .bmark {
    width: 15px;
    height: 15px;
    display: inline-grid;
    place-items: center;
  }

  .bmark :global(svg) {
    width: 15px;
    height: 15px;
  }

  .av {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 10px;
    font-weight: 800;
    font-style: normal;
    color: #fff;
    flex-shrink: 0;
    font-family: var(--display);
  }

  .side li:nth-child(1) .av {
    background: #f7b500;
  }
  .side li:nth-child(2) .av {
    background: #ff5e51;
  }
  .side li:nth-child(3) .av {
    background: #35c759;
  }
  .side li:nth-child(4) .av {
    background: #a97fff;
  }
  .side li:nth-child(5) .av {
    background: #5b7cfa;
  }
  .side li:nth-child(n + 6) .av {
    background: #9aa0a6;
  }

  /* Outlook */
  .window.theme-mail .titlebar {
    background: #0f6cbd;
    border-bottom-color: transparent;
  }

  .window.theme-mail .wtitle {
    color: #fff;
    font-weight: 600;
  }

  .window.theme-mail .meta {
    color: rgba(255, 255, 255, 0.75);
    opacity: 1;
  }

  .window.theme-mail .side {
    background: #f3f2f1;
  }

  .window.theme-mail .side-h {
    color: #0f6cbd;
    display: flex;
    align-items: center;
    gap: 7px;
  }

  .window.theme-mail .side li.on {
    background: #eff6fc;
    color: #0f6cbd;
    box-shadow: inset 3px 0 0 #0f6cbd;
    font-weight: 700;
  }

  .fields {
    display: flex;
    flex-wrap: wrap;
    gap: 7px;
    margin-bottom: 4px;
  }

  .fields span {
    display: inline-block;
    background: #fff;
    border: 1px solid #d1d1d1;
    border-radius: 4px;
    padding: 5px 9px;
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.04em;
    color: rgba(19, 23, 34, 0.6);
  }

  .sendbtn {
    align-self: flex-end;
    margin-top: 10px;
    background: #0f6cbd;
    color: #fff;
    font-family: var(--display);
    font-weight: 700;
    font-size: 13px;
    padding: 8px 24px;
    border-radius: 6px;
    box-shadow: 0 2px 0 rgba(0, 0, 0, 0.18);
  }

  /* Apple Notes */
  .window.theme-notes .paper {
    background: linear-gradient(180deg, #fff8e1 0%, #fffdf4 100%);
  }

  .window.theme-notes .side {
    background: #f6efdb;
  }

  /* native content: text lands at the right size, in the right place */
  .mail-text {
    font-size: 15px;
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.85);
  }

  .note-text {
    font-size: 15px;
    line-height: 1.5;
    color: rgba(19, 23, 34, 0.8);
  }

  .chan {
    font-family: var(--display);
    font-weight: 800;
    font-size: 16px;
    color: var(--ink);
  }

  .slack-msg {
    display: flex;
    align-items: flex-start;
    gap: 10px;
  }

  .sava {
    width: 30px;
    height: 30px;
    border-radius: 7px;
    background: #4a154b;
    color: #fff;
    display: grid;
    place-items: center;
    font-family: var(--display);
    font-weight: 800;
    font-size: 13px;
    flex-shrink: 0;
  }

  .sava.sa {
    background: #36c5f0;
  }
  .sava.ss {
    background: #2eb67d;
  }

  .shead {
    display: flex;
    align-items: baseline;
    gap: 7px;
  }

  .shead b {
    font-size: 14px;
    font-weight: 800;
    color: #1d1c1d;
  }

  .shead .mono {
    font-size: 9px !important;
    opacity: 0.5;
  }

  .stext {
    font-size: 14.5px;
    line-height: 1.5;
    color: rgba(29, 28, 29, 0.9);
  }

  .doc-title {
    font-family: var(--sans);
    font-weight: 400;
    font-size: 21px;
    color: #202124;
    margin-bottom: 10px;
  }

  .doc-text {
    font-size: 14.5px;
    line-height: 1.65;
    color: #202124;
  }

  /* Slack: purple aubergine */
  .window.theme-slack .titlebar {
    background: #4a154b;
    border-bottom-color: transparent;
  }

  .window.theme-slack .wtitle {
    color: #fff;
  }

  .window.theme-slack .meta {
    color: rgba(255, 255, 255, 0.6);
    opacity: 1;
  }

  .window.theme-slack .side {
    background: #3f0e40;
  }

  .window.theme-slack .side-h {
    color: #fff;
    display: flex;
    align-items: center;
    gap: 7px;
  }

  .window.theme-slack .side li {
    color: rgba(255, 255, 255, 0.72);
  }

  .window.theme-slack .side li.on {
    background: #1164a3;
    color: #fff;
    box-shadow: none;
    font-weight: 700;
  }

  .window.theme-slack .av {
    display: none;
  }

  .window.theme-slack .paper {
    background: #fff;
    justify-content: flex-start;
  }

  .window.theme-slack .ghost {
    padding-top: 4px;
  }

  /* Google Docs: inside a browser */
  .chromewrap {
    width: 100%;
    max-width: 640px;
    min-height: 0;
    margin-inline: auto;
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .browser {
    width: 100%;
    background: #dfe2e7;
    border-radius: 12px 12px 0 0;
    padding: 5px 6px 0;
  }

  .btabs {
    display: flex;
    align-items: flex-end;
    gap: 3px;
  }

  .btab {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 5px 10px;
    border-radius: 7px 7px 0 0;
    font-size: 11px;
    color: rgba(19, 23, 34, 0.5);
    max-width: 240px;
    white-space: nowrap;
    overflow: hidden;
  }

  .btab.on {
    background: #f8f9fa;
    color: var(--ink);
    font-weight: 600;
  }

  .bfav {
    width: 12px;
    height: 12px;
    display: inline-grid;
    place-items: center;
  }

  .bfav :global(svg) {
    width: 12px;
    height: 12px;
  }

  .bx {
    font-style: normal;
    opacity: 0.35;
    font-size: 9px;
    margin-left: 2px;
  }

  .burl {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f8f9fa;
    padding: 5px 8px 7px;
  }

  .bnav {
    color: rgba(19, 23, 34, 0.4);
    font-size: 11px;
    letter-spacing: 1px;
  }

  .baddr {
    flex: 1;
    background: #fff;
    border-radius: 999px;
    padding: 5px 12px;
    font-family: var(--mono);
    font-size: 10px;
    color: #5f6368;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    box-shadow: inset 0 0 0 1px rgba(19, 23, 34, 0.05);
  }

  .bprof {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: #5f6368;
    color: #fff;
    display: grid;
    place-items: center;
    font-size: 9px;
    font-weight: 700;
    font-family: var(--display);
  }

  .window.theme-docs {
    border-radius: 0 0 12px 12px;
    box-shadow: none;
  }

  .window.theme-docs .titlebar {
    display: none;
  }

  /* real Docs chrome: logo, name, menus, share */
  .docsbar {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px;
    border-bottom: 1px solid rgba(19, 23, 34, 0.07);
  }

  .dlogo {
    width: 26px;
    height: 26px;
    display: grid;
    place-items: center;
    flex-shrink: 0;
  }

  .dlogo :global(svg) {
    width: 26px;
    height: 26px;
  }

  .dmeta {
    display: flex;
    flex-direction: column;
    gap: 1px;
    min-width: 0;
  }

  .dn {
    font-size: 14px;
    color: #202124;
    line-height: 1.3;
    white-space: nowrap;
  }

  .dn b {
    font-weight: 500;
  }

  .dn span {
    margin-left: 6px;
    font-size: 13px;
    opacity: 0.55;
  }

  .dmenu {
    font-size: 10px !important;
    letter-spacing: 0.02em !important;
    text-transform: none !important;
    color: rgba(60, 64, 67, 0.75);
    white-space: nowrap;
    overflow: hidden;
  }

  .dshare {
    margin-left: auto;
    background: #1a73e8;
    color: #fff;
    font-family: var(--sans);
    font-weight: 600;
    font-size: 12.5px;
    padding: 7px 18px;
    border-radius: 4px;
    flex-shrink: 0;
  }

  /* the document itself: white page on gray canvas */
  .window.theme-docs .side {
    display: none;
  }

  .window.theme-docs .winbody {
    display: block;
    min-height: 0;
    overflow: hidden;
    background: #f8f9fa;
  }

  .window.theme-docs .paper {
    background: #fff;
    max-width: 430px;
    margin: 12px auto 16px;
    min-height: 190px;
    padding: 30px 42px;
    justify-content: flex-start;
    box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.14),
      0 4px 14px rgba(0, 0, 0, 0.07);
  }

  .window.theme-docs .ghost {
    color: rgba(60, 64, 67, 0.45);
  }

  /* VS Code: dark editor */
  .window.theme-code .titlebar {
    background: #323233;
    border-bottom-color: transparent;
  }

  .window.theme-code .wtitle {
    color: #cfcfcf;
    font-family: var(--sans);
    font-weight: 400;
  }

  .window.theme-code .meta {
    color: rgba(255, 255, 255, 0.4);
    opacity: 1;
  }

  .window.theme-code .side {
    background: #252526;
  }

  .window.theme-code .side-h {
    color: #bbbbbb;
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .window.theme-code .side li {
    font-family: var(--mono);
    font-size: 12px;
    color: #a9a9a9;
  }

  .window.theme-code .side li.on {
    background: #37373d;
    color: #fff;
    box-shadow: none;
    font-weight: 500;
  }

  .window.theme-code .paper {
    background: #1e1e1e;
  }

  .code {
    font-family: var(--mono);
    font-size: 13.5px;
    color: #d4d4d4;
    line-height: 1.8;
  }

  .ckw {
    color: #569cd6;
  }
  .cstr {
    color: #ce9178;
  }
  .cvar {
    color: #9cdcfe;
  }
  .cdim {
    color: #6a9955;
  }

  .window.theme-code .ghost {
    color: rgba(255, 255, 255, 0.35);
  }

  .window.theme-code .badge {
    background: #0e639c;
  }

  /* Messenger */
  .window.theme-chat .titlebar {
    background: #fff;
  }

  .tavatar {
    width: 26px;
    height: 26px;
    border-radius: 50%;
    background: linear-gradient(135deg, #00b2ff, #006aff);
    color: #fff;
    display: grid;
    place-items: center;
    font-size: 11px;
    font-weight: 800;
    font-family: var(--display);
  }

  .window.theme-chat .paper {
    background: #fff;
  }

  .window.theme-chat .paper > :first-child {
    margin-top: auto;
  }

  .window.theme-chat .badge {
    align-self: flex-end;
    background: #006aff;
  }

  .typing {
    display: inline-flex;
    align-self: flex-start;
    gap: 5px;
    background: #e4e6eb;
    padding: 13px 16px;
    border-radius: 16px 16px 16px 5px;
    margin-bottom: 12px;
  }

  .typing i {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #9aa0a6;
    animation: tdot 1.1s var(--ease-inout) infinite;
  }

  .typing i:nth-child(2) {
    animation-delay: 0.15s;
  }
  .typing i:nth-child(3) {
    animation-delay: 0.3s;
  }

  @keyframes tdot {
    0%,
    60%,
    100% {
      transform: translateY(0);
      opacity: 0.5;
    }
    30% {
      transform: translateY(-5px);
      opacity: 1;
    }
  }

  .window.theme-chat .side {
    background: #f5f6fa;
  }

  .bubble-in {
    align-self: flex-start;
    max-width: 82%;
    background: #e4e6eb;
    color: #050505;
    padding: 9px 14px;
    border-radius: 16px 16px 16px 5px;
    font-size: 14px;
    line-height: 1.4;
    margin-bottom: 12px;
  }

  .ghost {
    font-size: 12.5px !important;
    color: rgba(3, 89, 77, 0.42);
    line-height: 1.6;
  }

  .bubble-out {
    align-self: flex-end;
    max-width: 82%;
    background: linear-gradient(135deg, #00b2ff, #006aff);
    color: #fff;
    padding: 9px 14px;
    border-radius: 16px 16px 5px 16px;
    font-size: 14px;
    line-height: 1.4;
    box-shadow: 0 3px 10px rgba(0, 106, 255, 0.3);
  }

  .talking {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    animation: fadein 0.25s ease both;
  }

  .talking :global(.talkwave) {
    height: clamp(48px, 8vw, 72px);
    gap: 5px;
  }

  .talking :global(.talkwave i) {
    width: clamp(5px, 0.7vw, 8px);
  }

  .hint2 {
    text-align: center;
    font-size: clamp(19px, 2vw, 23px);
    color: var(--green-deep);
  }

  @keyframes fadein {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  .popwrap {
    position: relative;
    animation: pop 0.45s cubic-bezier(0.2, 1.4, 0.35, 1) both;
  }

  @keyframes pop {
    0% {
      opacity: 0;
      transform: scale(0.82) translateY(10px);
      filter: blur(10px);
    }
    55% {
      filter: blur(0);
      transform: scale(1.05) translateY(-3px);
    }
    100% {
      opacity: 1;
      transform: none;
    }
  }

  .sparkles {
    position: absolute;
    inset: 50%;
    pointer-events: none;
    z-index: 2;
  }

  .sparkles span {
    position: absolute;
    left: 0;
    top: 0;
    color: var(--hotpink);
    font-size: 15px;
    opacity: 0;
    animation: burst 0.7s ease-out forwards;
  }

  .sparkles span:nth-child(even) {
    color: var(--purple);
  }
  .sparkles span:nth-child(3n) {
    color: var(--sun);
  }

  @keyframes burst {
    0% {
      opacity: 0;
      transform: rotate(calc(var(--a) * 1deg)) translateX(24px) scale(0.3);
    }
    25% {
      opacity: 1;
    }
    100% {
      opacity: 0;
      transform: rotate(calc(var(--a) * 1deg)) translateX(120px) scale(1);
    }
  }

  .badge {
    align-self: flex-start;
    display: inline-block;
    margin-top: 14px;
    padding: 6px 13px;
    border-radius: 999px;
    background: var(--green-deep);
    color: var(--cream);
    font-size: 10px !important;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    animation: stamp 0.4s var(--spring) 0.15s both;
  }

  .dock {
    position: absolute;
    left: 50%;
    bottom: 12px;
    transform: translateX(-50%);
    display: flex;
    gap: 10px;
    padding: 7px 10px;
    background: rgba(255, 253, 247, 0.65);
    backdrop-filter: blur(14px);
    -webkit-backdrop-filter: blur(14px);
    border: 1px solid rgba(255, 253, 247, 0.8);
    border-radius: 20px;
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.18);
  }

  .dock-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    transition: transform 0.25s var(--spring);
  }

  .dock-item:hover {
    transform: translateY(-6px) scale(1.08);
  }

  .dicon {
    width: 42px;
    height: 42px;
    border-radius: 11px;
    display: grid;
    place-items: center;
    font-size: 22px;
    background: var(--cream);
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.9),
      0 3px 8px rgba(19, 23, 34, 0.2);
  }

  .dbmark {
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
  }

  .dbmark :global(svg) {
    width: 24px;
    height: 24px;
  }

  .dot {
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: transparent;
  }

  .dock-item.on .dot {
    background: var(--ink);
  }

  @media (max-width: 640px) {
    .lbl {
      font-size: 13px;
    }
    .key {
      width: 60px;
      height: 42px;
      font-size: 18px;
    }
    .winbody {
      grid-template-columns: 1fr;
    }
    .side {
      display: none;
    }
    .mbleft span:not(.apple) {
      display: none;
    }
    .meta {
      display: none;
    }
    .talking {
      gap: 6px;
    }
    .talking :global(.talkwave) {
      height: 28px;
      gap: 3px;
    }
    .talking :global(.talkwave i) {
      width: 4px;
    }
    .hint2 {
      font-size: 13px;
    }
  }
</style>
