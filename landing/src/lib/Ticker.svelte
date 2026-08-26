<script>
  /* one-line manifesto, marching across the page - intentionally endless */
  const items = [
    { txt: 'no cloud', c: '#fc5681' },
    { txt: 'no account', c: '#82eda6' },
    { txt: '$0 forever', c: '#ffda8a' },
    { txt: 'no telemetry', c: '#ddd8ff' },
    { txt: 'works on a plane', c: '#bcd6ff' },
    { txt: 'nothing uploaded. ever.', c: '#fc5681' },
    { txt: 'hold ⌥ and talk', c: '#82eda6' },
    { txt: 'speaker-split transcripts', c: '#ffda8a' },
    { txt: 'on-device AI summaries', c: '#ddd8ff' },
    { txt: '25 languages', c: '#bcd6ff' },
    { txt: 'your voice stays yours', c: '#fc5681' },
    { txt: 'free. free. free.', c: '#82eda6' }
  ];
</script>

<div class="ticker" aria-label="manifesto ticker">
  <div class="belt">
    {#each [0, 1, 2, 3] as copy (copy)}
      <div class="run" aria-hidden={copy !== 0}>
        {#each items as it}
          <span class="item">{it.txt}</span>
          <span class="star" style="color:{it.c}">✦</span>
        {/each}
      </div>
    {/each}
  </div>
</div>

<style>
  .ticker {
    background: var(--ink);
    color: var(--cream);
    overflow: hidden;
    padding: 13px 0;
    transform: rotate(-0.6deg) scale(1.01);
  }

  .belt {
    display: flex;
    width: max-content;
    animation: march 38s linear infinite;
  }

  @keyframes march {
    to { transform: translateX(-25%); }
  }

  .run {
    display: flex;
    align-items: center;
    flex-shrink: 0;
  }

  .item {
    font-family: var(--mono);
    font-size: 13px;
    font-weight: 500;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    white-space: nowrap;
    padding: 0 18px;
  }

  .star {
    font-size: 12px;
  }

  @media (prefers-reduced-motion: reduce) {
    .belt {
      animation: none;
    }
  }
</style>
