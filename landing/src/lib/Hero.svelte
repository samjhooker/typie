<script>
  import { reveal } from './reveal.js'
  import { nsSvg } from './svgid.js'
  import Robot from './Robot.svelte'
  import { Mic, PhoneCall, FileAudio, StickyNote } from 'lucide-svelte'
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

  const features = [
    {
      id: 'dictate',
      icon: Mic,
      label: 'Dictate anywhere',
      desc: 'Hold ⌥, speak, release. Real keystrokes land in any app.',
    },
    {
      id: 'capture',
      icon: PhoneCall,
      label: 'Capture any call',
      desc: 'No bot joins. System audio becomes a transcript with speakers.',
    },
    {
      id: 'summarize',
      icon: FileAudio,
      label: 'Transcribe & summarize',
      desc: 'Drop any audio file. Full transcript, summarized on this Mac.',
    },
    {
      id: 'notes',
      icon: StickyNote,
      label: 'Voice notes',
      desc: 'Say the thought. It lands as a searchable sticky note.',
    },
  ]

  const TAB_COLORS = ['#fc5681', '#6f8ffb', '#c88cfd', '#0ea86b']

  /* ── timeline engine ── each number = ms to stay in that step, plays ONCE then holds. Two clean hold→paste cycles for dictate (Slack→Docs) so the paste is readable, then long hold. Front dwells are deliberately short (240-280ms) to kill the "millennial pause" on drag/plus actions. */
  const STEPS = {
    dictate:   [280, 880, 2200, 320, 880, 2600, 2800],
    capture:   [520, 900, 1700, 1700, 1700, 1100, 2600, 2000],
    summarize: [240, 520, 2200, 2800, 1800],
    notes:     [260, 520, 1100, 1600, 2600],
  }
  let step = $state(0)
  let cursorClick = $state(false)
  let cursorVisible = $state(true)
  let lastDapp = $state('slack')
  // grand tour: on first load, walk through each feature once, then stop and let user explore
  let tourDone = $state(false)
  let userInteracted = $state(false)
  const TOUR_ORDER = ['dictate', 'capture', 'summarize', 'notes']
  let tourIdx = $state(0)
  $effect(() => {
    const times = STEPS[active]
    // when dictate is active, changing dapp via dock should restart the hold→paste demo so each app shows the pop
    if (active === 'dictate') dapp
    step = 0
    cursorVisible = active !== 'dictate'
    cursorClick = false
    let idx = 0
    let t1, t2
    const advance = () => {
      idx += 1
      if (idx >= times.length) {
        // hold at final frame — enable scrolling / inspection
        step = times.length - 1
        cursorClick = false
        // hide cursor after a beat
        t2 = setTimeout(() => { cursorVisible = false }, 700)
        // if this is the initial tour and user hasn't taken over, auto-advance to next feature
        if (!userInteracted && !tourDone) {
          const curTourPos = TOUR_ORDER.indexOf(active)
          if (curTourPos !== -1 && curTourPos < TOUR_ORDER.length - 1) {
            // dictate's final paste holds 2800ms already — shorten the idle gap between features for pace
            const gap = active === 'dictate' ? 1100 : active === 'capture' ? 1200 : 900
            t2 = setTimeout(() => {
              tourIdx = curTourPos + 1
              active = TOUR_ORDER[tourIdx]
            }, gap)
          } else if (curTourPos === TOUR_ORDER.length - 1) {
            tourDone = true
          }
        }
        return
      }
      step = idx
      // dictate: Slack paste (step 2) holds readable, then snap-swap to Docs during the 320ms transition (step 3).
      // Only for the auto tour — when user picks an app via dock, stay on their choice so each page's pop is visible.
      if (active === 'dictate' && idx === 3 && !userInteracted) {
        dapp = APPS[2].id // docs — proves "anywhere" without strobing
      } else if (active === 'dictate' && idx === 0 && !userInteracted) {
        dapp = APPS[0].id // reset to Slack at tour start — avoids lastDapp flicker
      }
      // cursor click pulse — not for dictate (per request)
      if (active !== 'dictate') {
        cursorClick = true
        clearTimeout(t1)
        t1 = setTimeout(() => { cursorClick = false }, 420)
      }
      lastDapp = dapp
      t1 = setTimeout(advance, times[idx])
    }
    // stagger the first tick
    t1 = setTimeout(advance, times[0])
    return () => { clearTimeout(t1); clearTimeout(t2) }
  })

  function selectFeature(id) {
    userInteracted = true
    tourDone = true
    active = id
    // reset dictate demo app
    if (id === 'dictate') dapp = 'slack'
  }

  /* ── notch state — mirrors the real NotchView right wing (7-step dictate: 0 idle,1 listen,2 done,3 swap-idle,4 listen,5 done,6 done-hold) ── */
  let notchState = $derived.by(() => {
    if (active === 'dictate') {
      if (step === 1 || step === 4) return 'listening'
      if (step === 2 || step === 5 || step === 6) return 'donems'
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
      if (step >= 2 && step <= 4) return 'recdot'
      if (step === 5) return 'processing'
      return 'idle'
    }
    if (active === 'summarize') {
      if (step === 1 || step === 2) return 'processing'
      if (step === 3 || step === 4) return 'donems'
      return 'idle'
    }
    return 'idle'
  })

  /* ── dictated text lands in each app's box at the paste frames — never live, never streaming. Keep visible through final hold so reading isn't rushed. ── */
  const DICTATED = "pricing page is sam's, video is mine — shipping friday"
  const typedNow = $derived(
    active === 'dictate' && (step === 2 || step === 5 || step === 6) ? DICTATED : ''
  )
  const listeningNow = $derived(active === 'dictate' && (step === 1 || step === 4))

  /* ── dictate: which app receives the words (dock switches it) ── */
  const APPS = [
    { id: 'slack', label: 'Slack',       brand: svgOf(slackIco),  title: 'Slack — #launch' },
    { id: 'mail',  label: 'Mail',        brand: MAIL_SVG,        title: 'Mail — Inbox' },
    { id: 'docs',  label: 'Google Docs', brand: svgOf(gdocs),    title: 'Launch plan — Google Docs' },
    { id: 'imsg',  label: 'Messages',    brand: svgOf(imessage), title: 'Messages — Maya Chen' },
  ]
  let dapp = $state('slack')
  const appMeta = $derived(APPS.find(a => a.id === dapp))

  /* ── notes: the fresh note that lands on the wall (real Notes pane) ── */
  const NOTES_EXTRA = {
    id: 'x7', text: "launch day idea — record the demo instead of typing it",
    pinned: true, date: 'just now', dur: '6s',
  }
  const notesExtra = $derived(active === 'notes' && step >= 4 ? NOTES_EXTRA : null)

  /* ── capture: the call being recorded ── */
  const CAP_TURNS = [
    { name:'Maya', time:'02:14', text:'and the launch checklist is basically done?' },
    { name:'Sam', time:'02:18', text:'two items left — pricing page and the demo video.' },
    { name:'Maya', time:'02:24', text:'perfect. i can take the video this afternoon.' },
    { name:'Sam', time:'02:31', text:"i'll handle the pricing page then." },
  ]
  const SP_COLORS = ['#fc5681','#6f8ffb']
  function spColor(i){ return SP_COLORS[i % SP_COLORS.length] }

  const CALL_PEOPLE = [
    { n: 'Maya', c: '#a48fff' },
    { n: 'You',  c: '#3aa76d' },
    { n: 'Sam',  c: '#ff9f68' },
    { n: 'Alex', c: '#5cc5ff' },
  ]
  /* who is talking during the recorded steps (0=Maya, 2=Sam tiles) */
  const speaker = $derived(
    step >= 2 && step <= 4 ? ((step - 2) % 2 === 0 ? 0 : 2) : -1
  )
  const callTurns = $derived(
    active === 'capture' && step >= 2 && step <= 5
      ? CAP_TURNS.slice(0, Math.min(step - 1, 4))
      : []
  )

  /* ── menu bar: the frontmost app ── */
  const menubarApp = $derived.by(() => {
    if (active === 'dictate') return appMeta.label
    if (active === 'capture' && step < 6) return 'Launch sync'
    return 'typie'
  })

  /* ── auto-play cursor: where it clicks on the screen per scene/step ── */
  const cursorPos = $derived.by(() => {
    if (active === 'dictate') {
      return { x: 50, y: 50 } // no cursor for dictate (per request)
    }
    if (active === 'capture') {
      if (step === 0) return { x: 58, y: 7 } // → notch [+] 
      if (step === 1) return { x: 50, y: 13 } // → "record call" in notch menu
      if (step >= 2 && step <= 4) return { x: 72, y: 46 } // transcript rail while holding ⌥
      if (step === 5) return { x: 50, y: 52 } // stop → processing overlay
      return { x: 50, y: 50 }
    }
    if (active === 'summarize') {
      if (step === 0) return { x: 50, y: 38 } // drag start — file chip
      if (step === 1) return { x: 50, y: 52 } // drop zone (drag & drop, no notch)
      if (step === 2) return { x: 50, y: 74 } // progress bar
      return { x: 50, y: 50 }
    }
    // notes — plus → quick note
    if (step === 0) return { x: 58, y: 7 } // → notch [+] 
    if (step === 1) return { x: 42, y: 13 } // → "quick note" in notch menu (left item)
    if (step >= 4) return { x: 34, y: 38 } // fresh sticky on wall
    return { x: 50, y: 58 } // recording (hold)
  })
  const cursorX = $derived(cursorPos.x)
  const cursorY = $derived(cursorPos.y)
  const isHolding = $derived(
    (active === 'dictate' && (step === 1 || step === 4)) ||
    (active === 'notes' && step === 2) ||
    (active === 'capture' && step >= 2 && step <= 4)
  )
  const isNotchTarget = $derived(
    (active === 'capture' && (step === 0 || step === 1)) ||
    (active === 'notes' && (step === 0 || step === 1))
  )

  // when the fresh voice note lands, scroll the notes pane to top so it's visible
  $effect(() => {
    if (active === 'notes' && step >= 4) {
      // microtask after DOM mounts the extra note
      queueMicrotask(() => {
        const el = document.querySelector('.hero .shellslot.scrollable')
        if (el) el.scrollTo({ top: 0, behavior: 'smooth' })
        const content = document.querySelector('.hero .shellslot.scrollable .content, .hero .shellslot.scrollable .wrap')
        if (content) content.scrollIntoView({ behavior: 'smooth', block: 'start' })
      })
    }
  })


