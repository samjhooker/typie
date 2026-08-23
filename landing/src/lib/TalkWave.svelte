<script>
  let { n = 13, color = 'currentColor' } = $props();
</script>

<div class="talkwave" style="color:{color}" aria-hidden="true">
  {#each Array(n) as _, i}
    <i style="--i:{i}"></i>
  {/each}
</div>

<style>
  .talkwave {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;
    height: 44px;
    pointer-events: none;
  }

  .talkwave i {
    display: block;
    width: 6px;
    height: 100%;
    border-radius: 999px;
    background: currentColor;
    transform-origin: center;
    animation: talk 1.05s var(--ease-inout) infinite;
    animation-delay: calc(var(--i) * -0.12s);
    animation-duration: calc(0.68s + (var(--i) * 0.07s));
  }

  /* speech-like: clusters of energy, then a breath, then another burst */
  @keyframes talk {
    0%, 100% { transform: scaleY(0.18); }
    8% { transform: scaleY(0.55); }
    14% { transform: scaleY(0.28); }
    22% { transform: scaleY(0.92); }
    30% { transform: scaleY(0.4); }
    38% { transform: scaleY(0.72); }
    46% { transform: scaleY(0.22); }
    54% { transform: scaleY(0.18); }
    64% { transform: scaleY(1); }
    72% { transform: scaleY(0.48); }
    80% { transform: scaleY(0.82); }
    90% { transform: scaleY(0.3); }
  }

  .talkwave i:nth-child(3n) { animation-duration: calc(0.78s + (var(--i) * 0.04s)); }
  .talkwave i:nth-child(4n) { animation-duration: calc(1.18s + (var(--i) * 0.03s)); }
  .talkwave i:nth-child(odd) { animation-delay: calc(var(--i) * -0.09s - 0.2s); }

  @media (prefers-reduced-motion: reduce) {
    .talkwave i {
      animation: none;
      transform: scaleY(0.45);
    }
    .talkwave i:nth-child(3n) { transform: scaleY(0.8); }
    .talkwave i:nth-child(5n) { transform: scaleY(0.3); }
  }
</style>
