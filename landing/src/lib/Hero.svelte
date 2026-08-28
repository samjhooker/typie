<script>
  import { reveal } from './reveal.js'
  import { nsSvg } from './svgid.js'
  import Robot from './Robot.svelte'
  import { Mic, PhoneCall, FileAudio, StickyNote, Wifi, WifiOff, FileText, ArrowRight } from 'lucide-svelte'
  import DemoShell from './real/DemoShell.svelte'
  import DemoTranscriptDetail from './real/DemoTranscriptDetail.svelte'
  import AppSlack from './real/AppSlack.svelte'
  import AppMail from './real/AppMail.svelte'
  import AppDocs from './real/AppDocs.svelte'
  import AppMessages from './real/AppMessages.svelte'
  import imessage from 'thesvg/imessage'
  import slackIco from 'thesvg/slack'
  import gdocs from 'thesvg/google-docs'

  const svgOf = (mod) => (typeof mod === 'string' ? mod : (mod.svg ?? String(mod)))
  const MAIL_SVG =
    '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" fill="#3b82f6"/><path d="m4.5 7.5 7.5 6 7.5-6" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>'

  let active = $state('dictate')
  let wifiOff = $state(false)
  let notchMenuOpen = $state(false)
  let notchHover = $state(false)

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
  ]

  /* ── dictate apps & text rotation ── */
  const DICTATE_APPS = [
    { id: 'slack', label: 'Slack',       brand: svgOf(slackIco),  title: 'Slack — #product', text: "pricing page is sam's, video is mine — shipping friday 🚀" },
    { id: 'docs',  label: 'Google Docs', brand: svgOf(gdocs),    title: 'Q3 Roadmap — Google Docs', text: "Launch checklist: 1. Deploy binary 2. Test offline mode" },
    { id: 'mail',  label: 'Mail',        brand: MAIL_SVG,        title: 'Mail — Inbox', text: "Hi Sarah, thanks for the intro — 3pm PST works perfectly for me." },
    { id: 'imsg',  label: 'Messages',    brand: svgOf(imessage), title: 'Messages — Team Sync', text: "omw right now, grabbing coffee — want an oat latte?" },
  ]
  
  let dictateAppIdx = $state(0)
  const currentDictateApp = $derived(DICTATE_APPS[dictateAppIdx % DICTATE_APPS.length])
  
  let typedStream = $state('')
  let isKeyHolding = $state(false)
  let isDictateDone = $state(false)

  /* ── continuous dictate loop (cycles between apps, animates keypress + typed stream) ── */
  $effect(() => {
    if (active !== 'dictate') {
      typedStream = ''
      isKeyHolding = false
      isDictateDone = false
      return
    }

    let cancelled = false
    let timer

    async function runDictateLoop() {
      while (!cancelled && active === 'dictate') {
        const target = DICTATE_APPS[dictateAppIdx % DICTATE_APPS.length]
        typedStream = ''
        isKeyHolding = false
        isDictateDone = false

        // 1. Pause briefly at empty app
        await new Promise(r => { timer = setTimeout(r, 600) })
        if (cancelled) return

        // 2. Press Option key down & start listening
        isKeyHolding = true
        await new Promise(r => { timer = setTimeout(r, 700) })
        if (cancelled) return

        // 3. Stream text character-by-character while holding key
        const fullText = target.text
        for (let i = 1; i <= fullText.length; i++) {
          if (cancelled) return
          typedStream = fullText.slice(0, i)
          await new Promise(r => { timer = setTimeout(r, 32) })
        }

        // 4. Release Option key & show 80ms speed checkmark
        isKeyHolding = false
        isDictateDone = true

        // 5. Hold finished state so user can read
        await new Promise(r => { timer = setTimeout(r, 2600) })
        if (cancelled) return

        // 6. Advance to next app in the dock
        dictateAppIdx = (dictateAppIdx + 1) % DICTATE_APPS.length
      }
    }

    runDictateLoop()

    return () => {
      cancelled = true
      clearTimeout(timer)
    }
  })

  /* ── File Transcription State (Drag & Drop -> Transcribing -> Navigate) ── */
  let fileStep = $state(0) // 0: idle dropzone, 1: file dragging in, 2: progress transcribing, 3: navigate to detail
  $effect(() => {
    if (active !== 'summarize') {
      fileStep = 0
      return
    }

    let cancelled = false
    let t1, t2, t3

    fileStep = 0
    t1 = setTimeout(() => {
      if (!cancelled) fileStep = 1 // file animates in
    }, 400)

    t2 = setTimeout(() => {
      if (!cancelled) fileStep = 2 // transcribing progress bar
    }, 1800)

    t3 = setTimeout(() => {
      if (!cancelled) fileStep = 3 // navigate to transcript detail
    }, 3800)

    return () => {
      cancelled = true
      clearTimeout(t1)
      clearTimeout(t2)
      clearTimeout(t3)
    }
  })

  /* ── Meeting & Voice Notes Steps ── */
  let otherStep = $state(0)
  $effect(() => {
    if (active === 'dictate' || active === 'summarize') return
    otherStep = 0
    let timer
    const times = active === 'capture' ? [400, 1200, 1800, 1800, 1400, 2600] : [300, 600, 1200, 1800, 2600]
    let idx = 0
    const advance = () => {
      idx += 1
      if (idx >= times.length) {
        otherStep = times.length - 1
        return
      }
      otherStep = idx
      timer = setTimeout(advance, times[idx])
    }
    timer = setTimeout(advance, times[0])
    return () => clearTimeout(timer)
  })

  function selectFeature(id) {
    active = id
    notchMenuOpen = false
    if (id === 'dictate') dictateAppIdx = 0
  }

  function pickDictateApp(idx) {
    active = 'dictate'
    dictateAppIdx = idx
  }

  /* ── notch state — mirrors the real app 1:1 ── */
  let notchMode = $derived.by(() => {
    if (notchMenuOpen) return 'menu'
    if (notchHover) return 'hover'
    if (active === 'dictate') {
      if (isKeyHolding) return 'transcribing'
      if (isDictateDone) return 'donems'
      return 'idle'
    }
    if (active === 'notes') {
      if (otherStep === 2 || otherStep === 3) return 'noterec'
      return 'idle'
    }
    if (active === 'capture') {
      if (otherStep >= 2 && otherStep <= 4) return 'callrec'
      return 'idle'
    }
    if (active === 'summarize') {
      if (fileStep === 1 || fileStep === 2) return 'transcribing'
      if (fileStep >= 3) return 'donems'
      return 'idle'
    }
    return 'idle'
  })

  /* ── notes extra ── */
  const NOTES_EXTRA = {
    id: 'x7', text: "Launch day idea — record the demo call with Typie instead of typing notes manually.",
    pinned: true, date: 'just now', dur: '6s',
  }
  const notesExtra = $derived(active === 'notes' && otherStep >= 4 ? NOTES_EXTRA : null)

  /* ── call capture data ── */
  const CAP_TURNS = [
    { name:'Maya', time:'02:14', text:'and the launch checklist is basically done?' },
    { name:'Sam', time:'02:18', text:'two items left — pricing page and the demo video.' },
    { name:'Maya', time:'02:24', text:'perfect. i can take the video this afternoon.' },
    { name:'Sam', time:'02:31', text:"i'll handle the pricing page then." },
  ]
  const CALL_PEOPLE = [
    { n: 'Maya', c: '#8b5cf6' },
    { n: 'You',  c: '#10b981' },
    { n: 'Sam',  c: '#f97316' },
    { n: 'Alex', c: '#06b6d4' },
  ]
  const speaker = $derived(otherStep >= 2 && otherStep <= 4 ? ((otherStep - 2) % 2 === 0 ? 0 : 2) : -1)
  const callTurns = $derived(active === 'capture' && otherStep >= 2 ? CAP_TURNS.slice(0, Math.min(otherStep, 4)) : [])

  const menubarApp = $derived.by(() => {
    if (active === 'dictate') return currentDictateApp.label
    if (active === 'capture' && otherStep < 5) return 'Zoom'
    return 'Typie'
  })
