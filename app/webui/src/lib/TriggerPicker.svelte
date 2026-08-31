<script>
  import { ToggleGroup } from 'bits-ui';
  import { ui, send } from './bridge.svelte.js';

  /** hold / tap / both selector with the friendly hint underneath.
      bits-ui ToggleGroup (single) provides the behavior + a11y. */
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

  function setMode(v) {
    if (v) send({ type: 'setSetting', key: 'triggerMode', value: v });
  }
</script>

<div class="tp-wrap">
  <ToggleGroup.Root
    type="single"
    value={ui.settings.triggerMode}
    onValueChange={setMode}
    class="tp-seg"
  >
    {#each modes as m (m.id)}
      <ToggleGroup.Item
        value={m.id}
        class="tp-segitem {ui.settings.triggerMode === m.id ? 'selected' : ''}"
        aria-label={m.label}
      >
        {m.label}
      </ToggleGroup.Item>
    {/each}
  </ToggleGroup.Root>
  <p>{hints[ui.settings.triggerMode]}</p>
</div>

<style>
  /* :global + .tp- namespace — bits-ui renders the root + items, and these
     must not collide with SortSeg's global .seg styles */
  :global(.tp-wrap) {
    display: flex;
    flex-direction: column;
    gap: 7px;
  }

  :global(.tp-seg) {
    display: inline-flex;
    gap: 4px;
    padding: 3px;
    border-radius: 12px;
    border: 1px solid var(--line-strong);
    align-self: flex-start;
  }

  :global(.tp-seg .tp-segitem) {
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

  :global(.tp-seg .tp-segitem.selected) {
    background: var(--pink);
    color: var(--ink);
  }

  p {
    font-size: 12.5px;
    color: var(--text-3);
  }
</style>
