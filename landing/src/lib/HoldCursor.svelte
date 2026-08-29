<script>
  /* a little waveform that chases the cursor while the visitor is
     holding anywhere on the page - the site itself listens */
  let { holding = false } = $props();

  let x = $state(-100);
  let y = $state(-100);

  const fine =
    typeof matchMedia !== 'undefined' &&
    matchMedia('(pointer: fine)').matches &&
    !matchMedia('(prefers-reduced-motion: reduce)').matches;

  function onMove(e) {
    if (!fine || e.pointerType !== 'mouse') return;
    x = e.clientX;
    y = e.clientY;
  }

  $effect(() => {
    if (!fine) return;
    addEventListener('pointermove', onMove, { passive: true });
    return () => removeEventListener('pointermove', onMove);
  });
</script>

<div
  class="holdcursor"
  class:on={holding && fine}
  style="transform: translate3d({x}px, {y}px, 0)"
  aria-hidden="true"
>
  <span class="bars"><i></i><i></i><i></i><i></i><i></i></span>
  <span class="lbl mono">listening…</span>
</div>

<style>
  .holdcursor {
    position: fixed;
    left: 0;
    top: 0;
    z-index: 300;
    pointer-events: none;
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 7px 13px;
    border-radius: 999px;
    background: rgba(19, 23, 34, 0.92);
    opacity: 0;
    scale: 0.7;
    transition:
      opacity 0.18s var(--ease-out),
      scale 0.25s var(--spring);
    will-change: transform;
  }

  .holdcursor.on {
    opacity: 1;
    scale: 1;
  }

  .bars {
    display: flex;
    align-items: center;
    gap: 2.5px;
    height: 14px;
  }

  .bars i {
    width: 2.5px;
    height: 100%;
    border-radius: 999px;
    background: var(--hotpink);
    transform-origin: center;
    animation: hbar 0.7s var(--ease-inout) infinite;
  }

  .bars i:nth-child(1) {
    animation-delay: 0s;
    height: 60%;
  }
  .bars i:nth-child(2) {
    animation-delay: 0.12s;
    height: 100%;
  }
  .bars i:nth-child(3) {
    animation-delay: 0.24s;
    height: 75%;
  }
  .bars i:nth-child(4) {
    animation-delay: 0.09s;
    height: 90%;
  }
  .bars i:nth-child(5) {
    animation-delay: 0.18s;
    height: 55%;
  }

  @keyframes hbar {
    0%,
    100% {
      transform: scaleY(0.35);
    }
    50% {
      transform: scaleY(1);
    }
  }

  .lbl {
    font-size: 10.5px;
    color: var(--cream);
    letter-spacing: 0.14em;
  }
</style>