</script>

<section class="hero" id="top">
  <div class="container">
    <!-- Hero Headline & Core Value Proposition -->
    <div class="hero-top" use:reveal>
      <h1>
        It types what you say.<br />
        <em>Then it keeps going.</em>
      </h1>
      <p class="sub">
        Hold ⌥, speak naturally, and let go. Typie types into any app in 80 milliseconds, records meetings without bots, and organizes voice notes — 100% offline on Apple Silicon.
      </p>
      
      <div class="actions">
        <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-primary bigcta">
          <svg viewBox="0 0 384 512" width="16" height="16" fill="currentColor" aria-hidden="true"><path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
          Download for Mac — Free
        </a>
        <a href="https://github.com/samjhooker/typie" class="btn btn-ghost" target="_blank" rel="noopener">
          View on GitHub
        </a>
      </div>

      <p class="trust-line" use:reveal={{ delay: 100 }}>
        Instant keystrokes · 100% offline · No account required · Open source MIT
      </p>
    </div>

    <!-- 4 Interactive Pillar Tabs -->
    <div class="vprops" role="tablist" aria-label="Typie features" use:reveal>
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
          <span class="vico" aria-hidden="true"><Icon size={20} strokeWidth={2} /></span>
          <span class="vbody">
            <span class="vlabel">{f.label}</span>
            <span class="vdesc">{f.desc}</span>
          </span>
        </button>
      {/each}
    </div>

    <!-- The Full Mac Hardware Display -->
    <div class="stage-wrap" id="demo" use:reveal={{ delay: 120 }}>
      <div class="mac">
        <div class="lid">
          
          <!-- Mac Menu Bar -->
          <div class="menubar">
            <svg class="apple" viewBox="0 0 384 512"><path fill="currentColor" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
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
              title={wifiOff ? 'Wi-Fi off — Typie is 100% functional offline' : 'Click to test offline / airplane mode'}
            >
              {#if wifiOff}
                <WifiOff size={13} strokeWidth={2} />
                <span>Offline · 0 bytes sent</span>
              {:else}
                <Wifi size={13} strokeWidth={2} />
                <span>Pull Wi-Fi</span>
              {/if}
            </button>

            <span class="mclock mono">9:41 AM</span>
          </div>

          <!-- Real Apple Hardware Notch with Expandable Wings & Menu (1:1 with Screenshots) -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div
            class="notch"
            class:expanded={notchMode !== 'idle'}
            class:menuopen={notchMode === 'menu'}
            onmouseenter={() => (notchHover = true)}
            onmouseleave={() => (notchHover = false)}
          >
            <!-- Top Wing Bar -->
            <div class="notch-top-bar">
              <!-- Left Wing: Dancing Robot -->
              <div class="wing left-wing">
                {#if notchMode !== 'idle'}
                  <button class="robot-btn" onclick={() => selectFeature('notes')} title="Open Typie">
                    <Robot size={21} mood={notchMode === 'transcribing' ? 'listening' : notchMode === 'donems' ? 'done' : 'idle'} />
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
                  <button class="menu-toggle-btn" onclick={() => (notchMenuOpen = false)} title="Close menu">
                    <svg viewBox="0 0 16 16" width="14" height="14" fill="none" stroke="var(--hotpink)" stroke-width="2" stroke-linecap="round"><path d="M3 3l10 10M13 3L3 13"/></svg>
                  </button>
                {:else if notchMode === 'hover' || notchMode === 'idle' && notchHover}
                  <button class="menu-toggle-btn" onclick={() => (notchMenuOpen = true)} title="Quick actions">
                    <svg viewBox="0 0 16 16" width="15" height="15" fill="none" stroke="var(--hotpink)" stroke-width="2.2" stroke-linecap="round"><path d="M8 2v12M2 8h12"/></svg>
                  </button>
                {:else if notchMode === 'transcribing'}
                  <!-- Pink Waveform (Screenshot 2) -->
                  <div class="nwave" aria-hidden="true">
                    <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                  </div>
                {:else if notchMode === 'donems'}
                  <!-- 80ms Done Checkmark -->
                  <div class="done-pill">
                    <svg viewBox="0 0 14 14" width="12" height="12" class="chk" aria-hidden="true">
                      <path d="M2.5 7.5l3 3 6-7" fill="none" stroke="#4ade80" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    <span class="nms mono">80ms</span>
                  </div>
                {:else if notchMode === 'noterec'}
                  <!-- Note Recording Icon -->
                  <span class="note-icn" title="Recording note">
                    <svg viewBox="0 0 16 16" width="16" height="16"><path d="M3 2h7l3 3v9H3z" fill="none" stroke="var(--hotpink)" stroke-width="1.8"/><path d="M10 2v3h3" fill="none" stroke="var(--hotpink)" stroke-width="1.8"/></svg>
                  </span>
                {:else if notchMode === 'callrec'}
                  <!-- Call Recording Icon -->
                  <span class="call-icn" title="Recording call">
                    <svg viewBox="0 0 16 16" width="16" height="16"><rect x="2.5" y="2.5" width="11" height="11" fill="none" stroke="#4ade80" stroke-width="1.8"/><rect x="6" y="6" width="4" height="4" fill="#4ade80"/></svg>
                  </span>
                {/if}
              </div>
            </div>

            <!-- Expanded 3-Action Dropdown (Screenshot 4) -->
            {#if notchMode === 'menu'}
              <div class="notch-menu-grid">
                <button class="nmenu-item" onclick={() => selectFeature('notes')}>
                  <span class="nmenu-icn">
                    <svg viewBox="0 0 16 16" width="18" height="18"><path d="M3 2h7l3 3v9H3z" fill="none" stroke="var(--hotpink)" stroke-width="1.6"/><path d="M10 2v3h3" fill="none" stroke="var(--hotpink)" stroke-width="1.6"/></svg>
                  </span>
                  <span class="nmenu-label">quick note</span>
                </button>
                
                <span class="nmenu-divider"></span>

                <button class="nmenu-item" onclick={() => selectFeature('capture')}>
                  <span class="nmenu-icn">
                    <svg viewBox="0 0 16 16" width="18" height="18"><rect x="2.5" y="2.5" width="11" height="11" fill="none" stroke="#4ade80" stroke-width="1.6"/><rect x="6" y="6" width="4" height="4" fill="#4ade80"/></svg>
                  </span>
                  <span class="nmenu-label">record call</span>
                </button>

                <span class="nmenu-divider"></span>

                <button class="nmenu-item" onclick={() => selectFeature('summarize')}>
                  <span class="nmenu-icn">
                    <svg viewBox="0 0 16 16" width="18" height="18"><path d="M4 1.5h5.5L13 5v9.5H4z" fill="none" stroke="#c88cfd" stroke-width="1.6"/><path d="M6 7.5h4M6 10h4M6 12.5h2.5" stroke="#c88cfd" stroke-width="1.4" stroke-linecap="round"/></svg>
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
                      <span class="winmeta mono">{isDictateDone ? 'transcribed · 80ms' : isKeyHolding ? 'listening…' : 'offline'}</span>
                    </header>
                    <div class="appbody">
                      {#if currentDictateApp.id === 'slack'}
                        <AppSlack typed={typedStream} listening={isKeyHolding} />
                      {:else if currentDictateApp.id === 'mail'}
                        <AppMail typed={typedStream} listening={isKeyHolding} />
                      {:else if currentDictateApp.id === 'docs'}
                        <AppDocs typed={typedStream} listening={isKeyHolding} />
                      {:else}
                        <AppMessages typed={typedStream} listening={isKeyHolding} />
                      {/if}
                    </div>
                  </div>
                {/key}

                <!-- Animated Tactile Option Key Press Overlay -->
                <div class="keyovl" class:holding={isKeyHolding} class:done={isDictateDone} aria-hidden="true">
                  <span class="kcap" class:pressed={isKeyHolding}>⌥</span>
                  <div class="ktext">
                    {#if isKeyHolding}
                      <span class="kstatus live">Holding Option · Listening</span>
                    {:else if isDictateDone}
                      <span class="kstatus done">Released · Inserted in 80ms ✓</span>
                    {:else}
                      <span class="kstatus">Hold Option to Dictate</span>
                    {/if}
                  </div>
                </div>
              </div>

            <!-- SCENE 2: MEETING CAPTURE (NO BOTS) -->
            {:else if active === 'capture'}
              <div class="screen-view">
                {#if otherStep < 5}
                  <div class="win callwin">
                    <header class="callbar">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="calltitle">Launch Sync — Live Call</span>
                      <span class="cspace"></span>
                      <span class="reccall mono" class:on={otherStep >= 2}>
                        <i></i> {otherStep >= 2 ? 'REC 0:12' : 'ready'}
                      </span>
                    </header>

                    <div class="callbody">
                      <div class="callgrid">
                        {#each CALL_PEOPLE as p, i}
                          <figure class="ctile" class:speaking={speaker === i}>
                            <span class="cini" style="background:{p.c}">{p.n[0]}</span>
                            <figcaption class="cname">{p.n}</figcaption>
                          </figure>
                        {/each}
                      </div>

                      {#if otherStep >= 2}
                        <aside class="callrail">
                          <p class="railhead mono">live transcript (no bots)</p>
                          {#each callTurns as t, i}
                            <p class="railturn">
                              <b style="color:{i % 2 === 0 ? 'var(--hotpink)' : 'var(--periwinkle)'}">{t.name.toLowerCase()}</b> {t.text}
                            </p>
                          {/each}
                        </aside>
                      {/if}
                    </div>
                  </div>
                {:else}
                  <div class="win typwin">
                    <header class="wintitle">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="wintxt">Typie — Call Summary & Actions</span>
                      <span class="winmeta mono">12:04 · 2 speakers</span>
                    </header>
                    <div class="realslot">
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
                    <DemoShell startPane="notes" notesExtra={notesExtra} locked={false} />
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
                    <span class="winmeta mono">{fileStep >= 3 ? 'transcribed · on-device' : 'drop zone'}</span>
                  </header>
                  
                  {#if fileStep < 3}
                    <!-- Dropzone + Animated Drag & Drop File Simulation -->
                    <div class="file-drop-arena">
                      
                      <!-- Animated Flying File Chip -->
                      <div class="floating-audio-file" class:in-flight={fileStep === 1} class:landed={fileStep >= 2}>
                        <span class="fa-icon"><FileText size={20} /></span>
                        <div class="fa-info">
                          <strong>interview-04.m4a</strong>
                          <span class="mono">38.2 MB · 12:04</span>
                        </div>
                      </div>

                      <div class="dz-target" class:active={fileStep >= 1}>
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
                            0 bytes sent · local Nvidia Parakeet model
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
                    <div class="realslot fade-in">
                      <DemoTranscriptDetail />
                    </div>
                  {/if}
                </div>
              </div>
            {/if}

          </div>

          <!-- Bottom App Dock for Switching Apps -->
          <nav class="dock" aria-label="Target applications">
            {#each DICTATE_APPS as a, i}
              <button
                class="ditem"
                class:on={active === 'dictate' && dictateAppIdx % DICTATE_APPS.length === i}
                onclick={() => pickDictateApp(i)}
                aria-label={a.label}
                title={a.label}
              >
                <span class="dico">{@html nsSvg(a.brand, 'dk' + a.id)}</span>
                <i class="ddot" aria-hidden="true"></i>
              </button>
            {/each}
            <button
              class="ditem"
              class:on={active === 'notes' || active === 'summarize'}
              onclick={() => selectFeature('notes')}
              aria-label="Typie App"
              title="Typie App"
            >
              <span class="dico dtyp"><Robot size={22} mood="idle" /></span>
              <i class="ddot" aria-hidden="true"></i>
            </button>
          </nav>

        </div>
        <!-- Mac Base / Notch Chin -->
        <div class="mac-base" aria-hidden="true"><i class="chin"></i></div>
      </div>
    </div>
  </div>
</section>

<style>
  .hero { padding: clamp(68px, 8vh, 96px) 0 clamp(50px, 6vh, 72px); }

  .hero-top {
    display: flex; flex-direction: column; align-items: center; text-align: center; gap: 18px;
    max-width: 820px; margin: 0 auto;
  }
  
  h1 {
    font-size: clamp(44px, 5.6vw, 76px);
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
    display: flex; align-items: center; justify-content: center; flex-wrap: wrap; gap: 14px;
    margin-top: 8px;
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

  /* 4 Value Prop Cards */
  .vprops {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin: 44px auto 0;
    max-width: 1100px;
    text-align: left;
  }
  .vprop {
    display: flex; gap: 14px; align-items: flex-start;
    padding: 16px 18px;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    cursor: pointer;
    transition: transform 0.2s var(--ease-out), border-color 0.2s ease, box-shadow 0.2s ease;
  }
  .vprop:hover {
    transform: translateY(-2px);
    border-color: var(--line-strong);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  }
  .vprop.active {
    border-color: var(--accent-c);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.07);
    background: var(--surface);
  }
  .vico {
    flex-shrink: 0;
    width: 40px; height: 40px;
    display: grid; place-items: center;
    border-radius: 12px;
    background: var(--surface-2);
    color: var(--accent-c);
    transition: transform 0.2s var(--spring);
  }
  .vprop.active .vico {
    transform: scale(1.08);
    background: var(--accent-c);
    color: #fff;
  }
  .vlabel {
    display: block;
    font-family: var(--display);
    font-size: 15.5px;
    font-weight: 800;
    color: var(--ink);
    margin-bottom: 2px;
  }
  .vdesc {
    display: block;
    font-size: 12.5px;
    color: var(--text-3);
    line-height: 1.45;
  }

  /* Full Mac Hardware Stage */
  .stage-wrap {
    margin-top: 36px;
    max-width: 1100px;
    margin-inline: auto;
  }

  .mac {
    background: var(--mac-lid-bg);
    border: 2px solid var(--line-strong);
    border-radius: 24px 24px 0 0;
    padding: 10px 10px 0;
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.24);
  }

  .lid {
    background: var(--mac-screen-bg);
    border-radius: 16px 16px 0 0;
    overflow: hidden;
    position: relative;
    aspect-ratio: 16 / 9.8;
    min-height: 520px;
    display: flex;
    flex-direction: column;
    border: 1px solid rgba(0, 0, 0, 0.15);
  }

  /* Mac Menu Bar */
  .menubar {
    height: 32px;
    background: rgba(255, 255, 255, 0.7);
    backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--line);
    display: flex; align-items: center; gap: 14px;
    padding: 0 16px;
    font-size: 12.5px; font-weight: 600;
    color: var(--text-2);
    z-index: 20;
  }
  :root[data-theme="dark"] .menubar {
    background: rgba(20, 22, 32, 0.75);
    border-bottom-color: rgba(255, 255, 255, 0.08);
  }
  .apple { width: 12px; height: 12px; }
  .mapp { color: var(--ink); font-weight: 700; }
  .mi { opacity: 0.7; }
  .mspace { flex: 1; }
  .wifi-test-btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 3px 10px; border-radius: 999px;
    background: var(--surface); border: 1px solid var(--line);
    font-size: 11px; font-weight: 600; color: var(--text-2);
    cursor: pointer; transition: all 0.15s ease;
  }
  .wifi-test-btn:hover { border-color: var(--hotpink); color: var(--hotpink); }
  .wifi-test-btn.off {
    background: var(--card-mint); color: #059669; border-color: #10b981;
  }
  .mclock { font-size: 12px; }

  /* ══ REAL MAC HARDWARE NOTCH (1:1 with Screenshots) ══ */
  .notch {
    position: absolute;
    top: 0; left: 50%;
    transform: translateX(-50%);
    background: #000000;
    color: #ffffff;
    border-radius: 0 0 10px 10px;
    z-index: 30;
    width: 172px;
    height: 30px;
    transition: width 0.35s var(--spring), height 0.35s var(--spring), border-radius 0.35s ease, box-shadow 0.35s ease;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4);
    overflow: hidden;
  }
  
  .notch.expanded {
    width: 380px;
    border-radius: 0 0 12px 12px;
  }

  .notch.menuopen {
    width: 440px;
    height: 82px;
    border-radius: 0 0 16px 16px;
    box-shadow: 0 14px 34px rgba(0, 0, 0, 0.55);
  }

  .notch-top-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 30px;
    padding: 0 16px;
  }

  .cam-housing {
    display: grid;
    place-items: center;
    width: 28px;
  }
  .cam-lens {
    width: 9px; height: 9px;
    border-radius: 50%;
    background: #0b0c11;
    border: 1px solid #1c1e28;
    box-shadow: inset 0 1px 2px rgba(0,0,0,0.8);
  }

  .wing {
    display: flex;
    align-items: center;
    min-width: 40px;
  }
  .left-wing { justify-content: flex-start; }
  .right-wing { justify-content: flex-end; }

  .robot-btn {
    display: grid;
    place-items: center;
    color: var(--hotpink);
    cursor: pointer;
    line-height: 0;
    transition: transform 0.15s var(--spring);
  }
  .robot-btn:hover { transform: scale(1.1); }

  .menu-toggle-btn {
    display: grid;
    place-items: center;
    cursor: pointer;
    transition: transform 0.15s var(--spring);
  }
  .menu-toggle-btn:hover { transform: scale(1.15); }

  .nwave {
    display: flex; align-items: center; gap: 2px; height: 16px;
  }
  .nwave i {
    width: 2.2px; border-radius: 2px; background: var(--hotpink); height: 40%;
    animation: nw 0.6s ease-in-out infinite alternate;
  }
  .nwave i:nth-child(2) { animation-delay: 0.1s; height: 80%; }
  .nwave i:nth-child(3) { animation-delay: 0.2s; height: 100%; }
  .nwave i:nth-child(4) { animation-delay: 0.3s; height: 60%; }
  .nwave i:nth-child(5) { animation-delay: 0.4s; height: 90%; }
  .nwave i:nth-child(6) { animation-delay: 0.5s; height: 45%; }
  .nwave i:nth-child(7) { animation-delay: 0.6s; height: 75%; }
  @keyframes nw { to { height: 20%; } }

  .done-pill {
    display: flex; align-items: center; gap: 5px;
  }
  .nms { color: #4ade80; font-weight: 700; font-size: 11px; }

  .note-icn, .call-icn {
    display: grid; place-items: center;
  }

  /* Dropdown Menu (Screenshot 4) */
  .notch-menu-grid {
    display: grid;
    grid-template-columns: 1fr 1px 1fr 1px 1fr;
    align-items: center;
    height: 52px;
    padding: 0 10px 4px;
    animation: menuFadeIn 0.25s var(--ease-out);
  }
  @keyframes menuFadeIn {
    from { opacity: 0; transform: translateY(-4px); }
    to { opacity: 1; transform: none; }
  }

  .nmenu-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    padding: 4px 6px;
    cursor: pointer;
    transition: transform 0.15s var(--spring);
  }
  .nmenu-item:hover { transform: translateY(-2px); }
  .nmenu-icn { display: grid; place-items: center; }
  .nmenu-label {
    font-size: 10.5px;
    font-weight: 600;
    color: #f3f4f6;
    white-space: nowrap;
  }
  .nmenu-divider {
    height: 24px;
    width: 1px;
    background: rgba(255, 255, 255, 0.12);
  }

  /* Screen Viewport */
  .screen-viewport {
    flex: 1;
    position: relative;
    padding: 16px 20px 60px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  .screen-view { height: 100%; display: flex; flex-direction: column; position: relative; }

  .win {
    flex: 1;
    background: var(--mac-win-bg);
    border: 1px solid var(--mac-win-border);
    border-radius: 12px;
    box-shadow: 0 12px 36px rgba(0, 0, 0, 0.12);
    display: flex; flex-direction: column;
    overflow: hidden;
  }
  .wintitle {
    height: 34px;
    background: var(--mac-titlebar);
    border-bottom: 1px solid var(--line);
    display: flex; align-items: center; gap: 10px;
    padding: 0 14px;
    font-size: 12px; font-weight: 700; color: var(--mac-title-text);
  }
  .dots { display: flex; gap: 6px; }
  .dots i { width: 10px; height: 10px; border-radius: 50%; background: #d1d5db; }
  .dots i:nth-child(1) { background: #ef4444; }
  .dots i:nth-child(2) { background: #f59e0b; }
  .dots i:nth-child(3) { background: #10b981; }
  .wintxt { flex: 1; font-weight: 600; }
  .winmeta { font-size: 10.5px; opacity: 0.7; }

  .appbody, .realslot, .shellslot { flex: 1; overflow: auto; }

  /* ══ ANIMATED TACTILE OPTION KEYPRESS OVERLAY ══ */
  .keyovl {
    position: absolute;
    bottom: 24px; left: 50%;
    transform: translateX(-50%);
    background: rgba(18, 20, 28, 0.90);
    backdrop-filter: blur(14px);
    color: #fff;
    border-radius: 999px;
    padding: 7px 18px 7px 10px;
    display: inline-flex; align-items: center; gap: 12px;
    font-size: 13px; font-weight: 600;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
    border: 1.5px solid rgba(255, 255, 255, 0.14);
    transition: all 0.22s var(--spring);
    z-index: 10;
  }
  .keyovl.holding {
    border-color: var(--hotpink);
    transform: translateX(-50%) scale(1.05);
    box-shadow: 0 12px 34px var(--hotpink-glow);
    background: rgba(28, 16, 24, 0.94);
  }
  .keyovl.done {
    border-color: #10b981;
    box-shadow: 0 10px 28px rgba(16, 185, 129, 0.25);
  }

  .kcap {
    width: 30px; height: 30px;
    border-radius: 8px;
    background: #252834;
    border: 1px solid rgba(255, 255, 255, 0.25);
    border-bottom: 3px solid rgba(0, 0, 0, 0.5);
    display: grid; place-items: center;
    font-size: 15px; font-weight: 800; color: #fff;
    box-shadow: 0 3px 6px rgba(0, 0, 0, 0.3);
    transition: transform 0.15s var(--spring), background-color 0.15s ease, border-color 0.15s ease;
  }
  .kcap.pressed {
    transform: translateY(2px) scale(0.96);
    background: var(--hotpink);
    color: #fff;
    border-color: var(--hotpink);
    border-bottom-width: 1px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
  }

  .ktext { display: flex; flex-direction: column; }
  .kstatus { font-size: 12.5px; font-weight: 600; color: #d1d5db; }
  .kstatus.live { color: var(--hotpink); font-weight: 700; }
  .kstatus.done { color: #4ade80; font-weight: 700; }

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
    display: flex; align-items: center; gap: 10px;
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
  .fa-icon { color: var(--hotpink); display: grid; place-items: center; }
  .fa-info { display: flex; flex-direction: column; }
  .fa-info strong { font-size: 13px; color: var(--ink); }
  .fa-info span { font-size: 10.5px; color: var(--text-3); }

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
  .dz-title { font-family: var(--display); font-size: 16px; font-weight: 800; color: var(--ink); }
  .dz-sub { font-size: 12px; color: var(--text-3); }

  .dz-progress-bar {
    width: 80%; height: 6px;
    background: rgba(0, 0, 0, 0.08);
    border-radius: 999px;
    margin-top: 14px;
    overflow: hidden;
  }
  .dz-bar-fill {
    display: block; height: 100%;
    background: linear-gradient(90deg, var(--purple), var(--hotpink));
    border-radius: 999px;
    animation: dzFill 1.8s ease-in-out infinite;
  }
  @keyframes dzFill {
    0% { width: 0%; }
    100% { width: 100%; }
  }

  .fade-in {
    animation: fadeIn 0.35s var(--ease-out);
  }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(8px); }
    to { opacity: 1; transform: none; }
  }

  /* Meeting Call UI */
  .callbar {
    height: 38px;
    background: #181a20;
    color: #fff;
    display: flex; align-items: center; gap: 12px;
    padding: 0 16px;
    font-size: 12.5px; font-weight: 600;
  }
  .calltitle { font-weight: 700; }
  .cspace { flex: 1; }
  .reccall {
    display: inline-flex; align-items: center; gap: 6px;
    font-size: 10.5px; color: #9ca3af;
  }
  .reccall.on { color: #ef4444; }
  .reccall.on i { width: 7px; height: 7px; border-radius: 50%; background: #ef4444; animation: recpulse 1.2s infinite; }
  @keyframes recpulse { 50% { opacity: 0.3; transform: scale(0.85); } }
  
  .callbody { flex: 1; display: flex; background: #0f1117; color: #fff; }
  .callgrid {
    flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 10px; padding: 14px;
  }
  .ctile {
    background: #1a1d27; border-radius: 10px;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    position: relative; border: 2px solid transparent;
  }
  .ctile.speaking { border-color: var(--hotpink); }
  .cini { width: 44px; height: 44px; border-radius: 50%; display: grid; place-items: center; font-size: 18px; font-weight: 800; color: #fff; }
  .cname { position: absolute; bottom: 8px; left: 10px; font-size: 11px; font-weight: 600; opacity: 0.8; }
  
  .callrail {
    width: 250px; background: #141720; border-left: 1px solid rgba(255, 255, 255, 0.08);
    padding: 14px; display: flex; flex-direction: column; gap: 10px; overflow-y: auto;
  }
  .railhead { font-size: 10px; color: var(--hotpink); margin-bottom: 2px; }
  .railturn { font-size: 12.5px; line-height: 1.45; color: #e5e7eb; }

  /* Dock */
  .dock {
    position: absolute;
    bottom: 10px; left: 50%;
    transform: translateX(-50%);
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(14px);
    border: 1px solid rgba(0, 0, 0, 0.1);
    border-radius: 18px;
    padding: 6px 12px;
    display: flex; gap: 8px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
    z-index: 25;
  }
  :root[data-theme="dark"] .dock {
    background: rgba(24, 26, 36, 0.88);
    border-color: rgba(255, 255, 255, 0.12);
  }
  .ditem {
    display: flex; flex-direction: column; align-items: center; gap: 4px;
    padding: 4px; border-radius: 8px; cursor: pointer;
    transition: transform 0.15s var(--spring);
  }
  .ditem:hover { transform: translateY(-4px) scale(1.12); }
  .dico { width: 34px; height: 34px; display: grid; place-items: center; border-radius: 8px; }
  .dico :global(svg) { width: 28px; height: 28px; border-radius: 6px; }
  .dtyp { color: var(--hotpink); }
  .ddot { width: 4px; height: 4px; border-radius: 50%; background: transparent; }
  .ditem.on .ddot { background: var(--hotpink); }

  /* Mac Base */
  .mac-base {
    height: 16px;
    background: #2b2e38;
    border-radius: 0 0 20px 20px;
    display: flex; justify-content: center;
  }
  .chin {
    width: 140px; height: 6px; background: #1e2028; border-radius: 0 0 8px 8px;
  }

  @media (max-width: 900px) {
    .vprops { grid-template-columns: 1fr 1fr; }
    .callrail { display: none; }
  }
  @media (max-width: 600px) {
    .vprops { grid-template-columns: 1fr; }
    .dock { display: none; }
  }
</style>
