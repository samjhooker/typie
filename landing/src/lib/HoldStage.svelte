<script>
  import Logo from './Logo.svelte';
  import Robot from './Robot.svelte';
  import { app } from './state.svelte.js';

  const scenes = [
    {
      id: 'mail',
      name: 'Mail',
      title: 'New Message',
      meta: 'To: chad@',
      text: "hey I'll be about thirty minutes late the train is delayed again"
    },
    {
      id: 'notes',
      name: 'Notes',
      title: 'Today',
      meta: 'Note',
      text: 'oat milk, candles, call mum, ship the changelog'
    },
    {
      id: 'chat',
      name: 'Messages',
      title: 'Group chat',
      meta: 'you, alex, sam',
      text: 'the deck is in the drive slides four through nine are yours'
    }
  ];

  const KEYS = [
    { char: '⌥', name: 'option', code: 'Alt' },
    { char: '⌘', name: 'command', code: 'Meta' },
    { char: '⇧', name: 'shift', code: 'Shift' },
    { char: '^', name: 'control', code: 'Control' }
  ];

  let step = $state(0);
  let mode = $state('idle');
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

  function startListening() {
    mode = 'listening';
    app.mood = 'listening';
    later(popNow, 720);
  }

  function popNow() {
    clearTimers();
    lastMs = 58 + Math.round(Math.random() * 36);
    app.lastMs = lastMs;
    mode = 'done';
    app.mood = 'done';
    later(() => {
      step = (step + 1) % scenes.length;
      mode = 'idle';
      app.mood = 'idle';
    }, 2000);
  }

  function press() {
    if (!armed) return;
    clearTimers();
    if (mode === 'listening') {
      popNow();
    } else if (mode === 'done') {
      step = (step + 1) % scenes.length;
      startListening();
    } else {
      startListening();
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
    press();
  }

  function onKeyUp(e) {
    if (e.key !== key.code) return;
    down = false;
    if (mode === 'listening') popNow();
  }

  function pick(i) {
    if (mode !== 'idle' || i === step) return;
    step = i;
    lastMs = null;
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
  });
</script>

<svelte:window onkeydown={onKey} onkeyup={onKeyUp} />

