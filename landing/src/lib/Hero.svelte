<script>
  import { reveal } from './reveal.js';
  import { nsSvg } from './svgid.js';
  import Robot from './Robot.svelte';
  import {
    Mic,
    PhoneCall,
    FileAudio,
    StickyNote,
    Wifi,
    WifiOff,
    FileText,
  } from 'lucide-svelte';
  import DemoShell from './real/DemoShell.svelte';
  import DemoTranscriptDetail from './real/DemoTranscriptDetail.svelte';
  import AppSlack from './real/AppSlack.svelte';
  import AppSafari from './real/AppSafari.svelte';
  import AppOutlook from './real/AppOutlook.svelte';
  import AppWhatsApp from './real/AppWhatsApp.svelte';
  import slackIco from 'thesvg/slack';
  import safariIco from 'thesvg/safari';
  import outlookIco from 'thesvg/microsoft-outlook';
  import zoom2025Mod from 'thesvg/zoom-2025';
  import whatsappIco from 'thesvg/whatsapp';

  const svgOf = (mod) =>
    typeof mod === 'string' ? mod : (mod.svg ?? String(mod));
  // Zoom — use the wordmark (dark) with a custom Apple squircle background
  // thesvg's wordmark is blue (#0b5cff) on transparent — invert to white for dark bg
  const _zoomWordmarkRaw =
    zoom2025Mod?.variants?.wordmark ?? zoom2025Mod?.svg ?? '';
  const zoomWordmarkDark = _zoomWordmarkRaw.replaceAll('#0b5cff', '#ffffff').replaceAll('#0B5CFF', '#ffffff');

  let active = $state('dictate');
  let wifiOff = $state(false);
  let notchMenuOpen = $state(false);
  let notchHover = $state(false);

  const features = [
    {
      id: 'dictate',
      icon: Mic,
      label: 'Dictate Anywhere',
      desc: 'Hold ⌥, talk, let go. Real keystrokes land in any app in 80 ms.',
      color: '#fc5681',
    },
    {
      id: 'capture',
      icon: PhoneCall,
      label: 'Meeting Capture',
      desc: 'Captures system audio without a bot. Transcribes and summarizes live.',
      color: '#6f8ffb',
    },
    {
      id: 'notes',
      icon: StickyNote,
      label: 'Voice Notes',
      desc: 'Quick thoughts land on your sticky wall — pinned, searchable, local.',
      color: '#0ea86b',
    },
    {
      id: 'summarize',
      icon: FileAudio,
      label: 'File Transcription',
      desc: 'Drop any audio file. Generates markdown with speakers and AI breakdown.',
      color: '#c88cfd',
    },
  ];

  /* ── dictate apps & text rotation ── */
  const DICTATE_APPS = [
    {
      id: 'slack',
      label: 'Slack',
      brand: svgOf(slackIco),
      shell: 'pad',
      title: 'Slack — #launch',
      text: "pricing page is sam's, video is mine — shipping friday 🚀",
    },
    {
      id: 'safari',
      label: 'Safari',
      brand: svgOf(safariIco),
      shell: 'pad',
      title: 'google.com — Safari',
      text: 'launch checklist template',
    },
    {
      id: 'outlook',
      label: 'Outlook',
      brand: svgOf(outlookIco),
      shell: 'pad',
      title: 'Inbox — Outlook',
      text: 'hi sarah, thanks for the intro — 3pm PST works perfectly for me.',
    },
    {
      id: 'whatsapp',
      label: 'WhatsApp',
      brand: svgOf(whatsappIco),
      shell: 'pad',
      title: 'WhatsApp — Maya Chen',
      text: 'omw right now, grabbing coffee — want an oat latte?',
    },
  ];

  let dictateAppIdx = $state(0);
  const currentDictateApp = $derived(
    DICTATE_APPS[dictateAppIdx % DICTATE_APPS.length]
  );

  let typedStream = $state('');
  let isKeyHolding = $state(false);
  let isDictateDone = $state(false);
  let justPasted = $state(false);

  function wait(ms) {
    return new Promise((r) => {
      timerBag.push(setTimeout(r, ms));
    });
  }
  let timerBag = [];

  /* ── continuous dictate loop (cycles between apps, animates keypress + typed stream) ── */
  $effect(() => {
    if (active !== 'dictate') {
      typedStream = '';
      isKeyHolding = false;
      isDictateDone = false;
      justPasted = false;
      return;
    }

    let cancelled = false;
    timerBag = [];

    async function runDictateLoop() {
      while (!cancelled && active === 'dictate') {
        const target = DICTATE_APPS[dictateAppIdx % DICTATE_APPS.length];
        typedStream = '';
        isKeyHolding = false;
        isDictateDone = false;
        justPasted = false;

        // 1. Pause briefly at empty app
        await wait(700);
        if (cancelled) return;

        // 2. Press Option key down & start listening (speech buffering)
        isKeyHolding = true;
        await wait(1600);
        if (cancelled) return;

        // 3. Release Option -> entire text pops in at once (80ms)
        isKeyHolding = false;
        isDictateDone = true;
        typedStream = target.text;
        justPasted = true;
        await wait(900);
        if (cancelled) return;
        justPasted = false;

        // 4. Hold finished state so user can read what was typed
        await wait(2000);
        if (cancelled) return;

        // 5. Advance to next app in the dock
        dictateAppIdx = (dictateAppIdx + 1) % DICTATE_APPS.length;
      }
    }

    runDictateLoop();

    return () => {
      cancelled = true;
      timerBag.forEach(clearTimeout);
    };
  });

  /* ── File Transcription State (Drag & Drop -> Transcribing -> Navigate) ── */
  let fileStep = $state(0); // 0: idle dropzone, 1: file dragging in, 2: progress transcribing, 3: navigate to detail
  $effect(() => {
    if (active !== 'summarize') {
      fileStep = 0;
      return;
    }

    let cancelled = false;
    let t1, t2, t3;

    fileStep = 0;
    t1 = setTimeout(() => {
      if (!cancelled) fileStep = 1; // file animates in
    }, 400);

    t2 = setTimeout(() => {
      if (!cancelled) fileStep = 2; // transcribing progress bar
    }, 1800);

    t3 = setTimeout(() => {
      if (!cancelled) fileStep = 3; // navigate to transcript detail
    }, 3800);

    return () => {
      cancelled = true;
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
    };
  });

  /* ── Voice Notes Steps ── */
  let otherStep = $state(0);
  $effect(() => {
    if (active !== 'notes') return;
    otherStep = 0;
    let timer;
    const times = [300, 600, 1200, 1800, 2600];
    let idx = 0;
    const advance = () => {
      idx += 1;
      if (idx >= times.length) {
        otherStep = times.length - 1;
        return;
      }
      otherStep = idx;
      timer = setTimeout(advance, times[idx]);
    };
    timer = setTimeout(advance, times[0]);
    return () => clearTimeout(timer);
  });

  /* ── Meeting Capture: Zoom (no in-app transcript) → Typie loading → ready ── */
  let capStep = $state(0); // 0 zoom, 1–2 recording via notch, 3 loading, 4 ready
  let liveSpeaker = $state(-1);
  $effect(() => {
    if (active !== 'capture') {
      capStep = 0;
      liveSpeaker = -1;
      return;
    }
    let cancelled = false;
    const timers = [];
    capStep = 0;
    timers.push(
      setTimeout(() => {
        if (!cancelled) capStep = 1;
      }, 700)
    );
    timers.push(
      setTimeout(() => {
        if (!cancelled) capStep = 2;
      }, 2800)
    );
    timers.push(
      setTimeout(() => {
        if (!cancelled) capStep = 3;
      }, 4800)
    );
    timers.push(
      setTimeout(() => {
        if (!cancelled) capStep = 4;
      }, 5300)
    );
    return () => {
      cancelled = true;
      timers.forEach(clearTimeout);
    };
  });
  $effect(() => {
    if (active !== 'capture' || capStep < 1 || capStep > 2) {
      liveSpeaker = -1;
      return;
    }
    liveSpeaker = 0;
    const id = setInterval(() => {
      liveSpeaker = liveSpeaker === 0 ? 2 : 0;
    }, 1300);
    return () => clearInterval(id);
  });

  function scrollToMac() {
    const el =
      document.getElementById('feature-tabs') ??
      document.getElementById('demo');
    if (!el) return;
    const y = el.getBoundingClientRect().top + window.scrollY - 72;
    window.scrollTo({ top: Math.max(0, y), behavior: 'smooth' });
  }

  function selectFeature(id) {
    active = id;
    notchMenuOpen = false;
    if (id === 'dictate') dictateAppIdx = 0;
    scrollToMac();
  }

  function pickDictateApp(idx) {
    active = 'dictate';
    dictateAppIdx = idx;
    scrollToMac();
  }

  /* ── notch state — mirrors the real app 1:1 ── */
  let notchMode = $derived.by(() => {
    if (notchMenuOpen) return 'menu';
    if (notchHover) return 'hover';
    if (active === 'dictate') {
      if (isKeyHolding) return 'transcribing';
      if (isDictateDone) return 'donems';
      return 'idle';
    }
    if (active === 'notes') {
      if (otherStep === 2 || otherStep === 3) return 'noterec';
      return 'idle';
    }
    if (active === 'capture') {
      if (capStep === 1 || capStep === 2) return 'callrec';
      if (capStep === 3) return 'processing';
      if (capStep >= 4) return 'donems';
      return 'idle';
    }
    if (active === 'summarize') {
      if (fileStep === 2) return 'processing';
      if (fileStep >= 3) return 'donems';
      return 'idle';
    }
    return 'idle';
  });

  const notchRipple = $derived(
    notchMode === 'transcribing' ||
      notchMode === 'noterec' ||
      notchMode === 'callrec' ||
      notchMode === 'processing'
  );
  const rippleTone = $derived.by(() => {
    if (notchMode === 'callrec') return 'mint';
    if (notchMode === 'processing') return 'purple';
    return 'pink';
  });

  /* ── notes extra ── */
  const NOTES_EXTRA = {
    id: 'x7',
    text: 'Launch day idea — record the demo call with Typie instead of typing notes manually.',
    pinned: true,
    date: 'just now',
    dur: '6s',
  };
  const notesExtra = $derived(
    active === 'notes' && otherStep >= 4 ? NOTES_EXTRA : null
  );

  /* ── call capture data ── */
  const CALL_PEOPLE = [
    { n: 'Maya', c: '#8b5cf6' },
    { n: 'You', c: '#10b981' },
    { n: 'Sam', c: '#f97316' },
    { n: 'Alex', c: '#06b6d4' },
  ];
  const menubarApp = $derived.by(() => {
    if (active === 'dictate') return currentDictateApp.label;
    if (active === 'capture' && capStep < 3) return 'zoom.us';
    return 'Typie';
  });

  const activeFeature = $derived(
    features.find((f) => f.id === active) ?? features[0]
  );
