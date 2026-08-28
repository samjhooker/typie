<script>
  import { reveal } from './reveal.js'
  import { nsSvg } from './svgid.js'
  import Robot from './Robot.svelte'
  import { Mic, PhoneCall, FileAudio, StickyNote, Wifi, WifiOff } from 'lucide-svelte'
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

  /* ── timing engine per tab ── */
  const STEPS = {
    dictate:   [300, 1000, 2400, 400, 1000, 2800],
    capture:   [400, 1200, 1800, 1800, 1400, 2600],
    notes:     [300, 600, 1200, 1800, 2600],
    summarize: [300, 600, 2200, 2800],
  }

  let step = $state(0)

  $effect(() => {
    const times = STEPS[active]
    step = 0
    let idx = 0
    let t1
    const advance = () => {
      idx += 1
      if (idx >= times.length) {
        step = times.length - 1
        return
      }
      step = idx
      t1 = setTimeout(advance, times[idx])
    }
    t1 = setTimeout(advance, times[0])
    return () => clearTimeout(t1)
  })

  function selectFeature(id) {
    active = id
    if (id === 'dictate') dapp = 'slack'
  }

  /* ── notch island state ── */
  let notchState = $derived.by(() => {
    if (active === 'dictate') {
      if (step === 1 || step === 4) return 'listening'
      if (step >= 2) return 'donems'
      return 'idle'
    }
    if (active === 'notes') {
      if (step === 1) return 'menu'
      if (step === 2) return 'noterec'
      if (step === 3) return 'processing'
      return 'idle'
    }
    if (active === 'capture') {
      if (step === 1) return 'menu'
      if (step >= 2 && step <= 3) return 'recdot'
      if (step === 4) return 'processing'
      return 'idle'
    }
    if (active === 'summarize') {
      if (step === 1 || step === 2) return 'processing'
      if (step >= 3) return 'donems'
      return 'idle'
    }
    return 'idle'
  })

  /* ── dictate: target apps & text stream ── */
  const DICTATED = "pricing page is sam's, video is mine — shipping friday"
  const typedNow = $derived(
    active === 'dictate' && step >= 2 ? DICTATED : ''
  )
  const listeningNow = $derived(active === 'dictate' && (step === 1 || step === 4))

  const APPS = [
    { id: 'slack', label: 'Slack',       brand: svgOf(slackIco),  title: 'Slack — #product' },
    { id: 'mail',  label: 'Mail',        brand: MAIL_SVG,        title: 'Mail — Inbox' },
    { id: 'docs',  label: 'Google Docs', brand: svgOf(gdocs),    title: 'Q3 Roadmap — Google Docs' },
    { id: 'imsg',  label: 'Messages',    brand: svgOf(imessage), title: 'Messages — Team Sync' },
  ]
  let dapp = $state('slack')
  const appMeta = $derived(APPS.find(a => a.id === dapp) || APPS[0])

  /* ── notes extra ── */
  const NOTES_EXTRA = {
    id: 'x7', text: "Launch day idea — record the demo call with Typie instead of typing notes manually.",
    pinned: true, date: 'just now', dur: '6s',
  }
  const notesExtra = $derived(active === 'notes' && step >= 4 ? NOTES_EXTRA : null)

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
  const speaker = $derived(step >= 2 && step <= 4 ? ((step - 2) % 2 === 0 ? 0 : 2) : -1)
  const callTurns = $derived(active === 'capture' && step >= 2 ? CAP_TURNS.slice(0, Math.min(step, 4)) : [])

  const menubarApp = $derived.by(() => {
    if (active === 'dictate') return appMeta.label
    if (active === 'capture' && step < 5) return 'Zoom'
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

          <!-- Hardware Notch & Expanding Typie Island -->
          <div
            class="notch"
            class:wide={notchState !== 'idle'}
            class:menuopen={notchState === 'menu'}
          >
            <div class="nrow">
              <!-- Animated Robot Mascot -->
              <span class="nbot">
                <Robot size={22} mood={notchState === 'listening' ? 'listening' : notchState === 'donems' ? 'done' : 'idle'} />
              </span>

              <div class="nright">
                {#if notchState === 'idle'}
                  <span class="nplus" aria-hidden="true">
                    <svg viewBox="0 0 12 12" width="11" height="11"><path d="M6 1.5v9M1.5 6h9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
                  </span>
                {:else if notchState === 'listening'}
                  <div class="nwave" aria-hidden="true">
                    <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
                  </div>
                {:else if notchState === 'donems'}
                  <svg viewBox="0 0 14 14" width="13" height="13" class="chk" aria-hidden="true">
                    <path d="M2.5 7.5l3 3 6-7" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  <span class="nms mono">80ms</span>
                {:else if notchState === 'noterec'}
                  <span class="npulse" aria-hidden="true">
                    <svg viewBox="0 0 16 16" width="14" height="14"><path d="M3 2h7l3 3v9H3z" fill="none" stroke="var(--hotpink)" stroke-width="1.8"/><path d="M10 2v3h3" fill="none" stroke="var(--hotpink)" stroke-width="1.8"/></svg>
                  </span>
                  <span class="nlab mono">recording…</span>
                {:else if notchState === 'recdot'}
                  <span class="recring" aria-hidden="true"><i></i></span>
                  <span class="nlab mono">REC 0:12</span>
                {:else if notchState === 'processing'}
                  <span class="ndots" aria-hidden="true"><i></i><i></i><i></i></span>
                  <span class="nproc mono">writing it down…</span>
                {/if}
              </div>
            </div>
          </div>

          <!-- The Screen Content -->
          <div class="screen-viewport">
            
            <!-- SCENE 1: DICTATE INTO ANY APP -->
            {#if active === 'dictate'}
              <div class="screen-view">
                {#key dapp}
                  <div class="win appwin">
                    <header class="wintitle">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="wintxt">{appMeta.title}</span>
                      <span class="winmeta mono">{typedNow ? 'transcribed · 80ms' : 'offline'}</span>
                    </header>
                    <div class="appbody">
                      {#if dapp === 'slack'}
                        <AppSlack typed={typedNow} listening={listeningNow} />
                      {:else if dapp === 'mail'}
                        <AppMail typed={typedNow} listening={listeningNow} />
                      {:else if dapp === 'docs'}
                        <AppDocs typed={typedNow} listening={listeningNow} />
                      {:else}
                        <AppMessages typed={typedNow} listening={listeningNow} />
                      {/if}
                    </div>
                  </div>
                {/key}

                <div class="keyovl" class:holding={listeningNow} aria-hidden="true">
                  <span class="kicon">⌥</span>
                  <span class="klabel">{listeningNow ? 'holding option…' : 'hold option'}</span>
                </div>
              </div>

            <!-- SCENE 2: MEETING CAPTURE (NO BOTS) -->
            {:else if active === 'capture'}
              <div class="screen-view">
                {#if step < 5}
                  <div class="win callwin">
                    <header class="callbar">
                      <span class="dots"><i></i><i></i><i></i></span>
                      <span class="calltitle">Launch Sync — Live Call</span>
                      <span class="cspace"></span>
                      <span class="reccall mono" class:on={step >= 2}>
                        <i></i> {step >= 2 ? 'REC 0:12' : 'ready'}
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

                      {#if step >= 2}
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

            <!-- SCENE 4: AUDIO FILE STUDIO -->
            {:else}
              <div class="screen-view">
                <div class="win typwin">
                  <header class="wintitle">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span class="wintxt">Typie — File Transcription</span>
                    <span class="winmeta mono">parakeet on-device</span>
                  </header>
                  <div class="realslot">
                    <DemoTranscriptDetail />
                  </div>
                </div>
              </div>
            {/if}

          </div>

          <!-- Bottom App Dock for Switching Apps -->
          <nav class="dock" aria-label="Target applications">
            {#each APPS as a}
              <button
                class="ditem"
                class:on={active === 'dictate' && dapp === a.id}
                onclick={() => { active = 'dictate'; dapp = a.id }}
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
  .hero { padding: clamp(100px, 12vh, 128px) 0 clamp(60px, 8vh, 84px); }

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

  /* Hardware Notch & Island */
  .notch {
    position: absolute;
    top: 0; left: 50%;
    transform: translateX(-50%);
    background: #000000;
    color: #ffffff;
    border-radius: 0 0 16px 16px;
    padding: 4px 14px 6px;
    z-index: 30;
    transition: width 0.35s var(--spring), padding 0.35s var(--spring), box-shadow 0.35s ease;
    width: 140px;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.35);
  }
  .notch.wide { width: 260px; padding-inline: 18px; }
  .nrow { display: flex; align-items: center; justify-content: space-between; height: 26px; }
  .nbot { display: grid; place-items: center; }
  .nright { display: flex; align-items: center; gap: 8px; font-size: 12px; }
  .nplus { opacity: 0.6; }
  .chk { color: #4ade80; }
  .nms { color: #4ade80; font-weight: 700; font-size: 11px; }
  .nlab { font-size: 10.5px; color: var(--hotpink); letter-spacing: 0.04em; }
  .nwave { display: flex; align-items: center; gap: 2px; height: 14px; }
  .nwave i { width: 2.5px; border-radius: 2px; background: var(--hotpink); height: 35%; animation: nw 0.6s ease-in-out infinite alternate; }
  .nwave i:nth-child(2) { animation-delay: 0.1s; height: 75%; }
  .nwave i:nth-child(3) { animation-delay: 0.2s; height: 100%; }
  .nwave i:nth-child(4) { animation-delay: 0.3s; height: 60%; }
  .nwave i:nth-child(5) { animation-delay: 0.4s; height: 90%; }
  .nwave i:nth-child(6) { animation-delay: 0.5s; height: 45%; }
  .nwave i:nth-child(7) { animation-delay: 0.6s; height: 80%; }
  @keyframes nw { to { height: 15%; } }

  .ndots { display: flex; gap: 4px; }
  .ndots i { width: 4px; height: 4px; border-radius: 50%; background: var(--hotpink); animation: ndot 0.8s infinite alternate; }
  .ndots i:nth-child(2) { animation-delay: 0.2s; }
  .ndots i:nth-child(3) { animation-delay: 0.4s; }
  @keyframes ndot { to { opacity: 0.2; transform: scale(0.7); } }
  .nproc { font-size: 10.5px; color: #a1a1aa; }

  .recring { display: inline-grid; place-items: center; width: 10px; height: 10px; }
  .recring i { width: 8px; height: 8px; border-radius: 50%; background: #ef4444; animation: recpulse 1.2s infinite; }
  @keyframes recpulse { 50% { opacity: 0.3; transform: scale(0.85); } }

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

  /* Dictation Option Key Overlay */
  .keyovl {
    position: absolute;
    bottom: 24px; left: 50%;
    transform: translateX(-50%);
    background: rgba(15, 17, 24, 0.88);
    backdrop-filter: blur(10px);
    color: #fff;
    border-radius: 999px;
    padding: 8px 18px;
    display: inline-flex; align-items: center; gap: 10px;
    font-size: 13px; font-weight: 600;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(255, 255, 255, 0.15);
    transition: transform 0.2s var(--spring);
  }
  .keyovl.holding {
    border-color: var(--hotpink);
    transform: translateX(-50%) scale(1.04);
    box-shadow: 0 8px 28px var(--hotpink-glow);
  }
  .kicon {
    font-size: 16px; font-weight: 800; color: var(--hotpink);
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
