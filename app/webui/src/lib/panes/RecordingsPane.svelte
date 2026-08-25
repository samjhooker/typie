<script>
  import { ui, send, local } from '../bridge.svelte.js'
  import { MonitorUp, Trash2, CheckCircle2, ShieldCheck, Loader2 } from 'lucide-svelte'
  import InlineEdit from '../InlineEdit.svelte'
  import SortSeg from '../SortSeg.svelte'
  import Glyph from '../Glyph.svelte'
  import { infinite } from '../infinite.js'
  import { trash, fmtDateSmart } from '../trash.svelte.js'

  // when embedded in the Library pane, the tab bar provides the title
  let { embedded = false } = $props()

  // ── sorting + progressive paging (hundreds of recordings stay fast) ──
  const SORTS = [
    { id:'newest',  label:'newest' },
    { id:'oldest',  label:'oldest' },
    { id:'longest', label:'longest' },
  ]
  const PAGE = 60
  let sortBy = $state('newest')
  let shown = $state(PAGE)

  const sorted = $derived.by(() => {
    const pending = trash.pendingIds('transcript')
    const arr = [...ui.transcripts.filter(t => t.isMeeting && !pending.has(t.id))]
    switch (sortBy) {
      case 'oldest':  return arr.sort((a, b) => new Date(a.date) - new Date(b.date))
      case 'longest': return arr.sort((a, b) => (b.durationSeconds || 0) - (a.durationSeconds || 0))
      default:        return arr.sort((a, b) => new Date(b.date) - new Date(a.date))
    }
  })
  const visible = $derived(sorted.slice(0, shown))
  $effect(() => { sortBy; shown = PAGE })

  function fmtDate(iso){ return fmtDateSmart(iso) }
  function fmtDur(s){ const n = Math.round(s || 0); return n > 0 ? `${Math.floor(n/60)}m ${String(n%60).padStart(2,'0')}s` : '—' }

  // ── live pipeline status per meeting row ──
  // the running job's name matches the placeholder's fileName
  const activeJob = $derived(ui.transcribe.busy ? ui.transcribe.queue[0] : null)
  const waitingNames = $derived(
    new Set((ui.transcribe.queue.slice(ui.transcribe.busy ? 1 : 0)).map(q => q.name))
  )
  const STAGE_LABELS = {
    'reading audio': 'loading audio',
    'transcribing': 'transcribing',
    'identifying speakers': 'splitting speakers',
  }
  function statusOf(r){
    if (r.turnCount > 0) {
      const sp = r.speakerCount > 0 ? ` · ${r.speakerCount} speaker${r.speakerCount === 1 ? '' : 's'}` : ''
      return { cls:'ok', label:`ready${sp}` }
    }
    if (activeJob && activeJob.name === r.fileName) {
      const label = STAGE_LABELS[ui.transcribe.stage] || 'working…'
      const pct = ui.transcribe.progress != null ? ` ${Math.round(ui.transcribe.progress * 100)}%` : ''
      return { cls:'busy', label:label + pct, eta:ui.transcribe.eta || '' }
    }
    if (waitingNames.has(r.fileName)) return { cls:'wait', label:'in queue' }
    return { cls:'wait', label:'warming up…' }
  }
</script>

