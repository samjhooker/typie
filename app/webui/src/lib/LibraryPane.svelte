<script>
  import { ui, local } from './bridge.svelte.js'
  import TranscribePane from './panes/TranscribePane.svelte'
  import TranscriptDetail from './panes/TranscriptDetail.svelte'
  import RecordingsPane from './panes/RecordingsPane.svelte'
  import Glyph from './Glyph.svelte'

  // transcripts + recordings live here now — one Library, two tabs
  const transcripts = $derived(ui.transcripts.filter(t => !t.isMeeting))
  const meetings = $derived(ui.transcripts.filter(t => t.isMeeting))

  function setTab(t) {
    local.libraryTab = t
    local.selectedTranscriptId = null
  }
</script>

<div class="lib">
  <div class="tabs" role="tablist">
    <button role="tab" aria-selected={local.libraryTab === 'transcripts'} class:selected={local.libraryTab === 'transcripts'} onclick={() => setTab('transcripts')}>
      <Glyph name="transcript" size={14} /> transcripts
      <span class="badge">{transcripts.length}</span>
    </button>
    <button role="tab" aria-selected={local.libraryTab === 'recordings'} class:selected={local.libraryTab === 'recordings'} onclick={() => setTab('recordings')}>
      <Glyph name="record" size={14} /> recordings
      <span class="badge">{meetings.length}</span>
    </button>
  </div>

  {#if local.selectedTranscriptId}
    <TranscriptDetail id={local.selectedTranscriptId} onBack={() => { local.selectedTranscriptId = null }} />
  {:else if local.libraryTab === 'recordings'}
    <RecordingsPane embedded />
  {:else}
    <TranscribePane embedded />
  {/if}
</div>

<style>
  .lib{ display:flex; flex-direction:column; min-height:0; flex:1 }

  .tabs{
    display:flex; gap:6px;
    padding:16px 32px 0;
    flex-shrink:0;
  }
  .tabs button{
    display:inline-flex; align-items:center; gap:8px;
    padding:9px 18px;
    border-radius:999px;
    font-family:var(--display); font-size:13.5px; font-weight:700; letter-spacing:-.01em;
    color:var(--text-2);
    border:1px solid var(--line);
    background:var(--cream);
    transition:
      background .2s var(--ease-out),
      color .2s var(--ease-out),
      border-color .2s var(--ease-out),
      box-shadow .25s var(--ease-out);
  }
  .tabs button:hover:not(.selected){ background:#fffdf7; color:var(--ink) }
  .tabs button.selected{
    background:var(--ink); color:#fffdf7;
    border-color:var(--ink);
    box-shadow:0 4px 12px rgba(19,23,34,.22);
  }
  .badge{
    font-family:var(--mono); font-size:10px; letter-spacing:.04em;
    padding:1px 7px; border-radius:99px;
    background:rgba(19,23,34,.08); color:var(--text-2);
  }
  .tabs button.selected .badge{ background:rgba(255,253,247,.22); color:#fffdf7 }
</style>
