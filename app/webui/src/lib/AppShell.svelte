<script>
  import { ui, local, send } from './bridge.svelte.js';
  import Robot from './Robot.svelte';
  import DevTag from './DevTag.svelte';
  import Toast from './Toast.svelte';
  import HomePane from './panes/HomePane.svelte';
  import NotesPane from './panes/NotesPane.svelte';
  import LibraryPane from './LibraryPane.svelte';
  import HistoryPane from './panes/HistoryPane.svelte';
  import SettingsPane from './panes/SettingsPane.svelte';
  import StatsPane from './panes/StatsPane.svelte';
  import { BarChart3 } from 'lucide-svelte';
  import Glyph from './Glyph.svelte';

  // core actions up top, admin down the bottom — two separate groups
  const navMain = [
    { id: 'home', label: 'Home', glyph: 'home' },
    { id: 'notes', label: 'Notes', glyph: 'note' },
    { id: 'library', label: 'Library', glyph: 'transcript' },
  ];
  const navAdmin = [
    { id: 'settings', label: 'Settings', glyph: 'gear' },
    { id: 'stats', label: 'Stats', icon: BarChart3 },
  ];
  const allPanes = [...navMain, ...navAdmin];

  if (!allPanes.some((n) => n.id === local.pane)) local.pane = 'home';

  const phaseLabel = $derived.by(() => {
    switch (ui.dictation.phase) {
      case 'listening':
        return { text: 'listening…', cls: 'live' };
      case 'transcribing':
        return { text: 'transcribing…', cls: 'think' };
      default:
        return null;
    }
  });

  // Slack-style: reading a conversation → the rail collapses to icons
  const compact = $derived(
    local.pane === 'library' && !!local.selectedTranscriptId
  );
</script>

<div
  class="shell"
  class:compact