<div class="wrap" class:embedded={embedded}>
  {#if !embedded}
    <header class="head">
      <div>
        <h2>Recordings</h2>
        <p>capture all the audio on this Mac — zoom, meet, whatever. <span class="hand hint-hand">press record, have your meeting</span></p>
      </div>
    </header>
  {/if}

  <!-- record card -->
  <div class="record card">
    <div class="rec-copy">
      <span class="mono-kicker">meeting recorder</span>
      <h3>Record a meeting</h3>
      <p>grabs the whole system mix (and your mic if you like), transcribes it live on-device and hands you a diarized transcript the moment you stop.</p>
      <div class="perm" class:ok={ui.permissions.screen}>
        <ShieldCheck size={13} />
        {ui.permissions.screen ? 'screen audio permission granted' : 'macOS will ask for audio permission once'}
      </div>
    </div>
    <button
      class="recbtn"
      class:armed={ui.permissions.screen}
      onclick={() => {
        if (!ui.permissions.screen) send({ type:'requestScreenPermission' })
        send({ type:'toggleMeetingRecording' })
      }}
    >
      <span class="disc">
        {#if !ui.permissions.screen}<MonitorUp size={22} />{:else}<Glyph name="record" size={20} />{/if}
      </span>
      <span>{!ui.permissions.screen ? 'grant & record' : 'start recording'}</span>
    </button>
    <span class="hand note-hand">blip blip blip → full transcript</span>
  </div>

  <!-- list -->
  <div class="lib-head">
    <h3>Past meetings <span class="count">{sorted.length}</span></h3>
    <SortSeg options={SORTS} bind:value={sortBy} />
  </div>

  {#if sorted.length === 0}
    <div class="empty">
      <span class="hand big">no meetings captured yet…</span>
      <p>your recorded calls will show up here, fully transcribed.</p>
    </div>
  {:else}
    <div class="list">
      {#each visible as r (r.id)}
        <div class="row card">
          <span class="ico"><Glyph name="transcript" size={16} /></span>
          <button class="main" onclick={() => (local.selectedTranscriptId = r.id)}>
            <strong><InlineEdit value={r.fileName} onSave={(v) => send({ type:'transcriptsRename', id:r.id, name:v })} /></strong>
            <span class="meta mono-kicker">{fmtDate(r.date)} · {fmtDur(r.durationSeconds)}{r.speakerCount > 0 ? ` · ${r.speakerCount} speaker${r.speakerCount === 1 ? '' : 's'}` : ''}</span>
          </button>
          {#if r.turnCount === 0}
            {@const st = statusOf(r)}
            <span class="chip st {st.cls}" title={st.eta || undefined}>
              {#if st.cls !== 'ok'}<Loader2 size={11} />{/if}{st.label}
            </span>
          {:else if r.hasAudio}<span class="chip ok"><CheckCircle2 size={11} /> ready</span>{/if}
          <button class="icon-btn" title="delete" onclick={() => trash.add('transcript', [r.id], r.fileName || 'recording')}><Trash2 size={13} /></button>
        </div>
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
  .wrap{ padding:28px 32px 40px; max-width:1000px; margin:0 auto; width:100% }
  .wrap.embedded{ padding-top:8px }

  .head{ margin-bottom:20px }
  .head h2{ font-size:26px }
  .head p{ font-size:13px; color:var(--text-3); margin-top:4px }
  .hint-hand{ font-size:16px; color:var(--hotpink); margin-left:8px }

  .record{
    display:flex; align-items:center; gap:34px;
    padding:28px 32px;
    background:linear-gradient(120deg, var(--cream) 55%, var(--card-lavender));
  }
  .rec-copy{ flex:1 }
  .rec-copy h3{ font-size:21px; margin:5px 0 7px }
  .rec-copy p{ font-size:13.5px; max-width:46ch; color:var(--text-2) }
  .perm{
    display:inline-flex; align-items:center; gap:6px;
    margin-top:12px; padding:4px 12px; border-radius:999px;
    background:var(--card-blue); color:var(--peri-ink);
    font-family:var(--mono); font-size:10.5px; letter-spacing:.04em;
  }
  .perm.ok{ background:var(--card-mint); color:var(--green-deep) }

  .recbtn{
    display:flex; flex-direction:column; align-items:center; gap:10px;
    padding:24px 30px; border-radius:22px; flex-shrink:0;
    background:var(--ink); color:#fff;
    box-shadow:0 8px 20px rgba(19,23,34,.25);
    transition:transform .2s var(--spring), box-shadow .2s var(--ease-out);
    /* glyphs default to ink — on this dark button face they go cream */
    --glyph:#fffdf7;
  }
  .recbtn:hover{ transform:translateY(-3px); box-shadow:0 14px 28px rgba(19,23,34,.3) }
  .recbtn.armed{ background:var(--hotpink); box-shadow:0 8px 22px rgba(252,86,129,.4) }
  .recbtn span:last-child{ font-size:13px; font-weight:700 }
  .disc{
    display:grid; place-items:center;
    width:52px; height:52px; border-radius:99px;
    border:2.5px solid rgba(255,255,255,.45);
  }

  .note-hand{ position:absolute; font-size:17px; color:var(--purple); transform:rotate(-2deg); margin-top:-46px; margin-left:340px }
  .record{ position:relative }

  .lib-head{ display:flex; align-items:center; justify-content:space-between; gap:18px; margin:32px 0 16px; flex-wrap:wrap }
  .lib-head h3{ font-size:17px }
  .count{ font-family:var(--mono); font-size:11px; color:var(--text-3); vertical-align:2px; margin-left:4px }

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

  .empty{ padding:60px 20px; text-align:center; border:2px dashed var(--line-strong); border-radius:24px }
  .big{ font-size:27px; color:var(--ink) }
  .empty p{ margin-top:8px; font-size:13px; color:var(--text-3) }

  .list{ display:flex; flex-direction:column; gap:10px }
  .row{ display:flex; align-items:center; gap:14px; padding:14px 18px }
  .ico{
    display:inline-grid; place-items:center; flex-shrink:0;
    width:38px; height:38px; border-radius:12px;
    background:var(--pink); color:var(--hotpink);
  }
  .main{ flex:1; min-width:0; text-align:left; display:flex; flex-direction:column; gap:2px }
  .main strong{ font-size:14px; color:var(--ink); white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
  .main:hover strong{ color:var(--hotpink) }
  .chip.ok{ background:var(--card-mint); color:var(--green-deep) }
  .chip.st{ gap:6px }
  .chip.wait{ background:var(--card-cream); color:var(--gold-ink) }
  .chip.busy{ background:var(--pink); color:var(--red-ink) }
  .chip.st :global(svg){ animation:wspin 1s linear infinite; flex-shrink:0 }
  @keyframes wspin{ to{ transform:rotate(360deg) } }
  .icon-btn{ width:26px; height:26px; border-radius:8px }
</style>
