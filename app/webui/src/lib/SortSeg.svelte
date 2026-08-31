<script>
  /** segmented sort picker, same visual language as TriggerPicker's segment.
      bits-ui ToggleGroup (single) provides the behavior + a11y. */
  import { ToggleGroup } from 'bits-ui';

  let { options = [], value = $bindable() } = $props();
</script>

<ToggleGroup.Root
  type="single"
  bind:value
  class="seg"
  aria-label="sort order"
>
  {#each options as o (o.id)}
    <ToggleGroup.Item
      value={o.id}
      class="segitem {value === o.id ? 'selected' : ''}"
      aria-label={o.label}
    >
      {o.label}
    </ToggleGroup.Item>
  {/each}
</ToggleGroup.Root>

<style>
  /* :global — bits-ui renders the root + items */
  :global(.seg) {
    display: inline-flex;
    gap: 4px;
    padding: 3px;
    border-radius: 12px;
    border: 1px solid var(--line);
    background: var(--cream);
  }
  :global(.seg .segitem) {
    padding: 6px 12px;
    border-radius: 9px;
    font-family: var(--display);
    font-size: 12px;
    font-weight: 600;
    color: var(--text-2);
    white-space: nowrap;
    transition:
      background 0.2s var(--ease-out),
      color 0.2s var(--ease-out),
      box-shadow 0.2s var(--ease-out);
  }
  :global(.seg .segitem:hover:not(.selected)) {
    background: var(--wash);
    color: var(--ink);
  }
  :global(.seg .segitem.selected) {
    background: var(--pink);
    color: var(--ink);
    box-shadow: 0 1px 5px rgba(252, 86, 129, 0.22);
  }
</style>
