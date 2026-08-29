<script>
  import './edu.css';
  import Logo from '../lib/Logo.svelte';
  import Robot from '../lib/Robot.svelte';
  import TalkWave from '../lib/TalkWave.svelte';
  import { reveal, countup } from '../enterprise/reveal.js';
  import VariantSwitcher from '../lib/VariantSwitcher.svelte';
  import canva from 'thesvg/canva';
  import googleClassroom from 'thesvg/google-classroom';
  import gmail from 'thesvg/gmail';
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

  /* ---- hero demo: dictation cycling through the school day's apps ----
     auto-plays above the fold; press & hold (⌥ or the keycap) to try it
     live in whichever app is on screen. */

  const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const SCENES = [
    {
      id: 'canva',
      name: 'Canva',
      brand: canva.svg,
      wave: '#00c4cc',
      title: 'Cell Biology: Period 3',
      meta: 'Presentation · 16:9',
      side: [['Design'], ['Elements'], ['Text'], ['Brand Kit'], ['Projects']],
      text: 'Mitochondria convert glucose into ATP during cellular respiration.',
    },
    {
      id: 'classroom',
      name: 'Classroom',
      brand: googleClassroom.svg,
      wave: '#188038',
      title: 'Biology: Period 3',
      meta: 'Stream',
      side: [['Stream', '2'], ['Classwork'], ['People'], ['Grades']],
      text: 'Lab reports due Friday. Cite your sources this time.',
    },
    {
      id: 'gmail',
      name: 'Gmail',
      brand: gmail.svg,
      wave: '#d93025',
      title: 'New Message',
      meta: "To Maya's parents",
      side: [['Inbox', '3'], ['Starred'], ['Sent'], ['Drafts']],
      text: 'Maya showed real grit on this project. Proud of her work.',
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

  $effect(() => {
    document.documentElement.classList.add('edu-page');

    const meta = document.querySelector('meta[name="theme-color"]');
    const prevTheme = meta?.getAttribute('content') ?? null;
    const prevTitle = document.title;
    meta?.setAttribute('content', '#f9f4e8');
    document.title = 'Typie for Education, On-Device Dictation for Schools';

    onScroll();
    return () => {
      document.documentElement.classList.remove('edu-page');
      if (meta && prevTheme !== null) meta.setAttribute('content', prevTheme);
      document.title = prevTitle;
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

  const stats = [
    {
      value: 0,
      prefix: '',
      suffix: '',
      unit: 'bytes',
      label:
        'of student audio ever transmitted. The architecture has no path out.',
    },
    {
      value: 100,
      prefix: '<',
      suffix: '',
      unit: 'ms',
      label:
        'release-to-keystroke latency. Faster than a student can find the period key.',
    },
    {
      value: 100,
      prefix: '',
      suffix: '%',
      unit: 'local',
      label:
        'of inference on-device. Works on filtered, throttled, or absent Wi-Fi.',
    },
    {
      value: 0,
      prefix: '$',
      suffix: '',
      unit: 'per seat',
      label:
        'for every educator. No licenses, no meters, no procurement cycle.',
    },
  ];

  const faqs = [
    {
      q: 'Where does student audio actually go?',
      a: 'Nowhere. Audio travels from microphone to the on-device model to a garbage collector. There is no upload endpoint, no vendor-side processing stage, and no transcript file. Delete the app and nothing remains.',
    },
    {
      q: 'Is typie FERPA and COPPA compliant?',
      a: 'Compliance frameworks govern how institutions handle student data. Typie never receives student data: no accounts, no telemetry, no audio leaving the device. We provide architecture documentation and sign DPAs so your privacy office can verify the data flow themselves.',
    },
    {
      q: 'Does it work on school networks without internet?',
      a: 'Yes. After the one-time ~500 MB model download, typie has no reason to touch the network. It works identically behind content filters, on throttled guest Wi-Fi, and on fully air-gapped machines.',
    },
    {
      q: 'Does it work with our LMS, SIS, and other apps?',
      a: 'Typie outputs standard synthetic keystrokes into whatever application has focus. Google Docs, Slides, Canvas, PowerSchool, email, legacy gradebooks, locked-down exam browsers, Electron apps. If it accepts typing, typie works there.',
    },
    {
      q: 'What about Chromebooks and Windows?',
      a: 'Today typie is native macOS on Apple Silicon, macOS 14 or newer. That is where sub-100 ms on-device inference lives. Join the campus pilot program and we will keep your district posted as platforms expand.',
    },
    {
      q: 'What does it cost?',
      a: 'Nothing for individual educators: the full engine, every language, free forever. For schools and districts, campus licensing covers MDM deployment, SSO-based seat management, and priority support. No per-minute or per-character billing, ever.',
    },
  ];
</script>

<svelte:window
  onscroll={onScroll}
  onkeydown={heroKeydown}
  onkeyup={heroKeyup}
  onpointerup={hRelease}
/>

<div
  class="edu"
  id="top"
>
  <!-- ============ nav ============ -->
  <header
    class="edu-nav"
    class:scrolled
  >
    <div class="container bar">
      <div
        class="edu-brand"
        style="--vn-fg: var(--ink); --vn-accent: var(--accent); --vn-menu-bg: var(--paper-raise); --vn-menu-border: var(--line); --vn-menu-shadow: 0 18px 44px rgba(22, 56, 43, 0.16); --vn-item-fg: var(--ink); --vn-item-muted: var(--muted); --vn-item-hover: rgba(22, 56, 43, 0.05);"
      >
        <VariantSwitcher
          variant="education"
          logoSize={24}
        />
      </div>

      <nav
        class="edu-links"
        aria-label="primary"
      >
        <a href="#why">Why typie</a>
        <a href="#classrooms">Classrooms</a>
        <a href="#deployment">Deployment</a>
        <a href="#pricing">Pricing</a>
        <a href="#faq">FAQ</a>
      </nav>

      <a
        href="mailto:sales@typie.cc?subject=Education%20pilot"
        class="btn btn-solid btn-sm"
        onclick={(e) => {
          e.preventDefault();
          pitch.show();
        }}>Book a pilot</a
      >
    </div>
    <div
      class="progress"
      style="--p:{progress}"
      aria-hidden="true"
    ></div>
  </header>

  <!-- ============ hero: asymmetric split, hand-annotated ============ -->
  <section class="edu-hero">
    <div class="container grid">
      <div>
        <p class="eyebrow hero-eyebrow">
          <b>typie for education</b>&ensp;/&ensp;K-12 &amp; higher ed
        </p>
        <h1>
          Every student<br />has a
          <span class="circled">
            voice<em>.</em>
            <svg
              class="ring"
              viewBox="0 0 230 100"
              preserveAspectRatio="none"
              aria-hidden="true"
            >
              <path
                d="M115 10 C 42 4, 8 32, 12 54 C 17 84, 96 96, 158 89 C 210 83, 224 56, 217 36 C 210 15, 166 4, 124 9"
              />
            </svg>
          </span>
        </h1>
        <p
          class="scribble"
          aria-hidden="true"
        >
          no cloud. no consent-form chase!
          <svg
            viewBox="0 0 60 44"
            aria-hidden="true"
          >
            <path d="M52 4 C 40 26, 26 32, 8 34" /><path
              d="M17 27 L 7 35 L 19 39"
            />
          </svg>
        </p>

        <p class="sub">
          Sub-100&nbsp;ms dictation, fully offline, on every school Mac. Student
          audio never leaves the device, because there is no cloud to send it
          to.
        </p>
        <div class="cta">
          <a
            href="mailto:sales@typie.cc?subject=Education%20pilot"
            class="btn btn-solid"
            onclick={(e) => {
              e.preventDefault();
              pitch.show();
            }}>Bring typie to your campus</a
          >
        </div>
      </div>

      <div
        class="hero-demo"
        bind:this={heroDemoEl}
      >
        <div
          class="hd-desktop"
          class:live={hphase === 'listening'}
          onpointerdown={(e) => {
            if (e.target.closest?.('.dock-item')) return;
            e.preventDefault();
            hPress();
          }}
        >
          <div
            class="island"
            class:idle={hphase === 'idle' || hphase === 'switch'}
            class:live={hphase === 'listening'}
            class:done={hphase === 'done'}
            aria-hidden="true"
          >
            {#if hphase === 'listening'}
              <span class="ibot"
                ><Robot
                  size={15}
                  mood="listening"
                /></span
              >
              <span class="icam"></span>
              <span class="iwave"
                ><TalkWave
                  n={5}
                  color="#fc5681"
                /></span
              >
            {:else if hphase === 'done'}
              <span class="ibot"
                ><Robot
                  size={17}
                  mood="done"
                /></span
              >
              <span class="icam"></span>
              <span class="ims">✓ 84ms</span>
            {:else}
              <span class="icam"></span>
            {/if}
          </div>

          <div
            class="menubar"
            aria-hidden="true"
          >
            <svg
              class="apple"
              viewBox="0 0 384 512"
              aria-hidden="true"
              ><path
                fill="currentColor"
                d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"
              /></svg
            >
            <span class="mitem app">{SCENES[hscene].name}</span>
            <span class="mitem">File</span>
            <span class="mitem">Edit</span>
            <span class="mitem">View</span>
            <span class="mspace"></span>
            <span class="net">NET 0 B</span>
            <svg
              class="sicn"
              viewBox="0 0 16 12"
              fill="none"
              stroke="currentColor"
              stroke-width="1.4"
              stroke-linecap="round"
              aria-hidden="true"
              ><path d="M1.5 4.4a10 10 0 0 1 13 0" /><path
                d="M3.9 7a6.4 6.4 0 0 1 8.2 0"
              /><circle
                cx="8"
                cy="9.9"
                r="1.15"
                fill="currentColor"
                stroke="none"
              /></svg
            >
            <svg
              class="sicn"
              viewBox="0 0 25 12"
              aria-hidden="true"
              ><rect
                x="0.5"
                y="0.5"
                width="21"
                height="11"
                rx="3.2"
                fill="none"
                stroke="currentColor"
              /><rect
                x="2.5"
                y="2.5"
                width="14"
                height="7"
                rx="1.6"
                fill="currentColor"
              /><path
                d="M23 4v4a2.2 2.2 0 0 0 0-4z"
                fill="currentColor"
              /></svg
            >
            <span class="mitem">9:41 AM</span>
          </div>

          <div
            class="hd-window theme-{SCENES[hscene].id}"
            class:live={hphase === 'listening'}
            class:done={hphase === 'done'}
            class:switching={hphase === 'switch'}
          >
            <div class="titlebar">
              <span
                class="lights"
                aria-hidden="true"><i></i><i></i><i></i></span
              >
              <span class="wtitle">{SCENES[hscene].title}</span>
              <span class="meta mono">{SCENES[hscene].meta}</span>
            </div>

            <div class="winbody">
              <aside class="side">
                <p class="side-h">
                  <i
                    class="bmark"
                    aria-hidden="true"
                    >{@html nsSvg(
                      SCENES[hscene].brand,
                      'hsh' + SCENES[hscene].id
                    )}</i
                  >
                  {SCENES[hscene].name}
                </p>
                <ul>
                  {#each SCENES[hscene].side as [label, count], i}
                    <li class:on={i === 0}>
                      <span>{label}</span>{#if count}<b>{count}</b>{/if}
                    </li>
                  {/each}
                </ul>
              </aside>

              <div class="paper">
                {#if hphase === 'listening'}
                  <div
                    class="talking"
                    aria-hidden="true"
                  >
                    <TalkWave
                      n={13}
                      color={SCENES[hscene].wave}
                    />
                    <p class="hint2">say anything…</p>
                  </div>
                {:else if SCENES[hscene].id === 'canva'}
                  <div class="slide">
                    <p class="slide-kicker mono">Cell Biology</p>
                    <p class="slide-title">
                      {SCENES[hscene].text.slice(
                        0,
                        hchars
                      )}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span
                          class="ghost"
                          >words land here, as real keystrokes</span
                        >{/if}<span
                        class="caret"
                        class:hidden={hphase === 'done'}
                        aria-hidden="true"
                      ></span>
                    </p>
                  </div>
                {:else if SCENES[hscene].id === 'classroom'}
                  <div class="stream">
                    <div class="shead">
                      <i
                        class="sava"
                        aria-hidden="true">MR</i
                      >
                      <div class="swho">
                        <b>Ms. Rivera</b><span class="mono"
                          >Cell Bio · just now</span
                        >
                      </div>
                    </div>
                    <p class="stream-text">
                      {SCENES[hscene].text.slice(
                        0,
                        hchars
                      )}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span
                          class="ghost"
                          >words land here, as real keystrokes</span
                        >{/if}<span
                        class="caret"
                        class:hidden={hphase === 'done'}
                        aria-hidden="true"
                      ></span>
                    </p>
                  </div>
                {:else}
                  <div class="fields">
                    <span>To: Maya's parents</span><span
                      >Subject: Science project</span
                    >
                  </div>
                  <p class="mail-text">
                    {SCENES[hscene].text.slice(
                      0,
                      hchars
                    )}{#if hchars === 0 && (hphase === 'idle' || hphase === 'switch')}<span
                        class="ghost">words land here, as real keystrokes</span
                      >{/if}<span
                      class="caret"
                      class:hidden={hphase === 'done'}
                      aria-hidden="true"
                    ></span>
                  </p>
                  <span class="sendbtn">Send</span>
                {/if}
                {#if hphase === 'done'}
                  <span class="badge mono">✓ typed in 84 ms</span>
                {/if}
              </div>
            </div>
          </div>

          <nav class="dock">
            {#each SCENES as s, i}
              <button
                class="dock-item"
                class:on={hscene === i}
                onclick={() => pick(i)}
                aria-label={s.name}
              >
                <span class="dicon"
                  ><i
                    class="dbmark"
                    aria-hidden="true">{@html nsSvg(s.brand, 'dk' + s.id)}</i
                  ></span
                >
                <i class="dot"></i>
              </button>
            {/each}
          </nav>
        </div>

        <p class="tryhint">
          <button
            class="minikey"
            class:down={hphase === 'listening'}
            onpointerdown={(e) => {
              e.preventDefault();
              hPress();
            }}
            onpointerup={hRelease}
            onpointerleave={hRelease}
            onkeydown={(e) => {
              if ((e.code === 'Space' || e.code === 'Enter') && !e.repeat) {
                e.preventDefault();
                hPress();
              }
            }}
            onkeyup={(e) => {
              if (e.code === 'Space' || e.code === 'Enter') {
                e.preventDefault();
                hRelease();
              }
            }}
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
  <div class="edu-comply">
    <div class="container row">
      <span
        class="cell"
        use:reveal><i>/</i> FERPA aligned</span
      >
      <span
        class="cell"
        use:reveal={{ delay: 0.06 }}><i>/</i> COPPA aligned</span
      >
      <span
        class="cell"
        use:reveal={{ delay: 0.12 }}><i>/</i> GDPR-K aligned</span
      >
      <span
        class="cell"
        use:reveal={{ delay: 0.18 }}><i>/</i> Zero retention</span
      >
      <span
        class="cell"
        use:reveal={{ delay: 0.24 }}><i>/</i> Audio never transmitted</span
      >
      <span
        class="cell"
        use:reveal={{ delay: 0.3 }}><i>/</i> DPA on request</span
      >
    </div>
  </div>

  <!-- ============ stats band ============ -->
  <section class="block edu-stats">
    <div class="container">
      <div class="grid">
        {#each stats as s, i}
          <div
            class="stat"
            use:reveal={{ delay: i * 0.08 }}
          >
            <span class="num"
              >{s.prefix}<span
                data-count={s.value}
                use:countup>{s.value}</span
              ><sub>{s.unit}</sub></span
            >
            <span class="label">{s.label}</span>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- ============ why typie: bento ============ -->
  <section
    class="block edu-bento"
    id="why"
  >
    <div class="container">
      <p class="eyebrow"><b>01</b> / why typie</p>
      <h2 use:reveal>The daily tool your<br />devices already owed you.</h2>
      <p
        class="lede"
        use:reveal={{ delay: 0.08 }}
      >
        One native app, installed once, working in every application on every
        Mac. No integrations to maintain, no vendor dashboard, no per-app
        plugins to break after every update.
      </p>

      <div class="grid">
        <div
          class="edu-card-wrap primary"
          use:reveal
        >
          <div class="edu-card">
            <span class="tag">works everywhere</span>
            <h3>Every app they already use</h3>
            <p>
              Output lands as real keyboard events in whatever has focus: Docs,
              Slides, Canvas, PowerSchool, email, legacy gradebooks, locked-down
              exam browsers. If it accepts typing, typie works there.
            </p>
            <pre>$ typie --trace
mic        ▸ on-device ASR (nvidia parakeet, local)
network    ▸ bytes transmitted: <b>0</b>
telemetry  ▸ endpoints configured: <b>none</b>
output     ▸ CGEvent keystrokes ▸ active application</pre>
            <p>
              This is the entire data flow. Three hops, none of them leave the
              machine. Your privacy office can verify it with a packet capture
              between periods.
            </p>
          </div>
        </div>

        <div
          class="edu-card-wrap"
          use:reveal={{ delay: 0.08 }}
        >
          <div class="edu-card">
            <span class="tag">your curriculum</span>
            <h3>Speaks the subject</h3>
            <p>
              Photosynthesis, mitochondria, the Treaty of Versailles, AP Chem
              nomenclature. Domain terminology recognized correctly, in 100+
              languages, on hardware the district already owns.
            </p>
          </div>
        </div>

        <div
          class="edu-card-wrap"
          use:reveal={{ delay: 0.16 }}
        >
          <div class="edu-card">
            <span class="tag">it-friendly</span>
            <h3>MDM-native deployment</h3>
            <p>
              Standard .app packaging for Jamf, Kandji, and Intune. No daemons,
              no kernel extensions, no system services, no helpdesk tickets.
            </p>
          </div>
        </div>

        <div
          class="edu-card-wrap half"
          use:reveal={{ delay: 0.24 }}
        >
          <div class="edu-card">
            <span class="tag">accessibility</span>
            <h3>Built-in, not bolted-on</h3>
            <p>
              Sub-100 ms voice input supports WCAG 2.2 and Section 508 goals,
              with remappable hold-to-talk keys for every motor-preference
              profile. An accommodation that feels like a superpower.
            </p>
          </div>
        </div>

        <div
          class="edu-card-wrap half"
          use:reveal={{ delay: 0.32 }}
        >
          <div class="edu-card">
            <span class="tag">student records</span>
            <div class="bignum">
              <span
                data-count={0}
                use:countup>0</span
              >
            </div>
            <p>voice recordings stored anywhere. Ever.</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ classrooms: stacked showcase ============ -->
  <section
    class="block edu-class"
    id="classrooms"
  >
    <div class="container">
      <p class="eyebrow"><b>02</b> / classrooms</p>
      <h2 use:reveal>One tool.<br />Three jobs done.</h2>

      <div class="rows">
        <div
          class="row"
          use:reveal
        >
          <div class="txt">
            <span class="tag">teachers</span>
            <h3>Feedback at the speed of speech</h3>
            <p>
              Comments in Docs, notes in the gradebook, parent emails between
              classes. Teachers speak roughly three times faster than they type,
              which turns Sunday-night marking into an afternoon task.
            </p>
          </div>
          <div class="viz tilt-l">
            <div class="card-note">
              <p class="note-q">
                &ldquo;Strong thesis, tighten paragraph two and cite your
                source.&rdquo;
              </p>
              <p class="note-m">
                feedback · 38 words · 11s spoken · 0 bytes sent
              </p>
            </div>
          </div>
        </div>

        <div
          class="row flip"
          use:reveal
        >
          <div class="txt">
            <span class="tag">students</span>
            <h3>Draft out loud, revise in writing</h3>
            <p>
              First drafts dictated before self-consciousness kicks in. For ELL
              learners, students with dyslexia, and anyone whose ideas outrun
              their keyboarding, the gap between thinking and writing closes.
            </p>
          </div>
          <div class="viz tilt-r">
            <div class="card-note">
              <p class="note-q">
                &ldquo;Intro, three body paragraphs, counterclaim,
                conclusion.&rdquo;
              </p>
              <p class="note-m">outline · 480 words drafted · 100% offline</p>
            </div>
          </div>
        </div>

        <div
          class="row"
          use:reveal
        >
          <div class="txt">
            <span class="tag">it &amp; administration</span>
            <h3>Nothing to audit. Nothing to breach.</h3>
            <p>
              No student data ever reaches a vendor, so there is no incident
              response plan to write and no breach notification letter to dread.
              Push the package over MDM and the deployment is finished.
            </p>
          </div>
          <div class="viz tilt-l">
            <div class="card-note dark">
              <pre>$ privacy-review typie
student records stored   ▸ <b>0</b>
subprocessors            ▸ <b>none</b>
breach surface           ▸ <b>n/a</b></pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ quote ============ -->
  <section class="block tight edu-quote">
    <div class="container">
      <hr
        class="line"
        use:reveal
      />
      <figure style="padding-top:56px">
        <blockquote use:reveal>
          &ldquo;Our previous dictation tool sent student audio to three
          subprocessors. Typie sends it to
          <em>a garbage collector.</em>&rdquo;
        </blockquote>
        <figcaption use:reveal={{ delay: 0.1 }}>
          Director of technology &middot; public school district &middot; 4,000
          staff MacBooks
        </figcaption>
      </figure>
    </div>
  </section>

  <!-- ============ deployment ============ -->
  <section
    class="block edu-deploy"
    id="deployment"
  >
    <div class="container">
      <p class="eyebrow"><b>03</b> / deployment</p>
      <h2 use:reveal>Pilot to rollout<br />in one prep term.</h2>

      <div class="grid">
        <div
          class="edu-step"
          use:reveal
        >
          <span class="no">/ 01</span>
          <h3>Pilot</h3>
          <p>
            Start free with a single department. Ten minutes of setup, no
            training required: hold a key, talk, release. Gather the staff
            quotes while your privacy office reads the architecture docs.
          </p>
        </div>
        <div
          class="edu-step"
          use:reveal={{ delay: 0.08 }}
        >
          <span class="no">/ 02</span>
          <h3>Deploy</h3>
          <p>
            Push the package through your existing MDM. Campus licensing adds
            SSO-based seat management and a DPA sized to your jurisdiction.
            Nothing touches your network after day one.
          </p>
        </div>
        <div
          class="edu-step"
          use:reveal={{ delay: 0.16 }}
        >
          <span class="no">/ 03</span>
          <h3>Roll out</h3>
          <p>
            Most users are productive in ninety seconds, which keeps adoption
            steep and PD sessions short. Helpdesk tickets stay near zero because
            there is no cloud service to go down.
          </p>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ visual break ============ -->
  <section class="edu-break">
    <div class="container">
      <h2 use:reveal>
        No uploads<i>.</i> No transcripts<i>.</i> No exceptions<i>.</i>
      </h2>
    </div>
  </section>

  <!-- ============ pricing ============ -->
  <section
    class="block edu-pricing"
    id="pricing"
  >
    <div class="container">
      <p class="eyebrow"><b>04</b> / pricing</p>
      <h2 use:reveal>Free for teachers.<br />Honest for districts.</h2>
      <p
        class="lede"
        use:reveal={{ delay: 0.08 }}
      >
        Inference runs on hardware schools already own, so our costs do not
        scale with your usage. Neither should your invoice.
      </p>

      <div class="grid">
        <div
          class="plan"
          use:reveal
        >
          <div class="edu-plan featured">
            <div class="headrow">
              <span class="tier">Educator</span>
              <span class="flag">free forever</span>
            </div>
            <div class="price">$0<small> /seat/mo</small></div>
            <ul>
              <li>Full engine, every language</li>
              <li>Unlimited dictation, no meters</li>
              <li>Remappable hotkeys &amp; vocabularies</li>
              <li>All future updates included</li>
            </ul>
            <a
              href="/#download"
              class="btn btn-solid">Get typie free</a
            >
          </div>
        </div>

        <div
          class="plan"
          use:reveal={{ delay: 0.08 }}
        >
          <div class="edu-plan">
            <span class="tier">Campus &amp; District</span>
            <div
              class="price"
              style="font-size:2rem;padding-block:8px"
            >
              Talk to us
            </div>
            <ul>
              <li>Volume licensing via MDM</li>
              <li>SSO portal + SCIM seat management</li>
              <li>DPA + privacy review support</li>
              <li>Priority support with SLA</li>
              <li>District-wide rollout planning</li>
            </ul>
            <a
              href="mailto:sales@typie.cc?subject=Campus%20licensing"
              class="btn btn-ghost"
              onclick={(e) => {
                e.preventDefault();
                pitch.show();
              }}>Contact us</a
            >
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============ faq ============ -->
  <section
    class="block edu-faq"
    id="faq"
  >
    <div class="container">
      <p class="eyebrow"><b>05</b> / faq</p>
      <h2 use:reveal>Questions your privacy<br />office asks first.</h2>

      <div
        class="list"
        use:reveal={{ delay: 0.1 }}
      >
        {#each faqs as f, i}
          <div
            class="edu-item"
            class:open={openFaq === i}
          >
            <button
              class="q"
              aria-expanded={openFaq === i}
              aria-controls={'edu-faq-a-' + i}
              onclick={() => (openFaq = openFaq === i ? -1 : i)}
            >
              {f.q}
              <span
                class="plus"
                aria-hidden="true"
              ></span>
            </button>
            <div
              class="a"
              id={'edu-faq-a-' + i}
            >
              <div><p>{f.a}</p></div>
            </div>
          </div>
        {/each}
      </div>
    </div>
  </section>

  <!-- ============ final cta ============ -->
  <section class="edu-final">
    <div class="container">
      <h2 use:reveal>Give every classroom<br />a voice<em>.</em></h2>
      <div
        class="actions"
        use:reveal={{ delay: 0.12 }}
      >
        <a
          href="mailto:sales@typie.cc?subject=Education%20pilot"
          class="btn btn-solid"
          onclick={(e) => {
            e.preventDefault();
            pitch.show();
          }}>Book a campus pilot</a
        >
      </div>
    </div>
  </section>

  <!-- ============ footer ============ -->
  <footer class="edu-footer">
    <div
      class="container top"
      use:reveal
    >
      <a
        href="/"
        class="edu-brand"
      >
        <Logo size={22} />
        <span
          class="divider"
          aria-hidden="true"
        ></span>
        <small>education</small>
      </a>

      <div class="cols">
        <div>
          <h4>Product</h4>
          <ul>
            <li><a href="/">Consumer edition</a></li>
            <li><a href="/enterprise">Enterprise</a></li>
            <li><a href="/#languages">Languages</a></li>
          </ul>
        </div>
        <div>
          <h4>Education</h4>
          <ul>
            <li><a href="#top">Try it live</a></li>
            <li><a href="#deployment">Deployment</a></li>
            <li><a href="#pricing">Campus licensing</a></li>
          </ul>
        </div>
        <div>
          <h4>Contact</h4>
          <ul>
            <li>
              <a
                href="mailto:sales@typie.cc?subject=Education"
                onclick={(e) => {
                  e.preventDefault();
                  pitch.show();
                }}>sales@typie.cc</a
              >
            </li>
            <li><a href="/about">About</a></li>
          </ul>
        </div>
        <div>
          <h4>Legal</h4>
          <ul>
            <li><a href="/privacy">Privacy</a></li>
            <li><a href="/terms">Terms</a></li>
            <li><a href="mailto:legal@typie.cc">DPA requests</a></li>
          </ul>
        </div>
      </div>
    </div>

    <div
      class="container base"
      use:reveal
    >
      <span>&copy; {new Date().getFullYear()} typie</span>
      <span>zero bytes transmitted since install</span>
    </div>
  </footer>

  <PitchBot variant="edu" />
</div>

<style>
  /* hover lift lives on inner cards/plans; the reveal animation owns
     wrapper transforms during entry */
  .plan > :global(*) {
    height: 100%;
  }
</style>
