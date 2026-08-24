<script>
  import Robot from './Robot.svelte'
  import Keycap from './Keycap.svelte'
  import TriggerPicker from './TriggerPicker.svelte'
  import Toggle from './Toggle.svelte'
  import DevTag from './DevTag.svelte'
  import { ui, local, send } from './bridge.svelte.js'

  const STEP_COUNT = 4

  const robotMood = $derived(
    local.step === 2
      ? ui.model.status === 'ready'
        ? 'done'
        : ui.model.status === 'downloading' || ui.model.status === 'loading'
          ? 'thinking'
          : 'idle'
      : local.step === 3
        ? 'listening'
        : 'idle',
  )

  const allPermissionsDone = $derived(ui.permissions.mic && ui.permissions.ax)
  const modelReady = $derived(ui.model.status === 'ready')
  const downloadApproved = $derived(
    ui.model.status !== 'notDownloaded' || ui.modelsExist,
  )

  const buttonLabel = $derived.by(() => {
    switch (local.step) {
      case 0:
        return "let's go →"
      case 1:
        return allPermissionsDone ? 'next' : 'waiting…'
      case 2:
        return modelReady
          ? 'continue'
          : downloadApproved
            ? 'downloading…'
            : 'approve below'
      default:
        return ''
    }
  })

  const nextEnabled = $derived(
    local.step === 0 ||
      (local.step === 1 && allPermissionsDone) ||
      (local.step === 2 && modelReady),
  )

  const stepHint = $derived(
    ['no account, no cloud, ever ↓', 'one-time things. we’ll never ask again', 'the whole brain, downloaded to this Mac', ''][local.step],
  )

  function next() {
    if (local.step === 0) {
      local.step = 1
    } else if (local.step === 1) {
      if (ui.modelsExist) send({ type: 'startModelDownload' })
      local.step = 2
    } else if (local.step === 2) {
      // hotkey must go live HERE so the practice box works pre-"done"
      send({ type: 'onboardingReadyStep' })
      local.step = 3
    }
  }
</script>

