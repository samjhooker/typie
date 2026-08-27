<script>
  import { ui, send, local } from './bridge.svelte.js'
  import { Search, UploadCloud, Trash2, Download, Loader2, ShieldCheck, MonitorUp } from 'lucide-svelte'
  import { fly, fade } from 'svelte/transition'
  import { cubicOut } from 'svelte/easing'
  import InlineEdit from './InlineEdit.svelte'
  import SortSeg from './SortSeg.svelte'
  import Glyph from './Glyph.svelte'
  import { infinite } from './infinite.js'
  import { trash, fmtDateSmart } from './trash.svelte.js'
  import TranscriptDetail from './panes/TranscriptDetail.svelte'

  let dragging = $state(false)
  let query = $state('')
  // local upload state (the JS side drives chunking, so it owns progress)
  let uploading = $state(null) // { name, sent, total } | null

  // ── filtering + sorting + progressive paging ──
  const SORTS = [
    { id:'newest',  label:'newest' },
    { id:'oldest',  label:'oldest' },
    { id:'longest', label:'longest' },
  ]
  const PAGE = 60
  let sortBy = $state('newest')
  let shown = $state(PAGE)

  // staged deletions vanish instantly; native delete fires after the grace window
  const pendingT = $derived(trash.pendingIds('transcript'))
  const library = $derived(ui.transcripts.filter(x => !pendingT.has(x.id)))

  const filtered = $derived.by(() => {
    let arr = library
    if (query.trim()) {
      const q = query.trim().toLowerCase()
      arr = arr.filter(x => `${x.fileName} ${x.preview ?? ''} ${(x.turns ?? []).map(t => t.text).join(' ')}`.toLowerCase().includes(q))
    }
    return arr
  })

  const sorted = $derived.by(() => {
    const arr = [...filtered]
    switch (sortBy) {
      case 'oldest':  return arr.sort((a, b) => new Date(a.date) - new Date(b.date))
      case 'longest': return arr.sort((a, b) => (b.durationSeconds || 0) - (a.durationSeconds || 0))
      default:        return arr.sort((a, b) => new Date(b.date) - new Date(a.date))
    }
  })
  const visible = $derived(sorted.slice(0, shown))
  // any change to search/order resets paging back to the first page
  $effect(() => { query; sortBy; shown = PAGE })

  const hasWork = $derived(uploading !== null || ui.transcribe.busy || ui.transcribe.queued > 0)
  const waitList = $derived(ui.transcribe.busy ? ui.transcribe.queue.slice(1) : ui.transcribe.queue)
  const activeQ = $derived(ui.transcribe.busy ? ui.transcribe.queue[0] : null)

  // in-place status for items whose words haven't landed yet
  const STAGE_LABELS = {
    'reading audio': 'loading audio',
    'transcribing': 'transcribing',
    'identifying speakers': 'splitting speakers',
  }
  function statusOf(item){
    if (activeQ && activeQ.name === item.fileName) {
      const label = STAGE_LABELS[ui.transcribe.stage] || 'working…'
      const pct = ui.transcribe.progress != null ? ` ${Math.round(ui.transcribe.progress * 100)}%` : ''
      return { cls:'busy', label:label + pct }
    }
    if (waitList.some(q => q.name === item.fileName)) return { cls:'wait', label:'in queue' }
    return { cls:'wait', label:'warming up…' }
  }

  function fmtDur(s){ const n = Math.round(s || 0); return n > 0 ? `${Math.floor(n/60)}m ${String(n%60).padStart(2,'0')}s` : '' }

  function onDelete(e, item){
    e.stopPropagation()
    trash.add('transcript', [item.id], item.fileName || 'transcript')
  }

  // ── call capture live state — mirrors HomePane's chip (toggle + elapsed) ──
  const capturing = $derived(ui.meeting.isCapturing)
  const hasScreen = $derived(ui.permissions.screen || local.askedScreenPermission)
  // 1s tick while capturing so the elapsed time breathes
  let nowTick = $state(Date.now())
  $effect(() => {
    if (!capturing) return
    const t = setInterval(() => (nowTick = Date.now()), 1000)
    return () => clearInterval(t)
  })
  const startedMs = $derived(ui.meeting.startedAt ? Date.parse(ui.meeting.startedAt) : NaN)
  const elapsedLabel = $derived.by(() => {
    if (!capturing || Number.isNaN(startedMs)) return ''
    const s = Math.max(0, Math.floor((nowTick - startedMs) / 1000))
    return `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`
  })

  // ── upload plumbing ──
  function pickFile(){ send({ type:'transcribeChooseFile' }) }
  function onDrop(e){
    e.preventDefault(); dragging = false
    const files = e.dataTransfer?.files
    if (files?.length) uploadAll([...files])
  }
  async function uploadAll(files){ for (const f of files) await upload(f) }
  async function upload(file){
    uploading = { name:file.name, sent:0, total:file.size }
    const CHUNK = 4 * 1024 * 1024
    const bufToB64 = buf => {
      const b = new Uint8Array(buf); let bin = ''
      for (let i = 0; i < b.length; i += 0x8000) bin += String.fromCharCode(...b.subarray(i, i + 0x8000))
      return btoa(bin)
    }
    send({ type:'transcribeDropBegin', name:file.name, totalChunks:Math.ceil(file.size / CHUNK) })
    for (let off = 0; off < file.size; off += CHUNK){
      const chunk = await file.slice(off, off + CHUNK).arrayBuffer()
      send({ type:'transcribeDropChunk', index:off / CHUNK, b64:bufToB64(chunk) })
      uploading = { name:file.name, sent:Math.min(off + CHUNK, file.size), total:file.size }
    }
    send({ type:'transcribeDropEnd' })
    uploading = null
  }
