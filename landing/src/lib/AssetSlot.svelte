<script>
  /**
   * Placeholder frame for final illustration assets.
   * Drop a file into public/assets/{id}.png (or .webp/.svg) and it appears
   * automatically; until then the fallback snippet renders.
   *
   * Note: we verify the response actually decodes as an image, because dev
   * servers answer 200 with index.html for missing files (SPA fallback).
   */
  let { id, alt = '', width = '100%', fallback, round = false } = $props();

  const EXTS = ['webp', 'png', 'svg'];
  let src = $state(null);

  function tryLoad(i = 0) {
    if (i >= EXTS.length) return; // nothing exists -> keep fallback
    const url = `${import.meta.env.BASE_URL}assets/${id}.${EXTS[i]}`;
    const img = new Image();
    img.onload = () => {
      if (img.naturalWidth > 0) src = url;
      else tryLoad(i + 1);
    };
    img.onerror = () => tryLoad(i + 1);
    img.src = url;
  }

  $effect(() => {
    tryLoad();
  });
</script>

<span class="slot" class:round style="width:{width}">
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

  .round {
    aspect-ratio: 1;
    border-radius: 50%;
    overflow: hidden;
    flex-shrink: 0;
  }

  .round img {
    height: 100%;
    object-fit: cover;
  }

  .fallback {
    display: block;
    line-height: 0;
  }
</style>
