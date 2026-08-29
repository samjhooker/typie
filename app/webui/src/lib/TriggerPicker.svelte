<script>
  import { ui, send } from './bridge.svelte.js';

  /** hold / tap / both selector with the friendly hint underneath */
  const modes = [
    { id: 'both', label: 'Hold or tap' },
    { id: 'hold', label: 'Hold to talk' },
    { id: 'toggle', label: 'Tap to toggle' },
  ];

  const hints = {
    both: 'hold it and speak, or tap to start and tap again to stop',
    hold: 'hold the key while you speak, let go to transcribe',
    toggle: 'press once to start, press again to stop',
  };
</script>

<div class="wrap">
  <div class="seg">
    {#each modes as m}
      <button
        class:selected={ui.settings.triggerMode === m.id}
        onclick={() => send({ type: 'setSetting', key: 'triggerMode', value: m.id })}
      >
        {m.label}
      </button>
    {/each}
  </div>
  <p>{hints[ui.settings.triggerMode]}</p>
</div>

<style>
  .wrap {
    display: flex;
    flex-direction: column;
    gap: 7px;
  }

  .seg {
    display: inline-flex;
    gap: 4px;
    padding: 3px;
    border-radius: 12px;
    border: 1px solid rgba(3, 89, 77, 0.18);
    align-self: flex-start;
  }

  button {
    padding: 7px 13px;
    border-radius: 9px;
    font-family: var(--display);
    font-size: 13px;
    font-weight: 600;
    color: var(--text-2);
    transition:
      background 0.2s var(--ease-out),
      color 0.2s var(--ease-out);
  }

  button.selected {
    background: var(--pink);
    color: var(--ink);
  }

  p {
    font-size: 12.5px;
    color: rgba(3, 89, 77, 0.6);
  }
</style>
