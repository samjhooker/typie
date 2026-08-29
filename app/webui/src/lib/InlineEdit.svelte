<script>
  import { Pencil, Check } from 'lucide-svelte';

  /** click-to-rename field — pencil appears on hover, inline input on edit */
  let { value, onSave, size = 'md' } = $props();

  let editing = $state(false);
  let draft = $state('');

  function start(e) {
    e?.stopPropagation();
    draft = value;
    editing = true;
  }
  function save() {
    editing = false;
    const v = draft.trim();
    if (v && v !== value) onSave(v);
  }
</script>

{#if editing}
  <span class="ie editing">
    <input
      bind:value={draft}
      onclick={(e) => e.stopPropagation()}
      onkeydown={(e) => {
        if (e.key === 'Enter') save();
        if (e.key === 'Escape') editing = false;
      }}
      spellcheck="false"
    />
    <button
      class="ok"
      title="save"
      onclick={(e) => {
        e.stopPropagation();
        save();
      }}><Check size={12} /></button
    >
  </span>
{:else}
  <span class="ie {size}" class:empty={!value}>
    <span class="txt" class:placeholder={!value}>{value || 'untitled'}</span>
    <button class="pencil" title="rename" onclick={start}><Pencil size={11} /></button>
  </span>
{/if}

<style>
  .ie {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    min-width: 0;
  }
  .editing input {
    background: var(--cream);
    border: 1px solid var(--hotpink);
    border-radius: 8px;
    padding: 3px 9px;
    outline: none;
    font-size: inherit;
    font-weight: inherit;
    color: var(--ink);
    min-width: 140px;
    box-shadow: 0 0 0 3px rgba(252, 86, 129, 0.12);
    user-select: text;
  }
  .pencil {
    display: inline-grid;
    place-items: center;
    width: 20px;
    height: 20px;
    border-radius: 6px;
    flex-shrink: 0;
    color: var(--text-3);
    opacity: 0;
    transition:
      opacity 0.15s var(--ease-out),
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .ie:hover .pencil {
    opacity: 0.8;
  }
  .pencil:hover {
    background: rgba(19, 23, 34, 0.07);
    color: var(--ink);
    opacity: 1 !important;
  }
  .ok {
    display: grid;
    place-items: center;
    width: 22px;
    height: 22px;
    border-radius: 99px;
    color: var(--green-deep);
    flex-shrink: 0;
  }
  .ok:hover {
    background: var(--card-mint);
  }
  .txt {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .lg {
    font-size: 24px;
    font-weight: 800;
    letter-spacing: -0.02em;
    color: var(--ink);
  }
  .placeholder {
    color: var(--text-3);
    font-style: italic;
  }
</style>
