<script>
  let {
    size = 100,
    mood = 'idle',
    eye = 'currentColor',
    bg = 'none',
  } = $props();

  /* ---- eye tracking: all robots watch the cursor ---- */
  let ex = $state(0);
  let ey = $state(0);
  let root;

  const pointer = { x: -9999, y: -9999 };
  let raf = 0;
  const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;

  function onMove(e) {
    pointer.x = e.clientX;
    pointer.y = e.clientY;
  }

  function tick() {
    if (root) {
      const r = root.getBoundingClientRect();
      if (r.bottom > -80 && r.top < innerHeight + 80) {
        const dx = pointer.x - (r.left + r.width / 2);
        const dy = pointer.y - (r.top + r.height * 0.62);
        const d = Math.hypot(dx, dy) || 1;
        /* keep pupils inside the key-square sockets, never the glyph edge */
        const maxX = Math.min(size * 0.018, 2.6);
        const maxY = Math.min(size * 0.012, 1.8);
        const pull = Math.min(d / 280, 1);
        ex = (dx / d) * maxX * pull;
        ey = (dy / d) * maxY * pull;
      }
    }
    raf = requestAnimationFrame(tick);
  }

  $effect(() => {
    if (reduced) return;
    addEventListener('pointermove', onMove, { passive: true });
    raf = requestAnimationFrame(tick);
    return () => {
      removeEventListener('pointermove', onMove);
      cancelAnimationFrame(raf);
    };
  });
</script>

<!-- the one and only typie glyph - split into its own subpaths so
     pillars can be ears and key squares can be eyes. fill follows `color`. -->
<div
  class="robot {mood}"
  bind:this={root}
  style="width:{size}px;--eye:{eye};--ex:{ex}px;--ey:{ey}px"
  aria-hidden="true"
>
  <svg
    viewBox="-1 -0.5 26 25"
    fill="currentColor"
    stroke="currentColor"
    stroke-width="1.3"
    stroke-linejoin="round"
  >
    {#if bg !== 'none'}
      <path
        fill={bg}
        stroke="none"
        d="M5 7h14v12H5z"
      />
    {/if}
    <!-- bottom bar -->
    <path d="M19 21H5v-2h14v2Z" />

    <!-- ears (the pillars) -->
    <path
      class="ear ear-l"
      d="M5 19H3v-4H1v-2h2V9h2v10Z"
    />
    <path
      class="ear ear-r"
      d="M21 13h2v2h-2v4h-2V9h2v4Z"
    />

    <!-- eyes (the two key squares) -->
    <path
      class="eye eye-l"
      fill={eye}
      stroke-width="0.55"
      d="M10 16H8v-4h2v4Z"
    />
    <path
      class="eye eye-r"
      fill={eye}
      stroke-width="0.55"
      d="M16 16h-2v-4h2v4Z"
    />

    <!-- screen + flag -->
    <path d="M13 7h6v2H5V7h6V5h2v2Z" />
    <path d="M11 5H7V3h4v2Z" />
  </svg>
</div>

<style>
  /* impeccable-disable bounce-easing — Robot moods use Theme.springy intentionally */
  .robot {
    display: block;
    line-height: 0;
    transition: transform 0.35s var(--spring);
  }

  /* hover shift */
  .robot:hover {
    transform: translateY(-7%) rotate(-7deg);
  }

  svg {
    display: block;
    width: 100%;
    height: auto;
    transform-origin: center;
  }

  /* idle: gentle float */
  .idle svg {
    animation: floaty 5s var(--ease-inout) infinite;
  }

  @keyframes floaty {
    0%,
    100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-4%);
    }
  }

  /* listening / typing: excited wiggle */
  .listening svg {
    animation: boogie 0.45s var(--ease-inout) infinite alternate;
  }

  @keyframes boogie {
    from {
      transform: rotate(-5deg) scale(1);
    }
    to {
      transform: rotate(5deg) scale(1.06);
    }
  }

  /* thinking: slow sway */
  .thinking svg {
    animation: sway 1.8s var(--ease-inout) infinite;
  }

  @keyframes sway {
    0%,
    100% {
      transform: rotate(-6deg);
    }
    50% {
      transform: rotate(6deg);
    }
  }

  /* done: springy pop */
  .done svg {
    animation: yay 0.55s cubic-bezier(0.2, 1.6, 0.35, 1);
  }

  @keyframes yay {
    0% {
      transform: scale(0.82) rotate(-6deg);
    }
    55% {
      transform: scale(1.12) rotate(3deg);
    }
    100% {
      transform: none;
    }
  }

  /* ears grow outward when typing */
  .ear {
    transform-box: fill-box;
    transition: transform 0.35s cubic-bezier(0.2, 1.4, 0.35, 1);
  }

  .ear-l {
    transform-origin: left center;
  }
  .ear-r {
    transform-origin: right center;
  }

  .listening .ear-l {
    transform: translateX(-4%) scaleX(1.18) scaleY(1.08);
  }

  .listening .ear-r {
    transform: translateX(4%) scaleX(1.18) scaleY(1.08);
  }

  /* blink + wink (eyes are the two key squares) + cursor tracking */
  .eye {
    transform-box: fill-box;
    transform-origin: center;
    translate: var(--ex, 0px) var(--ey, 0px);
    transition: translate 0.18s var(--snap);
    animation: blink 4.2s infinite;
  }

  .eye-r {
    animation-duration: 5.7s;
    animation-delay: 1.2s;
  }

  @keyframes blink {
    0%,
    91%,
    100% {
      transform: scaleY(1);
    }
    94% {
      transform: scaleY(0.12);
    }
    97% {
      transform: scaleY(1);
    }
  }
</style>
