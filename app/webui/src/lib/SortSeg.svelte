<script>
  /** segmented sort picker — same visual language as TriggerPicker's segment */
  let { options = [], value = $bindable() } = $props();
</script>

<div class="seg" role="group" aria-label="sort order">
  {#each options as o (o.id)}
    <button
      class:selected={value === o.id}
      aria-pressed={value === o.id}
      onclick={() => (value = o.id)}
    >
      {o.label}
    </button>
  {/each}
</div>

<style>
  .seg {
    display: inline-flex;
    gap: 4px;
    padding: 3px;
    border-radius: 12px;
    border: 1px solid var(--line);
    background: var(--cream);
  }
  button {
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
  button:hover:not(.selected) {
    background: rgba(19, 23, 34, 0.05);
    color: var(--ink);
  }
  button.selected {
    background: var(--pink);
    color: var(--ink);
    box-shadow: 0 1px 5px rgba(252, 86, 129, 0.22);
  }
</style>
