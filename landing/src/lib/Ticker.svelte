<script>
  /* one-line manifesto, marching across the page */
  const items = [
    { txt: 'no cloud', c: '#fc5681' },
    { txt: 'no account', c: '#82eda6' },
    { txt: '$0 forever', c: '#ffda8a' },
    { txt: 'no telemetry', c: '#ddd8ff' },
    { txt: 'works on a plane', c: '#bcd6ff' },
    { txt: 'nothing uploaded. ever.', c: '#fc5681' }
  ];
</script>

<div class="ticker" aria-label="no cloud. no account. zero dollars forever. no telemetry. works on a plane. nothing uploaded ever.">
  <div class="belt">
    {#each [0, 1] as copy (copy)}
      <div class="run" aria-hidden={copy === 1}>
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
    animation: march 26s linear infinite;
  }

  @keyframes march {
    to { transform: translateX(-50%); }
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
