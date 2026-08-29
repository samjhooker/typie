<script>
  /**
   * WindowFrame — macOS-style window chrome for bento UI mocks.
   * Traffic lights + title bar make the preview read as a real app
   * window; themed via landing tokens (works light + dark).
   */
  let { title = '', children } = $props();
</script>

<div class="wframe">
  <div class="wbar">
    {#if title}<span class="wtitle">{title}</span>{/if}
  </div>
  <div class="wbody">
    {@render children?.()}
  </div>
</div>

<style>
  .wframe {
    display: flex;
    flex-direction: column;
    height: 100%;
    background: var(--surface);
    /* dotted border — blueprint/mockup feel, clearly not the card edge */
    border: 1.5px dotted var(--line-strong);
    border-radius: 14px;
    overflow: hidden;
    /* layered elevation: tight contact + wide ambient */
    box-shadow:
      0 2px 4px rgba(19, 23, 34, 0.07),
      0 16px 40px rgba(19, 23, 34, 0.13);
    transition: box-shadow 0.25s ease;
  }
  .wbar {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 8px 12px;
    background: var(--surface-2);
    border-bottom: 1px solid var(--line);
    flex: none;
  }
  .wtitle {
    font-family: var(--mono, monospace);
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-3);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .wbody {
    position: relative;
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    --wbody: var(--surface);
  }

  /* dark: screen sits darker than the card, glass edge catches light */
  :global([data-theme='dark']) .wframe {
    background: #101218;
    border-color: rgba(255, 255, 255, 0.28);
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.07),
      0 3px 8px rgba(0, 0, 0, 0.5),
      0 28px 64px rgba(0, 0, 0, 0.55);
  }
  :global([data-theme='dark']) .wbody {
    background: #101218;
    --wbody: #101218;
  }
  :global([data-theme='dark']) .wbar {
    background: #1d2029;
    border-bottom-color: rgba(255, 255, 255, 0.08);
  }
</style>
