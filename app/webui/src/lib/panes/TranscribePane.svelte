<script>
  import { ui, send, markCopied, local } from '../bridge.svelte.js'

  /** drag & drop any audio file → batch transcription with speaker labels */

  const t = $derived(ui.transcribe)
  let dragging = $state(false)
  // chunked upload bookkeeping
  let uploading = $state(false)
  const CHUNK_BYTES = 4 * 1024 * 1024

  const SPEAKER_TINTS = ['var(--pink)', 'var(--sky)', 'var(--mint-live)', 'var(--butter)', 'var(--lavender)']
  const speakerTint = (i) => SPEAKER_TINTS[i % SPEAKER_TINTS.length]

  function fmtClock(seconds) {
    const s = Math.max(0, Math.round(seconds))
    return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
  }

  const transcriptText = $derived(
    t.result
      ? t.result.turns.length
        ? t.result.turns
            .map((turn) => `[${fmtClock(turn.start)}] Speaker ${turn.speakerIndex + 1}: ${turn.text}`)
            .join('\n\n')
        : t.result.plainTranscript
      : '',
  )

  function copyTranscript() {
    send({ type: 'copy', text: transcriptText })
    markCopied('transcript')
  }

  function startDownload() {
    send({ type: 'startDiarizerDownload' })
  }

  function pickFile() {
    if (!t.busy && !uploading) send({ type: 'transcribeChooseFile' })
  }

  function onDrop(e) {
    e.preventDefault()
    dragging = false
    const file = e.dataTransfer?.files?.[0]
    if (file && !t.busy && !uploading) uploadFile(file)
  }

  function arrayBufferToBase64(buf) {
    const bytes = new Uint8Array(buf)
    let bin = ''
    for (let i = 0; i < bytes.length; i += 0x8000) {
      bin += String.fromCharCode(...bytes.subarray(i, i + 0x8000))
    }
    return btoa(bin)
  }

  async function uploadFile(file) {
    uploading = true
    try {
      send({
        type: 'transcribeDropBegin',
        name: file.name,
        totalChunks: Math.ceil(file.size / CHUNK_BYTES),
      })
      for (let offset = 0; offset < file.size; offset += CHUNK_BYTES) {
        const buf = await file.slice(offset, offset + CHUNK_BYTES).arrayBuffer()
        send({ type: 'transcribeDropChunk', index: offset / CHUNK_BYTES, b64: arrayBufferToBase64(buf) })
      }
      send({ type: 'transcribeDropEnd' })
    } finally {
      uploading = false
    }
  }
</script>

