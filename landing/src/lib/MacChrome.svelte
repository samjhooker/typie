<script>
  /* the entire chrome of a mac, drawn around the website:
     menu bar up top, the hardware notch dead-center, a dock below.
     the notch is not decoration - it expands while the visitor holds,
     exactly like the shelf does in the real app */
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import VariantSwitcher from './VariantSwitcher.svelte';
  import { sound, blip } from './sound.svelte.js';

  let { holding = false } = $props();

  let scrolled = $state(false);
  let justTyped = $state(false);
  let releaseTimer;

  $effect(() => {
    if (!holding && justTyped) return;
    if (!holding) {
      /* released: flash the ✓ typed confirmation in the notch */
      justTyped = true;
      clearTimeout(releaseTimer);
      releaseTimer = setTimeout(() => (justTyped = false), 1600);
    }
  });

  const MENUS = [
    { href: '#notch', label: 'The notch' },
    { href: '#features', label: 'Features' },
    { href: '#versus', label: 'vs. the rest' },
    { href: '#languages', label: 'Languages' },
    { href: '#faq', label: 'FAQ' }
  ];

  /* ---- live clock, mac style ---- */
  let now = $state(new Date());
  $effect(() => {
    const iv = setInterval(() => (now = new Date()), 15000);
    return () => clearInterval(iv);
  });

  const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  const time = $derived.by(() => {
    const h = now.getHours();
    const m = String(now.getMinutes()).padStart(2, '0');
    const ampm = h >= 12 ? 'PM' : 'AM';
    const hr = h % 12 === 0 ? 12 : h % 12;
    return `${DAYS[now.getDay()]} ${MONTHS[now.getMonth()]} ${now.getDate()} ${hr}:${m} ${ampm}`;
  });
</script>

