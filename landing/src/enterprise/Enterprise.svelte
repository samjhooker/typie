<script>
  import './ent.css';
  import Logo from '../lib/Logo.svelte';
  import Robot from '../lib/Robot.svelte';
  import TalkWave from '../lib/TalkWave.svelte';
  import { reveal, countup } from './reveal.js';

  let scrolled = $state(false);
  let progress = $state(0);
  let openFaq = $state(0);

  const onScroll = () => {
    scrolled = window.scrollY > 24;
    const max = document.documentElement.scrollHeight - window.innerHeight;
    progress = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
  };

  /* ---- live demo: hold-to-dictate inside a mock corporate window ---- */

  const PHRASE = 'Q3 revenue is up 14 percent and churn held flat at 2.1 percent.';
  const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  let demoEl = $state(null);
  let demoVisible = $state(false);
  let phase = $state(REDUCED ? 'done' : 'idle'); // idle | listening | typing | done
  let chars = $state(REDUCED ? PHRASE.length : 0);
  let elapsed = $state(0);

  let timers = [];
  let rafId = 0;
  let listenStart = 0;

  const later = (fn, ms) => timers.push(setTimeout(fn, ms));

  function clearTimers() {
    timers.forEach(clearTimeout);
    timers = [];
    cancelAnimationFrame(rafId);
  }

  function startListen() {
    if (phase === 'listening') return;
    clearTimers();
    phase = 'listening';
    chars = 0;
    elapsed = 0;
    listenStart = performance.now();
    const tick = (now) => {
      elapsed = (now - listenStart) / 1000;
      if (phase === 'listening') rafId = requestAnimationFrame(tick);
    };
    rafId = requestAnimationFrame(tick);
  }

  function endListen() {
    if (phase !== 'listening') return;
    clearTimers();
    elapsed = Math.max((performance.now() - listenStart) / 1000, 0.4);
    phase = 'typing';
    // one short inference beat, then the keystroke burst —
    // mirrors the real release-to-text latency
    later(typeOut, 90);
  }

  function typeOut() {
    phase = 'typing';
    if (REDUCED) {
      chars = PHRASE.length;
      phase = 'done';
      return;
    }
    // CGEvent burst: the whole phrase lands in ~250ms,
    // not at human typing speed
    const step = () => {
      chars = Math.min(chars + 4, PHRASE.length);
      if (chars < PHRASE.length) later(step, 16);
      else {
        phase = 'done';
        later(reset, 3400);
      }
    };
    step();
  }

  function reset() {
    phase = 'idle';
    chars = 0;
    elapsed = 0;
    // keep looping for passive viewers while the demo is on screen
    if (demoVisible) later(autoRun, 1600);
  }

  function autoRun() {
    startListen();
    later(endListen, 2100);
  }

  function demoKeydown(e) {
    if ((e.code === 'Space' || e.code === 'Enter') && !e.repeat) {
      e.preventDefault();
      startListen();
    }
  }

  function demoKeyup(e) {
    if (e.code === 'Space' || e.code === 'Enter') {
      e.preventDefault();
      endListen();
    }
  }

  // the real product binds to option — so does the demo, page-wide,
  // while the demo section is in view
  function windowKeydown(e) {
    if (e.key === 'Alt' && demoVisible && !e.repeat) {
      e.preventDefault();
      startListen();
    }
  }

  function windowKeyup(e) {
    if (e.key === 'Alt' && demoVisible) {
      e.preventDefault();
      endListen();
    }
  }

  // auto-play while the demo is on screen; pause when it leaves
  $effect(() => {
    if (REDUCED || !demoEl) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        demoVisible = entry.isIntersecting;
        if (entry.isIntersecting) {
          if (phase === 'idle') autoRun();
        } else {
          clearTimers();
          phase = 'idle';
          chars = 0;
          elapsed = 0;
        }
      },
      { threshold: 0.35 }
    );
    io.observe(demoEl);
    return () => {
      io.disconnect();
      clearTimers();
    };
  });

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

<svelte:window onscroll={onScroll} onkeydown={windowKeydown} onkeyup={windowKeyup} />

