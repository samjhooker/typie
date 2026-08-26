<script>
  /* the emotional peak: three statements pinned full-screen while you
     scroll through them. cream -> pink -> mint, ending on the promise */
  import { reveal } from './reveal.js';

  const LINES = [
    {
      html: 'Your voice is the most <em>personal</em> thing your devices hear.',
      tone: 'ink'
    },
    {
      html: 'Most voice apps take it <em>upstairs</em> — to someone else’s computer.',
      tone: 'pink'
    },
    {
      html: 'Typie can’t hear you.<br /><em>There is no wire.</em>',
      tone: 'mint'
    }
  ];

  let el = $state(null);
  let p = $state(0);

  function visibility(i) {
    const n = LINES.length;
    const start = (i * 0.9) / n;
    const full = start + 0.22 / n + 0.06;
    const hold = ((i + 1) * 0.9) / n;
    if (p <= start) return 0;
    if (p < full) return (p - start) / (full - start);
    if (i === n - 1 || p <= hold) return 1;
    return Math.max(0, 1 - (p - hold) / (0.08 * n));
  }

  $effect(() => {
    if (!el) return;
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
      p = 1;
      return;
    }
    let raf = null;
    const update = () => {
      raf = null;
      const r = el.getBoundingClientRect();
      const total = el.offsetHeight - innerHeight;
      p = total > 0 ? Math.min(1, Math.max(0, -r.top / total)) : 1;
    };
    const onScroll = () => {
      if (!raf) raf = requestAnimationFrame(update);
    };
    update();
    addEventListener('scroll', onScroll, { passive: true });
    addEventListener('resize', onScroll, { passive: true });
    return () => {
      removeEventListener('scroll', onScroll);
      removeEventListener('resize', onScroll);
      if (raf) cancelAnimationFrame(raf);
    };
  });

  /* background washes: cream under line 1, blush under 2, mint under 3 */
  const washes = [
    { c: 'rgba(255, 253, 247, 1)' },
    { c: 'rgba(252, 86, 129, 0.09)' },
    { c: 'rgba(130, 237, 166, 0.16)' }
  ];
</script>

<section class="manifesto" bind:this={el} id="why">
  <!-- sticky stage -->
  <div class="stage">
    <div class="washes" aria-hidden="true">
      {#each washes as w, i}
        <span style="background:{w.c}; opacity:{visibility(i)}"></span>
      {/each}
    </div>

    <p class="mono kicker">why this exists</p>

    {#each LINES as line, i}
      {@const v = visibility(i)}
      <h2
        class="line {line.tone}"
        style="opacity:{v}; transform: translateY({(1 - v) * 46}px); filter: blur({(1 - v) * 8}px); visibility:{v < 0.05 ? 'hidden' : 'visible'}"
      >
        <!-- eslint-disable-next-line svelte/no-at-html-tags -- static copy above -->
        {@html line.html}
      </h2>
    {/each}

    <!-- scroll progress rail -->
    <span class="rail" aria-hidden="true"><i style="height:{p * 100}%"></i></span>

    <span class="scrollhint mono" style="opacity:{Math.max(0, 1 - p * 6)}">keep scrolling ↓</span>
  </div>
</section>

<style>
  .manifesto {
    height: 340vh;
    position: relative;
  }

  .stage {
    position: sticky;
    top: 0;
    height: 100vh;
    display: grid;
    place-items: center;
    overflow: hidden;
    padding: 24px;
  }

  .washes span {
    position: absolute;
    inset: 0;
    transition: opacity 0.15s linear;
  }

  .kicker {
    position: absolute;
    top: max(88px, 10vh);
    left: 50%;
    transform: translateX(-50%);
    z-index: 2;
  }

  .line {
    grid-area: 1 / 1;
    justify-self: center;
    align-self: center;
    max-width: 16ch;
    text-align: center;
    font-size: clamp(38px, 6.4vw, 86px);
    font-weight: 800;
    letter-spacing: -0.04em;
    line-height: 1.04;
    will-change: opacity, transform, filter;
  }

  /* the <em>s arrive via {@html}, so they need :global to escape scoping */
  .line :global(em) {
    font-style: normal;
  }

  .line.ink { color: var(--ink); }
  .line.ink :global(em) { color: var(--hotpink); }

  .line.pink { color: var(--ink); }
  .line.pink :global(em) {
    color: #d61f4c;
    box-shadow: inset 0 -0.18em 0 rgba(252, 86, 129, 0.35);
  }

  .line.mint { color: var(--green-deep); }
  .line.mint :global(em) {
    color: var(--green-deep);
    background: var(--mint);
    box-shadow: 0.08em 0 0 var(--mint), -0.08em 0 0 var(--mint);
    border-radius: 0.1em;
  }

  .rail {
    position: absolute;
    left: clamp(14px, 3vw, 34px);
    top: 50%;
    transform: translateY(-50%);
    width: 4px;
    height: min(200px, 30vh);
    border-radius: 999px;
    background: rgba(19, 23, 34, 0.12);
    overflow: hidden;
  }

  .rail i {
    display: block;
    width: 100%;
    border-radius: 999px;
    background: var(--hotpink);
  }

  .scrollhint {
    position: absolute;
    bottom: max(28px, 5vh);
    left: 50%;
    transform: translateX(-50%);
  }

  @media (max-width: 720px) {
    .rail {
      display: none;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .manifesto {
      height: auto;
    }

    .stage {
      position: static;
      height: auto;
      display: flex;
      flex-direction: column;
      gap: 48px;
      padding-block: 96px;
    }

    .line {
      opacity: 1 !important;
      transform: none !important;
      filter: none !important;
    }

    .washes,
    .rail,
    .scrollhint {
      display: none;
    }
  }
</style>
