<script>
  import {
    Mic,
    Accessibility,
    MonitorSpeaker,
    Keyboard,
    Zap,
    WifiOff,
    Brain,
    Ear,
    Check,
    AudioLines,
    ShieldCheck,
    NotebookPen,
    FileUp,
    Phone,
  } from 'lucide-svelte';
  import Robot from './Robot.svelte';
  import DownloadGame from './DownloadGame.svelte';
  import DevTag from './DevTag.svelte';
  import { ui, local, send } from './bridge.svelte.js';

  const STEP_COUNT = 4;

  // ── model states ─────────────────────────────────────────────
  const modelReady = $derived(ui.model.status === 'ready');
  const downloadApproved = $derived(
    ui.model.status !== 'notDownloaded' || ui.modelsExist
  );

  // speaker-label models (diarization) — downloaded alongside the main brain
  const diarizerState = $derived(ui.transcribe.model.state);
  const diarizerReady = $derived(diarizerState === 'ready');
  const diarizerBusy = $derived(
    diarizerState === 'downloading' ||
      diarizerState === 'compiling' ||
      diarizerState === 'unknown'
  );
  const diarizerFraction = $derived(ui.transcribe.model.fraction || 0);
  const allDownloadsReady = $derived(modelReady && diarizerReady);
  const anythingFailed = $derived(
    ui.model.status === 'failed' || diarizerState === 'failed'
  );

  // ── permissions — all three required ─────────────────────────
  const allPermissionsDone = $derived(
    ui.permissions.mic && ui.permissions.ax && ui.permissions.screen
  );

  const robotMood = $derived(
    local.step === 2
      ? allDownloadsReady
        ? 'done'
        : ui.model.status === 'downloading' ||
            ui.model.status === 'loading' ||
            diarizerBusy
          ? 'thinking'
          : 'idle'
      : local.step === 3
        ? 'listening'
        : 'idle'
  );

  // kick BOTH downloads off as soon as the user engages — by the time they
  // reach the downloads step the brain is usually already halfway home.
  // If files are already on disk we still need to send, so they load into
  // memory (modelsExist but model.status is still 'notDownloaded').
  function startDownloads() {
    if (!modelReady) send({ type: 'startModelDownload' });
    if (!diarizerReady) send({ type: 'startDiarizerDownload' });
  }

  let autoAdvancing = false;

  /** single path for every step change so side effects stay consistent */
  function goTo(step) {
    if (step <= local.step || step >= STEP_COUNT) return;
    // re-check mode: permissions step is the only one needed
    if (local.recheck && local.step === 1 && step === 2) {
      local.recheck = false;
      send({ type: 'completeOnboarding' });
      return;
    }
    if (step >= 1) startDownloads();
    // hotkey must go live entering the practice step
    if (step === 3) send({ type: 'onboardingReadyStep' });
    autoAdvancing = false;
    local.step = step;
  }

  // ── magic: the flow advances itself ──────────────────────────
  // permissions done? drift onward. downloads landed? celebrate, then move.
  $effect(() => {
    if (local.step === 1 && allPermissionsDone) {
      const t = setTimeout(() => {
        if (local.step === 1) {
          if (local.recheck) {
            // re-check mode: just permissions, skip downloads/practice
            local.recheck = false;
            send({ type: 'completeOnboarding' });
          } else {
            autoAdvancing = true;
            goTo(2);
          }
        }
      }, 1100);
      return () => clearTimeout(t);
    }
  });
  $effect(() => {
    if (
      local.step === 2 &&
      modelReady &&
      (diarizerReady || diarizerState === 'failed')
    ) {
      const t = setTimeout(() => {
        if (local.step === 2) {
          autoAdvancing = true;
          goTo(3);
        }
      }, 1800);
      return () => clearTimeout(t);
    }
  });

  const buttonLabel = $derived.by(() => {
    switch (local.step) {
      case 0:
        return "let's go →";
      case 1:
        return allPermissionsDone ? 'next' : 'waiting…';
      case 2:
        return allDownloadsReady
          ? 'continue'
          : anythingFailed
            ? 'continue anyway'
            : modelReady
              ? 'finishing speaker labels…'
              : 'downloading…';
      default:
        return '';
    }
  });

  const nextEnabled = $derived(
    local.step === 0 ||
      (local.step === 1 && allPermissionsDone) ||
      (local.step === 2 &&
        modelReady &&
        (diarizerReady || diarizerState === 'failed'))
  );

  const stepHint = $derived(
    [
      'no account, no cloud, ever',
      'one-time things — we’ll never ask again',
      autoAdvancing
        ? 'moving on its own…'
        : 'the whole brain + ears, onto this Mac',
      'try it — say something nice',
    ][local.step]
  );

  const progressPct = $derived(((local.step + 1) / STEP_COUNT) * 100);
