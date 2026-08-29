<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  /* counts up the subscription money you keep while the band is on screen */
  let saved = $state(0);
  let el = $state(null);
  const WISPRFLOW_YEARLY = 144;

  function count(to, dur = 1600) {
    const t0 = performance.now();
    const tick = (t) => {
      const p = Math.min((t - t0) / dur, 1);
      const e = 1 - Math.pow(1 - p, 4);
      saved = Math.round(to * e);
      if (p < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  $effect(() => {
    if (!el) return;
    const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
    const io = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        io.disconnect();
        if (reduce) saved = WISPRFLOW_YEARLY;
        else count(WISPRFLOW_YEARLY);
      },
      { threshold: 0.5 }
    );
    io.observe(el);
    return () => io.disconnect();
  });
</script>

<section
  class="priceband field-butter"
  id="pricing"
  bind:this={el}
>
  <div class="container">
    <p
      class="mono kicker"
      style="text-align:center;margin-bottom:clamp(24px,4vh,36px)"
    >
      chapter 05 · the price
    </p>
  </div>
  <div class="container inner">
    <p
      class="struck"
      use:reveal
    >
      <span class="mono kicker">a dictation subscription</span>
      <span class="amount">$144<span class="per">/year</span></span>
    </p>

    <svg
      class="arrow"
      viewBox="0 0 90 60"
      aria-hidden="true"
      use:reveal={{ delay: 120 }}
    >
      <path
        d="M6 14 C 30 8, 52 18, 66 34 M66 34 l-13 -2 M66 34 l1 -13"
        fill="none"
        stroke="var(--ink)"
        stroke-width="4"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>

    <div
      class="zero"
      use:reveal={{ delay: 200 }}
    >
      <b class="num">$0</b>
      <span class="hand sub"
        >forever. not "free tier". not "free trial". just free.</span
      >
    </div>

    <p
      class="kickerline"
      use:reveal={{ delay: 280 }}
    >
      that's <b>${saved || '…'}</b> still in your pocket every year
    </p>

    <span
      class="bot"
      aria-hidden="true"
      ><Robot
        size={54}
        mood="done"
      /></span
    >
  </div>
</section>

<style>
  .priceband {
    background: var(--butter);
    color: var(--ink);
    padding: clamp(56px, 9vh, 104px) 0;
    overflow: hidden;
  }

  .inner {
    display: grid;
    grid-template-columns: auto auto auto;
    justify-content: center;
    align-items: center;
    column-gap: clamp(24px, 5vw, 64px);
    position: relative;
  }

  .kicker {
    color: var(--text-3);
  }

  .struck {
    text-align: center;
    transform: rotate(-2deg);
  }

  .struck .amount {
    display: block;
    margin-top: 10px;
    font-family: var(--display);
    font-size: clamp(38px, 5vw, 62px);
    font-weight: 800;
    letter-spacing: -0.03em;
    line-height: 1;
    text-decoration: line-through;
    text-decoration-color: var(--hotpink);
    text-decoration-thickness: 6px;
    color: var(--text-3);
  }

  .per {
    font-size: 0.45em;
    font-weight: 700;
  }

  .arrow {
    width: clamp(48px, 7vw, 88px);
    flex-shrink: 0;
  }

  .zero {
    text-align: center;
    transform: rotate(-1deg);
  }

  .num {
    display: block;
    font-family: var(--display);
    font-size: clamp(84px, 12vw, 168px);
    font-weight: 800;
    letter-spacing: -0.05em;
    line-height: 0.9;
    color: var(--green-deep);
    text-shadow: 4px 4px 0 rgba(19, 23, 34, 0.14);
  }

  .sub {
    display: block;
    margin-top: 12px;
    font-size: clamp(19px, 2vw, 25px);
    color: var(--text-2);
  }

  .kickerline {
    grid-column: 1 / -1;
    justify-self: center;
    margin-top: clamp(24px, 4vh, 36px);
    font-size: clamp(15px, 1.6vw, 18px);
    font-weight: 600;
    color: var(--text-2);
  }

  .bot {
    position: absolute;
    right: clamp(-10px, 2vw, 40px);
    bottom: -34px;
    line-height: 0;
    color: var(--hotpink);
    transform: rotate(8deg);
  }

  @media (max-width: 720px) {
    .inner {
      grid-template-columns: 1fr;
      row-gap: 20px;
      justify-items: center;
    }

    .arrow {
      transform: rotate(72deg);
    }
  }
</style>
