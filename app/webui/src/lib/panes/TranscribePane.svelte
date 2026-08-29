<script>
  import { ui, send, local } from '../bridge.svelte.js';
  import {
    Search,
    UploadCloud,
    Trash2,
    Download,
    CheckCircle2,
    Loader2,
  } from 'lucide-svelte';
  import InlineEdit from '../InlineEdit.svelte';
  import SortSeg from '../SortSeg.svelte';
  import Glyph from '../Glyph.svelte';
  import { infinite } from '../infinite.js';
  import { trash, fmtDateSmart } from '../trash.svelte.js';

  let dragging = $state(false);
  let query = $state('');
  // when embedded in the Library pane, the tab bar provides the title
  let { embedded = false } = $props();
  // local upload state (the JS side drives chunking, so it owns progress)
  let uploading = $state(null); // { name, sent, total } | null

  // ── library sorting + progressive paging (hundreds of items stay fast) ──
  const SORTS = [
    { id: 'newest', label: 'newest' },
    { id: 'oldest', label: 'oldest' },
    { id: 'longest', label: 'longest' },
  ];
  const PAGE = 60;
  let sortBy = $state('newest');
  let shown = $state(PAGE);

  // meetings live in their own Recordings pane — never listed here
  // (staged-for-delete items vanish instantly too)
  const pendingT = $derived(trash.pendingIds('transcript'));
  const library = $derived(
    ui.transcripts.filter((x) => !x.isMeeting && !pendingT.has(x.id))
  );
  const filtered = $derived(
    query.trim() === ''
      ? library
      : library.filter((x) =>
          `${x.fileName} ${(x.turns ?? []).map((t) => t.text).join(' ')}`
            .toLowerCase()
            .includes(query.trim().toLowerCase())
        )
  );
  const hasWork = $derived(
    uploading !== null || ui.transcribe.busy || ui.transcribe.queued > 0
  );
  // queue items not yet running (when busy, the first entry IS the active job)
  const waitList = $derived(
    ui.transcribe.busy ? ui.transcribe.queue.slice(1) : ui.transcribe.queue
  );
  const activeQ = $derived(ui.transcribe.busy ? ui.transcribe.queue[0] : null);

  const sorted = $derived.by(() => {
    const arr = [...filtered];
    switch (sortBy) {
      case 'oldest':
        return arr.sort((a, b) => new Date(a.date) - new Date(b.date));
      case 'longest':
        return arr.sort(
          (a, b) => (b.durationSeconds || 0) - (a.durationSeconds || 0)
        );
      default:
        return arr.sort((a, b) => new Date(b.date) - new Date(a.date));
    }
  });
  const visible = $derived(sorted.slice(0, shown));
  // any change to search or order resets paging back to the first page
  $effect(() => {
    query;
    sortBy;
    shown = PAGE;
  });

  function fmtDate(iso) {
    return fmtDateSmart(iso);
  }
  function fmtDur(s) {
    const n = Math.round(s || 0);
    return `${Math.floor(n / 60)}m ${String(n % 60).padStart(2, '0')}s`;
  }

  function onDelete(e, item) {
    e.stopPropagation();
    trash.add('transcript', [item.id], item.fileName || 'transcript');
  }

  function pickFile() {
    send({ type: 'transcribeChooseFile' });
  }
  function onDrop(e) {
    e.preventDefault();
    dragging = false;
    const files = e.dataTransfer?.files;
    if (files?.length) uploadAll([...files]);
  }
  async function uploadAll(files) {
    for (const f of files) await upload(f);
  }
  async function upload(file) {
    uploading = { name: file.name, sent: 0, total: file.size };
    const CHUNK = 4 * 1024 * 1024;
    const bufToB64 = (buf) => {
      const b = new Uint8Array(buf);
      let bin = '';
      for (let i = 0; i < b.length; i += 0x8000)
        bin += String.fromCharCode(...b.subarray(i, i + 0x8000));
      return btoa(bin);
    };
    send({
      type: 'transcribeDropBegin',
      name: file.name,
      totalChunks: Math.ceil(file.size / CHUNK),
    });
    for (let off = 0; off < file.size; off += CHUNK) {
      const chunk = await file.slice(off, off + CHUNK).arrayBuffer();
      send({
        type: 'transcribeDropChunk',
        index: off / CHUNK,
        b64: bufToB64(chunk),
      });
      uploading = {
        name: file.name,
        sent: Math.min(off + CHUNK, file.size),
        total: file.size,
      };
    }
    send({ type: 'transcribeDropEnd' });
    uploading = null;
  }
