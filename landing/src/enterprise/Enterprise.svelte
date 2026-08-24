<script>
  import './ent.css';
  import Logo from '../lib/Logo.svelte';
  import Robot from '../lib/Robot.svelte';
  import TalkWave from '../lib/TalkWave.svelte';
  import { reveal, countup } from './reveal.js';
  import VariantSwitcher from '../lib/VariantSwitcher.svelte';
  import slack from 'thesvg/slack';
  import outlook from 'thesvg/microsoft-outlook';
  import warp from 'thesvg/warp';
  import { nsSvg } from '../lib/svgid.js';
  import PitchBot from '../lib/PitchBot.svelte';
  import { pitch } from '../lib/pitchbot.svelte.js';

  let scrolled = $state(false);
  let progress = $state(0);
  let openFaq = $state(0);

  const onScroll = () => {
    scrolled = window.scrollY > 24;
    const max = document.documentElement.scrollHeight - window.innerHeight;
    progress = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
  };

  /* ---- hero demo: dictation cycling through the enterprise day's apps ----
     auto-plays above the fold; press & hold (⌥ or the keycap) to try it
     live in whichever app is on screen. */

  const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const SCENES = [
    {
      id: 'slack',
      name: 'Slack',
      brand: slack.svg,
      wave: '#36c5f0',
      title: '#deal-review',
      meta: '4 members',
      side: [['# deal-review'], ['# general'], ['# security'], ['# eng-escalations']],
      text: 'Q3 numbers are final. Churn held flat at 2.1 percent.',
    },
    {
      id: 'outlook',
      name: 'Outlook',
      brand: outlook.svg,
      wave: '#0f6cbd',
      title: 'New Message',
      meta: 'To: board@',
      side: [['Inbox', '3'], ['Drafts'], ['Sent'], ['Archive']],
      text: 'Revenue is up 14 percent. Details in the deck.',
    },
    {
      id: 'terminal',
      name: 'Warp',
      brand: warp.svg,
      wave: '#34d399',
      title: 'prod-bastion — ssh',
      meta: 'tty7',
      side: [],
      text: 'verify-backup --vault main --full',
    },
  ];

  let heroDemoEl = $state(null);
  let heroVisible = $state(false);
  let hscene = $state(0);
  let hphase = $state(REDUCED ? 'done' : 'idle'); // idle | listening | typing | done | switch
  let hchars = $state(REDUCED ? SCENES[0].text.length : 0);

  let hTimers = [];
  const hLater = (fn, ms) => hTimers.push(setTimeout(fn, ms));
  const hClear = () => {
    hTimers.forEach(clearTimeout);
    hTimers = [];
  };

  function hListen(auto = true) {
    hClear();
    hphase = 'listening';
    hchars = 0;
    /* auto mode schedules its own release; manual holds end on key-up */
    if (auto) hLater(hEnd, 2100);
  }

  /* visitor interaction: press & hold anywhere on the desktop */
  function hPress() {
    if (hphase === 'listening' || hphase === 'typing') return;
    hListen(false);
  }

  function hRelease() {
    if (hphase !== 'listening') return;
    hEnd();
  }

  function hEnd() {
    if (hphase !== 'listening') return;
    hClear();
    hphase = 'typing';
    hLater(hType, 90);
  }

  function hType() {
    const full = SCENES[hscene].text;
    if (REDUCED) {
      hchars = full.length;
      hphase = 'done';
      return;
    }
    const step = () => {
      hchars = Math.min(hchars + 4, full.length);
      if (hchars < full.length) hLater(step, 16);
      else {
        hphase = 'done';
        hLater(hNext, 2500);
      }
    };
    step();
  }

  function hNext() {
    hphase = 'switch';
    hLater(() => {
      hscene = (hscene + 1) % SCENES.length;
      hchars = 0;
      hphase = 'idle';
      hLater(hListen, 550);
    }, 420);
  }

  /* dock clicks jump straight to an app */
  function pick(i) {
    if (i === hscene && hphase === 'idle') return;
    hClear();
    hscene = i;
    hchars = 0;
    hphase = 'idle';
    if (heroVisible && !REDUCED) hLater(hListen, 1200);
  }

  // run only while the hero demo is on screen
  $effect(() => {
    if (REDUCED || !heroDemoEl) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        heroVisible = entry.isIntersecting;
        if (entry.isIntersecting) {
          if (hphase === 'idle' && hchars === 0) hLater(hListen, 1400);
        } else {
          hClear();
          hphase = 'idle';
          hchars = 0;
        }
      },
      { threshold: 0.3 }
    );
    io.observe(heroDemoEl);
    return () => {
      io.disconnect();
      hClear();
    };
  });

  /* page-wide ⌥ hold-to-talk while the hero demo is in view */
  function heroKeydown(e) {
    if (e.key === 'Alt' && heroVisible && !e.repeat) {
      e.preventDefault();
      hPress();
    }
  }

  function heroKeyup(e) {
    if (e.key === 'Alt' && heroVisible) {
      e.preventDefault();
      hRelease();
    }
  }

  $effect(() => {
    document.documentElement.classList.add('ent-page');

    // dark browser chrome + enterprise title while on this route,
    // restored when navigating back to the consumer site
    const meta = document.querySelector('meta[name="theme-color"]');
    const prevTheme = meta?.getAttribute('content') ?? null;
    const prevTitle = document.title;
    meta?.setAttribute('content', '#0b0d12');
    document.title = 'Typie Enterprise — On-Device Voice Input for Business';

    onScroll();
    return () => {
      document.documentElement.classList.remove('ent-page');
      if (meta && prevTheme !== null) meta.setAttribute('content', prevTheme);
      document.title = prevTitle;
    };
  });

  const stats = [
    { value: 0, prefix: '', suffix: '', unit: 'bytes', label: 'of audio ever transmitted. The architecture has no path out.' },
    { value: 100, prefix: '<', suffix: '', unit: 'ms', label: 'release-to-keystroke latency. Inference is the only delay.' },
    { value: 100, prefix: '', suffix: '%', unit: 'local', label: 'of inference on-device. The network is never in the loop.' },
    { value: 1, prefix: '', suffix: '', unit: 'download', label: 'model fetched once at install. After day one, fully offline.' },
  ];

  const faqs = [
    {
      q: 'Where does audio processing actually happen?',
      a: 'On the Mac. Audio travels from microphone to the on-device ASR model to a garbage collector. There is no server, no upload endpoint, and no vendor-side processing stage to review.',
    },
    {
      q: 'Can we run a security review without a data flow diagram?',
      a: 'Yes. The full data flow is three hops long and none of them leave the machine. We provide architecture documentation, a Data Processing Addendum, and subprocessor lists that are, by design, empty.',
    },
    {
      q: 'How is typie deployed across a fleet?',
      a: 'Standard macOS .app distribution via MDM (Jamf, Kandji, Intune). License state is a managed preference. No daemons, no kernel extensions, no system services.',
    },
    {
      q: 'What happens when there is no internet?',
      a: 'Nothing changes. After the one-time model download, typie has no reason to touch the network. It works on air-gapped machines for the entire life of the deployment.',
    },
    {
      q: 'Is there per-minute or per-character billing?',
      a: 'No. Pricing is per seat, flat. Inference runs on hardware you already own, so our costs do not scale with your usage and neither does your invoice.',
    },
    {
      q: 'Does it work with our regulated applications?',
      a: 'typie outputs standard synthetic keystrokes into whatever application has focus. If it accepts typing, it works: EHR clients, legacy terminals, VDI sessions, Electron apps, everything.',
    },
  ];
