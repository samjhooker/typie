<script>
  import { onMount } from 'svelte';

  // one beat, three lines, the page dictates itself
  const L1 = 'hold a key. ';
  const L2 = 'say the thing. ';
  const L3 = "it's typed.";
  const FULL = L1 + L2 + L3;

  let typed = $state('');
  let done = $state(false);

  const reduce =
    typeof matchMedia !== 'undefined' &&
    matchMedia('(prefers-reduced-motion: reduce)').matches;

  const pressSfx =
    typeof Audio !== 'undefined' ? new Audio('/sounds/keypress.wav') : null;
  const releaseSfx =
    typeof Audio !== 'undefined' ? new Audio('/sounds/keyrelease.wav') : null;
  if (pressSfx) pressSfx.volume = 0.3;
  if (releaseSfx) releaseSfx.volume = 0.35;

  function play(a) {
    if (!a) return;
    try {
      a.currentTime = 0;
      // browsers without prior user activation simply stay silent, fine
      const p = a.play();
      if (p?.catch) p.catch(() => {});
    } catch {
      /* no audio, no problem */
    }
  }

  // dictation rhythm: quick bursts, a breath at the periods
  function delayFor(ch, next) {
    if (ch === '.') return next === ' ' ? 110 : 60;
    if (ch === ' ' && next && next !== ' ') return 150;
    return 40 + Math.random() * 55;
  }

  onMount(() => {
    if (reduce) {
      typed = FULL;
      done = true;
      return;
    }
    const el = document.getElementById('dictate-beat');
    if (!el) return;
    const io = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        io.disconnect();
        let i = 0;
        const step = () => {
          i++;
          typed = FULL.slice(0, i);
          play(pressSfx);
          if (i < FULL.length) {
            setTimeout(step, delayFor(FULL[i - 1], FULL[i]));
          } else {
            play(releaseSfx);
            setTimeout(() => (done = true), 3200);
          }
        };
        setTimeout(step, 400);
      },
      { threshold: 0.4 }
    );
    io.observe(el);
    return () => io.disconnect();
  });
</script>

<section
  class="beat"
  id="dictate-beat"
  aria-label="how typie works"
>
  <div class="container">
    <p
      class="line l1"
      class:set={typed.length > 0}
    >
      {typed.slice(0, L1.length)}{#if typed.length < L1.length}<i
          class="caret"
          aria-hidden="true"
        ></i>{/if}
    </p>
    <p
      class="line l2"
      class:set={typed.length > L1.length}
    >
      {typed.slice(
        L1.length,
        L1.length + L2.length
      )}{#if typed.length >= L1.length && typed.length < L1.length + L2.length}<i
          class="caret"
          aria-hidden="true"
        ></i>{/if}
    </p>
    <p
      class="line l3"
      class:set={typed.length > L1.length + L2.length}
    >
      {typed.slice(
        L1.length + L2.length
      )}{#if typed.length >= L1.length + L2.length && !done}<i
          class="caret"
          aria-hidden="true"
        ></i>{/if}
    </p>
  </div>
</section>

<style>
  /* impeccable-disable bounce-easing, the caret blink is a hardware-cursor stand-in, intentional */
  .beat {
    min-height: 100svh;
    display: grid;
    place-items: center;
    background:
      radial-gradient(
        ellipse 52% 40% at 50% 58%,
        rgba(252, 86, 129, 0.09) 0%,
        transparent 62%
      ),
      radial-gradient(
        ellipse 40% 32% at 18% 8%,
        rgba(199, 215, 255, 0.05) 0%,
        transparent 60%
      ),
      var(--ink-deep);
  }
  .container {
    width: min(1120px, calc(100% - 32px));
  }
  .line {
    font-family: var(--display);
    font-weight: 800;
    letter-spacing: -0.04em;
    line-height: 1.08;
    font-size: clamp(34px, 5.4vw, 74px);
    color: #f5efe4;
    text-align: left;
    min-height: 1.1em;
    margin: 0;
    opacity: 0.28;
    transition: opacity 0.5s var(--ease-out);
  }
  .line.set {
    opacity: 1;
  }
  .l3 {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    letter-spacing: -0.02em;
    color: var(--hotpink);
  }
  .caret {
    display: inline-block;
    width: 0.075em;
    height: 0.82em;
    vertical-align: -0.06em;
    margin-left: 0.07em;
    border-radius: 2px;
    background: var(--hotpink);
    animation: blink 1.05s steps(2) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  @media (prefers-reduced-motion: reduce) {
    .caret {
      animation: none;
    }
    .line {
      transition: none;
    }
  }

  @media (max-width: 700px) {
    .beat {
      min-height: 88svh;
    }
  }
</style>