>
  <!-- ── sidebar ── -->
  <aside class="sidebar">
    <div class="brand">
      <Robot
        size={26}
        mood={ui.dictation.phase === 'listening' ? 'listening' : 'idle'}
      />
      <span class="word">typie<i>.</i></span>
      <DevTag />
    </div>

  <!-- core actions -->
    <nav>
      {#each navMain as item}
        <button
          class="nav-item"
          class:active={local.pane === item.id}
          title={item.label}
          onclick={() => {
            local.pane = item.id;
            if (item.id === 'transcripts') local.selectedTranscriptId = null;
          }}
        >
          <span class="nav-ico">
            {#if item.glyph}
              <Glyph
                name={item.glyph}
                size={17}
              />
            {:else}
              <item.icon
                size={17}
                strokeWidth={2.1}
              />
            {/if}
          </span>
          <span class="nav-label">{item.label}</span>
        </button>
      {/each}
    </nav>

    <!-- dictation status, lives in the sidebar now that the topbar is gone -->
    {#if phaseLabel}
      <div
        class="livepill {phaseLabel.cls}"
        title={phaseLabel.text}
      >
        <i></i>{#if !compact}{phaseLabel.text}{/if}
      </div>
    {/if}

    <div class="spacer"></div>

    <!-- admin: pinned to the bottom, visually separate from the core actions -->
    <nav>
      {#each navAdmin as item}
        <button
          class="nav-item"
          class:active={local.pane === item.id}
          title={item.label}
          onclick={() => {
            local.pane = item.id;
            if (item.id === 'transcripts') local.selectedTranscriptId = null;
          }}
        >
          <span class="nav-ico">
            {#if item.glyph}
              <Glyph
                name={item.glyph}
                size={17}
              />
            {:else}
              <item.icon
                size={17}
                strokeWidth={2.1}
              />
            {/if}
          </span>
          <span class="nav-label">{item.label}</span>
        </button>
      {/each}
    </nav>

    <div class="local-card">
      <div class="row">
        <Robot
          size={16}
          mood="idle"
        />
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
      {:else if local.pane === 'stats'}
        <StatsPane />
      {/if}
    </main>
  </div>

  <!-- undo toasts for deletions, any pane -->
  <Toast />
</div>

<style>
  /* no opaque background here, lets the warm body glows show through */
  .shell {
    display: flex;
    height: 100vh;
    color: var(--text-2);
    --rail-w: 236px;
  }
  .shell.compact {
    --rail-w: 64px;
  }

  /* ── sidebar ── */
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    width: var(--rail-w);
    display: flex;
    flex-direction: column;
    padding: 20px 14px 16px;
    background: var(--paper);
    border-right: 1px solid var(--line);
    z-index: 30;
    transition:
      width 0.42s cubic-bezier(0.32, 0.9, 0.28, 1),
      padding 0.42s var(--ease-out);
    overflow: hidden;
  }
  .brand {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 2px 10px 20px;
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

  nav {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  .nav-item {
    display: flex;
    align-items: center;
    gap: 11px;
    padding: 9px 12px;
    border-radius: 13px;
    font-size: 13.5px;
    font-weight: 600;
    color: var(--text-2);
    white-space: nowrap;
    transition:
      background 0.18s var(--ease-out),
      color 0.18s var(--ease-out),
      box-shadow 0.18s var(--ease-out),
      padding 0.42s var(--ease-out);
  }
  .nav-item:hover {
    background: var(--wash);
    color: var(--ink);
  }
  .nav-item.active {
    background: var(--pink);
    color: var(--ink);
    box-shadow: 0 2px 8px rgba(252, 86, 129, 0.16);
  }
  .nav-ico {
    display: inline-grid;
    place-items: center;
    color: inherit;
    opacity: 0.85;
  }

  /* compact rail: icon-only, labels snap away while the width glides */
  .shell.compact .sidebar {
    padding-left: 10px;
    padding-right: 10px;
  }
  .shell.compact .brand {
    justify-content: center;
    padding-left: 0;
    padding-right: 0;
  }
  .shell.compact .brand .word,
  .shell.compact .brand :global(.devtag) {
    display: none;
  }
  .shell.compact .nav-item {
    justify-content: center;
    padding: 9px 0;
  }
  .shell.compact .nav-label {
    display: none;
  }
  .shell.compact .livepill {
    align-self: center;
    margin-left: 0;
    margin-right: 0;
    padding: 5px 7px;
  }
  .shell.compact .local-card {
    display: none;
  }

  .spacer {
    flex: 1;
  }

  .local-card {
    /* breathing room above the privacy card so the admin nav's highlight
       ring never touches it */
    margin-top: 12px;
    padding: 13px 14px;
    background: var(--card-mint);
    border-radius: 16px;
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  .local-card .row {
    display: flex;
    align-items: center;
    gap: 7px;
  }
  .local-card strong {
    font-size: 12px;
    font-weight: 800;
    color: var(--green-deep);
  }
  .dot {
    width: 7px;
    height: 7px;
    border-radius: 99px;
    background: var(--green-deep);
    animation: breathe 2.4s var(--ease-out) infinite;
  }
  @keyframes breathe {
    50% {
      opacity: 0.35;
    }
  }
  /* green-deep flips to light mint in dark mode, so a color-mix over it
     keeps the body copy legible in both themes (was hardcoded dark teal) */
  .local-card p {
    font-size: 10.5px;
    line-height: 1.45;
    color: color-mix(in srgb, var(--green-deep) 68%, transparent);
  }

  /* ── main ── */
  .main {
    margin-left: var(--rail-w);
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    background: var(--surface);
    /* follows the rail glide */
    transition: margin-left 0.42s cubic-bezier(0.32, 0.9, 0.28, 1),
      background-color 0.25s ease;
  }

  /* dictation status pill, sidebar, under the nav */
  .livepill {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    margin: 10px 4px 0;
    padding: 5px 12px;
    border-radius: 999px;
    align-self: flex-start;
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }
  .livepill i {
    width: 7px;
    height: 7px;
    border-radius: 99px;
    background: currentColor;
    animation: breathe 1.2s ease-in-out infinite;
  }
  .livepill.live {
    background: var(--pink);
    color: var(--red-ink);
  }
  .livepill.think {
    background: var(--card-blue);
    color: var(--peri-ink);
  }

  .content {
    flex: 1;
    overflow-y: auto;
    background: var(--surface);
    display: flex;
    flex-direction: column;
  }

  /* pane switches slide in from the right.
     NB: NO filter here, WebKit keeps the animated filter value alive after
     the animation ends, and any non-none filter on an ancestor turns the pane
     into the containing block for position:fixed children (the AI side menu),
     making it scroll away with the page. Slide + fade only. */
  @keyframes pane-slide {
    from {
      opacity: 0;
      transform: translateX(26px) translateY(8px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
  .content > :global(*) {
    animation: pane-slide 0.48s cubic-bezier(0.22, 0.9, 0.28, 1) both;
  }

  @media (max-width: 840px) {
    .sidebar {
      display: none;
    }
    .main {
      margin-left: 0;
    }
  }
</style>