<div class="onboarding">
  <header>
    <div class="brand">
      <Robot size={30} mood={robotMood} />
      <h1>typie{ui.variant === 'dev' ? ' dev' : ''}.</h1>
      <DevTag />
    </div>
    <span class="mono-kicker">step {local.step + 1} of {STEP_COUNT}</span>
  </header>

  <main>
    {#if local.step === 0}
      <section class="welcome">
        <div class="big-bot"><Robot size={54} mood="idle" /></div>
        <h1>HOLD A KEY. SAY THE THING.</h1>
        <p class="sub">Your words appear wherever your cursor is — entirely on this Mac.</p>
        <div class="trio">
          <div class="card">
            <i>⌨</i>
            <strong>works everywhere</strong>
            <span>any app that accepts typing</span>
          </div>
          <div class="card">
            <i>⚡</i>
            <strong>instant</strong>
            <span>text lands in ~100 ms</span>
          </div>
          <div class="card">
            <i>📡</i>
            <strong>zero cloud</strong>
            <span>audio never leaves this Mac</span>
          </div>
        </div>
      </section>
    {:else if local.step === 1}
      <section class="perms">
        <h1>Two tiny permissions.</h1>

        <div class="card perm" class:granted={ui.permissions.mic}>
          <span class="icon" style="background:var(--mint)">🎙</span>
          <div>
            <strong>Microphone</strong>
            <p>so typie can hear you while the key is held. audio is processed on-device and thrown away.</p>
          </div>
          {#if ui.permissions.mic}
            <em class="ok">granted ✓</em>
          {:else}
            <button class="btn btn-pink small" onclick={() => send({ type: 'requestMicPermission' })}>
              allow
            </button>
          {/if}
        </div>

        <div class="card perm" class:granted={ui.permissions.ax}>
          <span class="icon" style="background:var(--lavender)">⌨️</span>
          <div>
            <strong>Accessibility</strong>
            <p>so typie can watch for the hotkey and type text where your cursor already is.</p>
          </div>
          {#if ui.permissions.ax}
            <em class="ok">granted ✓</em>
          {:else}
            <button class="btn btn-pink small" onclick={() => send({ type: 'requestAccessibility' })}>
              allow
            </button>
          {/if}
        </div>
      </section>
    {:else if local.step === 2}
      <section class="model">
        <div class="halo">
          <Robot size={56} mood={robotMood} />
        </div>
        <h1>{modelReady ? 'All set.' : 'One-time download'}</h1>

        {#if ui.model.status === 'downloading'}
          <div class="progress"><div style="width:{Math.max(3, ui.model.fraction * 100)}%"></div></div>
          <p class="stat">{Math.round(ui.model.fraction * 100)}% · {Math.round(ui.model.fraction * 470)} / ~470 mb{ui.eta ? ` · ${ui.eta}` : ''}</p>
          <p class="note">typie's brain, downloaded straight onto this Mac.<br />after this, it never needs the internet again.</p>
        {:else if ui.model.status === 'loading'}
          <div class="progress"><div style="width:98%"></div></div>
          <p class="stat">waking it up…</p>
        {:else if modelReady}
          <p class="note">📶 ⃠ &nbsp;already installed — from here on, everything happens offline.</p>
        {:else if ui.model.status === 'failed'}
          <p class="error">{ui.model.error}</p>
          <button class="btn btn-pink" onclick={() => send({ type: 'startModelDownload' })}>
            try again
          </button>
        {:else if downloadApproved}
          <p class="stat">getting ready…</p>
        {:else}
          <p class="note big-note">
            typie transcribes your speech with a voice model that runs entirely on this Mac.
          </p>
          <p class="stat">~470 mb · downloaded once · offline forever after</p>
          <button class="btn btn-pink" onclick={() => send({ type: 'startModelDownload' })}>
            ↓ &nbsp;ok — download it
          </button>
        {/if}
      </section>
    {:else}
      <section class="ready">
        <div class="controls">
          <Keycap />
          <span class="vline"></span>
          <div class="trigger">
            <span class="mono-kicker">trigger</span>
            <TriggerPicker />
          </div>
        </div>

        <ol>
          <li>
            <b>1</b><i>{ui.settings.triggerMode === 'toggle' ? '☞' : '☜'}</i>
            <span>{ui.settings.triggerMode === 'hold'
              ? `hold ${ui.settings.hotkey.toLowerCase()} while you speak`
              : ui.settings.triggerMode === 'toggle'
                ? `tap ${ui.settings.hotkey.toLowerCase()} to start recording`
                : `hold ${ui.settings.hotkey.toLowerCase()} — or just tap it`}</span>
          </li>
          <li><b>2</b><i>🎙</i><span>say your thing</span></li>
          <li><b>3</b><i>⌨</i><span>{ui.settings.triggerMode === 'toggle'
              ? 'tap again — words land at your cursor'
              : 'release or tap again — words land right at your cursor'}</span></li>
        </ol>

        <div class="practice card" class:flash={local.flash}>
          <header>
            <strong>try it right now</strong>
            {#if ui.dictation.phase === 'listening'}
              <em class="live">〰 listening…</em>
            {:else if ui.dictation.phase === 'transcribing'}
              <em class="think">thinking…</em>
            {:else}
              <em>words land here automatically — just talk</em>
            {/if}
          </header>
          <textarea
            bind:value={local.practice}
            placeholder="your words will appear here…"
            spellcheck="false"
          ></textarea>
        </div>

        <div class="switches">
          <label>
            save history
            <Toggle setting="historyEnabled" />
          </label>
          <label>
            start at login
            <Toggle setting="launchAtLogin" />
          </label>
        </div>

        <button class="btn btn-pink done" onclick={() => send({ type: 'completeOnboarding' })}>
          done — start dictating →
        </button>
      </section>
    {/if}
  </main>

  <footer>
    <span class="hint">{stepHint}</span>
    {#if local.step < 3}
      <button class="btn btn-pink" disabled={!nextEnabled} onclick={next}>
        {buttonLabel}
      </button>
    {/if}
  </footer>
</div>

<style>
  .onboarding {
    display: flex;
    flex-direction: column;
    height: 100vh;
  }

  header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 26px;
    border-bottom: 1px solid rgba(3, 89, 77, 0.15);
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 9px;
    color: var(--ink);
  }

  h1 {
    font-size: 22px;
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
    padding: 0 28px 20px;
  }

  .hint {
    font-size: 12.5px;
    color: rgba(3, 89, 77, 0.65);
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
    font-size: 27px;
    letter-spacing: -0.02em;
  }

  .sub {
    color: var(--text-2);
    font-size: 14px;
  }

  .trio {
    display: flex;
    gap: 11px;
    margin-top: 10px;
    width: 100%;
  }

  .trio .card {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    padding: 14px 10px;
    text-align: center;
  }

  .trio i {
    font-style: normal;
    font-size: 17px;
  }

  .trio strong {
    font-size: 12.5px;
    font-weight: 800;
    color: var(--ink);
  }

  .trio span {
    font-size: 11px;
    color: rgba(44, 51, 66, 0.65);
  }

  /* ── permissions ── */
  .perms {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 15px;
  }

  .perms h1 {
    font-size: 25px;
  }

  .perm {
    display: flex;
    align-items: center;
    gap: 15px;
    width: min(560px, 100%);
    border-width: 2px;
    border-color: rgba(3, 89, 77, 0.08);
    transition: border-color 0.3s var(--ease-out);
  }

  .perm.granted {
    border-color: var(--mint-live);
  }

  .perm .icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    border-radius: 14px;
    font-size: 21px;
    flex-shrink: 0;
  }

  .perm > div {
    flex: 1;
  }

  .perm strong {
    font-size: 15px;
    font-weight: 800;
    color: var(--ink);
  }

  .perm p {
    font-size: 12.5px;
    color: rgba(44, 51, 66, 0.7);
  }

  .perm .small {
    padding: 8px 17px;
    font-size: 12.5px;
    flex-shrink: 0;
  }

  .ok {
    font-family: var(--mono);
    font-style: normal;
    font-size: 11px;
    letter-spacing: 0.06em;
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

  .model h1 {
    font-size: 24px;
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

  .progress {
    width: 330px;
    height: 13px;
    border-radius: 999px;
    background: rgba(3, 89, 77, 0.1);
    overflow: hidden;
  }

  .progress div {
    height: 100%;
    border-radius: 999px;
    background: linear-gradient(90deg, var(--mint), var(--mint-live));
    transition: width 0.35s var(--ease-out);
  }

  .stat {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.05em;
    color: rgba(3, 89, 77, 0.6);
  }

  .note {
    font-size: 13px;
    color: rgba(44, 51, 66, 0.7);
  }

  .big-note {
    font-size: 14.5px;
    max-width: 380px;
    color: rgba(44, 51, 66, 0.85);
  }

  .error {
    max-width: 400px;
    font-size: 13px;
    color: var(--hotpink);
  }

  /* ── ready ── */
  .ready {
    display: flex;
    flex-direction: column;
    gap: 15px;
  }

  .controls {
    display: flex;
    align-items: center;
    gap: 20px;
  }

  .vline {
    width: 1px;
    height: 40px;
    background: rgba(3, 89, 77, 0.15);
  }

  .trigger {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  ol {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 9px;
  }

  li {
    display: flex;
    align-items: center;
    gap: 11px;
    font-size: 13.5px;
    color: rgba(44, 51, 66, 0.85);
  }

  li b {
    display: inline-grid;
    place-items: center;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: rgba(130, 237, 166, 0.4);
    font-weight: 800;
    font-size: 12px;
    color: var(--slate, #2c3342);
  }

  li i {
    font-style: normal;
    width: 18px;
    text-align: center;
  }

  .practice {
    display: flex;
    flex-direction: column;
    gap: 7px;
    border-width: 2px;
    border-color: rgba(3, 89, 77, 0.12);
    transition:
      border-color 0.3s var(--ease-out),
      box-shadow 0.3s var(--ease-out);
  }

  .practice.flash {
    border-color: var(--mint-live);
    box-shadow: 0 0 0 3px rgba(110, 232, 154, 0.35);
  }

  .practice header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    padding: 0;
    border: none;
  }

  .practice strong {
    font-size: 14px;
    font-weight: 800;
    color: var(--ink);
  }

  .practice em {
    font-style: normal;
    font-size: 12px;
    color: rgba(3, 89, 77, 0.5);
  }

  .practice em.live {
    font-family: var(--mono);
    color: var(--hotpink);
  }

  .practice em.think {
    font-family: var(--mono);
    color: rgba(3, 89, 77, 0.6);
  }

  textarea {
    height: 84px;
    resize: none;
    border: none;
    outline: none;
    background: transparent;
    font-size: 13.5px;
    color: var(--text-2);
    user-select: text;
  }

  .switches {
    display: flex;
    gap: 22px;
  }

  .switches label {
    display: inline-flex;
    align-items: center;
    gap: 9px;
    font-size: 13px;
    color: var(--ink);
  }

  .done {
    align-self: center;
  }
</style>