<div class="stage" bind:this={root}>
  <button
    class="opt-btn"
    class:down={mode === 'listening'}
    onpointerdown={(e) => { e.preventDefault(); press(); }}
  >
    <span class="key" role="button" tabindex="-1" title="Click to remap">
      <b class="br">[</b>
      <span class="kstack">
        <span class="ksym">{key.char}</span>
        <span class="kname">{key.name}</span>
      </span>
      <b class="br">]</b>
    </span>
    <span class="lbl">
      {#if mode === 'listening'}listening…
      {:else if mode === 'done'}typed in {lastMs} ms
      {:else}press {key.name} - {scene.name}{/if}
    </span>
  </button>

  <p class="hint mono">
    or press {key.name} · tap <b>[ ]</b> to remap it, freak
  </p>

  <div class="window" class:listening={mode === 'listening'} class:done={mode === 'done'}>
    <div class="menubar">
      <span class="time mono">9:41</span>
      <div class="notchwrap">
        <div class="notch-mascot" class:up={mode !== 'idle'} aria-hidden="true">
          <Robot size={44} mood={mode === 'listening' ? 'listening' : mode === 'done' ? 'done' : 'idle'} />
        </div>
        <div class="notch" class:open={mode !== 'idle'}>
          <div class="notch-in">
            {#if mode === 'listening'}
              <span class="rec"></span>
              <div class="eq"><i></i><i></i><i></i><i></i></div>
              <span class="nlbl">listening</span>
            {:else if mode === 'done'}
              <span class="ok">✓</span>
              <span class="nlbl">{lastMs} ms</span>
            {:else}
              <span class="peek"><i></i><i></i></span>
            {/if}
          </div>
        </div>
      </div>
      <span class="trays mono" aria-hidden="true">⌘ ▲ ▮</span>
    </div>

    <header>
      <Logo size={17} />
      <span class="title">{scene.title}</span>
      <span class="meta mono">{scene.meta}</span>
    </header>

    <div class="body">
      {#if mode === 'listening'}
        <div class="ears" aria-hidden="true">
          {#each Array(28) as _, i}
            <i style="animation-delay:{(i % 9) * 80}ms; animation-duration:{450 + (i * 37) % 350}ms"></i>
          {/each}
        </div>
        <p class="hint2 hand">say anything…</p>
      {:else if mode === 'done'}
        {#key step}
          <div class="popwrap">
            <div class="sparkles" aria-hidden="true">
              {#each Array(10) as _, i}
                <span style="--a:{i * 36}deg; animation-delay:{i * 30}ms">✦</span>
              {/each}
            </div>
            <p class="pop">{scene.text}</p>
            <span class="badge mono">✓ typed in {lastMs} ms</span>
          </div>
        {/key}
      {:else}
        <p class="ghost mono">press {key.name} and speak - your words land here, whole, instantly.</p>
      {/if}
    </div>

    <nav class="dock">
      {#each scenes as s, i}
        <button class="dock-item" class:on={step === i} onclick={() => pick(i)}>
          {s.name}
        </button>
      {/each}
    </nav>
  </div>
</div>

<style>
  .stage {
    width: min(760px, 100%);
    margin-inline: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 14px;
  }

  .opt-btn {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 12px 24px 12px 12px;
    background: var(--cream);
    border-radius: 20px;
    box-shadow: 0 12px 32px rgba(2, 89, 77, 0.18);
    color: var(--green-deep);
    z-index: 3;
    transition: transform 0.25s var(--spring);
    user-select: none;
    -webkit-user-select: none;
  }

  .opt-btn:hover { transform: translateY(-2px); }

  .opt-btn.down .key {
    transform: translateY(4px);
    box-shadow: 0 0 0 #0b1f1b;
    background: var(--butter);
    color: var(--green-deep);
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
      0 5px 0 #0b1f1b;
    transition: transform 0.1s ease, box-shadow 0.1s ease, background 0.12s ease;
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
    0% { opacity: 0.9; transform: scale(0.85); }
    100% { opacity: 0; transform: scale(1.35); }
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

  .hint {
    font-size: 11px !important;
    color: rgba(2, 89, 77, 0.55);
    letter-spacing: 0.1em;
    text-transform: uppercase;
  }

  .hint b { color: var(--hotpink); }

  .window {
    width: 100%;
    background: var(--cream);
    border: 1px solid rgba(2, 89, 77, 0.09);
    border-radius: 28px;
    overflow: hidden;
    text-align: left;
    box-shadow:
      0 40px 90px rgba(2, 89, 77, 0.22),
      0 4px 14px rgba(2, 89, 77, 0.08);
    transition: box-shadow 0.3s ease, transform 0.3s var(--spring);
  }

  .window.listening {
    box-shadow:
      0 40px 90px rgba(2, 89, 77, 0.26),
      0 0 0 3px var(--mint-live);
  }

  .window.done {
    animation: land 0.5s cubic-bezier(0.2, 1.4, 0.35, 1);
  }

  @keyframes land {
    0% { transform: scale(0.985); }
    55% { transform: scale(1.008); }
    100% { transform: none; }
  }

  /* mac menubar + notch */
  .menubar {
    position: relative;
    height: 32px;
    background: #101413;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 18px;
  }

  .time,
  .trays {
    color: rgba(249, 248, 244, 0.75);
    font-size: 10px !important;
    letter-spacing: 0.08em;
  }

  .trays { font-size: 8px !important; opacity: 0.7; }

  .notchwrap {
    position: absolute;
    left: 50%;
    top: 0;
    transform: translateX(-50%);
  }

  .notch-mascot {
    position: absolute;
    left: -46px;
    bottom: -6px;
    z-index: 0;
    color: var(--hotpink);
    opacity: 0;
    transform: translateY(60%) scale(0.85);
    transition:
      transform 0.45s cubic-bezier(0.2, 1.4, 0.35, 1),
      opacity 0.3s ease;
    pointer-events: none;
  }

  .notch-mascot.up {
    opacity: 1;
    transform: translateY(-16%) rotate(-8deg) scale(1);
  }

  .notch {
    position: relative;
    z-index: 1;
    width: 92px;
    height: 40px;
    background: #000;
    border-radius: 0 0 14px 14px;
    display: flex;
    justify-content: center;
    transition: width 0.4s var(--ease-out);
    overflow: hidden;
  }

  .notch.open { width: min(230px, 56vw); }

  .notch-in {
    display: flex;
    align-items: center;
    gap: 10px;
    height: 30px;
  }

  .peek {
    display: flex;
    gap: 14px;
  }

  .peek i {
    width: 5px;
    height: 5px;
    border-radius: 50%;
    background: rgba(249, 248, 244, 0.85);
    animation: peek 5s infinite;
  }

  .peek i:last-child { animation-delay: 0.1s; }

  @keyframes peek {
    0%, 93%, 100% { transform: scaleY(1); }
    96% { transform: scaleY(0.05); }
  }

  .rec {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--hotpink);
    animation: blink 1s steps(2) infinite;
  }

  @keyframes blink {
    50% { opacity: 0.25; }
  }

  .eq {
    display: flex;
    align-items: center;
    gap: 3px;
    height: 14px;
  }

  .eq i {
    width: 3px;
    border-radius: 2px;
    background: var(--mint);
    animation: eq 0.55s ease-in-out infinite alternate;
  }

  .eq i:nth-child(2) { animation-delay: 0.12s; }
  .eq i:nth-child(3) { animation-delay: 0.05s; }
  .eq i:nth-child(4) { animation-delay: 0.2s; }

  @keyframes eq {
    from { height: 4px; }
    to { height: 13px; }
  }

  .ok { color: var(--mint); font-size: 12px; }

  .nlbl {
    font-family: var(--mono);
    font-size: 9px;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    color: var(--cream);
    opacity: 0.85;
    white-space: nowrap;
  }

  header {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 16px 22px;
    border-bottom: 1px solid rgba(2, 89, 77, 0.08);
  }

  .title {
    font-family: var(--display);
    font-weight: 800;
    font-size: 14px;
    color: var(--green-deep);
  }

  .meta {
    opacity: 0.55;
    font-size: 11px !important;
  }

  .body {
    min-height: 168px;
    padding: 28px 32px 24px;
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .ghost {
    font-size: 13px !important;
    color: rgba(2, 89, 77, 0.42);
    line-height: 1.6;
  }

  .ears {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    height: 64px;
  }

  .ears i {
    width: 5px;
    height: 14px;
    border-radius: 3px;
    background: var(--green);
    animation: wave ease-in-out infinite alternate;
    transform-origin: center;
  }

  @keyframes wave {
    from { transform: scaleY(0.4); opacity: 0.5; }
    to { transform: scaleY(3.2); opacity: 1; }
  }

  .hint2 {
    text-align: center;
    margin-top: 14px;
    font-size: clamp(19px, 2vw, 23px);
    color: var(--green-deep);
    animation: fadein 0.25s ease both;
  }

  @keyframes fadein {
    from { opacity: 0; }
    to { opacity: 1; }
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

  .pop {
    font-family: var(--display);
    font-weight: 800;
    font-size: clamp(20px, 2.6vw, 29px);
    line-height: 1.3;
    letter-spacing: -0.02em;
    color: var(--green-deep);
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

  .sparkles span:nth-child(even) { color: var(--purple); }
  .sparkles span:nth-child(3n) { color: var(--sun); }

  @keyframes burst {
    0% {
      opacity: 0;
      transform: rotate(calc(var(--a) * 1deg)) translateX(24px) scale(0.3);
    }
    25% { opacity: 1; }
    100% {
      opacity: 0;
      transform: rotate(calc(var(--a) * 1deg)) translateX(120px) scale(1);
    }
  }

  .badge {
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
    display: flex;
    justify-content: center;
    gap: 6px;
    padding: 0 22px 20px;
  }

  .dock-item {
    font-family: var(--display);
    font-weight: 800;
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 6px 13px;
    border-radius: 999px;
    color: rgba(2, 89, 77, 0.45);
    transition: all 0.2s ease;
  }

  .dock-item:hover:not(.on) {
    color: var(--green-deep);
    background: rgba(130, 237, 166, 0.3);
  }

  .dock-item.on {
    background: var(--green-deep);
    color: var(--cream);
  }

  @media (max-width: 640px) {
    .lbl { font-size: 13px; }
    .key { width: 60px; height: 42px; font-size: 18px; }
    .body { min-height: 190px; padding: 24px 22px 20px; }
    .meta { display: none; }
  }
</style>
