<script>
  import { ui, local, send } from './bridge.svelte.js'
  import Robot from './Robot.svelte'
  import DevTag from './DevTag.svelte'
  import Toast from './Toast.svelte'
  import HomePane from './panes/HomePane.svelte'
  import NotesPane from './panes/NotesPane.svelte'
  import LibraryPane from './LibraryPane.svelte'
  import HistoryPane from './panes/HistoryPane.svelte'
  import SettingsPane from './panes/SettingsPane.svelte'
  import Glyph from './Glyph.svelte'

  const nav = [
    { id:'home',       label:'Home',       glyph: 'home' },
    { id:'notes',      label:'Notes',      glyph: 'note' },
    { id:'library',    label:'Library',    glyph: 'transcript' },
    { id:'settings',   label:'Settings',   glyph: 'gear' },
  ]

  // support legacy pane ids pushed from native (menu bar items etc.)
  window.__typie.setPane = (p) => {
    if (p?.startsWith('transcript:')) {
      local.pane = 'library'
      local.libraryTab = 'transcripts'
      local.selectedTranscriptId = p.split(':')[1]
      return
    }
    const map = {
      dictation: 'notes', app: 'notes',
      past_dictations: 'history', history: 'history',
      transcripts: 'library', recordings: 'library',
      stats: 'home',
    }
    const nid = map[p] ?? p
    if (nid === 'library') local.libraryTab = p === 'recordings' ? 'recordings' : 'transcripts'
    if (['home','notes','library','history','settings'].includes(nid)) local.pane = nid
  }

  if (!nav.some(n => n.id === local.pane)) local.pane = 'home'

  const phaseLabel = $derived.by(() => {
    switch (ui.dictation.phase) {
      case 'listening':    return { text:'listening…', cls:'live' }
      case 'transcribing': return { text:'transcribing…', cls:'think' }
      default:             return null
    }
  })
</script>

<div class="shell">
  <!-- ── sidebar ── -->
  <aside class="sidebar">
    <div class="brand">
      <Robot size={26} mood={ui.dictation.phase === 'listening' ? 'listening' : 'idle'} />
      <span class="word">typie<i>.</i></span>
      <DevTag />
    </div>

    <nav>
      {#each nav as item}
        <button class="nav-item" class:active={local.pane === item.id} onclick={() => { local.pane = item.id; if (item.id === 'transcripts') local.selectedTranscriptId = null }}>
          <span class="nav-ico">
            {#if item.glyph}
              <Glyph name={item.glyph} size={17} />
            {:else}
              <item.icon size={17} strokeWidth={2.1} />
            {/if}
          </span>
          <span>{item.label}</span>
        </button>
      {/each}
    </nav>

    <!-- dictation status — lives in the sidebar now that the topbar is gone -->
    {#if phaseLabel}
      <div class="livepill {phaseLabel.cls}">
        <i></i>{phaseLabel.text}
      </div>
    {/if}

    <div class="spacer"></div>

    <div class="local-card">
      <div class="row">
        <Robot size={16} mood="idle" />
        <strong>everything stays here</strong>
      </div>
      <p>all transcription runs on this Mac. no cloud, ever.</p>
    </div>
  </aside>

  <!-- ── main column ── -->
  <div class="main">
    <main class="content">
      {#if local.pane === 'home'}
        <HomePane />
      {:else if local.pane === 'notes'}
        <NotesPane />
      {:else if local.pane === 'library'}
        <LibraryPane />
      {:else if local.pane === 'history'}
        <HistoryPane />
      {:else if local.pane === 'settings'}
        <SettingsPane />
      {/if}
    </main>
  </div>

  <!-- undo toasts for deletions, any pane -->
  <Toast />
</div>

<style>
  /* no opaque background here — lets the warm body glows show through */
  .shell{ display:flex; height:100vh; color:var(--text-2) }

  /* ── sidebar ── */
  .sidebar{
    position:fixed; left:0; top:0; bottom:0; width:var(--sidebar-w);
    display:flex; flex-direction:column;
    padding:20px 14px 16px;
    background:var(--paper);
    border-right:1px solid var(--line);
    z-index:30;
  }
  .brand{ display:flex; align-items:center; gap:8px; padding:2px 10px 20px; color:var(--hotpink) }
  .brand .word{
    font-family:var(--display); font-weight:900; font-size:21px;
    letter-spacing:-.05em; color:var(--ink);
  }
  .brand .word i{ font-style:normal; color:var(--hotpink) }

  nav{ display:flex; flex-direction:column; gap:3px }
  .nav-item{
    display:flex; align-items:center; gap:11px;
    padding:9px 12px; border-radius:13px;
    font-size:13.5px; font-weight:600; color:var(--text-2);
    transition:background .18s var(--ease-out), color .18s var(--ease-out), box-shadow .18s var(--ease-out);
  }
  .nav-item:hover{ background:rgba(19,23,34,.05); color:var(--ink) }
  .nav-item.active{
    background:var(--pink); color:var(--ink);
    box-shadow:0 2px 8px rgba(252,86,129,.16);
  }
  .nav-ico{ display:inline-grid; place-items:center; color:inherit; opacity:.85 }

  .spacer{ flex:1 }

  .local-card{
    padding:13px 14px;
    background:var(--card-mint);
    border-radius:16px;
    display:flex; flex-direction:column; gap:3px;
  }
  .local-card .row{ display:flex; align-items:center; gap:7px }
  .local-card strong{ font-size:12px; font-weight:800; color:var(--green-deep) }
  .dot{ width:7px; height:7px; border-radius:99px; background:var(--green-deep); animation:breathe 2.4s var(--ease-out) infinite }
  @keyframes breathe{ 50%{ opacity:.35 } }
  .local-card p{ font-size:10.5px; line-height:1.45; color:rgba(2,69,60,.62) }

  /* ── main ── */
  .main{ margin-left:var(--sidebar-w); flex:1; min-width:0; display:flex; flex-direction:column }

  /* dictation status pill — sidebar, under the nav */
  .livepill{
    display:inline-flex; align-items:center; gap:7px;
    margin:10px 4px 0; padding:5px 12px;
    border-radius:999px; align-self:flex-start;
    font-family:var(--mono); font-size:10px; letter-spacing:.08em; text-transform:uppercase;
  }
  .livepill i{ width:7px; height:7px; border-radius:99px; background:currentColor; animation:breathe 1.2s ease-in-out infinite }
  .livepill.live{ background:var(--pink); color:var(--red-ink) }
  .livepill.think{ background:var(--card-blue); color:var(--peri-ink) }

  .content{ flex:1; overflow-y:auto }

  /* every pane lands with the site's fade-up-deblur on switch */
  .content > :global(*){ animation:enter-up .55s var(--spring-snappy,ease) both }

  @media(max-width:840px){
    .sidebar{ display:none }
    .main{ margin-left:0 }
  }
</style>