{#if t.model.state === 'unknown'}
  <div class="pane"><p class="mono-kicker">checking models…</p></div>
{:else if t.model.state !== 'ready'}
  <!-- one-time model download gate -->
  <div class="pane">
    <section class="card setup" class:setup-error={t.model.state === 'failed'}>
      <span class="chip" style="background:var(--lavender)">👥</span>
      {#if t.model.state === 'notDownloaded'}
        <h2>first time here</h2>
        <p>
          speaker-labeled transcription needs a one-time
          <strong>~{t.downloadMB}&nbsp;MB model download</strong>. it runs entirely on this mac —
          after this, the app never touches the internet again.
        </p>
        <button class="primary" onclick={startDownload}>
          download model (~{t.downloadMB}&nbsp;MB)
        </button>
      {:else if t.model.state === 'downloading'}
        <h2>downloading model…</h2>
        <div class="bar">
          <div class="fill" style="width:{Math.round(t.model.fraction * 100)}%"></div>
        </div>
        <p class="mono-kicker">{Math.round(t.model.fraction * 100)}%</p>
      {:else if t.model.state === 'compiling'}
        <h2>preparing model…</h2>
        <span class="spinner"></span>
        <p>compiling for the neural engine — this only happens once</p>
      {:else if t.model.state === 'failed'}
        <h2>download failed</h2>
        <p class="err">{t.model.error}</p>
        <button class="primary" onclick={startDownload}>try again</button>
      {/if}
    </section>
  </div>
{:else}
  <div class="pane">
    {#if t.error}
      <div class="flash-err">{t.error}</div>
    {/if}

    {#if t.busy || uploading}
      <!-- working -->
      <section class="card working">
        <span class="spinner big"></span>
        <strong>{t.stage || 'reading file'}…</strong>
        {#if t.progress != null}
          <div class="bar">
            <div class="fill" style="width:{Math.round(t.progress * 100)}%"></div>
          </div>
          <p class="mono-kicker">{Math.round(t.progress * 100)}%</p>
        {:else}
          <p>this can take a little while — longer files need more thought</p>
        {/if}
      </section>
    {:else if !t.result}
      <!-- drop zone -->
      <div
        class="dropzone"
        class:dragging
        role="button"
        tabindex="0"
        ondragover={(e) => { e.preventDefault(); dragging = true }}
        ondragleave={() => (dragging = false)}
        ondrop={onDrop}
        onclick={pickFile}
        onkeydown={(e) => e.key === 'Enter' && pickFile()}
      >
        <span class="big-emoji">🎧</span>
        <strong>drop an audio file here</strong>
        <span class="hand">or click to browse</span>
        <small>wav · mp3 · m4a · aac · flac … anything macOS can play</small>
      </div>
    {:else}
      <!-- results -->
      <section class="card">
        <header class="res-head">
          <div>
            <h2>{t.result.fileName}</h2>
            <p class="mono-kicker">
              {fmtClock(t.result.durationSeconds)} · {t.result.speakerCount}
              {t.result.speakerCount === 1 ? 'speaker' : 'speakers'} · processed in
              {(t.result.elapsedMs / 1000).toFixed(1)}s
            </p>
          </div>
          <button class="ghost" onclick={copyTranscript}>
            {local.copiedId === 'transcript' ? 'copied ✓' : 'copy transcript'}
          </button>
        </header>

        {#if t.result.turns.length > 0}
          <div class="turns">
            {#each t.result.turns as turn}
              <div class="turn" style="border-left-color:{speakerTint(turn.speakerIndex)}">
                <span class="who mono-kicker" style="background:{speakerTint(turn.speakerIndex)}">
                  speaker {turn.speakerIndex + 1} · {fmtClock(turn.start)}
                </span>
                <p>{turn.text}</p>
              </div>
            {/each}
          </div>
        {:else}
          <p class="plain">{t.result.plainTranscript}</p>
          <p class="foot mono-kicker">no word timings available for speaker labels in this file</p>
        {/if}
      </section>

      <button class="ghost again" onclick={pickFile}>transcribe another file ↺</button>
    {/if}
  </div>
{/if}

<style>
  .pane {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 18px 20px;
    overflow-y: auto;
  }

  /* ── first-run gate ── */
  .setup {
    align-items: center;
    text-align: center;
    gap: 10px;
    border: 2px dashed rgba(3, 89, 77, 0.25);
  }
  .setup p {
    font-size: 13px;
    color: rgba(44, 51, 66, 0.8);
    max-width: 40ch;
  }
  .setup-error {
    background: rgba(252, 86, 129, 0.08);
  }
  .err {
    color: var(--hotpink);
    font-size: 12px;
    overflow-wrap: anywhere;
  }

  button.primary {
    padding: 9px 18px;
    border-radius: 999px;
    background: var(--hotpink);
    color: var(--cream);
    font-family: var(--display);
    font-weight: 600;
    font-size: 13.5px;
    box-shadow: 0 2px 6px rgba(252, 86, 129, 0.35);
  }
  button.primary:hover {
    filter: brightness(1.05);
  }
  button.ghost {
    padding: 6px 13px;
    border-radius: 999px;
    border: 1px solid rgba(3, 89, 77, 0.25);
    font-family: var(--display);
    font-size: 12px;
    color: rgba(44, 51, 66, 0.75);
  }
  button.ghost:hover {
    color: var(--ink);
    border-color: rgba(3, 89, 77, 0.45);
  }
  .again {
    align-self: center;
  }

  /* ── progress bits ── */
  .spinner {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    border: 3px solid rgba(3, 89, 77, 0.15);
    border-top-color: var(--hotpink);
    animation: spin 0.8s linear infinite;
    margin: 4px auto;
  }
  .spinner.big {
    width: 30px;
    height: 30px;
    border-width: 4px;
  }
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .working {
    align-items: center;
    text-align: center;
    gap: 10px;
  }
  .working strong {
    font-size: 16px;
  }
  .working p,
  .working .mono-kicker {
    font-size: 11.5px;
    color: rgba(44, 51, 66, 0.6);
  }

  .bar {
    width: min(320px, 80%);
    height: 10px;
    border-radius: 999px;
    background: var(--cream);
    border: 1px solid rgba(3, 89, 77, 0.2);
    overflow: hidden;
    margin-inline: auto;
  }
  .fill {
    height: 100%;
    background: linear-gradient(90deg, var(--mint-live), var(--hotpink));
    transition: width 0.3s var(--ease-out);
  }

  /* ── drop zone ── */
  .dropzone {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    min-height: 220px;
    border: 2px dashed rgba(3, 89, 77, 0.3);
    border-radius: var(--radius-card);
    cursor: pointer;
    transition:
      background 0.2s var(--ease-out),
      border-color 0.2s var(--ease-out);
  }
  .dropzone:hover,
  .dropzone.dragging {
    background: rgba(130, 237, 166, 0.18);
    border-color: var(--mint-live);
  }
  .big-emoji {
    font-size: 34px;
  }
  .dropzone strong {
    font-size: 17px;
  }
  .dropzone .hand {
    font-size: 14px;
    color: rgba(44, 51, 66, 0.65);
  }
  .dropzone small {
    font-size: 11px;
    color: rgba(3, 89, 77, 0.55);
  }

  /* ── results ── */
  .flash-err {
    padding: 10px 14px;
    border-radius: 10px;
    background: rgba(252, 86, 129, 0.1);
    border: 1px solid var(--hotpink);
    color: #b3274d;
    font-size: 12.5px;
  }

  section.card {
    display: flex;
    flex-direction: column;
    gap: 12px;
    text-align: left;
  }
  .res-head {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 10px;
  }
  h2 {
    font-size: 16px;
    overflow-wrap: anywhere;
  }
  .res-head .mono-kicker {
    font-size: 11px;
    margin-top: 3px;
  }

  .turns {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .turn {
    padding: 9px 12px;
    border-left: 3px solid var(--pink);
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.55);
  }
  .who {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 999px;
    font-size: 10px;
    margin-bottom: 5px;
    color: #2c3342;
  }
  .turn p {
    font-size: 13.5px;
    line-height: 1.45;
  }
  .plain {
    font-size: 13.5px;
    line-height: 1.5;
    white-space: pre-wrap;
  }
  .foot {
    font-size: 11px;
    text-align: center;
    color: rgba(3, 89, 77, 0.6);
  }
</style>
