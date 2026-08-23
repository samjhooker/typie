<script>
  /**
   * Placeholder frame for final illustration assets.
   * Drop a file into public/assets/{id}.png (or .webp/.svg) and it appears
   * automatically; until then the fallback snippet renders.
   */
  let { id, alt = '', width = '100%', fallback } = $props();

  const EXTS = ['png', 'webp', 'svg'];
  let src = $state(null);

  const url = (ext) => `${import.meta.env.BASE_URL}assets/${id}.${ext}`;

  async function probe() {
    for (const ext of EXTS) {
      try {
        const res = await fetch(url(ext), { method: 'HEAD' });
        if (res.ok) {
          src = url(ext);
          return;
        }
      } catch {
        /* keep probing */
      }
    }
    src = null;
  }

  $effect(() => {
    probe();
  });
</script>

<span class="slot" style="width:{width}">
  {#if src}
    <img {src} {alt} loading="lazy" />
  {:else}
    <span class="fallback">{@render fallback?.()}</span>
  {/if}
</span>

<style>
  .slot {
    display: block;
    line-height: 0;
  }

  .slot img {
    display: block;
    width: 100%;
    height: auto;
  }

  .fallback {
    display: block;
    line-height: 0;
  }
</style>