</script>

<section
  class="hero"
  id="top"
>
  <div class="container">
    <!-- Hero Headline & Core Value Proposition -->
    <div
      class="hero-top"
      use:reveal
    >
      <h1>
        It types what you say.<br />
        <em>Then it keeps going.</em>
      </h1>
      <p class="sub">
        Hold ⌥, speak naturally, and let go. Typie types into any app in 80
        milliseconds, records meetings without bots, and organizes voice notes —
        100% offline on Apple Silicon.
      </p>

      <div class="actions">
        <a
          href="https://github.com/samjhooker/typie/releases/latest"
          class="btn btn-primary bigcta"
        >
          <svg
            viewBox="0 0 384 512"
            width="16"
            height="16"
            fill="currentColor"
            aria-hidden="true"
            ><path
              d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"
            /></svg
          >
          Download for Mac — Free
        </a>
        <a
          href="https://github.com/samjhooker/typie"
          class="btn btn-ghost"
          target="_blank"
          rel="noopener"
        >
          View on GitHub
        </a>
      </div>

      <p
        class="trust-line"
        use:reveal={{ delay: 100 }}
      >
        Instant keystrokes · 100% offline · No account required · Open source
        MIT
      </p>
    </div>

    <!-- 4 Interactive Pillar Tabs -->
    <div
      class="vprops"
      id="feature-tabs"
      role="tablist"
      aria-label="Typie features"
      use:reveal
    >
      {#each features as f (f.id)}
        {@const Icon = f.icon}
        <button
          class="vprop"
          class:active={active === f.id}
          style="--accent-c:{f.color}"
          role="tab"
          aria-selected={active === f.id}
          onclick={() => selectFeature(f.id)}
        >
          <span
            class="vico"
            aria-hidden="true"
            ><Icon
              size={16}
              strokeWidth={2.2}
            /></span
          >
          <span class="vlabel">{f.label}</span>
        </button>
      {/each}
    </div>
    <p
      class="vcap"
      use:reveal={{ delay: 40 }}
    >
      {activeFeature.desc}
    </p>

    <!-- The Full Mac Hardware Display -->
    <div
      class="stage-wrap"
      id="demo"
      use:reveal={{ delay: 120 }}
    >
      <div class="mac">
        <div class="lid">
          <!-- Mac Menu Bar -->
          <div class="menubar">
            <svg
              class="apple"
              viewBox="0 0 384 512"
              ><path
                fill="currentColor"
                d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"
              /></svg
            >
            <span class="mapp">{menubarApp}</span>
            <span class="mi">File</span>
            <span class="mi">Edit</span>
            <span class="mi">View</span>
            <span class="mspace"></span>

            <!-- Airplane / Offline Test Toggle -->
            <button
              class="wifi-test-btn"
              class:off={wifiOff}
              onclick={() => (wifiOff = !wifiOff)}
              title={wifiOff
                ? 'Wi-Fi off — Typie is 100% functional offline'
                : 'Click to test offline / airplane mode'}
            >
              {#if wifiOff}
                <WifiOff
                  size={13}
                  strokeWidth={2}
                />
                <span>Offline · 0 bytes sent</span>
              {:else}
                <Wifi
                  size={13}
                  strokeWidth={2}
                />
                <span>Turn off Wi-Fi</span>
              {/if}
            </button>

            <span class="mclock mono">9:41 AM</span>
          </div>

          {#if notchRipple}
            <div
              class="notch-aura {rippleTone}"
              aria-hidden="true"
            >
              <span class="ring"></span>
              <span class="ring"></span>
              <span class="ring"></span>
              <span class="wobble"></span>
            </div>
          {/if}

          <!-- Real Apple Hardware Notch with Expandable Wings & Menu (1:1 with Screenshots) -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div
            class="notch"
            class:expanded={notchMode !== 'idle'}
            class:menuopen={notchMode === 'menu'}
            class:live={notchRipple}
            onmouseenter={() => (notchHover = true)}
            onmouseleave={() => (notchHover = false)}
          >
            <!-- Top Wing Bar -->
            <div class="notch-top-bar">
              <!-- Left Wing: Dancing Robot -->
              <div class="wing left-wing">
                {#if notchMode !== 'idle'}
                  <button
                    class="robot-btn"
                    onclick={() => selectFeature('notes')}
                    title="Open Typie"
                  >
                    <Robot
                      size={21}
                      mood={notchMode === 'transcribing'
                        ? 'listening'
                        : notchMode === 'donems'
                          ? 'done'
                          : 'idle'}
                    />
                  </button>
                {/if}
              </div>

              <!-- Physical Center: Real Mac Camera Lens -->
              <div class="cam-housing">
                <span class="cam-lens"></span>
              </div>

              <!-- Right Wing: Waveform / Plus / Note / Call / Close -->
              <div class="wing right-wing">
                {#if notchMode === 'menu'}
                  <button
                    class="menu-toggle-btn"
                    onclick={() => (notchMenuOpen = false)}
                    title="Close menu"
                  >
                    <svg
                      viewBox="0 0 16 16"
                      width="14"
                      height="14"
                      fill="none"
                      stroke="var(--hotpink)"
                      stroke-width="2"
                      stroke-linecap="round"
                      ><path d="M3 3l10 10M13 3L3 13" /></svg
                    >
                  </button>
                {:else if notchMode === 'hover' || (notchMode === 'idle' && notchHover)}
                  <button
                    class="menu-toggle-btn"
                    onclick={() => (notchMenuOpen = true)}
                    title="Quick actions"
                  >
                    <svg
                      viewBox="0 0 16 16"
                      width="15"
                      height="15"
                      fill="none"
                      stroke="var(--hotpink)"
                      stroke-width="2.2"
                      stroke-linecap="round"><path d="M8 2v12M2 8h12" /></svg
                    >
                  </button>
                {:else if notchMode === 'transcribing'}
                  <!-- Pink Waveform (Screenshot 2) -->
                  <div
                    class="nwave"
                    aria-hidden="true"
                  >
                    <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                  </div>
                {:else if notchMode === 'donems'}
                  <!-- 80ms Done Checkmark -->
                  <div class="done-pill">
                    <svg
                      viewBox="0 0 14 14"
                      width="12"
                      height="12"
                      class="chk"
                      aria-hidden="true"
                    >
                      <path
                        d="M2.5 7.5l3 3 6-7"
                        fill="none"
                        stroke="#4ade80"
                        stroke-width="2.2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                      />
                    </svg>
                    <span class="nms mono">80ms</span>
                  </div>
                {:else if notchMode === 'noterec'}
                  <!-- Note Recording Icon -->
                  <span
                    class="note-icn"
                    title="Recording note"
                  >
                    <svg
                      viewBox="0 0 16 16"
                      width="16"
                      height="16"
                      ><path
                        d="M3 2h7l3 3v9H3z"
                        fill="none"
                        stroke="var(--hotpink)"
                        stroke-width="1.8"
                      /><path
                        d="M10 2v3h3"
                        fill="none"
                        stroke="var(--hotpink)"
                        stroke-width="1.8"
                      /></svg
                    >
                  </span>
                {:else if notchMode === 'callrec'}
                  <!-- Call Recording Icon -->
                  <span
                    class="call-icn"
                    title="Recording call"
                  >
                    <svg
                      viewBox="0 0 16 16"
                      width="16"
                      height="16"
                      ><rect
                        x="2.5"
                        y="2.5"
                        width="11"
                        height="11"
                        fill="none"
                        stroke="#4ade80"
                        stroke-width="1.8"
                      /><rect
                        x="6"
                        y="6"
                        width="4"
                        height="4"
                        fill="#4ade80"
                      /></svg
                    >
                  </span>
                {:else if notchMode === 'processing'}
                  <div
                    class="nwave process"
                    aria-hidden="true"
                  >
                    <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                  </div>
                {/if}
              </div>
            </div>

            <!-- Expanded 3-Action Dropdown (Screenshot 4) -->
            {#if notchMode === 'menu'}
              <div class="notch-menu-grid">
                <button
                  class="nmenu-item"
                  onclick={() => selectFeature('notes')}
                >
                  <span class="nmenu-icn">
                    <svg
                      viewBox="0 0 16 16"
                      width="18"
                      height="18"
                      ><path
                        d="M3 2h7l3 3v9H3z"
                        fill="none"
                        stroke="var(--hotpink)"
                        stroke-width="1.6"
                      /><path
                        d="M10 2v3h3"
                        fill="none"
                        stroke="var(--hotpink)"
                        stroke-width="1.6"
                      /></svg
                    >
                  </span>
                  <span class="nmenu-label">quick note</span>
                </button>

                <span class="nmenu-divider"></span>

                <button
                  class="nmenu-item"
                  onclick={() => selectFeature('capture')}
                >
                  <span class="nmenu-icn">
                    <svg
                      viewBox="0 0 16 16"
                      width="18"
                      height="18"
                      ><rect
                        x="2.5"
                        y="2.5"
                        width="11"
                        height="11"
                        fill="none"
                        stroke="#4ade80"
                        stroke-width="1.6"
                      /><rect
                        x="6"
                        y="6"
                        width="4"
                        height="4"
                        fill="#4ade80"
                      /></svg
                    >
                  </span>
                  <span class="nmenu-label">record call</span>
                </button>

                <span class="nmenu-divider"></span>

                <button
                  class="nmenu-item"
                  onclick={() => selectFeature('summarize')}
                >
                  <span class="nmenu-icn">
                    <svg
                      viewBox="0 0 16 16"
                      width="18"
                      height="18"
                      ><path
                        d="M4 1.5h5.5L13 5v9.5H4z"
                        fill="none"
                        stroke="#c88cfd"
                        stroke-width="1.6"
                      /><path
                        d="M6 7.5h4M6 10h4M6 12.5h2.5"
                        stroke="#c88cfd"
                        stroke-width="1.4"
                        stroke-linecap="round"
                      /></svg
                    >
                  </span>
                  <span class="nmenu-label">upload file</span>
                </button>
              </div>
            {/if}
          </div>

          <!-- The Screen Content -->
          <div class="screen-viewport">
            <!-- SCENE 1: DICTATE INTO ANY APP (ANIMATED ROTATION & KEYPRESS STREAM) -->
            {#if active === 'dictate'}
              <div class="screen-view">
                {#key currentDictateApp.id}
                  <div class="win appwin">
                    <header class="wintitle">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="wintxt">{currentDictateApp.title}</span>
                      <span class="winmeta mono"
                        >{isDictateDone
                          ? 'transcribed · 80ms'
                          : isKeyHolding
                            ? 'listening…'
                            : 'offline'}</span
                      >
                    </header>
                    <div class="appbody">
                      {#if currentDictateApp.id === 'slack'}
                        <AppSlack
                          typed={typedStream}
                          listening={isKeyHolding}
                          pasted={justPasted}
                        />
                      {:else if currentDictateApp.id === 'safari'}
                        <AppSafari
                          typed={typedStream}
                          listening={isKeyHolding}
                          pasted={justPasted}
                        />
                      {:else if currentDictateApp.id === 'outlook'}
                        <AppOutlook
                          typed={typedStream}
                          listening={isKeyHolding}
                          pasted={justPasted}
                        />
                      {:else}
                        <AppWhatsApp
                          typed={typedStream}
                          listening={isKeyHolding}
                          pasted={justPasted}
                        />
                      {/if}
                    </div>
                  </div>
                {/key}
              </div>

              <!-- SCENE 2: MEETING CAPTURE (NO BOTS) -->
            {:else if active === 'capture'}
              <div class="screen-view">
                {#if capStep < 3}
                  <div class="win callwin">
                    <header class="callbar">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="calltitle">Launch Sync — zoom.us</span>
                      <span class="cspace"></span>
                      <span class="zoom-rec">
                        <i class="rec-dot"></i>REC <span class="zoom-timer mono">{capStep >= 1 ? '00:12' : '00:00'}</span>
                      </span>
                    </header>

                    <div class="callbody">
                      <div class="callgrid">
                        {#each CALL_PEOPLE as p, i}
                          <figure
                            class="ctile"
                            class:speaking={liveSpeaker === i}
                          >
                            <span
                              class="cini"
                              style="background:{p.c}">{p.n[0]}</span
                            >
                            <figcaption class="cname">{p.n}</figcaption>
                            {#if liveSpeaker === i}
                              <span class="cwave" aria-hidden="true"
                                ><i></i><i></i><i></i><i></i></span
                              >
                            {/if}
                          </figure>
                        {/each}
                      </div>
                      <div class="zoom-controls">
                        <button class="zc"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></svg></button>
                        <button class="zc"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="6" width="13" height="12" rx="2"/><path d="m16 10 5-3v10l-5-3z"/></svg></button>
                        <button class="zc"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round"><rect x="3" y="3" width="18" height="14" rx="2"/><path d="M8 21h8M12 17v4"/></svg></button>
                        <button class="zc rec on" title="Typie is recording system audio locally"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#4ade80" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="7"/></svg></button>
                        <button class="zc end"><svg viewBox="0 0 24 24" width="18" height="18" fill="#fff" stroke="none"><path d="M3 9a13 13 0 0 1 18 0v6l-4 1-2-3a8 8 0 0 0-6 0l-2 3-4-1z"/></svg></button>
                      </div>
                      <div class="zoom-typie-badge">
                        <Robot size={16} mood="idle" />
                        <span>Typie · recording locally · 0 bytes sent</span>
                      </div>
                    </div>
                  </div>
                {:else if capStep === 3}
                  <div class="win typwin">
                    <header class="wintitle">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="wintxt">Typie</span>
                      <span class="winmeta mono">on-device</span>
                    </header>
                    <div class="typie-loading fade-in">
                      <span class="load-bot"
                        ><Robot
                          size={44}
                          mood="listening"
                        /></span
                      >
                      <p>Transcribing on Apple Silicon…</p>
                      <div class="loadbar"><i></i></div>
                      <span class="mono">0 bytes sent · local model</span>
                    </div>
                  </div>
                {:else}
                  <div class="win typwin">
                    <header class="wintitle">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="wintxt">Typie — Call Summary & Actions</span>
                      <span class="winmeta mono">12:04 · 2 speakers</span>
                    </header>
                    <div class="realslot fill">
                      <DemoTranscriptDetail />
                    </div>
                  </div>
                {/if}
              </div>

              <!-- SCENE 3: VOICE NOTES ON THE WALL -->
            {:else if active === 'notes'}
              <div class="screen-view">
                <div class="win typwin">
                  <header class="wintitle">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span class="wintxt">Typie — Voice Notes</span>
                    <span class="winmeta mono">on-device storage</span>
                  </header>
                  <div class="shellslot">
                    <DemoShell
                      startPane="notes"
                      {notesExtra}
                      locked={true}
                    />
                  </div>
                </div>
              </div>

              <!-- SCENE 4: AUDIO FILE STUDIO (DRAG & DROP -> PROGRESS -> TRANSCRIPT PAGE) -->
            {:else}
              <div class="screen-view">
                <div class="win typwin">
                  <header class="wintitle">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span class="wintxt">Typie — File Transcription</span>
                    <span class="winmeta mono"
                      >{fileStep >= 3
                        ? 'transcribed · on-device'
                        : 'drop zone'}</span
                    >
                  </header>

                  {#if fileStep < 3}
                    <!-- Dropzone + Animated Drag & Drop File Simulation -->
                    <div class="file-drop-arena">
                      <!-- Animated Flying File Chip -->
                      <div
                        class="floating-audio-file"
                        class:in-flight={fileStep === 1}
                        class:landed={fileStep >= 2}
                      >
                        <span class="fa-icon"><FileText size={20} /></span>
                        <div class="fa-info">
                          <strong>interview-04.m4a</strong>
                          <span class="mono">38.2 MB · 12:04</span>
                        </div>
                      </div>

                      <div
                        class="dz-target"
                        class:active={fileStep >= 1}
                      >
                        <div class="dz-glow"></div>
                        <p class="dz-title">
                          {#if fileStep === 2}
                            Transcribing on Apple Silicon…
                          {:else}
                            Drop any audio file here
                          {/if}
                        </p>
                        <p class="dz-sub mono">
                          {#if fileStep === 2}
                            0 bytes sent · on-device · offline
                          {:else}
                            mp3 · m4a · wav · mp4
                          {/if}
                        </p>

                        {#if fileStep === 2}
                          <div class="dz-progress-bar">
                            <i class="dz-bar-fill"></i>
                          </div>
                        {/if}
                      </div>
                    </div>
                  {:else}
                    <!-- Navigated to the real transcript detail view -->
                    <div class="realslot fill fade-in">
                      <DemoTranscriptDetail
                        title="interview-04"
                        kind="file"
                        date="August 22, 2026"
                      />
                    </div>
                  {/if}
                </div>
              </div>
            {/if}
          </div>

          <!-- Bottom App Dock for Switching Apps -->
          <nav
            class="dock"
            aria-label="Target applications"
          >
            {#each DICTATE_APPS as a, i}
              <button
                class="ditem"
                class:on={active === 'dictate' &&
                  dictateAppIdx % DICTATE_APPS.length === i}
                onclick={() => pickDictateApp(i)}
                aria-label={a.label}
                title={a.label}
              >
                <span
                  class="dico"
                  data-app={a.id}
                  data-shell={a.shell}
                  >{@html nsSvg(a.brand, 'dk' + a.id)}</span
                >
                <i
                  class="ddot"
                  aria-hidden="true"
                ></i>
              </button>
            {/each}
            <button
              class="ditem"
              class:on={active === 'capture'}
              onclick={() => selectFeature('capture')}
              aria-label="Zoom"
              title="Zoom — capture a meeting"
            >
              <span
                class="dico"
                data-app="zoom"
                data-shell="zoom-wordmark"
                >{@html nsSvg(zoomWordmarkDark, 'dkzoom')}</span
              >
              <i
                class="ddot"
                aria-hidden="true"
              ></i>
            </button>
            <button
              class="ditem"
              class:on={active === 'notes' || active === 'summarize'}
              onclick={() => selectFeature('notes')}
              aria-label="Typie App"
              title="Typie App"
            >
              <span class="dico dtyp" data-app="typie"
                ><Robot
                  size={22}
                  mood="idle"
                /></span
              >
              <i
                class="ddot"
                aria-hidden="true"
              ></i>
            </button>
          </nav>
        </div>
        <!-- Mac keyboard deck — Option lives here so it never covers the screen -->
        <div
          class="mac-deck"
          class:dictate={active === 'dictate'}
          aria-hidden="true"
        >
          {#if active === 'dictate'}
            <div
              class="optkey"
              class:pressed={isKeyHolding}
              class:done={isDictateDone}
            >
              <span
                class="optcap"
                class:pressed={isKeyHolding}
              >
                <b>⌥</b>
                <small>option</small>
              </span>
              <div class="optmeta">
                {#if isKeyHolding}
                  <span class="optstatus live">Holding Option</span>
                  <strong>Listening…</strong>
                {:else if isDictateDone}
                  <span class="optstatus done">Released</span>
                  <strong>Pasted in 80ms ✓</strong>
                {:else}
                  <span class="optstatus">Hold Option</span>
                  <strong>to dictate anywhere</strong>
                {/if}
              </div>
            </div>
          {/if}
          <i class="chin"></i>
        </div>
      </div>
    </div>
  </div>
</section>

<style>
  .hero {
    padding: clamp(72px, 7vh, 88px) 0 clamp(44px, 5vh, 64px);
  }

  .hero-top {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 14px;
    max-width: 760px;
    margin: 0 auto;
  }

  h1 {
    font-size: clamp(40px, 5vw, 68px);
    font-weight: 900;
    letter-spacing: -0.05em;
    line-height: 0.96;
    text-wrap: balance;
  }
  h1 em {
    font-family: var(--serif);
    font-weight: 600;
    font-style: italic;
    letter-spacing: -0.03em;
    color: var(--hotpink);
  }

  .sub {
    font-size: clamp(16px, 1.8vw, 19px);
    line-height: 1.6;
    color: var(--text-2);
    max-width: 54ch;
    font-weight: 500;
  }

  .actions {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-wrap: wrap;
    gap: 14px;
    margin-top: 6px;
  }
  .bigcta {
    padding: 15px 28px;
    font-size: 16px;
  }
  .trust-line {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-3);
    margin-top: 2px;
  }

  /* 4 compact feature tabs */
  .vprops {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 8px;
    margin: 32px auto 0;
    max-width: 860px;
    scroll-margin-top: 72px;
  }
  .vprop {
    display: inline-flex;
    gap: 8px;
    align-items: center;
    padding: 8px 14px 8px 10px;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: 999px;
    cursor: pointer;
    transition:
      transform 0.2s var(--ease-out),
      border-color 0.2s ease,
      box-shadow 0.2s ease,
      background 0.2s ease;
  }
  .vprop:hover {
    transform: translateY(-1px);
    border-color: var(--line-strong);
  }
  .vprop.active {
    border-color: var(--accent-c);
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
    background: var(--surface);
  }
  .vico {
    flex-shrink: 0;
    width: 26px;
    height: 26px;
    display: grid;
    place-items: center;
    border-radius: 999px;
    background: var(--surface-2);
    color: var(--accent-c);
    transition:
      transform 0.2s var(--spring),
      background 0.2s ease,
      color 0.2s ease;
  }
  .vprop.active .vico {
    transform: scale(1.06);
    background: var(--accent-c);
    color: #fff;
  }
  .vlabel {
    font-family: var(--display);
    font-size: 13.5px;
    font-weight: 750;
    color: var(--ink);
    white-space: nowrap;
  }
  .vcap {
    text-align: center;
    font-size: 13.5px;
    color: var(--text-3);
    margin: 12px auto 0;
    max-width: 46ch;
    line-height: 1.45;
    min-height: 1.45em;
  }

  /* Full Mac Hardware Stage */
  .stage-wrap {
    margin-top: 28px;
    max-width: 1100px;
    margin-inline: auto;
    scroll-margin-top: 96px;
  }

  .mac {
    background: transparent;
    border: none;
    border-radius: 0;
    padding: 0;
    box-shadow: none;
    position: relative;
  }
  :root[data-theme='dark'] .mac {
    background: transparent;
    border: none;
    box-shadow: none;
  }

  .lid {
    background: linear-gradient(
      165deg,
      #f59e0b 0%,
      #fb923c 18%,
      #f472b6 48%,
      #c084fc 78%,
      #818cf8 100%
    );
    border-radius: 16px 16px 0 0;
    overflow: hidden;
    position: relative;
    aspect-ratio: 16 / 9.8;
    min-height: 530px;
    display: flex;
    flex-direction: column;
    border: none;
    box-shadow: none;
    transition: background 0.3s ease;
  }
  :root[data-theme='dark'] .lid {
    background: linear-gradient(
      165deg,
      #a83232 0%,
      #831843 20%,
      #4c1d95 50%,
      #1e1b4b 80%,
      #090d16 100%
    );
    border: none;
    box-shadow: none;
  }

  /* Mac Menu Bar — frosted glass layer */
  .menubar {
    height: 32px;
    background: rgba(0, 0, 0, 0.12);
    backdrop-filter: blur(20px) saturate(160%);
    -webkit-backdrop-filter: blur(20px) saturate(160%);
    border-bottom: 1px solid rgba(0, 0, 0, 0.12);
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 0 16px;
    font-size: 12.5px;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.95);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.25);
    z-index: 20;
  }
  :root[data-theme='dark'] .menubar {
    background: rgba(0, 0, 0, 0.28);
    border-bottom-color: rgba(255, 255, 255, 0.08);
  }
  .apple {
    width: 12px;
    height: 12px;
    fill: #ffffff;
    filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.2));
  }
  .mapp {
    color: #ffffff;
    font-weight: 700;
  }
  .mi {
    opacity: 0.85;
    color: #ffffff;
  }
  .mspace {
    flex: 1;
  }
  .wifi-test-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 3px 10px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.35);
    font-size: 11px;
    font-weight: 600;
    color: #ffffff;
    backdrop-filter: blur(8px);
    cursor: pointer;
    transition: all 0.15s ease;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.12);
  }
  .wifi-test-btn:hover {
    background: rgba(255, 255, 255, 0.32);
    border-color: #ffffff;
  }
  .wifi-test-btn.off {
    background: rgba(16, 185, 129, 0.45);
    color: #ffffff;
    border-color: #34d399;
  }
  .mclock {
    font-size: 12px;
    color: #ffffff;
  }

  /* ══ REAL MAC HARDWARE NOTCH (M-Series MacBook Air Proportions) ══ */
  .notch {
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    background: #000000;
    color: #ffffff;
    border-radius: 0 0 9px 9px;
    z-index: 30;
    width: 144px;
    height: 28px;
    transition:
      width 0.32s var(--spring),
      height 0.32s var(--spring),
      border-radius 0.32s ease,
      box-shadow 0.32s ease;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.45);
    overflow: hidden;
  }

  .notch.expanded {
    width: 252px;
    border-radius: 0 0 11px 11px;
  }

  .notch.menuopen {
    width: 310px;
    height: 70px;
    border-radius: 0 0 14px 14px;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.55);
  }

  .notch-top-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 28px;
    padding: 0 10px;
  }

  .cam-housing {
    display: grid;
    place-items: center;
    width: 22px;
  }
  .cam-lens {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #0b0c11;
    border: 1px solid #1c1e28;
    box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.8);
  }

  .wing {
    display: flex;
    align-items: center;
    min-width: 30px;
  }
  .left-wing {
    justify-content: flex-start;
  }
  .right-wing {
    justify-content: flex-end;
  }

  .robot-btn {
    display: grid;
    place-items: center;
    color: var(--hotpink);
    cursor: pointer;
    line-height: 0;
    transition: transform 0.15s var(--spring);
  }
  .robot-btn:hover {
    transform: scale(1.1);
  }

  .menu-toggle-btn {
    display: grid;
    place-items: center;
    cursor: pointer;
    transition: transform 0.15s var(--spring);
  }
  .menu-toggle-btn:hover {
    transform: scale(1.15);
  }

  .nwave {
    display: flex;
    align-items: center;
    gap: 2px;
    height: 16px;
  }
  .nwave i {
    width: 2.2px;
    border-radius: 2px;
    background: var(--hotpink);
    height: 40%;
    animation: nw 0.6s ease-in-out infinite alternate;
  }
  .nwave i:nth-child(2) {
    animation-delay: 0.1s;
    height: 80%;
  }
  .nwave i:nth-child(3) {
    animation-delay: 0.2s;
    height: 100%;
  }
  .nwave i:nth-child(4) {
    animation-delay: 0.3s;
    height: 60%;
  }
  .nwave i:nth-child(5) {
    animation-delay: 0.4s;
    height: 90%;
  }
  .nwave i:nth-child(6) {
    animation-delay: 0.5s;
    height: 45%;
  }
  .nwave i:nth-child(7) {
    animation-delay: 0.6s;
    height: 75%;
  }
  .nwave.process i {
    background: #c88cfd;
  }
  @keyframes nw {
    to {
      height: 20%;
    }
  }

  .notch.live {
    box-shadow:
      0 4px 16px rgba(0, 0, 0, 0.45),
      0 0 0 1px rgba(252, 86, 129, 0.35);
  }

  /* White glow — taller, waveform-like pulsing (not uniform), contained inside screen */
  .notch-aura {
    position: absolute;
    top: 0;
    left: 50%;
    width: 0;
    height: 0;
    z-index: 28;
    pointer-events: none;
  }
  .notch-aura .ring,
  .notch-aura .wobble {
    position: absolute;
    left: 50%;
    top: 0;
    width: 268px;
    height: 38px;
    border: none;
    border-radius: 0 0 14px 14px;
    background: #ffffff;
    box-shadow:
      0 0 16px rgba(255, 255, 255, 0.38),
      0 4px 18px rgba(255, 255, 255, 0.20);
    opacity: 0;
    transform: translateX(-50%) scale(0.92);
    transform-origin: 50% 0;
    animation: pulseWave 1.85s cubic-bezier(0.25, 0.46, 0.45, 0.94) infinite;
    will-change: transform, opacity;
  }
  .notch-aura .ring:nth-child(2) {
    width: 284px;
    height: 42px;
    border-radius: 0 0 15px 15px;
    animation-delay: 0.52s;
  }
  .notch-aura .ring:nth-child(3) {
    width: 302px;
    height: 46px;
    border-radius: 0 0 16px 16px;
    animation-delay: 1.04s;
  }
  .notch-aura .wobble {
    width: 252px;
    height: 36px;
    border-radius: 0 0 13px 13px;
    animation-name: pulseWaveSoft;
    animation-duration: 1.45s;
    animation-delay: 0.18s;
  }
  .notch-aura.mint .ring,
  .notch-aura.mint .wobble,
  .notch-aura.purple .ring,
  .notch-aura.purple .wobble {
    background: #ffffff;
  }
  @keyframes pulseWave {
    0% {
      transform: translateX(-50%) scale(0.88);
      opacity: 0;
    }
    10% {
      transform: translateX(-50%) scale(0.96);
      opacity: 0.86;
    }
    22% {
      transform: translateX(-50%) scale(1.12);
      opacity: 0.42;
    }
    34% {
      transform: translateX(-50%) scale(1.04);
      opacity: 0.22;
    }
    48% {
      transform: translateX(-50%) scale(1.34);
      opacity: 0.11;
    }
    62% {
      transform: translateX(-50%) scale(1.22);
      opacity: 0.05;
    }
    78% {
      transform: translateX(-50%) scale(1.52);
      opacity: 0.015;
    }
    100% {
      transform: translateX(-50%) scale(1.62);
      opacity: 0;
    }
  }
  @keyframes pulseWaveSoft {
    0% {
      transform: translateX(-50%) scale(0.90);
      opacity: 0;
    }
    14% {
      transform: translateX(-50%) scale(1.06);
      opacity: 0.86;
    }
    30% {
      transform: translateX(-50%) scale(0.98);
      opacity: 0.32;
    }
    52% {
      transform: translateX(-50%) scale(1.22);
      opacity: 0.09;
    }
    100% {
      transform: translateX(-50%) scale(1.38);
      opacity: 0;
    }
  }
  @media (prefers-reduced-motion: reduce) {
    .notch-aura {
      display: none;
    }
  }

  .done-pill {
    display: flex;
    align-items: center;
    gap: 5px;
  }
  .nms {
    color: #4ade80;
    font-weight: 700;
    font-size: 11px;
  }

  .note-icn,
  .call-icn {
    display: grid;
    place-items: center;
  }

  /* Dropdown Menu (Screenshot 4) */
  .notch-menu-grid {
    display: grid;
    grid-template-columns: 1fr 1px 1fr 1px 1fr;
    align-items: center;
    height: 42px;
    padding: 0 6px 4px;
    animation: menuFadeIn 0.25s var(--ease-out);
  }
  @keyframes menuFadeIn {
    from {
      opacity: 0;
      transform: translateY(-4px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .nmenu-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    padding: 2px 4px;
    cursor: pointer;
    transition: transform 0.15s var(--spring);
  }
  .nmenu-item:hover {
    transform: translateY(-2px);
  }
  .nmenu-icn {
    display: grid;
    place-items: center;
  }
  .nmenu-label {
    font-size: 9.5px;
    font-weight: 600;
    color: #f3f4f6;
    white-space: nowrap;
  }
  .nmenu-divider {
    height: 20px;
    width: 1px;
    background: rgba(255, 255, 255, 0.14);
  }

  /* Screen Viewport */
  .screen-viewport {
    flex: 1;
    position: relative;
    padding: 14px 18px 56px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  .screen-view {
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: column;
    position: relative;
  }

  .win {
    flex: 1;
    min-height: 0;
    background: var(--mac-win-bg);
    border: 1px solid var(--mac-win-border);
    border-radius: 12px;
    box-shadow: 0 12px 36px rgba(0, 0, 0, 0.12);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }
  .wintitle {
    height: 34px;
    background: var(--mac-titlebar);
    border-bottom: 1px solid var(--line);
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 0 14px;
    font-size: 12px;
    font-weight: 700;
    color: var(--mac-title-text);
  }
  .dots {
    display: flex;
    gap: 6px;
  }
  .dots i {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #d1d5db;
  }
  .dots i:nth-child(1) {
    background: #ef4444;
  }
  .dots i:nth-child(2) {
    background: #f59e0b;
  }
  .dots i:nth-child(3) {
    background: #10b981;
  }
  .wintxt {
    flex: 1;
    font-weight: 600;
  }
  .winmeta {
    font-size: 10.5px;
    opacity: 0.7;
  }

  .appbody,
  .realslot,
  .shellslot {
    flex: 1;
    min-height: 0;
    overflow: auto;
  }
  .realslot.fill {
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  /* ══ KEYBOARD DECK — Option key lives off the screen ══ */
  .mac-deck {
    position: relative;
    height: 16px;
    background: #2b2e38;
    border-radius: 0 0 20px 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    border: 1.5px solid var(--line-strong);
    border-top: none;
    transition: height 0.28s var(--ease-out);
  }
  .mac-deck.dictate {
    height: 72px;
    padding: 8px 16px 10px;
  }
  :root[data-theme='dark'] .mac-deck {
    background: linear-gradient(180deg, #1e212f 0%, #151722 100%);
    border-color: rgba(255, 255, 255, 0.22);
  }
  .chin {
    position: absolute;
    bottom: 0;
    width: 140px;
    height: 6px;
    background: #161822;
    border-radius: 0 0 8px 8px;
  }
  .optkey {
    display: inline-flex;
    align-items: center;
    gap: 14px;
    z-index: 2;
    color: #fff;
    animation: optIn 0.35s var(--ease-out) both;
  }
  @keyframes optIn {
    from {
      opacity: 0;
      transform: translateY(6px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
  .optcap {
    position: relative;
    width: 58px;
    height: 58px;
    border-radius: 16px;
    background: linear-gradient(180deg, #1a1d23 0%, #0f1115 100%);
    border: 1px solid #2d333f;
    border-bottom-width: 4px;
    display: block;
    color: #fff;
    box-shadow:
      0 4px 12px rgba(0, 0, 0, 0.18),
      inset 0 1px 0 rgba(255, 255, 255, 0.08);
    transition:
      transform 0.14s var(--spring),
      background-color 0.14s ease,
      border-color 0.14s ease,
      box-shadow 0.14s ease;
  }
  /* same anatomy as the bento keycap: ⌥ top-right, option bottom */
  .optcap b {
    position: absolute;
    top: 7px;
    right: 9px;
    font-size: 14px;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.8);
    line-height: 1;
  }
  .optcap small {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 8px;
    text-align: center;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: -0.01em;
    text-transform: lowercase;
  }
  .optcap b {
    font-size: 18px;
    font-weight: 800;
    line-height: 1;
  }
  .optcap small {
    font-size: 8px;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    opacity: 0.8;
  }
  .optcap.pressed {
    transform: translateY(3px) scale(0.97);
    background: linear-gradient(180deg, #ff7a9c 0%, var(--hotpink) 100%);
    border-color: #ff9db6;
    border-bottom-width: 1px;
    box-shadow:
      0 1px 4px rgba(0, 0, 0, 0.45),
      0 0 24px var(--hotpink-glow);
  }
  .optkey.done .optcap {
    background: #0f9d6a;
    border-color: #34d399;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.35);
  }
  .optmeta {
    display: flex;
    flex-direction: column;
    gap: 1px;
    text-align: left;
    width: 168px; /* fixed so status text changes never shift the key */
  }
  .optstatus {
    font-size: 11px;
    font-weight: 600;
    color: #9ca3af;
    letter-spacing: 0.02em;
  }
  .optstatus.live {
    color: var(--hotpink);
  }
  .optstatus.done {
    color: #4ade80;
  }
  .optmeta strong {
    font-size: 15px;
    font-weight: 800;
    letter-spacing: -0.02em;
    color: #fff;
  }

  /* ══ FILE TRANSCRIPTION DRAG & DROP ARENA ══ */
  .file-drop-arena {
    flex: 1;
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 30px 20px;
    background: var(--surface-2);
  }

  .floating-audio-file {
    position: absolute;
    top: 14px;
    left: 50%;
    transform: translateX(-50%) translateY(-60px) scale(0.8);
    opacity: 0;
    display: flex;
    align-items: center;
    gap: 10px;
    background: var(--surface);
    border: 1.5px solid var(--hotpink);
    border-radius: 12px;
    padding: 10px 16px;
    box-shadow: 0 14px 34px rgba(252, 86, 129, 0.25);
    color: var(--ink);
    z-index: 10;
    transition: all 0.6s var(--spring);
  }
  .floating-audio-file.in-flight {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1);
  }
  .floating-audio-file.landed {
    opacity: 0;
    transform: translateX(-50%) translateY(40px) scale(0.6);
  }
  .fa-icon {
    color: var(--hotpink);
    display: grid;
    place-items: center;
  }
  .fa-info {
    display: flex;
    flex-direction: column;
  }
  .fa-info strong {
    font-size: 13px;
    color: var(--ink);
  }
  .fa-info span {
    font-size: 10.5px;
    color: var(--text-3);
  }

  .dz-target {
    width: min(85%, 440px);
    border: 2px dashed var(--line-strong);
    border-radius: 18px;
    padding: 34px 20px;
    text-align: center;
    background: var(--surface);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    position: relative;
    overflow: hidden;
    transition: all 0.3s ease;
  }
  .dz-target.active {
    border-color: var(--purple);
    background: var(--card-lavender);
    box-shadow: 0 10px 30px rgba(200, 140, 253, 0.15);
  }
  .dz-title {
    font-family: var(--display);
    font-size: 16px;
    font-weight: 800;
    color: var(--ink);
  }
  .dz-sub {
    font-size: 12px;
    color: var(--text-3);
  }

  .dz-progress-bar {
    width: 80%;
    height: 6px;
    background: rgba(0, 0, 0, 0.08);
    border-radius: 999px;
    margin-top: 14px;
    overflow: hidden;
  }
  .dz-bar-fill {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, var(--purple), var(--hotpink));
    border-radius: 999px;
    width: 0%;
    animation: dzFill 1.9s ease-out forwards;
  }
  @keyframes dzFill {
    0% {
      width: 0%;
    }
    100% {
      width: 100%;
    }
  }

  .fade-in {
    animation: fadeIn 0.35s var(--ease-out);
  }
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(8px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  /* Meeting Call UI */
  .callbar {
    height: 38px;
    background: #181a20;
    color: #fff;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0 16px;
    font-size: 12.5px;
    font-weight: 600;
  }
  .calltitle {
    font-weight: 700;
  }
  .cspace {
    flex: 1;
  }
  .zoom-timer {
    font-size: 11px;
    color: #e5e7eb;
    letter-spacing: 0.04em;
    margin-left: 4px;
  }
  .zoom-rec {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    background: rgba(239, 68, 68, 0.18);
    border: 1px solid rgba(239, 68, 68, 0.4);
    color: #fca5a5;
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.06em;
    padding: 3px 8px;
    border-radius: 6px;
  }
  .rec-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #ef4444;
    margin-right: 4px;
    animation: recblink 1s steps(1) infinite;
  }
  @keyframes recblink {
    50% {
      opacity: 0.25;
    }
  }

  .callbody {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #0f1117;
    color: #fff;
  }
  .callgrid {
    flex: 1;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    padding: 14px;
  }
  .ctile {
    background: #1a1d27;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    border: 2px solid transparent;
    transition:
      border-color 0.2s ease,
      box-shadow 0.2s ease;
  }
  .ctile.speaking {
    border-color: #4ade80;
    box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.18);
  }
  .cini {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 18px;
    font-weight: 800;
    color: #fff;
  }
  .cname {
    position: absolute;
    bottom: 8px;
    left: 10px;
    font-size: 11px;
    font-weight: 600;
    opacity: 0.8;
  }
  .cwave {
    position: absolute;
    bottom: 8px;
    right: 10px;
    display: inline-flex;
    align-items: flex-end;
    gap: 2px;
    height: 12px;
  }
  .cwave i {
    width: 2px;
    border-radius: 2px;
    background: #4ade80;
    height: 40%;
    animation: cwave 0.6s ease-in-out infinite alternate;
  }
  .cwave i:nth-child(2) {
    animation-delay: 0.1s;
    height: 90%;
  }
  .cwave i:nth-child(3) {
    animation-delay: 0.2s;
    height: 60%;
  }
  .cwave i:nth-child(4) {
    animation-delay: 0.3s;
    height: 80%;
  }
  @keyframes cwave {
    to {
      height: 25%;
    }
  }

  .zoom-controls {
    flex: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    padding: 10px 14px;
  }
  .zc {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    background: #3a3d4a;
    display: grid;
    place-items: center;
    cursor: pointer;
    transition: background 0.15s ease;
  }
  .zc:hover {
    background: #4a4e5c;
  }
  .zc.rec {
    background: #2a3a2e;
  }
  .zc.rec.on {
    box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.5);
  }
  .zc.end {
    background: #ef4444;
  }
  .zoom-typie-badge {
    flex: none;
    display: inline-flex;
    align-items: center;
    gap: 7px;
    align-self: center;
    margin-bottom: 12px;
    padding: 6px 12px;
    background: rgba(252, 86, 129, 0.14);
    border: 1px solid rgba(252, 86, 129, 0.35);
    border-radius: 999px;
    font-size: 11px;
    font-weight: 600;
    color: #fdb6c7;
  }

  .typie-loading {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    background: var(--mac-win-bg);
    color: var(--ink);
  }
  .load-bot {
    color: var(--hotpink);
    line-height: 0;
  }
  .typie-loading p {
    font-family: var(--display);
    font-size: 16px;
    font-weight: 800;
  }
  .typie-loading .mono {
    font-size: 11px;
    color: var(--text-3);
  }
  .loadbar {
    width: 180px;
    height: 6px;
    background: rgba(19, 23, 34, 0.08);
    border-radius: 999px;
    overflow: hidden;
  }
  .loadbar i {
    display: block;
    height: 100%;
    width: 40%;
    background: linear-gradient(90deg, var(--hotpink), var(--purple));
    border-radius: 999px;
    animation: loadslide 0.55s ease-in-out infinite alternate;
  }
  @keyframes loadslide {
    from {
      transform: translateX(-10%);
    }
    to {
      transform: translateX(150%);
    }
  }

  /* Dock — macOS Tahoe liquid glass */
  .dock {
    position: absolute;
    bottom: 10px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 10px;
    border-radius: 20px;
    background: linear-gradient(
      180deg,
      rgba(255, 255, 255, 0.62) 0%,
      rgba(255, 255, 255, 0.42) 100%
    );
    backdrop-filter: blur(28px) saturate(180%);
    -webkit-backdrop-filter: blur(28px) saturate(180%);
    border: 1px solid rgba(255, 255, 255, 0.58);
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.78),
      inset 0 -1px 0 rgba(255, 255, 255, 0.22),
      0 8px 32px rgba(0, 0, 0, 0.16),
      0 1px 3px rgba(0, 0, 0, 0.08);
    z-index: 25;
  }
  :root[data-theme='dark'] .dock {
    background: linear-gradient(
      180deg,
      rgba(38, 40, 52, 0.72) 0%,
      rgba(22, 24, 34, 0.58) 100%
    );
    border-color: rgba(255, 255, 255, 0.14);
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.14),
      inset 0 -1px 0 rgba(0, 0, 0, 0.22),
      0 12px 36px rgba(0, 0, 0, 0.38),
      0 1px 3px rgba(0, 0, 0, 0.24);
  }
  .ditem {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    padding: 3px;
    border-radius: 12px;
    cursor: pointer;
    transition: transform 0.18s var(--spring);
  }
  .ditem:hover {
    transform: translateY(-5px) scale(1.10);
  }
  .ditem:active {
    transform: translateY(-2px) scale(1.04);
  }
  .dico {
    width: 40px;
    height: 40px;
    display: grid;
    place-items: center;
    border-radius: 10px;
    overflow: hidden;
    background: #ffffff;
    box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.12),
      0 4px 12px rgba(0, 0, 0, 0.10),
      inset 0 1px 0 rgba(255, 255, 255, 0.9);
    transition: box-shadow 0.18s ease;
  }
  .ditem:hover .dico {
    box-shadow:
      0 2px 6px rgba(0, 0, 0, 0.14),
      0 8px 20px rgba(0, 0, 0, 0.14);
  }
  .dico :global(svg) {
    width: 22px;
    height: 22px;
    display: block;
  }
  /* dock icons — real brand logos on solid Apple squircles (no transparency) */
  .dico[data-shell='pad'] {
    background: #ffffff;
    box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.12),
      0 4px 12px rgba(0, 0, 0, 0.1),
      inset 0 1px 0 rgba(255, 255, 255, 0.9);
  }
  .dico[data-shell='pad'] :global(svg) {
    width: 26px;
    height: 26px;
  }
  .dico[data-shell='cover'] :global(svg) {
    width: 100%;
    height: 100%;
  }
  /* solid Apple-style backgrounds per brand — never transparent */
  .dico[data-app='slack'] {
    background: #ffffff;
  }
  .dico[data-app='safari'] {
    background: #ffffff;
  }
  .dico[data-app='safari'] :global(svg) {
    width: 26px;
    height: 26px;
    border-radius: 0;
  }
  .dico[data-app='outlook'] {
    background: #ffffff;
  }
  .dico[data-app='outlook'] :global(svg) {
    width: 26px;
    height: 26px;
    border-radius: 0;
  }
  .dico[data-app='whatsapp'] {
    background: #ffffff;
  }
  .dico[data-app='whatsapp'] :global(svg) {
    width: 26px;
    height: 26px;
    border-radius: 0;
  }
  .dico[data-app='zoom'] {
    /* custom Apple squircle background for the wordmark-dark — Zoom blue, solid, no transparency */
    background: linear-gradient(135deg, #0b5cff 0%, #0845bf 55%, #4f90ee 100%);
    box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.18),
      0 4px 12px rgba(11, 92, 255, 0.28),
      inset 0 1px 0 rgba(255, 255, 255, 0.22);
    display: grid;
    place-items: center;
    padding: 0;
  }
  .dico[data-app='zoom'] :global(svg) {
    width: 78%;
    height: auto;
    display: block;
    border-radius: 0;
  }
  /* keep cover fallback rounded if ever used */
  .dico[data-shell='cover'] :global(svg) {
    border-radius: 0;
  }
  .dico.dtyp {
    background: #ffffff;
    color: var(--hotpink);
    box-shadow:
      0 1px 3px rgba(0, 0, 0, 0.12),
      0 4px 12px rgba(0, 0, 0, 0.10),
      inset 0 1px 0 rgba(255, 255, 255, 0.9);
  }
  :root[data-theme='dark'] .dico.dtyp {
    background: #1e1e22;
  }
  .dico.dtyp :global(svg) {
    width: 22px;
    height: 22px;
    border-radius: 0;
  }
  .dico[data-app='typie'] {
    background: #ffffff;
  }
  .dtyp {
    color: var(--hotpink);
  }
  .ddot {
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: transparent;
    transition: background 0.18s ease;
  }
  .ditem.on .ddot {
    background: rgba(0, 0, 0, 0.72);
  }
  :root[data-theme='dark'] .ditem.on .ddot {
    background: rgba(255, 255, 255, 0.88);
  }
  /* separator before Typie icon — like macOS */
  .ditem:last-child {
    margin-left: 2px;
    padding-left: 9px;
    position: relative;
  }
  .ditem:last-child::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    width: 1px;
    height: 22px;
    background: rgba(0, 0, 0, 0.10);
    transform: translateY(-50%);
    border-radius: 1px;
  }
  :root[data-theme='dark'] .ditem:last-child::before {
    background: rgba(255, 255, 255, 0.14);
  }

  @media (max-width: 900px) {
    .vprops {
      gap: 6px;
    }
  }
  @media (max-width: 600px) {
    .vlabel {
      font-size: 12.5px;
    }
    .dock {
      display: none;
    }
    .mac-deck.dictate {
      height: 64px;
    }
    .optcap {
      width: 50px;
      height: 50px;
      border-radius: 14px;
    }
  }
</style>
