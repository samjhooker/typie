<script>
  import { onMount } from 'svelte';
  import { reveal } from './reveal.js';

  let el;

  let ms = $state(0);
  let pct = $state(0);
  let langs = $state(0);

  /* quartic ease-out count-up — fast start, soft landing */
  function count(to, set, dur = 1400) {
    const t0 = performance.now();
    const tick = (t) => {
      const p = Math.min((t - t0) / dur, 1);
      const e = 1 - Math.pow(1 - p, 4);
      set(Math.round(to * e));
      if (p < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  onMount(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
      ms = 100;
      pct = 100;
      langs = 25;
      return;
    }
    const io = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        io.disconnect();
        count(100, (v) => (ms = v));
        count(100, (v) => (pct = v));
        count(25, (v) => (langs = v));
      },
      { threshold: 0.4 }
    );
    io.observe(el);
    return () => io.disconnect();
  });
</script>

<section class="metricband" id="metrics" bind:this={el}>
  <div class="container">
    <ul class="metrics">
      <li use:reveal>
        <b class="num pink">&lt;{ms}<small>ms</small></b>
        <span class="mono">voice to text</span>
      </li>
      <li use:reveal={{ delay: 90 }}>
        <b class="num peri">{pct}<small>%</small></b>
        <span class="mono">on your mac</span>
      </li>
      <li use:reveal={{ delay: 180 }}>
        <b class="num sun">{langs}</b>
        <span class="mono">languages</span>
      </li>
      <li use:reveal={{ delay: 270 }}>
        <b class="num green">$0</b>
        <span class="mono">now &amp; forever</span>
      </li>
    </ul>
  </div>
</section>

<style>
  .metricband {
    border-block: 1px solid rgba(19, 23, 34, 0.08);
    background: var(--paper);
    padding: clamp(44px, 6vh, 72px) 0;
  }

  .metrics {
    list-style: none;
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: clamp(24px, 4vw, 48px);
    text-align: center;
  }

  li {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }

  /* monumental numbers — social proof encoded as typography */
  .num {
    font-family: var(--display);
    font-size: clamp(2.4rem, 5vw, 4rem);
    font-weight: 800;
    letter-spacing: -0.03em;
    line-height: 1;
    font-variant-numeric: tabular-nums;
    color: var(--ink);
  }

  .num small {
    display: inline-block;
    margin-left: 2px;
    font-size: 0.42em;
    font-weight: 700;
    letter-spacing: 0;
    vertical-align: 0.28em;
  }

  .pink { color: var(--hotpink); }
  .peri { color: var(--periwinkle); }
  .sun { color: var(--gold-ink); }
  .green { color: var(--green); }

  li .mono {
    font-size: 11.5px;
  }

  @media (max-width: 720px) {
    .metrics {
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 32px 16px;
    }
  }
</style>