</script>

<div class="wrap">
  <!-- detail slides in from the right; the library glides back when it leaves.
       both views share one grid cell so the crossfade never reflows. -->
  <div class="pane-host">
  {#if local.selectedTranscriptId}
    <div class="pane-view" in:fly={{ x: 48, duration: 340, easing: cubicOut }} out:fade={{ duration: 130 }}>
      <TranscriptDetail id={local.selectedTranscriptId} onBack={() => { local.selectedTranscriptId = null }} />
    </div>
  {:else}
  <div class="pane-view" in:fly={{ x: -36, duration: 340, easing: cubicOut }} out:fade={{ duration: 130 }}>
  <header class="head">
    <div>
      <h2>Library</h2>
      <p>every conversation, saved forever. <span class="hand hint-hand">nothing ever leaves this mac</span></p>
    </div>
  </header>

  {#if ui.transcribe.model.state === 'notDownloaded' || ui.transcribe.model.state === 'failed'}
    <div class="gate card">
      <p><b>one-time setup:</b> speaker models (~22 mb) are needed for diarization.</p>
      <button class="btn btn-pink small" onclick={() => send({ type:'startDiarizerDownload' })}>download models</button>
      {#if ui.transcribe.model.state === 'failed'}<p class="mono-kicker" style="color:var(--red-ink)">{ui.transcribe.model.error ?? 'download failed — try again'}</p>{/if}
    </div>
  {:else if ui.transcribe.model.state === 'downloading'}
    <div class="gate card">
      <div class="progress"><div style="width:{Math.max(3, ui.transcribe.model.fraction * 100)}%"></div></div>
      <p class="mono-kicker">{Math.round(ui.transcribe.model.fraction * 100)}% downloading…</p>
    </div>
  {:else if ui.transcribe.model.state === 'compiling' || ui.transcribe.model.state === 'unknown'}
    <div class="gate card" style="padding:12px 16px">
      <p class="mono-kicker">preparing models…</p>
    </div>
  {/if}
  {#if ui.transcribe.model.state === 'ready' || ui.transcribe.model.state === 'unknown' || ui.transcribe.model.state === 'compiling' || ui.transcribe.model.state === 'downloading'}

    <!-- ── twin actions: drop a file · capture a call ── -->
    <div class="actions">
      <div
        role="button" tabindex="0"
        class="dropzone" class:over={dragging} class:dim={hasWork}
        ondragover={(e) => { e.preventDefault(); dragging = true }}
        ondragleave={() => dragging = false}
        ondrop={onDrop}
        onclick={pickFile}
        onkeydown={(e) => e.key === 'Enter' && pickFile()}
      >
        <div class="dz-head">
          <span class="ico"><UploadCloud size={17} /></span>
          <h3>drop anything</h3>
        </div>
        <p class="mono-kicker">mp3 · m4a · wav · mp4 — or click to browse</p>
        <span class="hand dz-hand">several at once is fine</span>
      </div>

      <!-- capture card — pill parked in header next to title, same toggle as HomePane recs -->
      <div class="reccard" class:live={capturing}>
        <div class="dz-head">
          <span class="ico call-ico"><Glyph name={capturing ? 'stop' : 'record'} size={15} /></span>
          <h3>capture a call</h3>
          <!-- header pill: start → stop + elapsed, mirrors HomePane's btn-mint/btn-stop -->
          <div class="capture-pill">
            {#if ui.meeting.processing}
              <span class="livedot"><Loader2 size={12} /> filing recording…</span>
            {:else}
              <button
                class="btn small"
                class:btn-mint={!capturing && hasScreen}
                class:btn-stop={capturing}
                class:btn-pink={!hasScreen && !capturing}
                onclick={() => {
                  if (!hasScreen) send({ type:'requestScreenPermission' })
                  send({ type:'toggleMeetingRecording' })
                }}
              >
                {#if !hasScreen}<ShieldCheck size={12} />{:else if capturing}<Glyph name="stop" size={11} />{:else}<MonitorUp size={12} />{/if}
                {!hasScreen ? 'grant & record' : capturing ? 'stop capture' : 'start capture'}
              </button>
              {#if capturing}
                <span class="livedot"><i></i>{elapsedLabel}</span>
              {/if}
            {/if}
          </div>
        </div>
        <p>
          {#if capturing}
            got it all — every voice on this Mac is being saved. stop whenever you're ready.
          {:else}
            saves the whole conversation offline — their side from your Mac's sound, yours mixed right in — then transcribes and splits the speakers.
          {/if}
        </p>
        {#if !capturing}
          <span class="hand rec-hand">blip blip blip → full transcript</span>
        {/if}
      </div>
    </div>

    <!-- live work: one card per file — uploading / running / waiting -->
    {#if hasWork}
      <div class="worklist">
        {#if uploading}
          <div class="wrow card">
            <span class="stg"><Loader2 size={14} /> uploading</span>
            <span class="fname">{uploading.name}</span>
            <div class="bar slim"><div style="width:{Math.max(3, (uploading.sent / Math.max(1, uploading.total)) * 100)}%"></div></div>
            <span class="eta mono-kicker">{Math.round((uploading.sent / Math.max(1, uploading.total)) * 100)}%</span>
          </div>
        {:else if activeQ}
          <div class="wrow card">
            <span class="stg"><Loader2 size={14} /> {ui.transcribe.stage || 'processing'}</span>
            <span class="fname">{activeQ.name}</span>
            <div class="bar slim">
              <div class="indeterminate" style="width:{ui.transcribe.progress != null ? Math.max(3, ui.transcribe.progress * 100) : 30}%"></div>
            </div>
            <span class="eta mono-kicker">{ui.transcribe.eta || (ui.transcribe.progress != null ? `${Math.round(ui.transcribe.progress * 100)}%` : 'working…')}</span>
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
  {/if}

  {#if ui.transcribe.error}
    <p class="error">{ui.transcribe.error}</p>
  {/if}

  <!-- ── unified library ── -->
  <div class="lib-head">
    <h3>All conversations <span class="count">{sorted.length}</span></h3>
    <div class="lib-tools">
      <SortSeg options={SORTS} bind:value={sortBy} />
      <label class="input search">
        <Search size={14} />
        <input bind:value={query} placeholder="search…" spellcheck="false" data-search />
      </label>
    </div>
  </div>

  {#if filtered.length === 0}
    <div class="empty">
      <span class="hand big">{library.length === 0 ? 'nothing here yet — capture a call or drop a file ☝' : `no matches for “${query}”`}</span>
    </div>
  {:else}
    <div class="grid">
      {#each visible as item (item.id)}
        {@const st = item.turnCount > 0 ? null : statusOf(item)}
        <button class="tcard card" onclick={() => (local.selectedTranscriptId = item.id)}>
          <div class="top">
            <span class="ico" class:meeting={item.isMeeting}>
              <Glyph name={item.isMeeting ? 'record' : 'transcript'} size={15} />
            </span>
            <span class="chips">
              {#if st}
                <span class="chip st {st.cls}"><Loader2 size={11} /> {st.label}</span>
              {:else if !local.openedIds[item.id]}
                <span class="chip new">new</span>
              {/if}
            </span>
          </div>
          <h4><InlineEdit value={item.fileName} onSave={(v) => send({ type:'transcriptsRename', id:item.id, name:v })} /></h4>
          <p class="meta">{fmtDateSmart(item.date)}{item.durationSeconds > 1 ? ` · ${fmtDur(item.durationSeconds)}` : ''}{item.speakerCount > 0 ? ` · ${item.speakerCount} spk` : ''}</p>
          <p class="peek">{item.preview}</p>
          <span class="acts">
            <span class="icon-btn" role="button" tabindex="0" title="export markdown" onkeydown={(e) => e.key === 'Enter' && (e.stopPropagation(), send({ type:'transcriptExport', id:item.id, format:'md' }))} onclick={(e) => { e.stopPropagation(); send({ type:'transcriptExport', id:item.id, format:'md' }) }}><Download size={13} /></span>
            <span class="icon-btn" role="button" tabindex="0" title="delete" onkeydown={(e) => e.key === 'Enter' && onDelete(e, item)} onclick={(e) => onDelete(e, item)}><Trash2 size={13} /></span>
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
  </div><!-- /.pane-view -->
  {/if} <!-- end detail-view branch -->
  </div><!-- /.pane-host -->
</div>

<style>
  .wrap{ padding:28px 32px 40px; max-width:1200px; margin:0 auto }

  /* stacked panes: outgoing fades in place while the incoming one flies */
  .pane-host{ display:grid }
  .pane-view{ grid-area:1/1; min-width:0 }

  .head{ margin-bottom:20px }
  .head h2{ font-size:26px }
  .head p{ font-size:13px; color:var(--text-3); margin-top:4px }
  .hint-hand{ font-size:16px; color:var(--hotpink); margin-left:8px }

  /* ── twin action cards ── */
  .actions{
    display:grid; grid-template-columns:1fr 1fr; gap:16px;
    margin-bottom:22px;
  }
  @media(max-width:900px){ .actions{ grid-template-columns:1fr } }

  .dropzone{
    min-height:170px;
    display:flex; flex-direction:column; align-items:flex-start; justify-content:center; gap:8px;
    padding:20px 24px;
    border:2px dashed var(--line-strong);
    border-radius:24px;
    background:var(--paper);
    cursor:pointer;
    transition:border-color .2s var(--ease-out), background .2s var(--ease-out), transform .2s var(--spring);
  }
  .dropzone.dim{ opacity:.7 }
  .dropzone:hover, .dropzone.over{
    border-color:var(--hotpink);
    background:rgba(252,86,129,.05);
    transform:scale(1.005);
  }
  .dz-head{ display:flex; align-items:center; gap:10px; width:100% }
  .dz-head h3{ font-size:18px }
  /* header pill — pushed right, same mint/stop palette as HomePane */
  .capture-pill{ margin-left:auto; display:flex; align-items:center; gap:8px; flex-wrap:wrap }
  .capture-pill .btn{ white-space:nowrap }
  .ico{
    display:inline-grid; place-items:center;
    width:34px; height:34px; border-radius:11px;
    background:var(--lavender); color:var(--violet-ink);
  }
  .call-ico{ background:var(--pink); color:var(--hotpink) }
  .dropzone p{ font-size:11px }

  .reccard{
    min-height:170px;
    padding:20px 24px;
    border-radius:24px;
    background:linear-gradient(120deg, var(--cream) 45%, var(--card-mint));
    display:flex; flex-direction:column; align-items:flex-start; justify-content:center; gap:8px;
    transition:background .3s var(--ease-out), border-color .3s var(--ease-out);
  }
  .reccard.live{
    background:linear-gradient(120deg, var(--pink-band) 45%, var(--card-cream));
  }
  .livedot{
    display:inline-flex; align-items:center; gap:7px;
    padding:4px 12px; border-radius:999px;
    background:var(--ink); color:#ffd3e0;
    font-family:var(--mono); font-size:10px; letter-spacing:.08em; text-transform:uppercase;
  }
  .livedot i{
    width:7px; height:7px; border-radius:99px; background:var(--hotpink);
    animation:pulsebar 1.2s ease-in-out infinite alternate;
  }
  .btn-mint{
    background:var(--green-deep); color:#fffdf7;
    box-shadow:0 4px 12px rgba(2,69,60,.3);
  }
  .btn-mint:hover{ box-shadow:0 8px 18px rgba(2,69,60,.38) }
  .btn-stop{
    background:var(--red-ink); color:#fffdf7;
    box-shadow:0 4px 14px rgba(194,46,86,.4);
  }
  .btn-stop:hover{ box-shadow:0 7px 18px rgba(194,46,86,.5) }
  .reccard p{ font-size:12.5px; color:var(--text-2); max-width:52ch }
  .acts{ display:flex; align-items:center; gap:10px; flex-wrap:wrap }
  .rec-hand{ font-size:15px; color:var(--mint-live); transform:rotate(-2deg) }

  /* ── work queue ── */
  .worklist{ display:flex; flex-direction:column; gap:8px; margin-bottom:16px }
  .wrow{ display:flex; align-items:center; gap:14px; padding:12px 18px }
  .wrow .stg{
    display:inline-flex; align-items:center; gap:7px;
    font-size:13px; font-weight:700; color:var(--ink); white-space:nowrap;
  }
  .wrow .stg.dim{ color:var(--text-3); font-weight:600 }
  .wrow :global(.stg svg){ animation:spin 1s linear infinite; color:var(--hotpink) }
  .wrow.waiting :global(.stg svg){ color:var(--text-3) }
  .fname{ flex:1; min-width:0; font-family:var(--mono); font-size:11.5px; color:var(--text-2); overflow:hidden; text-overflow:ellipsis; white-space:nowrap }
  .bar{ flex:1; height:8px; border-radius:99px; background:rgba(3,89,77,.1); overflow:hidden }
  .bar > div{ height:100%; border-radius:99px; background:linear-gradient(90deg,var(--hotpink),var(--purple)); transition:width .4s var(--ease-out) }
  .indeterminate{ animation:pulsebar 1.6s ease-in-out infinite alternate }
  @keyframes pulsebar{ from{ opacity:.45 } to{ opacity:1 } }
  @keyframes spin{ to{ transform:rotate(360deg) } }
  .eta{ white-space:nowrap }
  .chip.queued{ background:var(--card-blue); color:var(--peri-ink) }

  .error{
    margin-top:14px; padding:12px 16px; border-radius:14px;
    background:rgba(252,86,129,.12); color:var(--red-ink); font-size:13px;
  }

  .gate{
    padding:26px; text-align:center;
    display:flex; flex-direction:column; align-items:center; gap:12px;
    max-width:560px; margin-bottom:26px;
  }
  .gate p{ font-size:13.5px; color:var(--text-2) }
  .gate .progress{ width:min(340px, 80%) }

  /* ── library ── */
  .lib-head{
    display:flex; align-items:center; justify-content:space-between; gap:18px;
    margin:6px 0 16px; flex-wrap:wrap;
  }
  .lib-head h3{ font-size:17px }
  .lib-tools{ display:flex; align-items:center; gap:10px; flex-wrap:wrap }
  .count{ font-family:var(--mono); font-size:11px; color:var(--text-3); vertical-align:2px; margin-left:4px }
  .search{ max-width:260px; padding:8px 15px; background:var(--cream) }

  .empty{ padding:60px 20px; text-align:center }
  .big{ font-size:26px; color:var(--ink) }

  .grid{ display:grid; grid-template-columns:repeat(auto-fill, minmax(250px, 1fr)); gap:16px }

  .tcard{
    position:relative; text-align:left; cursor:pointer;
    padding:18px; display:flex; flex-direction:column; gap:8px;
    transition:transform .2s var(--spring), box-shadow .2s var(--ease-out), border-color .2s var(--ease-out);
  }
  .tcard:hover{ transform:translateY(-3px); box-shadow:0 10px 24px rgba(19,23,34,.09); border-color:var(--line-strong) }
  .tcard .top{ display:flex; align-items:center; justify-content:space-between }
  .ico{
    display:inline-grid; place-items:center;
    width:36px; height:36px; border-radius:12px;
    background:var(--lavender); color:var(--violet-ink);
  }
  .ico.meeting{ background:var(--pink); color:var(--hotpink) }
  .chips{ display:flex; align-items:center; gap:6px }
  .chip.new{ background:var(--card-mint); color:var(--green-deep); font-weight:700 }
  .chip.st{ gap:6px }
  .chip.st :global(svg){ animation:spin 1s linear infinite; flex-shrink:0 }
  .chip.st.busy{ background:var(--pink); color:var(--red-ink) }
  .chip.st.wait{ background:var(--card-cream); color:var(--gold-ink) }

  .tcard h4{ font-size:14.5px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
  .meta{ font-family:var(--mono); font-size:10.5px; letter-spacing:.04em; color:var(--text-3) }
  .peek{
    font-size:12.5px; color:var(--text-3); line-height:1.5;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
  }

  .acts{ position:absolute; top:12px; right:12px; display:flex; gap:2px; opacity:0; transition:opacity .18s var(--ease-out); background:var(--cream); border-radius:9px }
  .tcard:hover .acts, .tcard:focus-within .acts{ opacity:1 }
  .icon-btn{ width:26px; height:26px; border-radius:8px; cursor:pointer }

  .more{
    display:block; margin:20px auto 4px;
    padding:8px 18px; border-radius:999px;
    font-family:var(--mono); font-size:11px; letter-spacing:.08em; text-transform:uppercase;
    color:var(--text-3);
    border:1px dashed var(--line-strong);
    transition:
      color .18s var(--ease-out),
      border-color .18s var(--ease-out),
      background .18s var(--ease-out);
  }
  .more:hover{ color:var(--hotpink); border-color:var(--hotpink); background:rgba(252,86,129,.05) }
</style>