<div class="ent" id="top">
  <!-- ============ nav ============ -->
  <header class="ent-nav" class:scrolled>
    <div class="container bar">
      <a href="#top" class="ent-brand" aria-label="typie enterprise home">
        <Logo size={24} color="#34d399" />
        <span class="divider" aria-hidden="true"></span>
        <small>enterprise</small>
      </a>

      <nav class="ent-links" aria-label="primary">
        <a href="#demo">Demo</a>
        <a href="#platform">Platform</a>
        <a href="#security">Security</a>
        <a href="#deployment">Deployment</a>
        <a href="#pricing">Pricing</a>
        <a href="#faq">FAQ</a>
      </nav>

      <a href="mailto:sales@typie.cc?subject=Enterprise%20briefing" class="btn btn-solid btn-sm">Book a briefing</a>
    </div>
    <div class="progress" style="--p:{progress}" aria-hidden="true"></div>
  </header>

  <!-- ============ hero / architecture B asymmetric split ============ -->
  <section class="ent-hero">
    <div class="container grid">
      <div>
        <p class="eyebrow hero-eyebrow"><b>typie enterprise</b>&ensp;/&ensp;on-device voice input</p>
        <h1><em>Zero</em> attack surface.</h1>
      </div>

      <div>
        <p class="sub">
          Enterprise dictation at sub-100ms on every corporate Mac. Audio
          never leaves the device, and there is nothing to breach.
        </p>
        <div class="cta">
          <a href="mailto:sales@typie.cc?subject=Enterprise%20briefing" class="btn btn-solid">Book a security briefing</a>
        </div>
        <div class="meta">
          <span><b>&gt;</b> on-device speech infrastructure</span>
          <span><b>&gt;</b> apple silicon · macos 14+</span>
          <span><b>&gt;</b> fleet deployment via MDM</span>
        </div>
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

  <!-- ============ live demo ============ -->
  <section class="block ent-demo" id="demo" bind:this={demoEl}>
    <div class="container">
      <p class="eyebrow"><b>01</b> / live demo</p>
      <h2 use:reveal>Hold a key. Say the thing.<br />It's typed.</h2>
      <p class="lede" use:reveal={{ delay: 0.08 }}>
        This is the entire product. Hold to dictate, release, and the words
        land as real keystrokes in whatever app has focus. Try it here, or
        just watch.
      </p>

      <div class="stage" use:reveal={{ delay: 0.12 }}>
        <div class="desktop">
          <div
            class="island"
            class:idle={phase === 'idle'}
            class:live={phase === 'listening'}
            class:done={phase === 'done'}
            aria-hidden="true"
          >
            {#if phase === 'listening'}
              <span class="ibot"><Robot size={17} mood="listening" /></span>
              <span class="icam"></span>
              <span class="iwave"><TalkWave n={5} color="#34d399" /></span>
            {:else if phase === 'done'}
              <span class="ibot"><Robot size={19} mood="done" /></span>
              <span class="icam"></span>
              <span class="ims">✓ 84ms</span>
            {:else}
              <span class="icam"></span>
            {/if}
          </div>

          <div class="menubar" aria-hidden="true">
            <span class="mitem app">Notes</span>
            <span class="mitem">File</span>
            <span class="mitem">Edit</span>
            <span class="mitem">View</span>
            <span class="mspace"></span>
            <span class="net">NET 0 B</span>
            <span class="mitem">9:41 AM</span>
          </div>

          <div class="notepad" class:live={phase === 'listening'}>
            <div class="titlebar">
              <span class="lights" aria-hidden="true"><i></i><i></i><i></i></span>
              <span class="title">Q3 board update</span>
              <span class="tspace" aria-hidden="true"></span>
            </div>

            <div class="sheet">
              <p class="typed">
                {PHRASE.slice(0, chars)}{#if chars === 0 && phase === 'idle'}<span class="ghost">Dictation will appear here, as real keystrokes.</span>{/if}<span class="caret" class:hidden={phase === 'done'} aria-hidden="true"></span>
              </p>
            </div>

            <div class="status">
              <div class="who">
                <span class="bot" class:active={phase !== 'idle'}>
                  <Robot size={34} mood={phase === 'typing' ? 'thinking' : phase} />
                </span>
                <span class="bars" aria-hidden="true"><TalkWave n={9} color="#34d399" /></span>
                <span class="phase-label">
                  {phase === 'idle'
                    ? 'idle — hold ⌥ to dictate'
                    : phase === 'listening'
                      ? `listening — on-device · ${elapsed.toFixed(1)}s`
                      : phase === 'typing'
                        ? 'typing — synthetic keystrokes'
                        : 'done — 84 ms release-to-text'}
                </span>
              </div>
              <span class="chip" class:show={phase === 'done'}>84 ms</span>
            </div>
          </div>
        </div>

        <div class="controls">
          <p class="holdline">
            hold
            <button
              class="key"
              class:down={phase === 'listening'}
              onpointerdown={(e) => { e.preventDefault(); startListen(); }}
              onpointerup={endListen}
              onpointerleave={endListen}
              onkeydown={demoKeydown}
              onkeyup={demoKeyup}
              aria-label="the option key - press and hold to dictate"
            >
              <span class="ksym" aria-hidden="true">&#8997;</span>
              <span class="klbl">option</span>
            </button>
            and talk. release, and it's typed.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ platform bento ============ -->
  <section class="block ent-bento" id="platform">
    <div class="container">
      <p class="eyebrow"><b>02</b> / platform</p>
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
      <p class="eyebrow"><b>03</b> / security</p>
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
      <p class="eyebrow"><b>04</b> / deployment</p>
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
      <p class="eyebrow"><b>05</b> / pricing</p>
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
            <a href="mailto:sales@typie.cc?subject=Pilot%20program" class="btn btn-ghost">Start a pilot</a>
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
            <a href="mailto:sales@typie.cc?subject=Enterprise%20plan" class="btn btn-solid">Contact sales</a>
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
            <a href="mailto:sales@typie.cc?subject=Sovereign%20deployment" class="btn btn-ghost">Talk to us</a>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ faq ============ -->
  <section class="block ent-faq" id="faq">
    <div class="container">
      <p class="eyebrow"><b>06</b> / faq</p>
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
        <a href="mailto:sales@typie.cc?subject=Enterprise%20briefing" class="btn btn-solid">Book a security briefing</a>
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
            <li><a href="mailto:sales@typie.cc" use:reveal={{ delay: 0.24 }}>sales@typie.cc</a></li>
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
</div>

<style>
  /* hover lift lives on inner cards/plans; the reveal animation owns
     wrapper transforms during entry */
  .plan > :global(*) {
    height: 100%;
  }
</style>