</script>

<div class="onboard">
  <div
    class="blob b1"
    aria-hidden="true"
  ></div>
  <div
    class="blob b2"
    aria-hidden="true"
  ></div>

  <div
    class="rail"
    aria-hidden="true"
  >
    <div
      class="rail-fill"
      style="width:{progressPct}%"
    ></div>
  </div>

  <header class="top">
    <div class="brand">
      <Robot
        size={26}
        mood={robotMood}
      />
      <span class="word">typie{ui.variant === 'dev' ? ' dev' : ''}<i>.</i></span
      >
      <DevTag />
    </div>
    <span class="mono-kicker">step {local.step + 1} of {STEP_COUNT}</span>
  </header>

  <main>
    {#key local.step}
      {#if local.step === 0}
        <section class="welcome enter-up">
          <div class="big-bot">
            <Robot
              size={54}
              mood="idle"
            />
          </div>
          <h1>hold a key. say the thing.</h1>
          <p class="sub">
            Your words appear wherever your cursor is — entirely on this Mac.
          </p>
          <div class="trio">
            <div class="card trio-card">
              <span
                class="tile"
                style="background:var(--mint)"><Keyboard size={20} /></span
              >
              <strong>works everywhere</strong>
              <span>any app that accepts typing</span>
            </div>
            <div class="card trio-card">
              <span
                class="tile"
                style="background:var(--butter)"><Zap size={20} /></span
              >
              <strong>instant</strong>
              <span>text lands in ~100 ms</span>
            </div>
            <div class="card trio-card">
              <span
                class="tile"
                style="background:var(--sky)"><ShieldCheck size={20} /></span
              >
              <strong>zero cloud</strong>
              <span>audio never leaves this Mac</span>
            </div>
          </div>
        </section>
      {:else if local.step === 1}
        <section class="perms enter-up">
          <h1>three quick permissions</h1>
          <p class="sub">
            one-time things, straight to macOS — typie never sees them twice
          </p>

          <div class="perm-list">
            <div
              class="card perm"
              class:granted={ui.permissions.mic}
            >
              <span
                class="tile"
                style="background:var(--mint)"><Mic size={21} /></span
              >
              <div class="body">
                <strong>Microphone</strong>
                <p>
                  hears you while the key is held. processed on-device, thrown
                  away after.
                </p>
              </div>
              {#if ui.permissions.mic}
                <span class="chip granted-chip"><Check size={12} />granted</span
                >
              {:else}
                <button
                  class="btn btn-pink small"
                  onclick={() => send({ type: 'requestMicPermission' })}
                >
                  allow
                </button>
              {/if}
            </div>

            <div
              class="card perm"
              class:granted={ui.permissions.ax}
            >
              <span
                class="tile"
                style="background:var(--lavender)"
                ><Accessibility size={21} /></span
              >
              <div class="body">
                <strong>Accessibility</strong>
                <p>
                  watches for the hotkey and types where your cursor already is.
                </p>
              </div>
              {#if ui.permissions.ax}
                <span class="chip granted-chip"><Check size={12} />granted</span
                >
              {:else}
                <button
                  class="btn btn-pink small"
                  onclick={() => send({ type: 'requestAccessibility' })}
                >
                  allow
                </button>
              {/if}
            </div>

            <div
              class="card perm"
              class:granted={ui.permissions.screen}
            >
              <span
                class="tile"
                style="background:var(--card-blue)"
                ><MonitorSpeaker size={21} /></span
              >
              <div class="body">
                <strong>Screen recording</strong>
                <p>
                  captures call audio so meeting transcripts include everyone.
                </p>
                {#if !ui.permissions.screen}
                  <span class="relaunch"
                    >macOS finishes this one after a relaunch</span
                  >
                {/if}
              </div>
              {#if ui.permissions.screen}
                <span class="chip granted-chip"><Check size={12} />granted</span
                >
              {:else}
                <button
                  class="btn btn-pink small"
                  onclick={() => send({ type: 'requestScreenPermission' })}
                >
                  allow
                </button>
              {/if}
            </div>
          </div>
        </section>
      {:else if local.step === 2}
        <section class="model enter-up">
          <div
            class="halo"
            class:pulse={!allDownloadsReady}
          >
            <Robot
              size={56}
              mood={robotMood}
            />
          </div>
          <h1>{allDownloadsReady ? 'all set' : 'one-time downloads'}</h1>

          {#if modelReady && diarizerReady}
            <p class="note">
              <WifiOff size={15} /> everything's installed — from here on, everything
              happens offline.
            </p>
          {:else}
            <!-- main ASR model -->
            <div
              class="card dlrow"
              class:done={modelReady}
              class:failed={ui.model.status === 'failed'}
            >
              <span
                class="tile"
                style="background:var(--mint)"><Brain size={21} /></span
              >
              <div class="body">
                <header class="rowhead">
                  <strong>the brain</strong><span class="mono-kicker"
                    >dictation · ~470 mb</span
                  >
                </header>
                {#if modelReady}
                  <p class="stat done"><Check size={12} /> ready</p>
                {:else if ui.model.status === 'failed'}
                  <p class="error">{ui.model.error}</p>
                  <button
                    class="btn btn-pink small"
                    onclick={() => send({ type: 'startModelDownload' })}
                    >try again</button
                  >
                {:else if ui.model.status === 'loading'}
                  <div class="progress"><div style="width:98%"></div></div>
                  <p class="stat">waking it up…</p>
                {:else}
                  <div class="progress">
                    <div
                      style="width:{Math.max(3, ui.model.fraction * 100)}%"
                    ></div>
                  </div>
                  <p class="stat">
                    {ui.model.fraction > 0.01
                      ? `${Math.round(ui.model.fraction * 100)}% · ${Math.round(ui.model.fraction * 470)} / ~470 mb${ui.eta ? ` · ${ui.eta}` : ''}`
                      : 'starting…'}
                  </p>
                {/if}
              </div>
            </div>

            <!-- speaker-label models -->
            <div
              class="card dlrow"
              class:done={diarizerReady}
              class:failed={diarizerState === 'failed'}
            >
              <span
                class="tile"
                style="background:var(--lavender)"><Ear size={21} /></span
              >
              <div class="body">
                <header class="rowhead">
                  <strong>the ears</strong><span class="mono-kicker"
                    >speaker labels · ~{ui.transcribe.downloadMB || 22} mb</span
                  >
                </header>
                {#if diarizerReady}
                  <p class="stat done"><Check size={12} /> ready</p>
                {:else if diarizerState === 'failed'}
                  <p class="error">{ui.transcribe.model.error}</p>
                  <button
                    class="btn btn-pink small"
                    onclick={() => send({ type: 'startDiarizerDownload' })}
                    >try again</button
                  >
                {:else if diarizerState === 'compiling'}
                  <div class="progress"><div style="width:96%"></div></div>
                  <p class="stat">waking them up…</p>
                {:else}
                  <div class="progress">
                    <div
                      style="width:{Math.max(3, diarizerFraction * 100)}%"
                    ></div>
                  </div>
                  <p class="stat">
                    {diarizerFraction > 0.01
                      ? `${Math.round(diarizerFraction * 100)}% downloading${ui.transcribe.eta ? ` · ${ui.transcribe.eta}` : ''}`
                      : 'starting…'}
                  </p>
                {/if}
              </div>
            </div>

            <p class="note">
              after this, typie never needs the internet again.
            </p>

            {#if !anythingFailed}
              <DownloadGame />
            {/if}
          {/if}
        </section>
      {:else}
        <section class="ready enter-up">
          <h1 class="turn">now you.</h1>

          <div class="how">
            <span class="cap-static">{ui.settings.hotkeyShort}</span>
            <p class="how-text">
              {#if ui.settings.triggerMode === 'toggle'}
                tap <b>{ui.settings.hotkey.toLowerCase()}</b>, say anything out
                loud, tap again.
              {:else}
                hold <b>{ui.settings.hotkey.toLowerCase()}</b>, say anything out
                loud, let go.
              {/if}
            </p>
          </div>

          <div
            class="result card"
            class:flash={local.flash}
          >
            {#if ui.dictation.phase === 'listening'}
              <span class="state live"><AudioLines size={18} /> listening…</span
              >
            {:else if ui.dictation.phase === 'transcribing'}
              <span class="state think">thinking…</span>
            {:else if local.practice}
              <p class="words">{local.practice}</p>
            {:else}
              <p class="placeholder">
                your words will land here — in big letters
              </p>
            {/if}
          </div>

          <div class="more">
            <span class="mono-kicker">more to explore inside</span>
            <div class="feat-row">
              <div class="card feat">
                <span
                  class="tile sm"
                  style="background:var(--card-cream)"
                  ><NotebookPen size={18} /></span
                >
                <div>
                  <strong>quick notes</strong><span
                    >dictation kept with its audio</span
                  >
                </div>
              </div>
              <div class="card feat">
                <span
                  class="tile sm"
                  style="background:var(--card-blue)"><FileUp size={18} /></span
                >
                <div>
                  <strong>upload audio</strong><span
                    >transcripts with speaker labels</span
                  >
                </div>
              </div>
              <div class="card feat">
                <span
                  class="tile sm"
                  style="background:var(--pink)"><Phone size={18} /></span
                >
                <div>
                  <strong>meeting capture</strong><span
                    >live transcripts of your calls</span
                  >
                </div>
              </div>
            </div>
          </div>

          <button
            class="btn btn-pink explore"
            onclick={() => send({ type: 'completeOnboarding' })}
          >
            explore typie →
          </button>
        </section>
      {/if}
    {/key}
  </main>

  <footer>
    <span class="hand hint">{stepHint}</span>
    {#if local.step < 3}
      <button
        class="btn btn-pink"
        disabled={!nextEnabled}
        onclick={() => goTo(local.step + 1)}
      >
        {buttonLabel}
      </button>
    {/if}
  </footer>
</div>

<style>
  .onboard {
    position: relative;
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
  }

  /* ── ambient warmth, same idea as the landing ── */
  .blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(90px);
    opacity: 0.4;
    pointer-events: none;
    z-index: 0;
  }

  .b1 {
    width: 480px;
    height: 480px;
    top: -160px;
    right: -120px;
    background: radial-gradient(
      circle,
      rgba(130, 237, 166, 0.5),
      transparent 70%
    );
    animation: drift-a 22s ease-in-out infinite alternate;
  }

  .b2 {
    width: 420px;
    height: 420px;
    bottom: -180px;
    left: -140px;
    background: radial-gradient(
      circle,
      rgba(255, 211, 224, 0.55),
      transparent 70%
    );
    animation: drift-b 26s ease-in-out infinite alternate;
  }

  @keyframes drift-a {
    from {
      transform: translate(0, 0) scale(1);
    }
    to {
      transform: translate(-90px, 70px) scale(1.15);
    }
  }

  @keyframes drift-b {
    from {
      transform: translate(0, 0) scale(1);
    }
    to {
      transform: translate(80px, -60px) scale(1.1);
    }
  }

  /* ── overall progress rail ── */
  .rail {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: var(--wash);
    z-index: 3;
  }

  .rail-fill {
    height: 100%;
    border-radius: 999px;
    background: linear-gradient(90deg, var(--mint), var(--mint-live));
    transition: width 0.6s var(--ease-out);
  }

  .top,
  main,
  footer {
    position: relative;
    z-index: 1;
  }

  /* the top bar — left padding clears the traffic lights */
  .top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 18px 26px 14px 86px;
    border-bottom: 1px solid var(--line);
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--hotpink);
  }

  .brand .word {
    font-family: var(--display);
    font-weight: 900;
    font-size: 21px;
    letter-spacing: -0.05em;
    color: var(--ink);
  }

  .brand .word i {
    font-style: normal;
    color: var(--hotpink);
  }

  h1 {
    font-size: 26px;
  }

  main {
    flex: 1;
    overflow-y: auto;
    display: flex;
  }

  main > section {
    flex: 1;
    padding: 22px 28px;
  }

  footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 0 28px 18px;
  }

  .hint {
    font-size: 16px;
    color: var(--green-deep);
    opacity: 0.75;
    transform: rotate(-1.2deg);
  }

  /* ── shared icon tile ── */
  .tile {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 42px;
    height: 42px;
    border-radius: 12px;
    color: var(--ink);
    flex-shrink: 0;
  }

  /* ── welcome ── */
  .welcome {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    gap: 13px;
  }

  .welcome h1 {
    font-size: 30px;
    letter-spacing: -0.03em;
  }

  .sub {
    color: var(--text-2);
    font-size: 14px;
  }

  .trio {
    display: flex;
    gap: 12px;
    margin-top: 12px;
    width: 100%;
    max-width: 720px;
  }

  .trio-card {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 18px 12px 15px;
    text-align: center;
  }

  .trio-card strong {
    font-size: 13px;
    font-weight: 800;
    color: var(--ink);
  }

  .trio-card span:last-child {
    font-size: 11.5px;
    color: var(--text-3);
  }

  /* ── permissions ── */
  .perms {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .perm-list {
    display: flex;
    flex-direction: column;
    gap: 11px;
    width: min(560px, 100%);
    margin-top: 18px;
  }

  .perm {
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 15px 18px;
    border-radius: var(--radius-card);
    transition:
      border-color 0.3s var(--ease-out),
      background 0.3s var(--ease-out),
      box-shadow 0.3s var(--ease-out);
  }

  .perm.granted {
    background: var(--card-mint);
    border-color: transparent;
    box-shadow: none;
  }

  .perm .body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .perm strong {
    font-size: 14.5px;
    font-weight: 800;
    color: var(--ink);
  }

  .perm p {
    font-size: 12.5px;
    line-height: 1.45;
    color: var(--text-2);
  }

  .perm .relaunch {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.03em;
    color: var(--text-3);
  }

  .perm .small {
    padding: 8px 18px;
    font-size: 12.5px;
    flex-shrink: 0;
  }

  .granted-chip {
    background: rgba(130, 237, 166, 0.35);
    color: var(--green-deep);
    flex-shrink: 0;
  }

  /* ── model ── */
  .model {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 14px;
    text-align: center;
  }

  .halo {
    display: grid;
    place-items: center;
    width: 104px;
    height: 104px;
    border-radius: 50%;
    background: rgba(130, 237, 166, 0.25);
    color: var(--ink);
  }

  .halo.pulse {
    animation: halo-pulse 2.2s ease-in-out infinite;
  }

  @keyframes halo-pulse {
    0%,
    100% {
      box-shadow: 0 0 0 0 rgba(130, 237, 166, 0.35);
    }
    50% {
      box-shadow: 0 0 0 18px rgba(130, 237, 166, 0);
    }
  }

  .dlrow {
    display: flex;
    align-items: center;
    gap: 15px;
    width: min(460px, 100%);
    padding: 15px 18px;
    text-align: left;
  }
  .dlrow.done {
    background: var(--card-mint);
    border-color: transparent;
    box-shadow: none;
  }
  .dlrow.failed {
    background: rgba(252, 86, 129, 0.07);
    border-color: rgba(252, 86, 129, 0.25);
  }

  .dlrow .body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    gap: 7px;
  }

  .dlrow header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
  }

  .dlrow strong {
    font-size: 13.5px;
    font-weight: 800;
    color: var(--ink);
  }

  .dlrow .stat.done {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    color: var(--green-deep);
    font-weight: 600;
  }

  .dlrow .error {
    max-width: none;
    font-size: 12px;
  }

  .dlrow .progress {
    width: 100%;
    height: 11px;
  }

  .stat {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.05em;
    color: var(--text-3);
  }

  .note {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    font-size: 13px;
    color: var(--text-2);
  }

  .error {
    max-width: 400px;
    font-size: 13px;
    color: var(--hotpink);
  }

  /* ── ready: big, instructional, hands-on ── */
  .ready {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 22px;
    max-width: 780px;
    margin: 0 auto;
  }

  .turn {
    font-size: 34px;
    letter-spacing: -0.03em;
  }

  .how {
    display: flex;
    align-items: center;
    gap: 18px;
  }

  .cap-static {
    display: inline-block;
    font-family: var(--display);
    font-weight: 800;
    font-size: 30px;
    color: var(--cream);
    padding: 14px 26px;
    border-radius: 14px;
    background: var(--ink);
    box-shadow: 0 7px 0 #0b1f1b;
  }

  .how-text {
    font-size: 17px;
    color: var(--text-1);
    max-width: 380px;
    line-height: 1.5;
  }

  .how-text b {
    color: var(--ink);
    font-weight: 800;
  }

  .result {
    width: 100%;
    min-height: 190px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 28px 32px;
    border-width: 2px;
    border-color: var(--line);
    transition:
      border-color 0.3s var(--ease-out),
      box-shadow 0.3s var(--ease-out);
  }

  .result.flash {
    border-color: var(--mint-live);
    box-shadow: 0 0 0 3px rgba(110, 232, 154, 0.35);
  }

  .result .words {
    font-family: var(--display);
    font-weight: 800;
    font-size: clamp(24px, 3.4vw, 38px);
    line-height: 1.15;
    letter-spacing: -0.02em;
    color: var(--ink);
    text-wrap: balance;
    width: 100%;
  }

  .result .placeholder {
    font-family: var(--hand);
    font-size: 22px;
    color: var(--text-3);
    transform: rotate(-1deg);
  }

  .result .state {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-family: var(--mono);
    font-size: 13px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .result .state.live {
    color: var(--hotpink);
    animation: breathe 1.2s ease-in-out infinite;
  }

  .result .state.think {
    color: var(--text-3);
  }

  @keyframes breathe {
    50% {
      opacity: 0.35;
    }
  }

  .more {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }

  .feat-row {
    display: flex;
    gap: 12px;
  }

  .feat {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    text-align: left;
  }

  .feat .tile.sm {
    width: 36px;
    height: 36px;
    border-radius: 10px;
  }

  .feat strong {
    display: block;
    font-size: 13px;
    font-weight: 800;
    color: var(--ink);
  }

  .feat span:not(.tile) {
    font-size: 11.5px;
    color: var(--text-3);
  }

  .explore {
    padding: 14px 34px;
    font-size: 15px;
  }
</style>
