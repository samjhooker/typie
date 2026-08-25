<script>
  import { ui, send, transcriptCache, local } from '../bridge.svelte.js'
  import InlineEdit from '../InlineEdit.svelte'
  import { ArrowLeft, Search, Download, Play, Pause, Pencil, Check, Sparkles, Clock, Loader2, Wand2 } from 'lucide-svelte'
  import { infinite } from '../infinite.js'

  let { id, onBack } = $props()

  let query = $state('')
  let playing = $state(false)
  let currentTime = $state(0)
  let duration = $state(0)
  let rate = $state(1)
  let renaming = $state(null)
  let renameVal = $state('')
  let audioEl

  // progressive rendering — long meetings are thousands of word spans;
  // mount them a page at a time as the reader (or playback) advances
  const TURN_PAGE = 50
  let shown = $state(TURN_PAGE)

  const meta = $derived(ui.transcripts.find(x => x.id === id))
  // once a transcript has been opened it's no longer "new"
  $effect(() => { if (id) local.openedIds[id] = true })
  const cached = $derived(transcriptCache[id])
  // metadata arrives via the global push; turns/words arrive on demand —
  // request (or refresh) whenever the stored turnCount moves ahead of cache
  $effect(() => {
    if (!id || !meta) return
    const needsAI = !cached || cached.aiStatus !== meta.aiStatus || cached.aiSummary !== meta.aiSummary || cached.aiTitle !== meta.aiTitle
    if (!cached || cached.turns.length !== meta.turnCount || cached.fileName !== meta.fileName || needsAI) {
      send({ type:'transcriptGet', id })
    }
  })
  const t = $derived(meta
    ? { ...meta, ...(cached ?? {}), speakerNames: { ...(meta.speakerNames ?? {}), ...(cached?.speakerNames ?? {}) },
        // AI fields: prefer cached when it has real content, but fall through to meta when cached is empty/stale
        aiTitle: (cached?.aiTitle && cached.aiTitle !== '' ? cached.aiTitle : (meta.aiTitle ?? '')),
        aiSummary: (cached?.aiSummary && cached.aiSummary !== '' ? cached.aiSummary : (meta.aiSummary ?? '')),
        aiStatus: (cached?.aiStatus && cached.aiStatus !== '' ? cached.aiStatus : (meta.aiStatus ?? '')),
        aiTopics: (cached?.aiTopics && cached.aiTopics.length ? cached.aiTopics : (meta.aiTopics ?? [])) }
    : null)
  // turns arrive via the on-demand fetch; metadata alone has none yet
  const turns = $derived(t ? (t.turns ?? []) : [])
  const filtered = $derived(
    !t || query.trim() === ''
      ? turns
      : turns.filter(x => x.text.toLowerCase().includes(query.trim().toLowerCase()))
  )
  const visibleTurns = $derived(filtered.slice(0, shown))
  $effect(() => { query; shown = TURN_PAGE })
  const speakers = $derived(
    t ? [...new Set(turns.map(x => x.speaker))].sort((a, b) => a - b) : []
  )

  const SP_COLORS = ['var(--sp1)','var(--sp2)','var(--sp3)','var(--sp4)','var(--sp5)','var(--sp6)']
  function spColor(i){ return SP_COLORS[i % SP_COLORS.length] }
  function spName(i){ return t?.speakerNames?.[String(i)] ?? `Speaker ${i + 1}` }
  function spInitial(i){ return (spName(i).trim()[0] ?? '?').toUpperCase() }

  function startRename(i){
    renaming = i
    renameVal = spName(i)
  }
  function saveRename(){
    if (renaming != null && renameVal.trim() && t) {
      send({ type:'transcriptsRenameSpeaker', id:t.id, index:renaming, name:renameVal.trim() })
    }
    renaming = null
  }

  function fmtDur(s){
    const n = Math.max(0, Math.floor(s))
    return `${String(Math.floor(n/60)).padStart(2,'0')}:${String(n%60).padStart(2,'0')}`
  }
  function fmtDate(iso){ return new Date(iso).toLocaleDateString(undefined,{ month:'long', day:'numeric', year:'numeric' }) }
  function fmtClock(s){ // h:mm:ss for the dock
    const n = Math.max(0, Math.floor(s))
    const h = Math.floor(n / 3600)
    return h > 0 ? `${h}:${String(Math.floor(n/60)%60).padStart(2,'0')}:${String(n%60).padStart(2,'0')}` : fmtDur(s)
  }

  // ── audio playback ──────────────────────────────────────────

  function togglePlay(){
    if (!audioEl) return
    if (playing) audioEl.pause()
    else audioEl.play().catch(() => {})
  }
  function seekTo(s, andPlay = false){
    if (!audioEl) return
    audioEl.currentTime = Math.max(0, Math.min(s, duration || t?.durationSeconds || 0))
    if (andPlay && !playing) audioEl.play().catch(() => {})
  }

  // smooth word highlighting — rAF while playing, timeupdate as fallback
  let raf = 0
  function tick(){ currentTime = audioEl.currentTime; raf = requestAnimationFrame(tick) }
  function onPlay(){ playing = true; tick() }
  function onStop(){ playing = false; cancelAnimationFrame(raf); if (audioEl) currentTime = audioEl.currentTime }
  $effect(() => () => cancelAnimationFrame(raf))

  function setRate(r){
    rate = r
    if (audioEl) audioEl.playbackRate = r
  }

  // ── words ───────────────────────────────────────────────────

  // real word timings when present; legacy transcripts get estimates
  function wordsOf(turn){
    if (turn.words?.length) {
      return turn.words.map(w => ({ text:w.text, start:w.start, end:w.end }))
    }
    const parts = (turn.text || '').split(/\s+/).filter(Boolean)
    const totalLen = parts.reduce((a, p) => a + p.length + 1, 0) || 1
    const span = Math.max(0.4, turn.end - turn.start)
    let at = turn.start
    return parts.map(p => {
      const d = ((p.length + 1) / totalLen) * span
      const w = { text:p, start:at, end:at + d }
      at += d
      return w
    })
  }

  const activeTurnIdx = $derived(
    turns.findIndex(turn => currentTime >= turn.start && currentTime < turn.end + 0.3)
  )
  const activeTurn = $derived(activeTurnIdx >= 0 ? turns[activeTurnIdx] : null)

  // follow playback: keep the spoken block in view (paging in more if needed)
  let turnEls = {}
  $effect(() => {
    if (!playing || activeTurnIdx < 0) return
    if (activeTurnIdx >= shown) shown = Math.min(filtered.length, activeTurnIdx + 25)
    turnEls[activeTurnIdx]?.scrollIntoView({ block:'center', behavior:'smooth' })
  })

  // reset when switching transcripts
  $effect(() => {
    id
    playing = false; currentTime = 0; duration = 0; rate = 1; shown = TURN_PAGE
  })

  // ── AI helpers ───────────────────────────────────────────────
  const aiTopics = $derived(t?.aiTopics ?? [])
  const aiSummary = $derived(t?.aiSummary ?? '')
  const aiTitle = $derived(t?.aiTitle ?? '')
  const aiStatus = $derived(t?.aiStatus ?? '')
  const aiAvailable = $derived(ui.aiAvailable ?? false)
  function generateAI(){ if (t) send({ type:'transcriptGenerateAI', id:t.id }) }
  function clearAI(){ if (t) send({ type:'transcriptClearAI', id:t.id }) }

  // esc returns to the library (unless a speaker rename is in progress)
  function onKeydown(e){
    if (e.key === 'Escape' && renaming == null) onBack()
  }
