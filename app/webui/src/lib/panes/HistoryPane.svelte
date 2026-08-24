<script>
  import Robot from '../Robot.svelte'
  import { ui, local, send, markCopied } from '../bridge.svelte.js'

  /** recent transcriptions, newest first */
  function fmtDate(iso) {
    const d = new Date(iso)
    return d.toLocaleDateString(undefined, { dateStyle: 'medium' }) +
      ' ' + d.toLocaleTimeString(undefined, { timeStyle: 'short' })
  }

  function copy(entry) {
    send({ type: 'copy', text: entry.text })
    markCopied(entry.id)
  }
</script>

{#if ui.history.length === 0}
  <div class="empty">
    <Robot size={40} mood="idle" />
    <p class="hand">nothing here yet.</p>
    <small>
      {ui.settings.historyEnabled
        ? `say something first — hold ${ui.settings.hotkeyShort}`
        : 'turn on "save previous transcriptions" in settings'}
    </small>
  </div>
{:else}
  <div class="pane">
    {#each ui.history as entry (entry.id)}
      <article>
        <div class="body">
          <p>{entry.text}</p>
          <span>{fmtDate(entry.date)} · {Math.round(entry.latencyMs)}ms</span>
        </div>
        <button class:copied={local.copiedId === entry.id} onclick={() => copy(entry)}>
          {local.copiedId === entry.id ? '✓ copied' : '⧉ copy'}
        </button>
      </article>
    {/each}
  </div>
{/if}

<style>
  .pane {
    display: flex;
    flex-direction: column;
    padding: 6px 20px;
    overflow-y: auto;
  }

  .empty {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    color: rgba(44, 51, 66, 0.55);
  }

  .empty .hand {
    font-size: 21px;
  }

  article {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 11px 0;
    border-bottom: 1px solid rgba(3, 89, 77, 0.08);
  }

  .body {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .body p {
    font-size: 13px;
    color: #2c3342;
    user-select: text;
    overflow-wrap: anywhere;
  }

  .body span {
    font-family: var(--mono);
    font-size: 9.5px;
    letter-spacing: 0.03em;
    color: rgba(44, 51, 66, 0.45);
  }

  button {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.04em;
    color: var(--hotpink);
    padding: 4px 8px;
    border-radius: 7px;
    white-space: nowrap;
    flex-shrink: 0;
    transition:
      color 0.15s var(--ease-out),
      background 0.15s var(--ease-out);
  }

  button:hover {
    background: rgba(252, 86, 129, 0.09);
  }

  button.copied {
    color: var(--green-deep);
  }
</style>
