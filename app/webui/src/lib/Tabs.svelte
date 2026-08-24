<script>
  import { local, ui } from './bridge.svelte.js'

  /** chunky pill switcher between the panes */
  const panes = [
    {
      id: 'settings',
      label: 'settings',
      icon: '<path d="M9 5.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Zm-2.6-.8L4.9 3l-1.4.8.7 1.9c-.4.3-.7.6-1 1L1.3 6 1 7.7l1.8.7a5 5 0 0 0 0 1.4L1 10.5l.3 1.7 1.9-.7c.3.4.6.7 1 1l-.7 1.9 1.4.8 1.5-1.7a5 5 0 0 0 1.4.2l.5 1.9h1.8l.5-2a5 5 0 0 0 1.3-.6l1.7 1.3 1.4-.9-.9-1.8c.3-.4.5-.8.6-1.3l2-.3v-1.8l-2-.4a5 5 0 0 0-.5-1.2l1.2-1.7-1.3-1.2-1.7 1.2a5 5 0 0 0-1.3-.6L11.8 1H10l-.5 2a5 5 0 0 0-1.4.2z" transform="translate(4 3)"/>',
    },
    {
      id: 'stats',
      label: 'stats',
      icon: '<path d="M4 16V9h3v7H4Zm5 0V4h3v12H9Zm5 0v-5h3v5h-3Z"/>',
    },
    {
      id: 'transcribe',
      label: 'transcribe',
      icon: '<path d="M3 9h2v6H3V9Zm4-4h2v14H7V5Zm4-2h2v18h-2V3Zm4 4h2v10h-2V7Zm4 3h2v4h-2v-4Z"/>',
    },
    {
      id: 'history',
      label: 'history',
      icon: '<path d="M10 4a6 6 0 1 0 5.7 7.9l-1.9-.6A4 4 0 1 1 14 8h-2.5l3 3.5L17.5 8H15a6 6 0 0 0-5-4Zm-1 3v4l3 1.5.7-1.2-2.2-1.1V7H9Z"/>',
    },
  ]
</script>

<nav>
  {#each panes.filter((p) => p.id !== 'transcribe' || ui.variant === 'dev') as p}
    <button
      class:selected={local.pane === p.id}
      onclick={() => (local.pane = p.id)}
      data-pane={p.id}
    >
      <svg viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">{@html p.icon}</svg>
      {p.label}
    </button>
  {/each}
</nav>

<style>
  nav {
    display: flex;
    gap: 4px;
    padding: 4px;
    border-radius: 999px;
    background: var(--cream);
    border: 1px solid rgba(3, 89, 77, 0.18);
  }

  button {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 13px;
    border-radius: 999px;
    font-family: var(--display);
    font-size: 12.5px;
    font-weight: 500;
    color: rgba(44, 51, 66, 0.7);
    transition:
      background 0.2s var(--ease-out),
      color 0.2s var(--ease-out),
      box-shadow 0.2s var(--ease-out);
  }

  button:hover {
    color: var(--ink);
  }

  button.selected {
    background: var(--hotpink);
    color: var(--cream);
    box-shadow: 0 2px 6px rgba(252, 86, 129, 0.35);
  }

  svg {
    width: 13px;
    height: 13px;
  }
</style>