<!-- ==================== menu bar ==================== -->
<header class="menubar" class:scrolled>
  <div class="mbleft">
    <a href="#top" class="applink" aria-label="typie home">
      <!-- apple -->
      <svg viewBox="0 0 384 512" aria-hidden="true"><path fill="currentColor" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
    </a>

    <span class="appmenu"><VariantSwitcher variant="personal" logoSize={18} /></span>

    <nav class="menus" aria-label="primary">
      {#each MENUS as m}
        <a href={m.href} class="menuitem">{m.label}</a>
      {/each}
      <a href="#pricing" class="menuitem price">
        <span class="struck">Pricing</span>
        <span class="freehand hand">$0</span>
      </a>
    </nav>
  </div>

  <div class="mbright">
    <button
      class="tray soundbtn"
      aria-pressed={sound.on}
      title={sound.on ? 'mute the little sounds' : 'tiny synth sounds, made by this page'}
      onclick={() => {
        sound.on = !sound.on;
        if (sound.on) blip(720, 0.12, 'sine', 0.06);
      }}
    >
      {sound.on ? '🔊' : '🔇'}
    </button>

    <span class="tray battery" aria-hidden="true">
      <i class="cell"><i></i></i>87%
    </span>

    <svg class="tray wifi" viewBox="0 0 24 24" aria-hidden="true">
      <path
        d="M12 19.4a1.6 1.6 0 1 0 0-3.2 1.6 1.6 0 0 0 0 3.2Zm0-5.6c1.6 0 3 .6 4.1 1.6l1.5-1.6A8.1 8.1 0 0 0 12 11.6c-2.2 0-4.2.8-5.6 2.2l1.5 1.6A6 6 0 0 1 12 13.8Zm0-4.6c2.8 0 5.4 1.1 7.3 2.9l1.5-1.6A12 12 0 0 0 12 7c-3.4 0-6.5 1.3-8.8 3.5l1.5 1.6A10 10 0 0 1 12 9.2Z"
        fill="currentColor"
      />
    </svg>

    <span class="tray clock">{time}</span>

    <!-- macos lights this up when an app has your mic -->
    <span class="micdot" class:on={holding} aria-hidden="true"></span>

    <DownloadCta kind="green" />
  </div>
</header>

<!-- ==================== the notch ==================== -->
<div
  class="notch"
  class:live={holding}
  class:done={justTyped}
  aria-hidden="true"
>
  <span class="cam"></span>

  {#if holding}
    <span class="nbot"><Robot size={20} mood="listening" /></span>
    <span class="nwave"><TalkWave n={5} color="#fc5681" /></span>
    <span class="nlbl mono">listening…</span>
  {:else if justTyped}
    <span class="nbot"><Robot size={20} mood="done" /></span>
    <span class="nok mono">✓ typed · 80ms</span>
  {:else}
    <span class="nidle mono">⌥ hold anywhere</span>
  {/if}
</div>

<style>
  /* ==================== menu bar ==================== */
  .menubar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 220;
    height: 34px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 clamp(10px, 1.6vw, 18px);
    background: color-mix(in srgb, var(--page) 82%, transparent);
    backdrop-filter: blur(16px) saturate(160%);
    -webkit-backdrop-filter: blur(16px) saturate(160%);
    border-bottom: 1px solid rgba(19, 23, 34, 0.07);
    transition: background 0.35s var(--ease-out);
  }

  .mbleft,
  .mbright {
    display: flex;
    align-items: center;
    gap: clamp(6px, 1vw, 14px);
    min-width: 0;
  }

  .applink {
    display: grid;
    place-items: center;
    width: 22px;
    opacity: 0.85;
    transition: opacity 0.2s var(--ease-out);
  }

  .applink:hover { opacity: 1; }

  .applink svg {
    width: 13px;
    height: 15px;
    margin-top: -3px;
  }

  .appmenu {
    line-height: 0;
  }

  .menus {
    display: flex;
    align-items: center;
    gap: 2px;
  }

  .menubar a {
    position: relative;
    font-size: 13px;
    font-weight: 500;
    color: var(--ink);
    padding: 4px 10px;
    border-radius: 6px;
    opacity: 0.85;
    white-space: nowrap;
    transition: opacity 0.2s var(--ease-out), background 0.2s var(--ease-out);
  }

  .menuitem:hover,
  .applink:hover {
    opacity: 1;
    background: rgba(19, 23, 34, 0.06);
  }

  .price .struck {
    text-decoration: line-through;
    text-decoration-color: var(--hotpink);
    text-decoration-thickness: 2px;
  }

  .freehand {
    position: absolute;
    top: calc(100% - 4px);
    left: 50%;
    transform: translateX(-50%) rotate(-8deg);
    font-size: 12px;
    color: var(--hotpink);
    pointer-events: none;
  }

  .mbright {
    gap: 10px;
  }

  .tray {
    font-family: var(--sans);
    font-size: 12px;
    font-weight: 500;
    color: var(--ink);
    opacity: 0.85;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    white-space: nowrap;
  }

  .wifi {
    width: 15px;
    height: 15px;
    color: var(--ink);
    opacity: 0.85;
  }

  .clock {
    font-variant-numeric: tabular-nums;
  }

  .soundbtn {
    font-size: 12px;
    padding: 2px 6px;
    border-radius: 5px;
    border: none;
    background: none;
    cursor: pointer;
  }

  .soundbtn[aria-pressed='true'] {
    background: rgba(252, 86, 129, 0.12);
  }

  .battery .cell {
    position: relative;
    display: inline-block;
    width: 20px;
    height: 10px;
    border: 1.2px solid rgba(19, 23, 34, 0.55);
    border-radius: 3px;
    padding: 1.5px;
  }

  .battery .cell::after {
    content: '';
    position: absolute;
    right: -3.5px;
    top: 2.5px;
    width: 2px;
    height: 4px;
    border-radius: 0 2px 2px 0;
    background: rgba(19, 23, 34, 0.55);
  }

  .battery .cell i {
    display: block;
    height: 100%;
    width: 87%;
    border-radius: 1.5px;
    background: var(--green);
  }

  /* ==================== the notch ==================== */
  .notch {
    position: fixed;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    z-index: 230;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    height: 26px;
    min-width: 170px;
    padding: 0 18px;
    background: #000;
    color: var(--cream);
    border-radius: 0 0 14px 14px;
    overflow: hidden;
    transition:
      min-width 0.45s var(--spring-smooth),
      height 0.45s var(--spring-smooth);
  }

  .notch.live {
    min-width: 300px;
    height: 32px;
  }

  .notch.done {
    min-width: 250px;
  }

  .cam {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background:
      radial-gradient(circle at 35% 32%, #4a5568 0 18%, #151a22 42%, #07080c 100%);
    box-shadow:
      inset 0 0 0 1px rgba(120, 130, 150, 0.4),
      0 0 0 2px #000;
    flex-shrink: 0;
  }

  .nidle {
    font-size: 10px;
    letter-spacing: 0.12em;
    color: rgba(255, 253, 247, 0.55);
  }

  .nbot {
    display: block;
    line-height: 0;
    color: var(--hotpink);
  }

  .notch.done .nbot { color: var(--mint); }

  .nwave {
    width: 30px;
  }

  .nwave :global(.talkwave) {
    height: 12px;
    gap: 2px;
  }

  .nwave :global(.talkwave i) {
    width: 2.5px;
  }

  .nlbl,
  .nok {
    font-size: 10.5px;
    letter-spacing: 0.08em;
  }

  .nok { color: var(--mint); }

  .micdot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: rgba(19, 23, 34, 0.15);
    transition: background 0.3s var(--ease-out), box-shadow 0.3s var(--ease-out);
  }

  .micdot.on {
    background: #ff9f0a;
    box-shadow: 0 0 8px rgba(255, 159, 10, 0.7);
  }

  @media (max-width: 1080px) {
    .menus { display: none; }
  }

  @media (max-width: 720px) {
    .battery, .clock { display: none; }
    .notch { min-width: 130px; }
    .nidle { font-size: 9px; }
  }
</style>