</script>

<div
  class="wrap"
  class:embedded
>
  {#if !embedded}
    <header class="head">
      <div>
        <h2>Transcripts</h2>
        <p>
          drop any audio or video — diarized, timestamped, entirely on this Mac. <span
            class="hand hint-hand">like otter, but offline</span
          >
        </p>
      </div>
    </header>
  {/if}

  <!-- model gate -->
  {#if ui.transcribe.model.state !== 'ready'}
    <div class="gate card">
      {#if ui.transcribe.model.state === 'notDownloaded'}
        <p>
          <b>one-time setup:</b> speaker models (~22 mb) are needed for diarization.
        </p>
        <button
          class="btn btn-pink small"
          onclick={() => send({ type: 'startDiarizerDownload' })}
          >download models</button
        >
      {:else if ui.transcribe.model.state === 'downloading'}
        <div class="progress">
          <div
            style="width:{Math.max(3, ui.transcribe.model.fraction * 100)}%"
          ></div>
        </div>
        <p class="mono-kicker">
          {Math.round(ui.transcribe.model.fraction * 100)}% downloading…
        </p>
      {:else}
        <p class="mono-kicker">preparing models…</p>
      {/if}
    </div>
  {:else}
    <!-- live work: one card per file — uploading / running / waiting -->
    {#if hasWork}
      <div class="worklist">
        {#if uploading}
          <div class="wrow card">
            <span class="stg"><Loader2 size={14} /> uploading</span>
            <span class="fname">{uploading.name}</span>
            <div class="bar slim">
              <div
                style="width:{Math.max(
                  3,
                  (uploading.sent / Math.max(1, uploading.total)) * 100
                )}%"
              ></div>
            </div>
            <span class="eta mono-kicker"
              >{Math.round(
                (uploading.sent / Math.max(1, uploading.total)) * 100
              )}%</span
            >
          </div>
        {:else if activeQ}
          <div class="wrow card">
            <span class="stg"
              ><Loader2 size={14} /> {ui.transcribe.stage || 'processing'}</span
            >
            <span class="fname">{activeQ.name}</span>
            <div class="bar slim">
              <div
                class="indeterminate"
                style="width:{ui.transcribe.progress != null
                  ? Math.max(3, ui.transcribe.progress * 100)
                  : 30}%"
              ></div>
            </div>
            <span class="eta mono-kicker"
              >{ui.transcribe.eta ||
                (ui.transcribe.progress != null
                  ? `${Math.round(ui.transcribe.progress * 100)}%`
                  : 'working…')}</span
            >
          </div>
        {/if}
        {#each waitList as q, i (q.name + i)}
          <div class="wrow card waiting">
            <span class="stg dim"><Loader2 size={13} /> waiting</span>
            <span class="fname">{q.name}</span>
            <span class="chip queued">in queue</span>
          </div>
        {/each}
      </div>
    {/if}

    <div
      role="button"
      tabindex="0"
      class="dropzone"
      class:over={dragging}
      class:dim={hasWork}
      ondragover={(e) => {
        e.preventDefault();
        dragging = true;
      }}
      ondragleave={() => (dragging = false)}
      ondrop={onDrop}
      onclick={pickFile}
      onkeydown={(e) => e.key === 'Enter' && pickFile()}
    >
      <div class="bubble">
        <UploadCloud
          size={30}
          strokeWidth={1.8}
        />
      </div>
      <h3>
        {hasWork
          ? 'add more files — they line up in the queue'
          : 'drop files, or click to browse'}
      </h3>
      <p class="mono-kicker">mp3 · m4a · wav · mp4 · several at once is fine</p>
      <span class="hand note-hand">nothing uploads anywhere — promise</span>
    </div>
  {/if}

  {#if ui.transcribe.error}
    <p class="error">{ui.transcribe.error}</p>
  {/if}

  <!-- library -->
  <div class="lib-head">
    <h3>Your library <span class="count">{sorted.length}</span></h3>
    <div class="lib-tools">
      <SortSeg
        options={SORTS}
        bind:value={sortBy}
      />
      <label class="input search">
        <Search size={14} />
        <input
          bind:value={query}
          placeholder="search transcripts…"
          spellcheck="false"
          data-search
        />
      </label>
    </div>
  </div>

  {#if filtered.length === 0}
    <div class="empty">
      <span class="hand big"
        >{library.length === 0
          ? 'no transcripts yet — drop a file up there ☝'
          : `no matches for “${query}”`}</span
      >
    </div>
  {:else}
    <div class="grid">
      {#each visible as item (item.id)}
        <button
          class="tcard card"
          onclick={() => (local.selectedTranscriptId = item.id)}
        >
          <div class="top">
            <span
              class="ico"
              class:meeting={item.isMeeting}
              ><Glyph
                name="transcript"
                size={16}
              /></span
            >
            {#if item.hasAudio}
              <span class="chip ok"><CheckCircle2 size={11} /> ready</span>
            {:else}
              <span class="chip plain">text only</span>
            {/if}
          </div>
          <h4>
            <InlineEdit
              value={item.fileName}
              onSave={(v) =>
                send({ type: 'transcriptsRename', id: item.id, name: v })}
            />
          </h4>
          <p class="meta">
            {fmtDate(item.date)} · {fmtDur(item.durationSeconds)} · {item.speakerCount}
            speaker{item.speakerCount === 1 ? '' : 's'}{item.isMeeting
              ? ' · meeting'
              : ''}
          </p>
          <p class="peek">{item.preview}</p>
          <span class="acts">
            <span
              class="icon-btn"
              role="button"
              tabindex="0"
              title="export markdown"
              onkeydown={(e) =>
                e.key === 'Enter' &&
                (e.stopPropagation(),
                send({ type: 'transcriptExport', id: item.id, format: 'md' }))}
              onclick={(e) => {
                e.stopPropagation();
                send({ type: 'transcriptExport', id: item.id, format: 'md' });
              }}><Download size={13} /></span
            >
            <span
              class="icon-btn"
              role="button"
              tabindex="0"
              title="delete"
              onkeydown={(e) => e.key === 'Enter' && onDelete(e, item)}
              onclick={(e) => onDelete(e, item)}><Trash2 size={13} /></span
            >
          </span>
        </button>
      {/each}
    </div>

    {#if visible.length < sorted.length}
      <button
        class="more"
        use:infinite={() => (shown += PAGE)}
        onclick={() => (shown += PAGE)}
      >
        show more · {sorted.length - visible.length} left
      </button>
    {/if}
  {/if}
</div>

<style>
  .wrap {
    padding: 28px 32px 40px;
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
  }
  .wrap.embedded {
    padding-top: 8px;
  }

  .head {
    margin-bottom: 20px;
  }
  .head h2 {
    font-size: 26px;
  }
  .head p {
    font-size: 13px;
    color: var(--text-3);
    margin-top: 4px;
  }
  .hint-hand {
    font-size: 16px;
    color: var(--periwinkle);
    margin-left: 8px;
  }

  .gate {
    padding: 26px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    max-width: 560px;
    margin-bottom: 26px;
  }
  .gate p {
    font-size: 13.5px;
    color: var(--text-2);
  }
  .gate .progress {
    width: min(340px, 80%);
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .dropzone {
    position: relative;
    min-height: 220px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 9px;
    border: 2.5px dashed var(--line-strong);
    border-radius: 28px;
    background: var(--paper);
    cursor: pointer;
    transition:
      border-color 0.2s var(--ease-out),
      background 0.2s var(--ease-out),
      transform 0.2s var(--spring),
      opacity 0.2s var(--ease-out);
  }
  .dropzone.dim {
    opacity: 0.75;
    min-height: 140px;
  }

  .worklist {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 16px;
  }
  .wrow {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 12px 18px;
  }
  .wrow .stg {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    font-size: 13px;
    font-weight: 700;
    color: var(--ink);
    white-space: nowrap;
  }
  .wrow .stg.dim {
    color: var(--text-3);
    font-weight: 600;
  }
  .wrow :global(.stg svg) {
    animation: spin 1s linear infinite;
    color: var(--hotpink);
  }
  .wrow.waiting :global(.stg svg) {
    color: var(--text-3);
  }
  .fname {
    flex: 1;
    min-width: 0;
    font-family: var(--mono);
    font-size: 11.5px;
    color: var(--text-2);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .bar {
    flex: 1;
    height: 8px;
    border-radius: 99px;
    background: var(--wash);
    overflow: hidden;
  }
  .bar > div {
    height: 100%;
    border-radius: 99px;
    background: linear-gradient(90deg, var(--hotpink), var(--purple));
    transition: width 0.4s var(--ease-out);
  }
  .indeterminate {
    animation: pulsebar 1.6s ease-in-out infinite alternate;
  }
  @keyframes pulsebar {
    from {
      opacity: 0.45;
    }
    to {
      opacity: 1;
    }
  }
  .eta {
    white-space: nowrap;
  }
  .chip.queued {
    background: var(--card-blue);
    color: var(--peri-ink);
  }
  .dropzone:hover,
  .dropzone.over {
    border-color: var(--hotpink);
    background: rgba(252, 86, 129, 0.05);
    transform: scale(1.005);
  }
  .bubble {
    display: grid;
    place-items: center;
    width: 66px;
    height: 66px;
    border-radius: 50%;
    background: var(--hotpink);
    color: #fff;
    box-shadow: 0 8px 20px rgba(252, 86, 129, 0.35);
    margin-bottom: 6px;
    transition: transform 0.25s var(--spring);
  }
  .dropzone:hover .bubble {
    transform: scale(1.08) rotate(-4deg);
  }
  .dropzone h3 {
    font-size: 19px;
  }
  .note-hand {
    font-size: 18px;
    color: var(--mint-live);
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.7);
    transform: rotate(-2deg);
    margin-top: 8px;
  }

  .error {
    margin-top: 14px;
    padding: 12px 16px;
    border-radius: 14px;
    background: rgba(252, 86, 129, 0.12);
    color: var(--red-ink);
    font-size: 13px;
  }

  .lib-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    margin: 32px 0 16px;
    flex-wrap: wrap;
  }
  .lib-head h3 {
    font-size: 17px;
  }
  .lib-tools {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .count {
    font-family: var(--mono);
    font-size: 11px;
    color: var(--text-3);
    vertical-align: 2px;
    margin-left: 4px;
  }
  .search {
    max-width: 280px;
    padding: 8px 15px;
    background: var(--cream);
  }

  .more {
    display: block;
    margin: 20px auto 4px;
    padding: 8px 18px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-3);
    border: 1px dashed var(--line-strong);
    transition:
      color 0.18s var(--ease-out),
      border-color 0.18s var(--ease-out),
      background 0.18s var(--ease-out);
  }
  .more:hover {
    color: var(--hotpink);
    border-color: var(--hotpink);
    background: rgba(252, 86, 129, 0.05);
  }

  .empty {
    padding: 60px 20px;
    text-align: center;
  }
  .big {
    font-size: 26px;
    color: var(--ink);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 16px;
  }
  .tcard {
    position: relative;
    text-align: left;
    cursor: pointer;
    padding: 18px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    transition:
      transform 0.2s var(--spring),
      box-shadow 0.2s var(--ease-out),
      border-color 0.2s var(--ease-out);
  }
  .tcard:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 24px rgba(19, 23, 34, 0.09);
    border-color: var(--line-strong);
  }
  .tcard .top {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .ico {
    display: inline-grid;
    place-items: center;
    width: 36px;
    height: 36px;
    border-radius: 12px;
    background: var(--lavender);
    color: var(--violet-ink);
  }
  .ico.meeting {
    background: var(--pink);
    color: var(--hotpink);
  }
  .chip.ok {
    background: var(--card-mint);
    color: var(--green-deep);
  }
  .chip.plain {
    background: var(--wash);
    color: var(--text-3);
  }
  .tcard h4 {
    font-size: 14.5px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .meta {
    font-family: var(--mono);
    font-size: 10.5px;
    letter-spacing: 0.04em;
    color: var(--text-3);
  }
  .peek {
    font-size: 12.5px;
    color: var(--text-3);
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  .acts {
    position: absolute;
    top: 12px;
    right: 12px;
    display: flex;
    gap: 2px;
    opacity: 0;
    transition: opacity 0.18s var(--ease-out);
    background: var(--cream);
    border-radius: 9px;
  }
  .tcard:hover .acts,
  .tcard:focus-within .acts {
    opacity: 1;
  }
  .icon-btn {
    width: 26px;
    height: 26px;
    border-radius: 8px;
    cursor: pointer;
  }
</style>
