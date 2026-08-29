<script>
  import { Trash2 } from 'lucide-svelte';
  import { trash } from './trash.svelte.js';
</script>

{#if trash.entries.length}
  <div
    class="toasts"
    role="status"
    aria-live="polite"
  >
    {#each trash.entries as t (t.uid)}
      <div class="toast">
        <span class="msg"><Trash2 size={13} /> deleted <b>{t.preview}</b></span>
        <button
          class="undo"
          onclick={() => trash.undo(t.uid)}>undo</button
        >
      </div>
    {/each}
  </div>
{/if}

<style>
  .toasts {
    position: fixed;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    flex-direction: column;
    gap: 8px;
    align-items: center;
    z-index: 900;
  }
  .toast {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 9px 9px 9px 16px;
    border-radius: 999px;
    background: var(--ink);
    color: #fffdf7;
    box-shadow: 0 10px 28px rgba(19, 23, 34, 0.3);
    animation: toast-in 0.45s var(--spring-snappy, ease) both;
  }
  .msg {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    font-size: 12.5px;
    color: rgba(255, 253, 247, 0.85);
    white-space: nowrap;
  }
  .msg b {
    font-weight: 700;
    color: #fffdf7;
    max-width: 220px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .msg :global(svg) {
    opacity: 0.6;
    flex-shrink: 0;
  }
  .undo {
    padding: 5px 14px;
    border-radius: 999px;
    background: var(--hotpink);
    color: #fff;
    font-size: 11.5px;
    font-weight: 800;
    letter-spacing: 0.02em;
    transition:
      transform 0.18s var(--spring),
      box-shadow 0.18s var(--ease-out);
  }
  .undo:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(252, 86, 129, 0.45);
  }
  .undo:active {
    transform: translateY(0) scale(0.97);
  }

  @keyframes toast-in {
    from {
      opacity: 0;
      transform: translateY(14px);
      filter: blur(4px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
      filter: blur(0);
    }
  }
</style>
