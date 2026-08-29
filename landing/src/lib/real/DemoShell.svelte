<script>
  import Robot from './Robot.svelte'
  import Glyph from './Glyph.svelte'
  import DemoHomePane from './DemoHomePane.svelte'
  import DemoNotesPane from './DemoNotesPane.svelte'
  import DemoLibraryPane from './DemoLibraryPane.svelte'
  import DemoTranscriptDetail from './DemoTranscriptDetail.svelte'
  import DemoStatsPane from './DemoStatsPane.svelte'

  let { startPane = 'home', startTranscript = null, notesExtra = null, locked = false } = $props()
  let pane = $state('home')
  let selectedTranscript = $state(null)

  $effect(() => {
    pane = startPane
    selectedTranscript = startTranscript
  })

  const nav = [
    { id:'home',     label:'Home',     glyph:'home' },
    { id:'notes',    label:'Notes',    glyph:'note' },
    { id:'library',  label:'Library',  glyph:'transcript' },
    { id:'stats',    label:'Stats',    glyph:'stats' },
  ]

  function go(id) { if (locked) return; pane = id; selectedTranscript = null }
  function openTranscript() { if (locked) return; pane = 'library'; selectedTranscript = 'beta-sync' }
  function backFromTranscript() { selectedTranscript = null }
</script>