</script>

<svelte:window onkeydown={onKeydown} />

{#if !t}
  <div class="missing">
    <p>transcript not found.</p>
    <button class="btn btn-ghost small" onclick={onBack}>← back</button>
  </div>
{:else}
<div class="wrap" class:docked={t.audioUrl}>
  <!-- sticky header: arrow + title + exports on one line -->
  <header>
    <div class="titlerow">
      <button class="back-arrow" onclick={onBack} aria-label="back"><ArrowLeft size={18} /></button>
      <div class="titleblock">
        <h2><InlineEdit value={t.fileName} size="lg" onSave={(v) => send({ type:'transcriptsRename', id:t.id, name:v })} /></h2>
        <p class="meta mono-kicker">{fmtDate(t.date)} · {fmtDur(duration || t.durationSeconds)} · {speakers.length} speaker{speakers.length === 1 ? '' : 's'}{t.isMeeting ? ' · call' : ''}</p>
      </div>
      <div class="exports">
        <button class="btn btn-ghost small" onclick={() => send({ type:'transcriptExport', id:t.id, format:'md' })}><Download size={13} /> .md</button>
        <button class="btn btn-ghost small" onclick={() => send({ type:'transcriptExport', id:t.id, format:'txt' })}><Download size={13} /> .txt</button>
      </div>
    </div>
  </header>

  <!-- AI summary + topics — on-device via Apple Foundation Models -->
  {#if aiSummary || aiStatus === 'pending' || aiStatus === 'failed' || (t.turns?.length > 0 && !aiSummary)}
    <div class="ai card">
      <div class="ai-head">
        <span class="ai-badge"><Sparkles size={13} /> on-device AI</span>
        {#if aiStatus === 'pending'}
          <span class="mono-kicker ai-pending"><Loader2 size={12} /> generating…</span>
        {:else if aiSummary}
          <button class="btn btn-ghost small ai-regen" onclick={generateAI} title="regenerate"><Wand2 size={12} /> regenerate</button>
        {:else if aiStatus === 'failed'}
          <span class="mono-kicker" style="color:var(--red-ink)">failed — try again</span>
        {/if}
      </div>
      {#if aiStatus === 'pending'}
        <p class="ai-pending-text hand">writing your meeting notes… this runs entirely on this Mac, no network</p>
        <div class="progress" style="margin-top:10px"><div style="width:30%" class="indet"></div></div>
      {:else if aiSummary}
        {#if aiTitle}<h3 class="ai-title">{aiTitle}</h3>{/if}
        <p class="ai-summary">{aiSummary}</p>
        {#if aiTopics.length > 0}
          <div class="ai-topics">
            {#each aiTopics as topic (topic.title + topic.start)}
              <button class="topic pill" onclick={() => seekTo(topic.start, true)} title={topic.summary}>
                <Clock size={11} /> {fmtDur(topic.start)} · {topic.title}
              </button>
            {/each}
          </div>
        {/if}
      {:else}
        <p class="ai-empty">no summary yet</p>
        {#if aiAvailable}
          <button class="btn btn-pink small" onclick={generateAI}><Sparkles size={13} /> generate title + summary + topics</button>
        {:else}
          <p class="mono-kicker ai-hint">requires macOS 26 with Apple Intelligence enabled — or enjoy the local heuristic on this device</p>
          <button class="btn btn-ghost small" onclick={generateAI}><Wand2 size={13} /> generate with heuristic</button>
        {/if}
      {/if}
    </div>
  {/if}

  <div class="filters">
    <label class="input search">
      <Search size={14} />
      <input bind:value={query} placeholder="search this transcript…" spellcheck="false" />
    </label>

    <!-- speaker legend -->
    {#if speakers.length > 0}
      <div class="legend">
        {#each speakers as i (i)}
          {#if renaming === i}
            <span class="speaker pill editing" style="--c:{spColor(i)}">
              <input
                bind:value={renameVal}
                onkeydown={(e) => { if (e.key === 'Enter') saveRename(); if (e.key === 'Escape') renaming = null }}
                spellcheck="false"
              />
              <button class="ok" onclick={saveRename}><Check size={12} /></button>
            </span>
          {:else}
            <button class="speaker pill" style="--c:{spColor(i)}" title="click to rename" onclick={() => startRename(i)}>
              <i></i>{spName(i)} <Pencil size={10} />
            </button>
          {/if}
        {/each}
      </div>
    {/if}
  </div>

  <!-- transcript — otter-style blocks -->
  {#if turns.length === 0}
    <div class="pending">
      <span class="hand big">recording saved — the words are on their way…</span>
      <p class="mono-kicker">transcription + speaker labels land here automatically</p>
    </div>
  {:else}
    <div class="turns">
      {#each visibleTurns as turn, idx (idx)}
        {@const isNow = t.audioUrl && turn === activeTurn}
        <div class="oturn" class:now={isNow} bind:this={turnEls[idx]}>
          <div class="ohead">
            <span class="avatar" style="background:{spColor(turn.speaker)}">{spInitial(turn.speaker)}</span>
            <span class="oname">{spName(turn.speaker)}</span>
            <button
              class="ts mono-kicker"
              title={t.audioUrl ? 'play from here' : undefined}
              onclick={() => t.audioUrl && seekTo(turn.start, true)}
            >
              {fmtDur(turn.start)}
            </button>
            {#if isNow}<span class="eq"><i></i><i></i><i></i></span>{/if}
          </div>
          <p class="otext">
            {#each wordsOf(turn) as w, wi (wi)}
              <span
                class="w"
                class:on={t.audioUrl && currentTime >= w.start && currentTime < w.end}
                onclick={() => t.audioUrl && seekTo(w.start, true)}
              >{w.text}</span>
            {/each}
          </p>
        </div>
      {/each}
      {#if filtered.length === 0}
        <p class="nomatch hand">no matches for “{query}”…</p>
      {/if}

      {#if visibleTurns.length < filtered.length}
        <button
          class="more"
          use:infinite={() => (shown += TURN_PAGE)}
          onclick={() => (shown += TURN_PAGE)}
        >
          show more · {filtered.length - visibleTurns.length} blocks left
        </button>
      {/if}
    </div>
  {/if}

  <!-- bottom bar: static, stuck to viewport bottom like header -->
  {#if t.audioUrl}
    <div class="dock">
      <button class="play" onclick={togglePlay}>
        {#if playing}<Pause size={16} />{:else}<Play size={16} />{/if}
      </button>
      <span class="time mono-kicker now">{fmtClock(currentTime)}</span>

      <div
        class="tl"
        role="slider" tabindex="0" aria-label="seek"
        onkeydown={(e) => { if (e.key === 'ArrowRight') seekTo(currentTime + 5); if (e.key === 'ArrowLeft') seekTo(currentTime - 5) }}
        onclick={(e) => seekTo(((e.clientX - e.currentTarget.getBoundingClientRect().left) / e.currentTarget.getBoundingClientRect().width) * (duration || t.durationSeconds))}
      >
        {#each filtered as seg}
          {@const left = (seg.start / Math.max(1, duration || t.durationSeconds)) * 100}
          {@const width = Math.max(0.4, ((seg.end - seg.start) / Math.max(1, duration || t.durationSeconds)) * 100)}
          <div class="seg" style="left:{left}%; width:{width}%; background:{spColor(seg.speaker)}"></div>
        {/each}
        <div class="head" style="left:{((duration ? currentTime / duration : 0)) * 100}%"><i></i></div>
      </div>

      <span class="time mono-kicker dim">{fmtClock(duration || t.durationSeconds)}</span>
      <div class="rates">
        {#each [0.75, 1, 1.5, 2] as r (r)}
          <button class="rate" class:on={rate === r} onclick={() => setRate(r)}>{r}×</button>
        {/each}
      </div>

      <audio
        bind:this={audioEl}
        src="{t.audioUrl}"
        onplay={onPlay}
        onpause={onStop}
        onended={onStop}
        ontimeupdate={() => { if (!playing && audioEl) currentTime = audioEl.currentTime }}
        onloadedmetadata={() => { duration = audioEl.duration || t.durationSeconds }}
        preload="metadata"
      ></audio>
    </div>
  {:else}
    <p class="noaudio hand">this one was saved without audio — text only.</p>
  {/if}
</div>
{/if}

<style>
  .wrap{ padding:24px 32px 80px; max-width:880px; margin:0 auto; flex:1; min-height:100%; display:flex; flex-direction:column }
  .wrap.docked{ padding-bottom:80px }
  /* ── sticky header — pinned to top of viewport ── */
  header{
    position:sticky; top:0; z-index:30;
    margin:-24px -32px 14px; padding:16px 32px 12px;
    background:#fff;
    backdrop-filter:blur(12px);
    border-bottom:1px solid var(--line);
  }
  .wrap.docked header{ margin-top:-24px }
  .missing{ padding:60px; text-align:center; display:flex; flex-direction:column; gap:14px; align-items:center }

  .back-arrow{
    display:grid; place-items:center; flex-shrink:0;
    width:32px; height:32px; border-radius:999px;
    color:var(--text-2);
    transition:background .15s var(--ease-out), color .15s var(--ease-out);
  }
  .back-arrow:hover{ background:rgba(19,23,34,.06); color:var(--ink) }
  .back-arrow:active{ transform:scale(.96) }

  .titlerow{ display:flex; align-items:center; gap:14px }
  .titleblock{ flex:1; min-width:0 }
  h2 :global(.ie .txt){ white-space:normal }
  h2 :global(.ie input){ font-size:22px; font-weight:800; letter-spacing:-.02em }
  .meta{ margin-top:4px }

  .exports{ display:flex; gap:8px; flex-shrink:0 }
  .filters{ display:flex; flex-direction:column; align-items:flex-start; gap:12px; margin-top:2px }
  .search{ max-width:420px }

  .legend{ display:flex; flex-wrap:wrap; gap:8px; margin-top:14px }
  .pill{
    display:inline-flex; align-items:center; gap:6px;
    padding:4px 12px; border-radius:999px;
    background:var(--paper); border:1px solid var(--line);
    font-size:12px; font-weight:600; color:var(--ink);
    transition:border-color .18s var(--ease-out), transform .18s var(--spring);
  }
  button.pill:hover{ border-color:var(--c); transform:translateY(-1px) }
  .pill i{ width:9px; height:9px; border-radius:99px; background:var(--c); flex-shrink:0 }
  .pill svg{ opacity:.4 }
  .pill.editing{ gap:4px; padding-right:6px }
  .pill.editing input{
    width:110px; background:none; border:none; outline:none;
    font-size:12px; font-weight:600; color:var(--ink);
    user-select:text;
  }
  .pill .ok{ display:grid; place-items:center; width:22px; height:22px; border-radius:99px; color:var(--green-deep) }
  .pill .ok:hover{ background:var(--card-mint) }

  /* ── otter-style blocks ── */
  .turns{ margin-top:26px; display:flex; flex-direction:column; gap:6px; padding-bottom:8px }

  .oturn{
    position:relative;
    padding:10px 14px 11px;
    border-radius:14px;
    border:1px solid transparent;
    transition:background .2s var(--ease-out), border-color .2s var(--ease-out);
  }
  .oturn:hover{ background:var(--paper) }
  .oturn.now{
    background:color-mix(in srgb, var(--hotpink) 5%, transparent);
    border-color:rgba(252,86,129,.25);
  }

  .ohead{ display:flex; align-items:center; gap:9px; margin-bottom:5px }
  .avatar{
    display:grid; place-items:center;
    width:24px; height:24px; border-radius:99px; flex-shrink:0;
    color:#fff; font-size:11px; font-weight:800;
    letter-spacing:0;
  }
  .oname{ font-size:13px; font-weight:700; color:var(--ink) }
  .ts{
    cursor:pointer; opacity:.55; letter-spacing:.05em;
    transition:opacity .15s var(--ease-out), color .15s var(--ease-out);
  }
  .ts:hover{ opacity:1; color:var(--hotpink); text-decoration:underline }
  .eq{ display:inline-flex; gap:2px; height:9px; align-items:flex-end }
  .eq i{ width:3px; background:var(--hotpink); border-radius:2px; animation:eq 0.7s ease-in-out infinite }
  .eq i:nth-child(1){ animation-delay:0s }
  .eq i:nth-child(2){ animation-delay:.18s }
  .eq i:nth-child(3){ animation-delay:.36s }
  @keyframes eq{ 50%{ height:3px } 0%,100%{ height:9px } }

  .otext{ font-size:15px; line-height:1.85; color:var(--text-1); user-select:text; overflow-wrap:anywhere }
  .w{
    border-radius:5px; padding:1px 2px; margin:0 -1px;
    cursor:pointer;
    transition:background .12s var(--ease-out);
  }
  .w:hover{ background:rgba(252,86,129,.14) }
  .w.on{ background:var(--hotpink); color:#fff }
  .nomatch{ text-align:center; padding:40px 0; font-size:26px; color:var(--ink) }

  .more{
    display:block; margin:16px auto;
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

  /* ── bottom dock ── */
  .noaudio{ margin-top:20px; font-size:19px; color:var(--text-3) }

  .pending{ padding:60px 20px; text-align:center; display:flex; flex-direction:column; gap:8px }
  .pending .big{ font-size:26px; color:var(--ink) }

  .dock{
    position:sticky; bottom:0; z-index:5;
    margin-top:auto;
    margin-left:-32px; margin-right:-32px; margin-bottom:-80px;
    padding:11px 32px;
    display:flex; align-items:center; gap:13px;
    background:#fff;
    border-top:1px solid var(--line);
  }
  .play{
    display:grid; place-items:center; flex-shrink:0;
    width:42px; height:42px; border-radius:99px;
    background:var(--hotpink); color:#fff;
    box-shadow:0 4px 12px rgba(252,86,129,.35);
    transition:transform .18s var(--spring);
  }
  .play:hover{ transform:scale(1.07) }
  .play:active{ transform:scale(.96) }
  .time{ white-space:nowrap }
  .now{ color:var(--ink); font-weight:500 }
  .dim{ color:var(--text-3) }

  .tl{
    position:relative; flex:1; height:14px; border-radius:99px;
    background:rgba(3,89,77,.09); cursor:pointer;
    overflow:hidden;
  }
  .tl::before{ content:''; position:absolute; inset:0 } /* hit area */
  .seg{
    position:absolute; top:3px; bottom:3px;
    border-radius:99px; opacity:.75;
  }
  .head{
    position:absolute; top:-2px; bottom:-2px; width:2.5px;
    background:var(--ink); border-radius:2px;
    pointer-events:none;
  }
  .head i{
    position:absolute; top:-1px; left:50%; transform:translateX(-50%);
    width:9px; height:9px; border-radius:99px;
    background:var(--ink);
  }
  .rates{ display:flex; gap:2px; flex-shrink:0 }
  .rate{
    padding:3px 8px; border-radius:99px;
    font-family:var(--mono); font-size:10px; color:var(--text-3);
    transition:background .15s var(--ease-out), color .15s var(--ease-out);
  }
  .ai{ padding:18px 20px; margin:14px 0 6px; background:linear-gradient(135deg, var(--cream) 40%, var(--card-mint)); border-color:rgba(3,89,77,.12) }
  .ai-head{ display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px }
  .ai-badge{ display:inline-flex; align-items:center; gap:6px; padding:4px 10px; border-radius:999px; background:var(--ink); color:#fffdf7; font-family:var(--mono); font-size:10px; letter-spacing:.08em; text-transform:uppercase }
  .ai-badge :global(svg){ color:var(--mint) }
  .ai-pending{ display:inline-flex; align-items:center; gap:6px; color:var(--text-3) }
  .ai-pending :global(svg){ animation:spin 1s linear infinite }
  @keyframes spin{ to{ transform:rotate(360deg) } }
  .ai-pending-text{ font-size:16px; color:var(--text-2) }
  .ai-title{ font-size:18px; margin:6px 0 6px }
  .ai-summary{ font-size:13.5px; line-height:1.6; color:var(--text-1); user-select:text }
  .ai-topics{ display:flex; flex-wrap:wrap; gap:8px; margin-top:12px }
  .topic{ background:var(--paper); border:1px solid var(--line); color:var(--ink); cursor:pointer }
  .topic:hover{ border-color:var(--hotpink); color:var(--hotpink) }
  .ai-empty{ font-size:13px; color:var(--text-3); margin-bottom:10px }
  .ai-hint{ font-size:10px; margin:8px 0 10px; line-height:1.4 }
  .ai-regen{ padding:5px 10px; font-size:11px }
  .progress .indet{ animation:pulsebar 1.4s ease-in-out infinite alternate }
  @keyframes pulsebar{ from{ opacity:.4 } to{ opacity:1 } }

  .rate:hover{ background:rgba(19,23,34,.06); color:var(--ink) }
  .rate.on{ background:var(--ink); color:#fff }
</style>