</script>

<svelte:window onscroll={onScroll} onkeydown={heroKeydown} onkeyup={heroKeyup} onpointerup={hRelease} />

<div class="ent" id="top">
  <!-- ============ nav ============ -->
  <header class="ent-nav" class:scrolled>
    <div class="container bar">
      <div
        class="ent-brand"
        style="--vn-fg: var(--bone); --vn-accent: var(--accent); --vn-menu-bg: #10131a; --vn-menu-border: rgba(237, 239, 242, 0.12); --vn-menu-shadow: 0 18px 44px rgba(0, 0, 0, 0.55); --vn-item-fg: var(--bone); --vn-item-muted: var(--muted); --vn-item-hover: rgba(237, 239, 242, 0.06);"
      >
        <VariantSwitcher variant="enterprise" logoSize={24} logoColor="#34d399" />
      </div>

      <nav class="ent-links" aria-label="primary">
        <a href="#platform">Platform</a>
        <a href="#security">Security</a>
        <a href="#deployment">Deployment</a>
        <a href="#pricing">Pricing</a>
        <a href="#faq">FAQ</a>
      </nav>

      <a
        href="mailto:sales@typie.cc?subject=Enterprise%20briefing"
        class="btn btn-solid btn-sm"
        onclick={(e) => { e.preventDefault(); pitch.show(); }}
      >Book a briefing</a>
    </div>
    <div class="progress" style="--p:{progress}" aria-hidden="true"></div>
  </header>

  <!-- ============ hero / architecture B asymmetric split ============ -->
  <section class="ent-hero">
    <div class="container grid">
      <div>
        <p class="eyebrow hero-eyebrow"><b>typie enterprise</b>&ensp;/&ensp;on-device voice input</p>
        <h1><em>Zero</em> attack surface.</h1>

        <p class="sub">
          Enterprise dictation at sub-100ms on every corporate Mac. Audio
          never leaves the device, and there is nothing to breach.
        </p>
        <div class="cta">
          <a
            href="mailto:sales@typie.cc?subject=Enterprise%20briefing"
            class="btn btn-solid"
            onclick={(e) => { e.preventDefault(); pitch.show(); }}
          >Book a security briefing</a>
        </div>
        <div class="meta">
          <span><b>&gt;</b> on-device speech infrastructure</span>
          <span><b>&gt;</b> apple silicon · macos 14+</span>
          <span><b>&gt;</b> fleet deployment via MDM</span>
        </div>
      </div>

      <div class="hero-demo" bind:this={heroDemoEl}>
        <div
          class="hd-desktop"
          class:live={hphase === 'listening'}
          onpointerdown={(e) => { if (e.target.closest?.('.dock-item')) return; e.preventDefault(); hPress(); }}
        >
          <div class="island" class:idle={hphase === 'idle' || hphase === 'switch'} class:live={hphase === 'listening'} class:done={hphase === 'done'} aria-hidden="true">
            {#if hphase === 'listening'}
              <span class="ibot"><Robot size={15} mood="listening" /></span>
              <span class="icam"></span>
              <span class="iwave"><TalkWave n={5} color="#34d399" /></span>
            {:else if hphase === 'done'}
              <span class="ibot"><Robot size={17} mood="done" /></span>
              <span class="icam"></span>
              <span class="ims">✓ 84ms</span>
            {:else}
              <span class="icam"></span>
            {/if}
          </div>

          <div class="menubar" aria-hidden="true">
            <svg class="apple" viewBox="0 0 384 512" aria-hidden="true"><path fill="currentColor" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/></svg>
            <span class="mitem app">{SCENES[hscene].name}</span>
            <span class="mitem">File</span>
            <span class="mitem">Edit</span>
            <span class="mitem">View</span>
            <span class="mspace"></span>
            <span class="net">NET 0 B</span>
            <svg class="sicn" viewBox="0 0 16 12" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" aria-hidden="true"><path d="M1.5 4.4a10 10 0 0 1 13 0"/><path d="M3.9 7a6.4 6.4 0 0 1 8.2 0"/><circle cx="8" cy="9.9" r="1.15" fill="currentColor" stroke="none"/></svg>
            <svg class="sicn" viewBox="0 0 25 12" aria-hidden="true"><rect x="0.5" y="0.5" width="21" height="11" rx="3.2" fill="none" stroke="currentColor"/><rect x="2.5" y="2.5" width="14" height="7" rx="1.6" fill="currentColor"/><path d="M23 4v4a2.2 2.2 0 0 0 0-4z" fill="currentColor"/></svg>
            <span class="mitem">9:41 AM</span>
          </div>

          <div
            class="hd-window theme-{SCENES[hscene].id}"
            class:live={hphase === 'listening'}
            class:done={hphase === 'done'}
            class:switching={hphase === 'switch'}
          >
            <div class="titlebar">
              <span class="lights" aria-hidden="true"><i></i><i></i><i></i></span>
              <span class="wtitle">{SCENES[hscene].title}</span>
              <span class="tmeta mono">{SCENES[hscene].meta}</span>
            </div>

            <div class="winbody">
              {#if SCENES[hscene].side.length}
                <aside class="side">
                  <p class="side-h">
                    <i class="bmark" aria-hidden="true">{@html nsSvg(SCENES[hscene].brand, 'hsh' + SCENES[hscene].id)}</i>
                    {SCENES[hscene].name}
                  </p>
                  <ul>
                    {#each SCENES[hscene].side as [label, count], i}
                      <li class:on={i === 0}><span>{label}</span>{#if count}<b>{count}</b>{/if}</li>
                    {/each}
                  </ul>
                </aside>
              {/if}

              <div class="paper">
                {#if hphase === 'listening'}
                  <div class="talking" aria-hidden="true">
                    <TalkWave n={13} color={SCENES[hscene].wave} />
                    <p class="hint2 mono">say anything…</p>
                  </div>
                {:else if SCENES[hscene].id === 'terminal'}
                  <p class="term-line"><span class="prompt">$</span> ssh admin@prod-bastion</p>
                  <p class="term-line typed">
                    <span class="prompt">$</span>
                    {SCENES[hscene].text.slice(0, hchars)}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span class="ghost">words land here, as real keystrokes</span>{/if}<span class="caret" class:hidden={hphase === 'done'} aria-hidden="true"></span>
                  </p>
                {:else if SCENES[hscene].id === 'outlook'}
                  <div class="fields"><span>To: board@typie.cc</span><span>Subject: Q3 close</span></div>
                  <p class="mail-text">
                    {SCENES[hscene].text.slice(0, hchars)}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span class="ghost">words land here, as real keystrokes</span>{/if}<span class="caret" class:hidden={hphase === 'done'} aria-hidden="true"></span>
                  </p>
                  <span class="sendbtn">Send</span>
                {:else}
                  <div class="slack-msg">
                    <i class="sava sa" aria-hidden="true">A</i>
                    <div class="sbody">
                      <p class="shead"><b>alex</b><span class="mono">2h ago</span></p>
                      <p class="stext">ok, who owns the Q3 close narrative?</p>
                    </div>
                  </div>
                  <div class="slack-msg">
                    <i class="sava sy" aria-hidden="true">Y</i>
                    <div class="sbody">
                      <p class="shead"><b>you</b><span class="mono">now</span></p>
                      <p class="stext">
                        {SCENES[hscene].text.slice(0, hchars)}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span class="ghost">words land here, as real keystrokes</span>{/if}<span class="caret" class:hidden={hphase === 'done'} aria-hidden="true"></span>
                      </p>
                    </div>
                  </div>
                {/if}
                {#if hphase === 'done'}
                  <span class="badge mono">✓ typed in 84 ms</span>
                {/if}
              </div>
            </div>
          </div>

          <nav class="dock">
            {#each SCENES as s, i}
              <button class="dock-item" class:on={hscene === i} onclick={() => pick(i)} aria-label={s.name}>
                <span class="dicon"><i class="dbmark" aria-hidden="true">{@html nsSvg(s.brand, 'dk' + s.id)}</i></span>
                <i class="dot"></i>
              </button>
            {/each}
          </nav>
        </div>

        <p class="tryhint">
          <button
            class="minikey"
            class:down={hphase === 'listening'}
            onpointerdown={(e) => { e.preventDefault(); hPress(); }}
            onpointerup={hRelease}
            onpointerleave={hRelease}
            onkeydown={(e) => { if ((e.code === 'Space' || e.code === 'Enter') && !e.repeat) { e.preventDefault(); hPress(); } }}
            onkeyup={(e) => { if (e.code === 'Space' || e.code === 'Enter') { e.preventDefault(); hRelease(); } }}
            aria-label="press and hold to try typie live"
          >
            <b>&#8997;</b>option
          </button>
          press &amp; hold to try it live
        </p>
        <p class="hd-caption">same key, every app. zero bytes on the wire.</p>
      </div>
    </div>
  </section>

  <!-- ============ compliance strip ============ -->
  <div class="ent-comply">
    <div class="container row">
      <span class="cell" use:reveal><i>/</i> SOC 2 Type II</span>
      <span class="cell" use:reveal={{ delay: 0.06 }}><i>/</i> GDPR</span>
      <span class="cell" use:reveal={{ delay: 0.12 }}><i>/</i> HIPAA-ready deployment</span>
      <span class="cell" use:reveal={{ delay: 0.18 }}><i>/</i> CCPA</span>
      <span class="cell" use:reveal={{ delay: 0.24 }}><i>/</i> Zero retention</span>
      <span class="cell" use:reveal={{ delay: 0.3 }}><i>/</i> DPA on request</span>
    </div>
  </div>

  <!-- ============ stats band ============ -->
  <section class="block ent-stats">
    <div class="container">
      <div class="grid">
        {#each stats as s, i}
          <div class="stat" use:reveal={{ delay: i * 0.08 }}>
            <span class="num"
              >{s.prefix}<span data-count={s.value} use:countup>{s.value}</span><sub>{s.unit}</sub></span
            >
            <span class="label">{s.label}</span>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- ============ platform bento ============ -->
  <section class="block ent-bento" id="platform">
    <div class="container">
      <p class="eyebrow"><b>01</b> / platform</p>
      <h2 use:reveal>Built like infrastructure,<br />not like an app.</h2>
      <p class="lede" use:reveal={{ delay: 0.08 }}>
        One native binary. One dependency. No browser runtime, no background
        agents, no per-app integrations to maintain.
      </p>

      <div class="grid">
        <div class="ent-card-wrap primary" use:reveal>
          <div class="ent-card">
            <span class="tag">works everywhere</span>
            <h3>Dictation for every application</h3>
            <p>
              Output lands as real keyboard events in whatever has focus.
              Mail, Slack, EHR clients, mainframe terminals, Electron
              abominations. If it accepts typing, typie works there.
            </p>
            <pre>$ typie --trace
mic        ▸ on-device ASR (nvidia parakeet, local)
network    ▸ bytes transmitted: <b>0</b>
telemetry  ▸ endpoints configured: <b>none</b>
output     ▸ CGEvent keystrokes ▸ active application</pre>
            <p>
              This is the entire data flow. Three hops, all local. Your
              auditors can verify it with a packet capture in ten minutes.
            </p>
          </div>
        </div>

        <div class="ent-card-wrap" use:reveal={{ delay: 0.08 }}>
          <div class="ent-card">
            <span class="tag">your lexicon</span>
            <h3>Custom vocabulary</h3>
            <p>
              Product names, internal codenames, clinical terminology,
              regulatory acronyms. Domain language recognized correctly,
              on hardware you control.
            </p>
          </div>
        </div>

        <div class="ent-card-wrap" use:reveal={{ delay: 0.16 }}>
          <div class="ent-card">
            <span class="tag">fleet-ready</span>
            <h3>MDM-native deployment</h3>
            <p>
              Standard .app packaging for Jamf, Kandji, and Intune.
              No daemons, no kernel extensions, no system services.
            </p>
          </div>
        </div>

        <div class="ent-card-wrap half" use:reveal={{ delay: 0.24 }}>
          <div class="ent-card">
            <span class="tag">accessibility</span>
            <h3>A conformance win</h3>
            <p>
              Sub-100ms voice input supports WCAG 2.2 and Section 508 goals,
              with remappable hold-to-talk hotkeys for every motor-preference
              profile.
            </p>
          </div>
        </div>

        <div class="ent-card-wrap half" use:reveal={{ delay: 0.32 }}>
          <div class="ent-card">
            <span class="tag">standing infrastructure</span>
            <div class="bignum"><span data-count={0} use:countup>0</span></div>
            <p>servers provisioned for your dictation. Ever.</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ security (raised band) ============ -->
  <section class="block band ent-security" id="security">
    <div class="container">
      <p class="eyebrow"><b>02</b> / security</p>
      <h2 use:reveal>Not a privacy policy.<br />An architecture.</h2>
      <p class="lede" use:reveal={{ delay: 0.08 }}>
        Most vendors promise to handle your data carefully. Typie's promise is
        simpler: it cannot exfiltrate what it never receives.
      </p>

      <div class="flow" use:reveal>
        <div class="stage" use:reveal>
          <span class="idx">STAGE 1</span>
          <span class="name">Microphone</span>
          <span class="desc">Audio captured only while the hotkey is held. Hold-to-talk means recording is <b>physically bounded</b> by the gesture.</span>
        </div>
        <div class="stage" use:reveal={{ delay: 0.08 }}>
          <span class="idx">STAGE 2</span>
          <span class="name">On-device model</span>
          <span class="desc">Nvidia Parakeet TDT, ~500 MB, running locally on Apple Silicon. <b>No inference server exists</b> on our side, so none can be subpoenaed, breached, or misconfigured.</span>
        </div>
        <div class="stage" use:reveal={{ delay: 0.16 }}>
          <span class="idx">STAGE 3</span>
          <span class="name">Keystrokes</span>
          <span class="desc">Text enters the target app as synthetic keyboard events. <b>No clipboard pollution,</b> no intermediate storage, no transcript file.</span>
        </div>
        <div class="stage" use:reveal={{ delay: 0.24 }}>
          <span class="idx">STAGE 4</span>
          <span class="name">Garbage collector</span>
          <span class="desc">Audio buffers are freed the moment transcription completes. Delete the app and <b>nothing remains.</b></span>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ quote ============ -->
  <section class="block tight ent-quote">
    <div class="container">
      <hr class="line" use:reveal />
      <figure style="padding-top:56px">
        <blockquote use:reveal>
          &ldquo;Our previous dictation vendor required a DPIA, four
          subprocessors, and a standing exception. Typie required
          <em>a packet capture and ten minutes.</em>&rdquo;
        </blockquote>
        <figcaption use:reveal={{ delay: 0.1 }}>CISO &middot; global financial services firm &middot; 40,000 seats evaluated</figcaption>
      </figure>
    </div>
  </section>

  <!-- ============ deployment ============ -->
  <section class="block ent-deploy" id="deployment">
    <div class="container">
      <p class="eyebrow"><b>03</b> / deployment</p>
      <h2 use:reveal>Pilot to fleet<br />in under two weeks.</h2>

      <div class="grid">
        <div class="ent-step" use:reveal>
          <span class="no">/ 01</span>
          <h3>Procure</h3>
          <p>
            Volume licensing with a single agreement and a DPA sized to your
            jurisdiction. Procurement packets available on request, including
            the security whitepaper your reviewers will ask for anyway.
          </p>
        </div>
        <div class="ent-step" use:reveal={{ delay: 0.08 }}>
          <span class="no">/ 02</span>
          <h3>Deploy</h3>
          <p>
            Push the package through your existing MDM. Licenses activate via
            managed preferences. SSO-gated license portal and SCIM provisioning
            for seat management on Enterprise plans.
          </p>
        </div>
        <div class="ent-step" use:reveal={{ delay: 0.16 }}>
          <span class="no">/ 03</span>
          <h3>Roll out</h3>
          <p>
            No training required: hold a key, talk, release. Most users are
            productive within ninety seconds, which keeps adoption curves steep
            and helpdesk tickets near zero.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ visual break ============ -->
  <section class="ent-break">
    <div class="container">
      <h2 use:reveal>No servers<i>.</i> No endpoints<i>.</i> No exceptions<i>.</i></h2>
    </div>
  </section>

  <!-- ============ pricing ============ -->
  <section class="block ent-pricing" id="pricing">
    <div class="container">
      <p class="eyebrow"><b>04</b> / pricing</p>
      <h2 use:reveal>Per seat. Flat.<br />No usage meters.</h2>
      <p class="lede" use:reveal={{ delay: 0.08 }}>
        Inference runs on your hardware, so our costs do not scale with your
        usage. Neither should your invoice.
      </p>

      <div class="grid">
        <div class="plan" use:reveal>
          <div class="ent-plan">
            <span class="tier">Pilot</span>
            <div class="price">$19<small> /seat/mo</small></div>
            <ul>
              <li>Up to 50 seats</li>
              <li>MDM deployment package</li>
              <li>Email support</li>
              <li>Security whitepaper access</li>
            </ul>
            <a
              href="mailto:sales@typie.cc?subject=Pilot%20program"
              class="btn btn-ghost"
              onclick={(e) => { e.preventDefault(); pitch.show(); }}
            >Start a pilot</a>
          </div>
        </div>

        <div class="plan" use:reveal={{ delay: 0.08 }}>
          <div class="ent-plan featured">
            <div class="headrow">
              <span class="tier">Enterprise</span>
              <span class="flag">recommended</span>
            </div>
            <div class="price">$39<small> /seat/mo</small></div>
            <ul>
              <li>Unlimited seats, annual commit</li>
              <li>SSO license portal + SCIM provisioning</li>
              <li>Custom vocabulary tooling</li>
              <li>DPA + security review support</li>
              <li>Priority support, 4-hour SLA</li>
            </ul>
            <a
              href="mailto:sales@typie.cc?subject=Enterprise%20plan"
              class="btn btn-solid"
              onclick={(e) => { e.preventDefault(); pitch.show(); }}
            >Contact sales</a>
          </div>
        </div>

        <div class="plan" use:reveal={{ delay: 0.16 }}>
          <div class="ent-plan">
            <span class="tier">Sovereign</span>
            <div class="price" style="font-size:2rem;padding-block:8px">Custom</div>
            <ul>
              <li>Air-gapped model distribution</li>
              <li>Dedicated support engineer</li>
              <li>Custom SLA and procurement terms</li>
              <li>Regulated-industry deployment review</li>
            </ul>
            <a
              href="mailto:sales@typie.cc?subject=Sovereign%20deployment"
              class="btn btn-ghost"
              onclick={(e) => { e.preventDefault(); pitch.show(); }}
            >Talk to us</a>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ faq ============ -->
  <section class="block ent-faq" id="faq">
    <div class="container">
      <p class="eyebrow"><b>05</b> / faq</p>
      <h2 use:reveal>Questions your security<br />team will ask first.</h2>

      <div class="list" use:reveal={{ delay: 0.1 }}>
        {#each faqs as f, i}
          <div class="ent-item" class:open={openFaq === i}>
            <button
              class="q"
              aria-expanded={openFaq === i}
              aria-controls={'faq-a-' + i}
              onclick={() => (openFaq = openFaq === i ? -1 : i)}
            >
              {f.q}
              <span class="plus" aria-hidden="true"></span>
            </button>
            <div class="a" id={'faq-a-' + i}>
              <div><p>{f.a}</p></div>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- ============ final cta ============ -->
  <section class="ent-final">
    <div class="container">
      <h2 use:reveal>Put a voice interface<br />on every corporate Mac.</h2>
      <div class="actions" use:reveal={{ delay: 0.12 }}>
        <a
          href="mailto:sales@typie.cc?subject=Enterprise%20briefing"
          class="btn btn-solid"
          onclick={(e) => { e.preventDefault(); pitch.show(); }}
        >Book a security briefing</a>
      </div>
    </div>
  </section>

  <!-- ============ footer ============ -->
  <footer class="ent-footer">
    <div class="container top" use:reveal>
      <a href="/" class="ent-brand" style="animation:none">
        <Logo size={22} color="#34d399" />
        <span class="divider" aria-hidden="true" style="animation:none"></span>
        <small style="animation:none">enterprise</small>
      </a>

      <div class="cols">
        <div>
          <h4>Product</h4>
          <ul>
            <li><a href="/#features" use:reveal>Consumer edition</a></li>
            <li><a href="/#languages" use:reveal={{ delay: 0.06 }}>Languages</a></li>
            <li><a href="/#pricing" use:reveal={{ delay: 0.12 }}>Free tier</a></li>
          </ul>
        </div>
        <div>
          <h4>Company</h4>
          <ul>
            <li><a href="/about" use:reveal={{ delay: 0.18 }}>About</a></li>
            <li><a
              href="mailto:sales@typie.cc"
              use:reveal={{ delay: 0.24 }}
              onclick={(e) => { e.preventDefault(); pitch.show(); }}
            >sales@typie.cc</a></li>
          </ul>
        </div>
        <div>
          <h4>Legal</h4>
          <ul>
            <li><a href="/privacy" use:reveal={{ delay: 0.3 }}>Privacy</a></li>
            <li><a href="/terms" use:reveal={{ delay: 0.36 }}>Terms</a></li>
            <li><a href="mailto:legal@typie.cc" use:reveal={{ delay: 0.42 }}>DPA requests</a></li>
          </ul>
        </div>
      </div>
    </div>

    <div class="container base" use:reveal>
      <span>&copy; {new Date().getFullYear()} typie</span>
      <span>zero bytes transmitted since install</span>
    </div>
  </footer>

  <PitchBot variant="ent" />
</div>

<style>
  /* hover lift lives on inner cards/plans; the reveal animation owns
     wrapper transforms during entry */
  .plan > :global(*) {
    height: 100%;
  }
</style>