</script>

<section class="hero" id="top">
  <div class="container">
    <div class="hero-top" use:reveal>
      <h1>
        It types what you say.<br />
        <em>Then it keeps going.</em>
      </h1>
      <p class="sub">
        Hold ⌥, talk, done. Voice notes, call transcripts and summaries — all on this Mac.
      </p>
      <div class="actions">
        <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-black">
          <svg viewBox="0 0 384 512" width="15" height="15" fill="currentColor" aria-hidden="true"><path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
          Download for Mac — free
        </a>
        <a href="https://github.com/samjhooker/typie" class="quietlink">View on GitHub</a>
      </div>
      <p class="trust mono" use:reveal={{ delay: 100 }}>100% free · 100% offline · no account · open source</p>
    </div>

    <!-- Four value props — each one drives the Mac -->
    <div class="vprops" role="tablist" aria-label="Typie features" use:reveal>
      {#each features as f, i (f.id)}
        {@const Icon = f.icon}
        <button
          class="vprop"
          class:active={active === f.id}
          style="--tabc:{TAB_COLORS[i]}"
          role="tab"
          aria-selected={active === f.id}
          onclick={() => selectFeature(f.id)}
        >
          <span class="vico" aria-hidden="true"><Icon size={19} strokeWidth={1.8} /></span>
          <span class="vbody">
            <span class="vlabel">{f.label}</span>
            <span class="vdesc">{f.desc}</span>
          </span>
        </button>
      {/each}
    </div>
    <p class="vphint mono" use:reveal={{ delay: 80 }}>click a card — the mac plays it live</p>

    <!-- The Mac — the whole pitch -->
    <div class="stage-wrap" use:reveal>

      <!-- comically large cursor — smooth glide, click pulse, hides at end -->
      {#if cursorVisible}
        <div class="big-cursor" class:clicking={cursorClick} style="top:{cursorY}%; left:{cursorX}%"><i></i></div>
      {/if}

      <div class="mac">
        <div class="lid">
          <div class="wallpaper" aria-hidden="true">
            <span class="streak s1"></span><span class="streak s2"></span><span class="streak s3"></span>
          </div>

          <!-- Menu bar -->
          <div class="menubar" aria-hidden="true">
            <svg class="apple" viewBox="0 0 384 512"><path fill="currentColor" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
            <span class="mapp">{menubarApp}</span>
            <span class="mi">File</span>
            <span class="mi">Edit</span>
            <span class="mi">View</span>
            <span class="mspace"></span>
            <span class="mnet">NET 0 B</span>
            <svg class="sicn" viewBox="0 0 16 12" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"><path d="M1.5 4.4a10 10 0 0 1 13 0"/><path d="M3.9 7a6.4 6.4 0 0 1 8.2 0"/><circle cx="8" cy="9.9" r="1.15" fill="currentColor" stroke="none"/></svg>
            <svg class="sicn" viewBox="0 0 25 12"><rect x="0.5" y="0.5" width="21" height="11" rx="3.2" fill="none" stroke="currentColor"/><rect x="2.5" y="2.5" width="14" height="7" rx="1.6" fill="currentColor"/><path d="M23 4v4a2.2 2.2 0 0 0 0-4z" fill="currentColor"/></svg>
            <span class="mclock mono">9:41 AM</span>
          </div>

          <!-- Notch — mirrors the real NotchView island: robot left, + right, even at idle -->
          <div class="notch" class:wide={notchState !== 'idle'} class:menuopen={notchState === 'menu'} class:targeted={isNotchTarget}>
            <div class="nrow">
              <svg class="nbot" viewBox="0 0 24 16" width="24" height="16" aria-hidden="true"><path fill="#fc5681" d="M6 0h2v2H6V0ZM10 0h2v2h-2V0ZM4 2h2v2H4V2ZM12 2h2v2h-2V2ZM2 4h16v8H2V4Zm4 2h2v4H6V6Zm6 0h2v4h-2V6Z"/></svg>

              <div class="nright">
                {#if notchState === 'idle'}
                  <span class="nplus" aria-hidden="true"><svg viewBox="0 0 12 12" width="10" height="10"><path d="M6 1.5v9M1.5 6h9" stroke="rgba(255,255,255,.92)" stroke-width="1.6" stroke-linecap="round"/></svg></span>
                {:else if notchState === 'menu'}
                  <span class="nclose" aria-hidden="true"><svg viewBox="0 0 12 12" width="9" height="9"><path d="M2 2l8 8M10 2l-8 8" stroke="rgba(255,255,255,.92)" stroke-width="1.6" stroke-linecap="round"/></svg></span>
                {:else if notchState === 'listening'}
                  <div class="nwave" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><i></i><i></i></div>
                {:else if notchState === 'transcribing'}
                  <span class="ndots" aria-hidden="true"><i></i><i></i><i></i></span>
                {:else if notchState === 'donems'}
                  <svg viewBox="0 0 14 14" width="13" height="13" aria-hidden="true"><path d="M2.5 7.5l3 3 6-7" fill="none" stroke="#6ee89a" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                  <span class="nms mono">84ms</span>
                {:else if notchState === 'noterec'}
                  <span class="npulse" aria-hidden="true"><svg viewBox="0 0 16 16" width="15" height="15"><path d="M3 2h7l3 3v9H3z" fill="none" stroke="#fc5681" stroke-width="1.7"/><path d="M10 2v3h3" fill="none" stroke="#fc5681" stroke-width="1.7"/></svg></span>
                  <span class="nlab mono">recording…</span>
                {:else if notchState === 'recdot'}
                  <span class="recring" aria-hidden="true"><i></i></span>
                  <span class="nlab mono">0:12</span>
                {:else if notchState === 'processing'}
                  <span class="ndots" aria-hidden="true"><i></i><i></i><i></i></span>
                  <span class="nproc mono">writing it down…</span>
                {/if}
              </div>
            </div>

            {#if notchState === 'menu'}
              <div class="nmenu">
                <span class="nact" class:hl={active === 'notes'}>
                  <svg viewBox="0 0 16 16" width="19" height="19" aria-hidden="true"><path d="M3 2h7l3 3v9H3z" fill="none" stroke="#fc5681" stroke-width="1.5"/><path d="M10 2v3h3" fill="none" stroke="#fc5681" stroke-width="1.5"/></svg>
                  <span>quick note</span>
                </span>
                <span class="ndiv" aria-hidden="true"></span>
                <span class="nact" class:hl={active === 'capture'}>
                  <svg viewBox="0 0 16 16" width="19" height="19" aria-hidden="true"><rect x="2.5" y="2.5" width="11" height="11" fill="none" stroke="#6ee89a" stroke-width="1.5"/><rect x="6" y="6" width="4" height="4" fill="#6ee89a"/></svg>
                  <span>record call</span>
                </span>
                <span class="ndiv" aria-hidden="true"></span>
                <span class="nact">
                  <svg viewBox="0 0 16 16" width="19" height="19" aria-hidden="true"><path d="M4 1.5h5.5L13 5v9.5H4z" fill="none" stroke="#c88cfd" stroke-width="1.5"/><path d="M6 7.5h4M6 10h4M6 12.5h2.5" stroke="#c88cfd" stroke-width="1.4" stroke-linecap="round"/></svg>
                  <span>upload file</span>
                </span>
              </div>
            {/if}
          </div>

          <!-- ══ SCENE: dictate into any app — the real app UI ══ -->
          {#if active === 'dictate'}
            <div class="screen">
              {#key dapp}
                <div class="win">
                  <header class="wintitle">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span>{appMeta.title}</span>
                    <span class="off mono">{typedNow ? 'saved · offline' : 'offline'}</span>
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
              <div class="keyovl" class:down={isHolding} class:holding={isHolding} aria-hidden="true">
                <span class="kicon">⌥</span>
                <span class="klabel">{isHolding ? 'holding…' : 'hold ⌥'}</span>
              </div>
            </div>

          <!-- ══ SCENE: the real app — voice notes on the wall ══ -->
          {:else if active === 'notes'}
            <div class="screen scrollable">
              <div class="win typwin">
                <header class="wintitle">
                  <span class="dots"><i></i><i></i><i></i></span>
                  <span>typie</span>
                  <span class="off mono">offline</span>
                </header>
                <div class="shellslot scrollable">
                  <DemoShell startPane="notes" notesExtra={notesExtra} locked={false} />
                </div>
              </div>
              <div class="keyovl" class:down={isHolding} class:holding={isHolding} aria-hidden="true">
                <span class="kicon">⌥</span>
                <span class="klabel">{isHolding ? 'holding…' : 'hold ⌥'}</span>
              </div>
            </div>

          <!-- ══ SCENE: capture any call — in the call, then it's typed ══ -->
          {:else if active === 'capture'}
            <div class="screen scrollable">
              {#if step < 6}
                <!-- the call, recorded off system audio -->
                <div class="win callwin">
                  <header class="callbar">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span class="calltitle">Launch sync — team call</span>
                    <span class="cspace"></span>
                    {#if step >= 2 && step <= 4}
                      <span class="reccall mono on"><i></i>REC 0:12</span>
                      <span class="stopbtn" aria-hidden="true">■ stop</span>
                    {:else if step === 5}
                      <span class="reccall saved mono">✓ saved to library</span>
                    {/if}
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
                      <aside class="callrail" class:dim={step === 5}>
                        <p class="railhead mono">live transcript</p>
                        {#each callTurns as t, i}
                          <p class="railturn" style="animation-delay:{i * 120}ms"><b style="color:{spColor(i % 2)}">{t.name.toLowerCase()}</b> {t.text}</p>
                        {/each}
                      </aside>
                    {/if}
                  </div>

                  <footer class="callctl">
                    <span class="cbtn"><svg viewBox="0 0 24 24" width="13" height="13" fill="none" stroke="rgba(255,255,255,.85)" stroke-width="2" stroke-linecap="round" aria-hidden="true"><rect x="9" y="2.5" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3.5"/></svg></span>
                    <span class="cbtn"><svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="rgba(255,255,255,.85)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="6" width="13" height="12" rx="2.5"/><path d="M15 10.5l7-3.5v10l-7-3.5"/></svg></span>
                    <span class="cbtn rec" class:on={step >= 2 && step <= 4}><svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="6" y="6" width="12" height="12" rx="2.5"/></svg></span>
                    <span class="cbtn leave">Leave</span>
                  </footer>

                  {#if step === 5}
                    <div class="callsave">
                      <span class="savespin"></span>
                      <p>stopping recording — writing it down…</p>
                      <p class="mono savedim">split by speaker · timed · summarized on this mac</p>
                    </div>
                  {/if}
                </div>
              {:else}
                <!-- the call, already written down — the real transcript view -->
                <div class="win typwin">
                  <header class="wintitle">
                    <span class="dots"><i></i><i></i><i></i></span>
                    <span>typie — call capture</span>
                    <span class="off mono">12:04 · 2 speakers</span>
                  </header>
                  <div class="realslot scrollable">
                    <DemoTranscriptDetail />
                  </div>
                </div>
              {/if}
            </div>

          <!-- ══ SCENE: drop a file — the real transcript view — scrollable always so you can explore the transcript -->
          {:else}
            <div class="screen scrollable">
              <div class="win typwin">
                <header class="wintitle"><span class="dots"><i></i><i></i><i></i></span><span>typie — library</span><span class="off mono">offline</span></header>

                {#if step <= 2}
                  <div class="droparea">
                    <div class="filechip" class:dropped={step >= 1}>
                      <span class="fico mono">m4a</span>
                      <div><strong>Beta sync — Friday</strong><span class="mono">12:04 · 2 speakers</span></div>
                    </div>
                    <div class="dzbox" class:hover={step >= 1}>
                      <p class="dz-h">drop anything</p>
                      <p class="mono dz-s">mp3 · m4a · wav · mp4</p>
                      {#if step === 2}
                        <div class="prog"><i></i></div>
                        <p class="mono dz-s translabel">on-device model — nothing uploaded</p>
                      {/if}
                    </div>
                  </div>
                {:else}
                  <div class="realslot scrollable">
                    <DemoTranscriptDetail />
                  </div>
                {/if}
              </div>
            </div>
          {/if}
          <!-- dock inside lid — actually inside the screen, liquid glass -->
          <nav class="dock" aria-label="on-screen apps">
            {#each APPS as a}
              <button
                class="ditem"
                class:on={active === 'dictate' && dapp === a.id}
                onclick={() => { userInteracted = true; tourDone = true; active = 'dictate'; dapp = a.id }}
                aria-label={a.label}
                title={a.label}
              >
                <span class="dico">{@html nsSvg(a.brand, 'dk' + a.id)}</span>
                <i class="ddot" aria-hidden="true"></i>
              </button>
            {/each}
            <button
              class="ditem"
              class:on={active !== 'dictate'}
              onclick={() => selectFeature('notes')}
              aria-label="typie"
              title="typie"
            >
              <span class="dico dtyp"><Robot size={22} mood="idle" /></span>
              <i class="ddot" aria-hidden="true"></i>
            </button>
          </nav>
        </div>
        <div class="base" aria-hidden="true"><i class="chin"></i></div>
      </div>

      </div>
  </div>
</section>

<style>
  /* impeccable-disable bounce-easing, layout-transition — Hero notch uses Theme.springy intentionally; width anim is island shape (app does same) */
  /* ── Hero — headline, one ask, then the Mac. Nothing else. ── */
  .hero { padding: clamp(92px, 11vh, 118px) 0 74px; }

  .hero-top {
    display:flex; flex-direction:column; align-items:center; text-align:center; gap:16px;
    max-width:760px; margin:0 auto;
  }
  h1 { font-size: clamp(42px, 5.4vw, 68px); font-weight:800; letter-spacing:-0.05em; line-height:0.94; text-wrap:balance; }
  h1 em { font-family: var(--serif); font-weight:600; font-style:italic; letter-spacing:-0.03em; color:var(--hotpink); }
  .sub { font-family: var(--sans); font-size:16px; line-height:1.6; color:var(--text-2); max-width:46ch; font-weight:500; }
  .actions { display:flex; align-items:center; justify-content:center; flex-wrap:wrap; gap:18px; margin-top:2px; }
  .quietlink {
    font-size:13.5px; font-weight:600; color:var(--text-3);
    transition: color .2s ease;
  }
  .quietlink:hover { color:var(--ink); }
  .trust { text-transform:none; letter-spacing:.05em; opacity:.62; margin-top:-6px; }

  /* ── Four value props — cards that drive the Mac ── */
  .vprops {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin: 32px auto 0;
    max-width: 1080px;
    text-align: left;
  }
  .vprop {
    display: flex; gap: 12px; align-items: flex-start;
    padding: 15px 16px 14px;
    background: #fff;
    border: 1px solid var(--line);
    border-radius: 16px;
    cursor: pointer;
    transition: border-color .22s var(--ease-out), transform .22s var(--ease-out), box-shadow .22s var(--ease-out), background .22s ease;
  }
  .vprop:hover {
    border-color: var(--line-strong);
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(19,23,34,.07);
  }
  .vprop.active {
    border-color: var(--tabc);
    background: color-mix(in srgb, var(--tabc) 5%, #fff);
    box-shadow: 0 10px 26px color-mix(in srgb, var(--tabc) 16%, transparent);
  }
  .vico {
    flex: none;
    width: 36px; height: 36px; border-radius: 11px;
    display: grid; place-items: center;
    color: var(--text-3);
    background: var(--surface-2);
    transition: color .22s ease, background .22s ease;
  }
  .vprop.active .vico, .vprop:hover .vico {
    color: var(--tabc);
    background: color-mix(in srgb, var(--tabc) 12%, #fff);
  }
  .vbody { display: flex; flex-direction: column; gap: 3px; min-width: 0; }
  .vlabel { font-size: 13.5px; font-weight: 700; letter-spacing: -0.01em; color: var(--ink); }
  .vdesc {
    font-size: 12px; line-height: 1.45; color: var(--text-3);
    display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
  }
  .vprop.active .vdesc { color: var(--text-2); }
  .vprop:focus-visible { outline: 2.5px solid var(--hotpink); outline-offset: 3px; }
  .vphint { text-align: center; margin: 10px auto 30px; opacity: .75; text-transform: none; letter-spacing: .05em; }
  @media (max-width: 900px) {
    .vprops { grid-template-columns: 1fr 1fr; }
  }
  @media (max-width: 560px) {
    .vprops { grid-template-columns: 1fr; }
  }

  /* ── Stage / Mac ── the protagonist, not a prop ── */
  .stage-wrap { position:relative; width:100%; }

  /* cursor — correct Mac size, tip-anchored, subtle. Was 42px comically large and center-anchored. */
  .big-cursor {
    position:absolute; z-index:50; pointer-events:none;
    width:26px; height:26px; margin:0;
    transform: translate(-2px, -2px);
    will-change: left, top, transform;
    transition: left 0.42s cubic-bezier(.16,1,.3,1), top 0.42s cubic-bezier(.16,1,.3,1), transform .16s var(--spring);
    filter: drop-shadow(0 1px 2px rgba(0,0,0,.28)) drop-shadow(0 4px 8px rgba(0,0,0,.18));
    background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Cpath d='M7 4.5 L7 25.5 L12.3 18.2 L16.2 23.6 L18.8 21.9 L14.6 16.6 L22.2 16.6 Z' fill='white' stroke='%23131722' stroke-width='1.5' stroke-linejoin='round' stroke-linecap='round'/%3E%3C/svg%3E") no-repeat center;
    background-size: 22px 22px;
  }
  .big-cursor i {
    position:absolute; left:9px; top:9px; width:16px; height:16px;
    border-radius:50%; border:1.5px solid rgba(252,86,129,0);
    transition: border-color .16s ease, transform .16s ease, background .16s ease, opacity .16s ease;
    background: rgba(252,86,129,0);
    opacity:0;
  }
  .big-cursor.clicking { transform: translate(-2px, -2px) scale(.94); }
  .big-cursor.clicking i {
    background: rgba(252,86,129,.16);
    border-color: rgba(252,86,129,.70);
    transform: scale(1.35);
    opacity:1;
    box-shadow: 0 0 0 6px rgba(252,86,129,.10);
  }

  .mac { filter: none; }
  .lid {
    position:relative;
    aspect-ratio: 16/10;
    background:#0c0e12;
    border-radius:22px;
    padding:12px;
    overflow:hidden;
    /* outer Mac shadow — sits INSIDE the page, not bleeding inner window shadows outward */
    box-shadow:
      0 28px 60px rgba(19,23,34,.22),
      0 8px 20px rgba(19,23,34,.14),
      inset 0 1px 0 rgba(255,255,255,.08);
    border: 1px solid rgba(0,0,0,.18);
  }
  .wallpaper {
    position:absolute; inset:12px 12px 12px;
    border-radius:14px;
    overflow:hidden;
    background: linear-gradient(112deg, #0b5cff 0%, #2ec5ff 22%, #3dd68c 48%, #c7d7ff 74%, #ff5a7a 100%);
    /* subtle inner edge so screen feels inset, not floating — bottom edge now visible */
    box-shadow: inset 0 0 0 1px rgba(255,255,255,.10), inset 0 1px 0 rgba(255,255,255,.12);
  }
  .streak { position:absolute; inset:-20%; opacity:.4; background: linear-gradient(100deg, transparent 35%, rgba(255,255,255,.5) 50%, transparent 65%); transform: skewX(-14deg); }
  .streak.s2 { opacity:.24; transform: skewX(-18deg) translateX(60px); }
  .streak.s3 { opacity:.16; transform: skewX(-10deg) translateX(-70px); }

  /* ── Menu bar ── */
  .menubar {
    position:absolute; top:12px; left:12px; right:12px; height:24px; z-index:30;
    display:flex; align-items:center; gap:14px; padding:0 12px;
    background:rgba(5,8,12,.32); backdrop-filter:blur(8px);
    font-family: var(--sans); font-size:10.5px; color:rgba(255,255,255,.85);
  }
  .menubar .apple { height:11px; width:auto; color:rgba(255,255,255,.95); flex:none }
  .menubar .mapp { font-weight:700; white-space:nowrap; color: rgba(255,255,255,.96) }
  .menubar .mi { color:rgba(255,255,255,.78); white-space:nowrap }
  .menubar .mspace { flex:1 }
  .menubar .mnet { color:#6ee89a; font-size:9.5px; letter-spacing:.1em; white-space:nowrap; font-weight: 600; }
  .menubar .sicn { height:10px; width:auto; color:rgba(255,255,255,.72); flex:none }
  .menubar .mclock { font-size:10px; color:rgba(255,255,255,.88); white-space:nowrap }

  /* ── Notch — faithful to the real NotchView island (see screenshots):
       idle = 210×26 black island, r14, robot left + plus right.
       Geometry matches NotchPanel: UnevenRoundedRectangle, soft bottom corners,
       shadow radius 12 y6. */
  .notch {
    position:absolute; top:12px; left:50%; transform:translateX(-50%);
    z-index:40;
    width:210px; height:26px;
    background:#000; border-radius:0 0 14px 14px;
    transition:
      width .42s cubic-bezier(.16,1,.3,1),
      height .32s cubic-bezier(.16,1,.3,1),
      border-radius .28s cubic-bezier(.16,1,.3,1),
      box-shadow .24s ease;
    box-shadow: 0 4px 14px rgba(0,0,0,.28);
    overflow:hidden;
  }
  /* active wings: wider island, corners pop open like the real one — springy islandpop */
  .notch.wide { width:340px; height:26px; border-radius:0 0 20px 20px; animation: islandpop .52s cubic-bezier(0.22,1.28,0.36,1); will-change: width, transform; }
  /* plus menu expanded: drops taller for the trio — true UnevenRoundedRectangle, like the real island */
  .notch.menuopen { width:340px; height:142px; border-radius:0 0 20px 20px; animation: islandpop .52s cubic-bezier(0.22,1.28,0.36,1); }
  @keyframes islandpop { 0%{ transform:translateX(-50%) scale(1,1) } 42%{ transform:translateX(-50%) scale(1.04,1.08) } 100%{ transform:translateX(-50%) scale(1,1) } }
  /* robot left + plus right — always visible, exactly like the real island at rest */
  .nrow { display:flex; align-items:center; justify-content:space-between; gap:8px; padding:0 12px; height:26px; }
  .nbot { flex-shrink:0; transition: opacity .26s cubic-bezier(.16,1,.3,1), transform .34s cubic-bezier(.16,1,.3,1); filter: drop-shadow(0 0 6px rgba(252,86,129,.18)); transform: scale(1.06); }
  .nright { display:flex; align-items:center; gap:10px; min-width:0; transition: opacity .26s cubic-bezier(.16,1,.3,1), transform .34s cubic-bezier(.16,1,.3,1); }
  .notch.targeted { box-shadow: 0 8px 24px rgba(0,0,0,.45), 0 0 0 3px rgba(252,86,129,.38), 0 0 18px rgba(252,86,129,.22); }
  .notch.targeted .nplus {
    background: #fc5681;
    border-color: #fc5681;
    box-shadow: 0 0 0 6px rgba(252,86,129,.18), 0 0 14px rgba(252,86,129,.35);
    animation: plusPulse 1s ease-in-out infinite;
  }
  .notch.targeted .nplus svg path { stroke: #fff; }
  @keyframes plusPulse { 0%,100%{ transform:scale(1) } 50%{ transform:scale(1.12) } }
  .nplus, .nclose {
    width:22px; height:22px; border-radius:50%;
    background:rgba(255,255,255,.10);
    border:1px solid rgba(255,255,255,.10);
    display:grid; place-items:center;
    transition: background .2s ease, border-color .2s ease, box-shadow .2s ease, transform .2s var(--spring);
  }

  /* listening — 7 hotpink waveform bars, like WaveformBars */
  .nwave { display:flex; align-items:center; gap:3px; height:26px; }
  .nwave i { width:4px; border-radius:99px; background:#fc5681; animation:nbar 0.9s ease-in-out infinite; }
  .nwave i:nth-child(1){ height:11px; animation-delay:0s }
  .nwave i:nth-child(2){ height:17px; animation-delay:.08s }
  .nwave i:nth-child(3){ height:23px; animation-delay:.16s }
  .nwave i:nth-child(4){ height:26px; animation-delay:.24s }
  .nwave i:nth-child(5){ height:22px; animation-delay:.32s }
  .nwave i:nth-child(6){ height:16px; animation-delay:.4s }
  .nwave i:nth-child(7){ height:10px; animation-delay:.48s }
  @keyframes nbar { 0%,100%{ transform:scaleY(.55) } 50%{ transform:scaleY(1.12) } }

  /* done — mint check + ms */
  .nms { color:#6ee89a; font-size:11px; }

  /* note recording — pulsating pink note icon */
  .npulse { display:grid; place-items:center; animation:npulse 1.1s ease-in-out infinite; }
  @keyframes npulse { 0%,100%{ transform:scale(.95); opacity:.75 } 50%{ transform:scale(1.15); opacity:1 } }
  .nlab { color:rgba(255,255,255,.6); font-size:10px; letter-spacing:.06em; }

  /* call capture — record ring + dot, pulsating */
  .recring {
    width:18px; height:18px; border-radius:50%;
    border:2px solid #fc5681;
    display:grid; place-items:center;
  }
  .recring i { width:7px; height:7px; border-radius:50%; background:#fc5681; animation:dotpulse 1.2s ease-in-out infinite; }
  @keyframes dotpulse { 0%,100%{ transform:scale(.68); opacity:.55 } 50%{ transform:scale(1); opacity:1 } }

  /* processing — sun-yellow dots + "writing it down…" */
  .ndots { display:flex; gap:4px; }
  .ndots i { width:5px; height:5px; border-radius:99px; background:#ffd230; opacity:.3; transform:scale(.85); animation:ndot 0.9s ease-in-out infinite; }
  .ndots i:nth-child(2){ animation-delay:.15s } .ndots i:nth-child(3){ animation-delay:.3s }
  @keyframes ndot { 0%,100%{ opacity:.3; transform:scale(.85) } 30%{ opacity:1; transform:scale(1.25) } }
  .nproc { color:rgba(255,255,255,.75); font-size:10px; }

  /* expanded menu — quick note / record call / upload file — horizontal trio, same width as hover */
  .nmenu {
    display:flex; align-items:center; justify-content:center; gap:0;
    padding:12px 12px 16px;
  }
  .nact {
    display:flex; flex-direction:column; align-items:center; gap:9px;
    padding:10px 18px; border-radius:12px;
    transition: background .2s ease;
    flex:1;
  }
  .nact span { color:#fff; font-family: var(--sans); font-size:12.5px; font-weight:600; white-space:nowrap; }
  .nact.hl { background:rgba(252,86,129,.14); box-shadow: inset 0 0 0 1px rgba(252,86,129,.18); }
  .ndiv { width:1px; align-self:stretch; margin:6px 0; background:rgba(255,255,255,.10); }

  /* ── Screen & windows ── */
  .screen {
    position:absolute; inset:12px 12px 18px;
    border-radius:14px;
    padding: 40px 3.5% 56px; /* bottom 56 leaves room for liquid glass dock overlay */
    display:flex;
    overflow:hidden; /* clip inner window shadows so they never bleed outside the Mac */
    border: 1px solid rgba(255,255,255,.06);
  }
  .screen.scrollable { overflow:hidden; }
  .screen.scrollable .win { overflow:hidden; }

  .win {
    position:relative; flex:1;
    display:flex; flex-direction:column;
    background:#fffdf7;
    border-radius:14px;
    overflow:hidden;
    /* contained window shadow — soft, stays INSIDE the screen */
    box-shadow:
      0 8px 20px rgba(0,0,0,.14),
      0 2px 8px rgba(0,0,0,.08),
      inset 0 0 0 1px rgba(255,255,255,.9);
    min-width:0;
    animation: winIn .46s cubic-bezier(.22,1,.36,1) both;
  }
  .win.typwin { min-height: 100%; }
  @keyframes winIn { from { opacity:0; transform:translateY(10px) scale(.988); filter: blur(3px) } to { opacity:1; transform:none; filter: blur(0) } }
  /* dictation — pop when text lands so you SEE it (scale + pink flash, then settle) */
  .appbody :global(.mtxt.fresh),
  .appbody :global(.field.typed),
  .appbody :global(.rtext),
  .appbody :global(.bub.mine.fresh) {
    animation: typeReveal .58s cubic-bezier(.16,1,.3,1) both;
  }
  @keyframes typeReveal {
    0%   { opacity:0; transform: translateY(10px) scale(.94); filter: blur(4px); background: rgba(252,86,129,.16); box-shadow: 0 0 0 0 rgba(252,86,129,0); }
    38%  { opacity:1; transform: translateY(-3px) scale(1.04); filter: blur(0); background: rgba(252,86,129,.14); box-shadow: 0 4px 16px rgba(252,86,129,.18); }
    68%  { opacity:1; transform: translateY(1px) scale(1.01); filter: blur(0); background: rgba(252,86,129,.08); box-shadow: 0 2px 10px rgba(252,86,129,.12); }
    100% { opacity:1; transform: none; filter: blur(0); background: transparent; box-shadow: none; }
  }
  .wintitle {
    display:flex; align-items:center; gap:10px;
    padding:8px 12px;
    background:#f4f1ea;
    border-bottom:1px solid var(--line);
    font-family: var(--sans); font-size:11px; font-weight:600; color:var(--text-2);
  }
  .dots { display:flex; gap:6px; } .dots i { width:10px; height:10px; border-radius:50%; display:block; }
  .dots i:nth-child(1){ background:#ff5f57 } .dots i:nth-child(2){ background:#febc2e } .dots i:nth-child(3){ background:#28c840 }
  .off { margin-left:auto; font-size:9px; color:var(--text-3); letter-spacing:.08em; }

  .appbody { flex:1; min-height:0; display:flex; }
  .appbody > :global(*) { flex:1; min-width:0 }

  .shellslot { flex:1; min-height:0; overflow:hidden; pointer-events:none; }
  .shellslot.scrollable { overflow:auto; pointer-events:auto; }
  .shellslot.scrollable :global(.content) { overflow:visible; }

  /* ── key overlay — awfully clear when held ── */
  .keyovl {
    position:absolute; bottom:78px; right:16px;
    display:inline-flex; align-items:center; gap:11px;
    padding:13px 18px 13px 14px;
    background:#0a0e1a; color:#fff;
    border-radius:16px;
    font-family: var(--mono); font-size:11.5px; font-weight:800; letter-spacing:.1em; text-transform:uppercase;
    box-shadow:
      0 12px 28px rgba(0,0,0,.42),
      0 4px 10px rgba(0,0,0,.24),
      inset 0 1px 0 rgba(255,255,255,.14),
      inset 0 -1px 0 rgba(0,0,0,.2);
    transition: transform .22s var(--spring), box-shadow .22s var(--ease-out), background .22s ease, border-color .22s ease;
    z-index:35;
    border:1.5px solid rgba(255,255,255,.10);
  }
  .keyovl::before {
    content:''; position:absolute; inset:-6px; border-radius:20px;
    border:1.5px dashed rgba(255,255,255,.0);
    transition: border-color .22s ease;
    pointer-events:none;
  }
  .keyovl .kicon {
    width:38px; height:38px; border-radius:11px;
    display:grid; place-items:center;
    background: rgba(255,255,255,.09);
    border:1px solid rgba(255,255,255,.14);
    font-family: var(--sans); font-size:20px; font-weight:900; line-height:1;
    transition: background .2s ease, transform .2s var(--spring), border-color .2s ease, color .2s ease;
    box-shadow: inset 0 1px 0 rgba(255,255,255,.12);
  }
  .keyovl .klabel { opacity:.92; white-space:nowrap; letter-spacing:.14em; }
  .keyovl .klabel::after {
    content:' → talk'; opacity:.55; font-weight:600; letter-spacing:.08em;
  }
  .keyovl.holding .klabel::after { content:' • listening'; opacity:1; color:#fff; }
  .keyovl.holding {
    background: linear-gradient(135deg, #ff3b6b 0%, #ff5a7a 100%);
    border-color: rgba(255,255,255,.22);
    box-shadow:
      0 16px 36px rgba(255,59,107,.45),
      0 0 0 7px rgba(255,59,107,.18),
      0 0 36px rgba(255,59,107,.32),
      inset 0 1px 0 rgba(255,255,255,.28);
    transform: translateY(1px) scale(1.06);
    animation: keyPulse 1.0s ease-in-out infinite;
  }
  .keyovl.holding::before { border-color: rgba(255,59,107,.38); }
  .keyovl.holding .kicon {
    background: #fff;
    color: #ff1744;
    border-color: #fff;
    transform: scale(1.08);
    box-shadow: 0 2px 10px rgba(0,0,0,.18), inset 0 1px 0 rgba(255,255,255,1);
  }
  .keyovl.down { transform: translateY(4px) scale(.98); }

  /* ═══ CAPTURE — the call window ═══ */
  .callwin { background:#16181d; }
  .callbar {
    flex:none; display:flex; align-items:center; gap:10px;
    padding:8px 12px; background:#0e1013;
    border-bottom:1px solid rgba(255,255,255,.08);
    font-family: var(--sans);
  }
  .calltitle { color:rgba(255,255,255,.75); font-size:11px; font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
  .cspace { flex:1 }
  .reccall { display:inline-flex; align-items:center; gap:6px; font-size:10px; letter-spacing:.1em; color:rgba(255,255,255,.4); white-space:nowrap }
  .reccall i { width:7px; height:7px; border-radius:50%; background:currentColor }
  .reccall.on { color:#ff4d4d }
  .reccall.on i { animation:pulse 1.2s ease-in-out infinite }
  .reccall.saved { color:#6ee89a; letter-spacing:.06em }
  .stopbtn { border-radius:6px; padding:5px 12px; background:rgba(255,255,255,.12); color:#fff; font-size:11px; font-weight:600; white-space:nowrap }

  .callbody { flex:1; min-height:0; display:flex; }
  .callgrid { flex:1; display:grid; grid-template-columns:1fr 1fr; gap:8px; padding:10px; min-width:0 }
  .ctile {
    position:relative; border-radius:10px; overflow:hidden;
    background:linear-gradient(140deg,#232630,#191c24);
    display:grid; place-items:center;
    transition:box-shadow .3s ease;
  }
  .ctile.speaking { box-shadow:inset 0 0 0 2px #6ee89a }
  .cini { font-size:22px; font-weight:700; color:#fff; border-radius:50%; width:50px; height:50px; display:grid; place-items:center; font-family:var(--sans) }
  .cname { position:absolute; bottom:8px; left:10px; font-size:10.5px; color:rgba(255,255,255,.85); background:rgba(0,0,0,.4); padding:2px 8px; border-radius:4px; font-family:var(--sans) }

  .callrail {
    width:210px; flex:none; border-left:1px solid rgba(255,255,255,.08);
    background:rgba(0,0,0,.25); padding:14px; overflow:hidden;
    display:flex; flex-direction:column; gap:9px;
    transition:opacity .3s ease;
  }
  .callrail.dim { opacity:.45 }
  .railhead { font-size:9px; letter-spacing:.12em; color:rgba(255,255,255,.45) }
  .railturn { font-size:11px; line-height:1.5; color:rgba(255,255,255,.8); animation:turnIn .38s var(--ease-out) both; font-family:var(--sans) }
  .railturn b { font-weight:700 }
  @keyframes turnIn { from{opacity:0; transform:translateY(8px)} to{opacity:1; transform:none} }

  .callctl { flex:none; display:flex; align-items:center; justify-content:center; gap:10px; padding:8px 0 10px; background:rgba(0,0,0,.3) }
  .cbtn { width:30px; height:30px; border-radius:50%; background:rgba(255,255,255,.12); display:grid; place-items:center; color:#fff }
  .cbtn.rec { background:rgba(224,49,49,.3); color:#ff6b6b; transition:background .2s ease }
  .cbtn.rec.on { background:rgba(224,49,49,.6) }
  .cbtn.leave { width:auto; border-radius:7px; padding:0 14px; height:28px; background:#e02e2e; font-size:11px; font-weight:600; font-family:var(--sans) }

  .callsave {
    position:absolute; inset:0; z-index:5;
    display:flex; flex-direction:column; align-items:center; justify-content:center; gap:9px;
    background:rgba(5,8,12,.55); backdrop-filter:blur(3px);
    animation: fadeUp .3s ease both;
  }
  .callsave p { color:#fff; font-size:13.5px; font-weight:600; font-family:var(--sans); margin:0 }
  .savedim { font-size:9.5px; color:rgba(255,255,255,.5); letter-spacing:.08em; text-transform:uppercase }
  .savespin { width:24px; height:24px; border-radius:50%; border:3px solid rgba(255,255,255,.15); border-top-color:#ffd230; animation:spin .9s linear infinite }
  @keyframes spin { to{transform:rotate(360deg)} }
  @keyframes fadeUp { from { opacity:0 } to { opacity:1 } }

  /* ═══ SUMMARIZE — drop a file ═══ */
  .droparea { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:0; padding:18px 26px; position:relative; }
  .filechip {
    display:flex; align-items:center; gap:11px;
    padding:11px 16px; border:1px solid var(--line); border-radius:13px; background:#fff;
    box-shadow:0 10px 24px rgba(19,23,34,.14);
    animation: bob 3.2s ease-in-out infinite;
    transition: transform .54s cubic-bezier(.16,1,.3,1), opacity .40s ease, filter .40s ease, box-shadow .3s ease;
    margin-bottom:-20px; z-index:2;
    will-change: transform, opacity;
  }
  @keyframes bob { 0%,100%{ transform:translateY(0) rotate(-.5deg) } 50%{ transform:translateY(-5px) rotate(-.5deg) } }
  /* drop: physical arc down into the zone — no scale(1.3) pop, just slide + settle + fade */
  .filechip.dropped { animation:none; transform:translate3d(6px, 52px, 0) scale(0.94) rotate(0.6deg); opacity:0; filter: blur(0.5px); box-shadow:0 4px 12px rgba(19,23,34,.10); }
  .filechip strong { display:block; font-size:13px; color:var(--ink); }
  .filechip .mono { font-size:10px; color:var(--text-3); }
  .fico {
    font-size:9px; font-weight:700; letter-spacing:.06em;
    background:var(--surface-2); border:1px solid var(--line);
    padding:5px 7px; border-radius:7px; color:var(--text-2); flex-shrink:0;
  }
  .dzbox {
    width:min(420px, 100%);
    padding:30px 24px 24px;
    border:2px dashed var(--line-strong); border-radius:18px;
    text-align:center;
    display:flex; flex-direction:column; align-items:center; gap:6px;
    transition: border-color .28s cubic-bezier(.16,1,.3,1), background .28s ease, transform .28s var(--spring), box-shadow .28s ease;
  }
  .dzbox.hover { border-color:var(--hotpink); background:rgba(252,86,129,.06); transform: scale(1.015); box-shadow: 0 6px 18px rgba(252,86,129,.08); }
  .dz-h { font-size:17px; font-weight:700; color:var(--ink); letter-spacing:-0.01em; }
  .dz-s { font-size:10.5px; color:var(--text-3); letter-spacing:.06em; }
  .prog { width:78%; height:6px; border-radius:99px; background:var(--surface-2); overflow:hidden; margin-top:12px; box-shadow: inset 0 1px 2px rgba(0,0,0,.06); }
  .prog i { display:block; height:100%; width:0; border-radius:99px; background:linear-gradient(90deg,#6ee89a,#03594d); animation: fillbar 2.0s cubic-bezier(.22,1,.36,1) forwards; }
  @keyframes fillbar { from { width:0 } to { width:100% } }
  .translabel { margin-top:9px; color:var(--mint-live, #4db87a); }

  /* summarize + capture — the real transcript view */
  .realslot { flex:1; overflow:hidden; animation: fadeUp .45s ease both; }
  .realslot.scrollable { overflow:auto; }
  .realslot.scrollable :global(.wrap) { height:auto; min-height:100%; overflow:visible; padding:20px 22px 28px; }
  .realslot :global(.wrap) { height:100%; overflow-y:auto; padding:20px 22px 28px; }

  /* ── Dock ── — liquid glass, seated ON the screen, not floating off it */
  .dock {
    position:absolute; bottom:14px; left:50%; transform:translateX(-50%);
    z-index:32; display:flex; gap:8px; align-items:flex-end;
    padding:8px 11px 9px;
    background: rgba(255,255,255,.10);
    backdrop-filter: blur(22px) saturate(180%);
    -webkit-backdrop-filter: blur(22px) saturate(180%);
    border:1px solid rgba(255,255,255,.22);
    border-radius:16px;
    /* layered glass shadow — stays on the screen glass, never outside the Mac */
    box-shadow:
      0 8px 24px rgba(0,0,0,.22),
      0 2px 8px rgba(0,0,0,.14),
      inset 0 1px 0 rgba(255,255,255,.45),
      inset 0 -1px 0 rgba(255,255,255,.08);
  }
  .dock::before {
    content:''; position:absolute; inset:0; border-radius:16px;
    background: linear-gradient(180deg, rgba(255,255,255,.18) 0%, transparent 55%);
    pointer-events:none;
  }
  .ditem {
    position:relative; display:flex; flex-direction:column; align-items:center; gap:3px;
    padding:0; border:0; background:none; cursor:pointer;
    transition:transform .25s var(--spring);
  }
  .ditem:hover { transform:translateY(-4px) }
  .ditem.on {
    transform:translateY(-6px);
    animation: dockPulse .5s ease-out;
  }
  @keyframes dockPulse {
    0% { transform: scale(1.1) }
    40% { transform: scale(1.2) }
    100% { transform: scale(1) }
  }
  .dico {
    width:36px; height:36px; border-radius:9px; display:grid; place-items:center;
    background:#fff;
    box-shadow:inset 0 1px 0 rgba(255,255,255,.4), 0 3px 8px rgba(0,0,0,.35);
  }
  .dico :global(svg) { width:22px; height:22px; display:block }
  .dico.dtyp { background:#fffdf7; color:#fc5681 }
  .ddot { width:4px; height:4px; border-radius:50%; background:rgba(255,255,255,.25); transition:background .2s }
  .ditem.on .ddot { background:#fff }
  .ditem:focus-visible { outline: 2.5px solid var(--hotpink); outline-offset: 3px; border-radius: 8px; }
  @media (pointer: coarse) {
    .dico { width:44px; height:44px; border-radius:11px; }
    .dock { gap:6px; padding:6px 8px 7px; }
  }

  /* ── Mac base ── */
  .base { height:20px; margin:-1px -4.6% 0; background: linear-gradient(90deg,#9aa0ac 0%, #f0f2f6 50%, #9aa0ac 100%); border-radius:0 0 12px 12px; position:relative; box-shadow: inset 0 1px 0 rgba(255,255,255,.9); }
  .base .chin { position:absolute; left:50%; transform:translateX(-50%); top:1px; width:17%; min-width:104px; height:9px; background:linear-gradient(180deg,#7e8490,#5a5f6a); border-radius:0 0 9px 9px; }

  @media (max-width:900px) {
    .lid { aspect-ratio:auto; height:540px; }
    .callrail { width:170px }
  }
  @media (max-width:760px) {
    .menubar { display:none }
  }
  @media (max-width:700px) {
    .callrail { display:none }
    .dock { gap:6px; padding:6px 8px 7px }
    .dico { width:32px; height:32px }
    .dico :global(svg) { width:20px; height:20px }
  }
  @media (max-width:560px) {
    .tabs { gap: 4px 18px; margin: 32px auto 16px; }
    .nact { padding:8px 10px; }
    .nact span { font-size:10px; }
    .keyovl { bottom:78px; right:10px; padding:10px 12px; }
    .keyovl .kicon { width:32px; height:32px; font-size:16px; }
    .big-cursor { width:36px; height:36px; background-size:32px 32px; }
  }
  @media (prefers-reduced-motion: reduce) {
    .tabdesc { animation: none !important; }
    .nwave i, .ndots i, .filechip, .npulse, .recring i, .reccall.on i, .savespin, .win { animation:none !important; }
  }
</style>
