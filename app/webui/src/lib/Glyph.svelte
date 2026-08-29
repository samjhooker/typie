<script>
  /**
   * typie's own pixel-flavoured glyphs (hand-authored SVGs).
   *   note       — voice notes / the wall
   *   transcript — transcripts & anything transcribed
   *   record     — meeting recorder (armed)
   *   stop       — meeting recorder (running)
   *   home       — home / everything hub
   *   history    — dictation history
   *   gear       — settings
   */
  const PATHS = {
    note: 'M20 22H4v-2h16v2ZM4 20H2V4h2v16Zm18 0h-2v-8h-8V4H4V2h12v2h-2v6h6V8h2v12ZM20 8h-2V6h2v2Zm-2-2h-2V4h2v2Z',
    transcript:
      'M18 22H6v-2h12v2ZM6 20H4V4h2v16ZM16 4h-2v4h4V6h2v14h-2V10h-6V4H6V2h10v2Zm0 14H8v-2h8v2Zm0-4H8v-2h8v2Zm-6-4H8V8h2v2Zm8-4h-2V4h2v2Z',
    record: 'M20 20H4V4H20V20ZM6 18H18V6H6V18ZM14 14H10V10H14V14Z',
    stop: 'M20 20H4V4H20V20ZM10 14H14V10H10V14Z',
    home: 'M10 20h4v-6h2v6h4v2H4v-2h4v-6h2v6Zm-6 0H2V10h2v10Zm18 0h-2V10h2v10Zm-8-6h-4v-2h4v2Zm-8-4H4V8h2v2Zm14 0h-2V8h2v2ZM8 8H6V6h2v2Zm10 0h-2V6h2v2Zm-8-2H8V4h2v2Zm6 0h-2V4h2v2Zm-2-2h-4V2h4v2Z',
    history:
      'M20 22H4v-2h16v2ZM4 20H2V4h2v16Zm18 0h-2V4h2v16Zm-7-5v2h-2v-2h2Zm-2 0h-2v-2h2v2Zm-2-2H9v-2h2v2Zm2-2h-2V9h2v2Zm2-2h-2V7h2v2Zm5-5H4V2h16v2Z',
    gear: 'M4 20h3v-2h4v4h2v-4h4v2h-2v4H9v-4H7v2H2v-5h2v3Zm18 2h-5v-2h3v-3h2v5ZM6 11H2v2h4v4H4v-2H0V9h4V7h2v4Zm14-2h4v6h-4v2h-2v-4h4v-2h-4V7h2v2Zm-6 7h-4v-2h4v2Zm-4-2H8v-4h2v4Zm6 0h-2v-4h2v4Zm-2-4h-4V8h4v2ZM7 4H4v3H2V2h5v2Zm8 0h2V2h5v5h-2V4h-3v2h-4V2h-2v4H7V4h2V0h6v4Z',
    stats:
      'M20 22H4v-2h16v2ZM4 20H2V4h2v16Zm18 0h-2V4h2v16ZM9 17H7v-6h2v6Zm4 0h-2V7h2v10Zm4 0h-2v-4h2v4Zm3-13H4V2h16v2Z',
  };

  let { name = 'note', size = 24, class: cls = '' } = $props();
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 24 24"
  width={size}
  height={size}
  class={cls}
  aria-hidden="true"
  stroke-width="1"
  stroke-linejoin="miter"
  style="fill:var(--glyph, var(--ink)); stroke:var(--glyph, var(--ink))"
>
  <path d={PATHS[name] ?? PATHS.note} />
</svg>

<style>
  svg {
    display: inline-block;
    flex-shrink: 0;
    vertical-align: middle;
    /* chunky strokes bleed past the 24×24 box — let them */
    overflow: visible;
  }
</style>
