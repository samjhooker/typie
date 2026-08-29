<script>
  const summaryLines = [
    'Meeting with Maya to plan next steps.',
    'Two items left: pricing page and demo video.',
    'Sam handles pricing page.',
    'Maya records demo video this afternoon.',
    'Team syncs at 4pm.',
  ];
</script>

<div class="summary-card">
  <div class="summary-head">
    <span class="summary-icon"></span>
    <span class="summary-kicker">AI</span>
  </div>
  <div class="summary-body">
    {#each summaryLines as line, i}
      <div
        class="summary-line"
        style="animation-delay:{i * 70}ms"
      >
        <span class="summary-bullet"></span>
        <span class="summary-text">{line}</span>
      </div>
    {/each}
  </div>
</div>

<style>
  .summary-card {
    border: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    border-radius: 14px;
    padding: 18px 20px;
    background: rgba(253, 248, 238, 0.5);
  }
  .summary-head {
    display: flex;
    align-items: center;
    gap: 9px;
    margin-bottom: 12px;
  }
  .summary-icon {
    width: 8px;
    height: 8px;
    border-radius: 99px;
    background: var(--mint);
    box-shadow: 0 0 8px rgba(110, 232, 154, 0.5);
    animation: pulse 2s ease-in-out infinite;
  }
  @keyframes pulse {
    0%,
    100% {
      opacity: 1;
    }
    50% {
      opacity: 0.45;
    }
  }
  .summary-kicker {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 10px;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--text-3);
  }

  .summary-body {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }
  .summary-line {
    display: flex;
    align-items: flex-start;
    gap: 9px;
    font-size: 13px;
    line-height: 1.65;
    color: var(--text-2);
    animation: fadeIn 0.3s ease both;
  }
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(3px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
  .summary-bullet {
    flex-shrink: 0;
    width: 5px;
    height: 5px;
    margin-top: 7px;
    border-radius: 99px;
    background: var(--ink-app);
  }
  .summary-text {
    flex: 1;
  }
</style>
