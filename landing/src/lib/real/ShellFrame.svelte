<script>
  import Glyph from './Glyph.svelte';
  let { active = 'notes', sidebar = true, children } = $props();

  const nav = [
    { id: 'home', label: 'Home', glyph: 'home' },
    { id: 'notes', label: 'Notes', glyph: 'note' },
    { id: 'library', label: 'Library', glyph: 'transcript' },
    { id: 'stats', label: 'Stats', glyph: 'stats' },
  ];
</script>

<div class="shell-frame">
  {#if sidebar}
  <aside class="sf-sidebar">
    <div class="sf-brand" aria-hidden="true">
      <span class="sf-dot"></span>
      <span class="sf-word">typie.</span>
    </div>
    <nav class="sf-navlist">
      {#each nav as item}
        <div
          class="sf-nav"
          class:active={active === item.id}
          title={item.label}
        >
          <Glyph name={item.glyph} size={14} />
          <span class="sf-label">{item.label}</span>
        </div>
      {/each}
    </nav>
  </aside>
  {/if}
  <div class="sf-main">
    {@render children?.()}
  </div>
</div>

<style>
  .shell-frame {
    display: flex;
    height: 100%;
    min-height: 0;
    overflow: hidden;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: 12px;
    /* in-app elevation, lifted above the bento mat */
    box-shadow:
      0 2px 4px rgba(19, 23, 34, 0.08),
      0 32px 64px -12px rgba(19, 23, 34, 0.35),
      0 12px 24px -8px rgba(19, 23, 34, 0.18);
  }
  .sf-sidebar {
    width: 86px;
    min-width: 86px;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    gap: 10px;
    padding: 12px 8px 10px;
    background: var(--paper);
    border-right: 1px solid var(--line);
    flex-shrink: 0;
  }
  .sf-brand {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 2px 6px 8px;
    border-bottom: 1px solid var(--line);
    margin-bottom: 2px;
  }
  .sf-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--hotpink);
    box-shadow: 0 0 0 3px rgba(252, 86, 129, 0.15);
    flex-shrink: 0;
  }
  .sf-word {
    font-family: var(--display);
    font-size: 12px;
    font-weight: 800;
    letter-spacing: -0.04em;
    color: var(--ink);
  }
  .sf-navlist {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  .sf-nav {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 6px 8px;
    border-radius: 9px;
    font-size: 11px;
    font-weight: 600;
    color: var(--text-2);
    line-height: 1;
  }
  .sf-nav :global(svg) {
    opacity: 0.85;
    flex-shrink: 0;
  }
  .sf-nav.active {
    background: var(--pink);
    color: var(--ink);
  }
  .sf-label {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .sf-main {
    flex: 1;
    min-width: 0;
    min-height: 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background: var(--surface);
    --wbody: var(--surface);
  }

  /* dark: shell sits as real app, paper sidebar darker than card */
  :global([data-theme='dark']) .shell-frame {
    border-color: rgba(255, 255, 255, 0.08);
    box-shadow:
      0 2px 4px rgba(0, 0, 0, 0.35),
      0 32px 64px -12px rgba(0, 0, 0, 0.65),
      0 12px 24px -8px rgba(0, 0, 0, 0.5);
  }
  :global([data-theme='dark']) .sf-sidebar {
    background: #171a23;
    border-right-color: rgba(255, 255, 255, 0.08);
  }
  :global([data-theme='dark']) .sf-main {
    background: #14161f;
    --wbody: #14161f;
  }
  :global([data-theme='dark']) .sf-nav.active {
    background: #3d1c28;
  }

  /* compact on narrow cards */
  @media (max-width: 560px) {
    .sf-sidebar {
      width: 56px;
      min-width: 56px;
      align-items: center;
      padding: 10px 6px;
    }
    .sf-brand {
      justify-content: center;
      padding: 2px 0 8px;
    }
    .sf-word {
      display: none;
    }
    .sf-nav {
      justify-content: center;
      padding: 7px;
    }
    .sf-label {
      display: none;
    }
  }
</style>