<div class="shell">
  <aside class="sidebar">
    <div class="brand">
      <Robot size={26} mood="idle" />
      <span class="word">typie<i>.</i></span>
    </div>

    <nav class:locked={locked}>
      {#each nav as item}
        <button class="nav-item" class:active={pane === item.id} class:disabled={locked && item.id !== startPane} title={item.label} onclick={() => go(item.id)} disabled={locked && item.id !== startPane}>
          <span class="nav-ico"><Glyph name={item.glyph} size={17} /></span>
          <span class="nav-label">{item.label}</span>
        </button>
      {/each}
    </nav>

    <div class="spacer"></div>

    <div class="local-card">
      <div class="row">
        <Robot size={16} mood="idle" />
        <strong>everything stays here</strong>
      </div>
      <p>all transcription runs on this Mac. no cloud, ever.</p>
    </div>
  </aside>

  <div class="main">
    <main class="content">
      {#if pane === 'home'}
        <DemoHomePane />
      {:else if pane === 'notes'}
        <DemoNotesPane extra={notesExtra} />
      {:else if pane === 'library'}
        {#if selectedTranscript}
          <DemoTranscriptDetail onBack={backFromTranscript} />
        {:else}
          <DemoLibraryPane onSelect={openTranscript} />
        {/if}
      {:else if pane === 'stats'}
        <DemoStatsPane />
      {/if}
    </main>
  </div>
</div>

<style>
  .shell{
    display:flex; height:100%; --rail-w:236px; overflow:hidden;
    font-family:'Inter',-apple-system,system-ui,sans-serif;

    /* app design system — scoped to demo shell */
    --page:#fffdf7; --cream:#fffdf7; --paper:#fdf8ee;
    --ink:#131722;
    --text-1:var(--ink);
    --text-2:rgba(19,23,34,.76);
    --text-3:rgba(19,23,34,.54);
    --hotpink:#fc5681;
    --pink:#ffd3e0;
    --pink-band:#fbdae4;
    --green:#03594d;
    --green-deep:#02453c;
    --butter:#ffda8a;
    --sun:#fdc068;
    --gold-ink:#e59e12;
    --sky:#bcd6ff;
    --lavender:#ddd8ff;
    --periwinkle:#6f8ffb;
    --purple:#c88cfd;
    --orange:#ff9124;
    --mint:#82eda6;
    --mint-live:#6ee89a;
    --lime:#d8e268;
    --card-cream:#fdf3dc;
    --card-lavender:#efecfb;
    --card-blue:#dde9fa;
    --card-mint:#dff0e4;
    --sp1:#fc5681; --sp2:#6f8ffb; --sp3:#c88cfd; --sp4:#ff9124; --sp5:#03594d; --sp6:#e59e12;
    --peri-ink:#3a5a9a;
    --violet-ink:#6a52c9;
    --red-ink:#c22e56;
    --glow-pink:rgba(252,86,129,.22);
    --glow-mint:rgba(130,237,166,.28);
    --line:rgba(3,89,77,.12);
    --line-strong:rgba(3,89,77,.22);
    --radius-card:20px;
    --mono:'IBM Plex Mono',ui-monospace,monospace;
    --display:'Bricolage Grotesque','Inter',-apple-system,system-ui,sans-serif;
    --sans:'Inter',-apple-system,system-ui,sans-serif;
    --hand:'Caveat',cursive;
    --ease-out:cubic-bezier(.22,1,.36,1);
    --spring:cubic-bezier(.22,1.2,.36,1);
    --ease-inout:cubic-bezier(.65,0,.35,1);
    --snap:cubic-bezier(.22,1,.36,1);
    color:var(--text-2);
  }

  .sidebar{
    position:relative; width:var(--rail-w); min-width:var(--rail-w);
    display:flex; flex-direction:column;
    padding:20px 14px 16px;
    background:var(--paper);
    border-right:1px solid var(--line);
    z-index:30;
    overflow:hidden;
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
    white-space:nowrap; cursor:pointer;
    transition:background .18s var(--ease-out), color .18s var(--ease-out), box-shadow .18s var(--ease-out);
  }
  .nav-item:hover{ background:rgba(19,23,34,.05); color:var(--ink) }
  .nav-item.active{
    background:var(--pink); color:var(--ink);
    box-shadow:0 2px 8px rgba(252,86,129,.16);
  }
  .nav-item.disabled{ opacity:.42; pointer-events:none; cursor:default; }
  nav.locked .nav-item:not(.active){ opacity:.4; pointer-events:none; cursor:default; }
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
  .local-card p{ font-size:10.5px; line-height:1.45; color:rgba(2,69,60,.62) }

  .main{
    flex:1; min-width:0; display:flex; flex-direction:column; background:#fff;
    --page:#fff; --cream:#fff; --paper:#fff; --card-cream:#fff;
  }

  .content{ flex:1; overflow-y:auto; background:#fff; display:flex; flex-direction:column }

  @keyframes pane-slide{
    from{ opacity:0; transform:translateX(26px) translateY(8px) }
    to{ opacity:1; transform:none }
  }
  .content > :global(*){ animation:pane-slide .48s cubic-bezier(.22,.9,.28,1) both }

  /* ── app global styles (scoped to demo) ── */
  .shell :global(a){ color:inherit; text-decoration:none }
  .shell :global(button){ font:inherit; cursor:pointer; border:none; background:none; color:inherit }
  .shell :global(input),.shell :global(textarea){ font:inherit; color:inherit }
  .shell :global(::selection){ background:var(--hotpink); color:#fffdf7 }
  .shell :global(:focus-visible){ outline:2.5px solid var(--hotpink); outline-offset:3px; border-radius:6px }

  .shell :global(.card){
    background:var(--cream);
    border:1px solid var(--line);
    border-radius:var(--radius-card);
    box-shadow:0 2px 10px rgba(19,23,34,.04);
  }

  .shell :global(.btn){
    display:inline-flex; align-items:center; justify-content:center; gap:8px;
    padding:11px 22px; border-radius:999px;
    font-size:13.5px; font-weight:600; letter-spacing:-.01em;
    transition:transform .35s var(--snap), background-color .25s var(--ease-out), box-shadow .35s var(--snap), color .25s var(--ease-out), border-color .2s var(--ease-out);
  }
  .shell :global(.btn:hover){ transform:translateY(-2px) }
  .shell :global(.btn:active){ transform:translateY(1px) scale(.98); transition-duration:.12s }
  .shell :global(.btn:disabled){ opacity:.45; cursor:default; transform:none }

  .shell :global(.btn-pink){ background:var(--hotpink); color:#fff; box-shadow:0 4px 14px rgba(252,86,129,.35) }
  .shell :global(.btn-pink:hover){ box-shadow:0 7px 18px rgba(252,86,129,.42) }

  .shell :global(.btn-butter){ background:var(--butter); color:var(--ink); box-shadow:0 4px 12px rgba(19,23,34,.12) }
  .shell :global(.btn-butter:hover){ background:var(--sun) }

  .shell :global(.btn-ghost){ border:2px solid var(--line-strong); color:var(--ink); background:transparent }
  .shell :global(.btn-ghost:hover){ border-color:var(--ink); background:rgba(19,23,34,.05) }

  .shell :global(.btn.small){ padding:7px 15px; font-size:12px }

  .shell :global(.chip){
    display:inline-flex; align-items:center; gap:5px;
    padding:3px 10px; border-radius:999px;
    font-family:var(--mono); font-size:10.5px; letter-spacing:.06em;
  }

  .shell :global(.icon-btn){
    display:inline-grid; place-items:center;
    width:30px; height:30px; border-radius:9px;
    color:var(--text-3);
    transition:background .18s var(--ease-out), color .18s var(--ease-out);
  }
  .shell :global(.icon-btn:hover){ background:rgba(19,23,34,.07); color:var(--ink) }

  .shell :global(.input){
    display:flex; align-items:center; gap:9px;
    padding:10px 16px; border-radius:999px;
    background:var(--paper); border:1px solid var(--line);
    outline:none; width:100%;
    transition:border-color .2s var(--ease-out), box-shadow .2s var(--ease-out);
  }
  .shell :global(.input:focus-within){ border-color:var(--hotpink); box-shadow:0 0 0 3px rgba(252,86,129,.14) }
  .shell :global(.input input){ flex:1; min-width:0; background:none; border:none; outline:none; font-size:13.5px; color:var(--ink) }
  .shell :global(.input input::placeholder){ color:var(--text-3) }

  .shell :global(.mono-kicker){
    font-family:var(--mono); font-size:11px; letter-spacing:.14em;
    text-transform:uppercase; color:var(--text-3);
  }
  .shell :global(.hand){ font-family:var(--hand); font-weight:600; letter-spacing:.01em }
</style>
