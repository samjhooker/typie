<script>
  import { onMount } from 'svelte';

  const summaryLines = [
    'Aligned on launch plan, pricing page and demo video are the two remaining items.',
    'Sam will handle the pricing page.',
    'Maya will take the demo video this afternoon.',
    'Team will sync at 4pm to align on deliverables.',
  ];

  let { compact = false } = $props();
  let visible = $state(false);
  onMount(() => {
    visible = true;
  });
</script>

<div
  class="rail"
  class:compact
>
  <div class="rail-head">
    <span class="mono">TRANSFORM</span>
    <span class="ai-dot"></span>
    <span class="mono">AI</span>
  </div>

  <div class="section">
    <h4 class="section-title">Summary</h4>
    {#each summaryLines as line, i}
      <div
        class="pline"
        style="animation-delay:{120 + i * 80}ms"
      >
        <span class="pbullet"></span>
        <span>{line}</span>
      </div>
    {/each}
  </div>

  {#if !compact}
    <div class="divider"></div>

    <div class="section">
      <h4 class="section-title">Actions</h4>
      <div class="action-chips">
        <span class="achip">Finish pricing page</span>
        <span class="achip">Record demo video</span>
      </div>
    </div>

    <div class="divider"></div>

    <div class="section">
      <h4 class="section-title">Timeline</h4>
      <span class="achip">Sync at 4pm</span>
    </div>
  {/if}
</div>

<style>
  .rail {
    display: flex;
    flex-direction: column;
    gap: 18px;
    padding: 24px 20px 18px;
    background: #f9f4ee;
    border-left: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    overflow-y: auto;
  }
  .compact .divider,
  .compact .section:nth-child(n + 3) {
    display: none;
  }

  .rail-head {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .mono {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 10px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--text-3);
  }
  .ai-dot {
    width: 7px;
    height: 7px;
    border-radius: 99px;
    background: var(--mint);
    box-shadow: 0 0 6px rgba(110, 232, 154, 0.45);
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

  .divider {
    height: 1px;
    background: var(--line, rgba(3, 89, 77, 0.12));
  }

  .section {
    display: flex;
    flex-direction: column;
    gap: 7px;
  }
  .section-title {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 10px;
    font-weight: 500;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-3);
  }

  .pline {
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
      transform: translateY(4px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
  .pbullet {
    flex-shrink: 0;
    width: 5px;
    height: 5px;
    margin-top: 7px;
    border-radius: 99px;
    background: var(--ink-app);
  }

  .action-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }
  .achip {
    display: inline-flex;
    align-items: center;
    padding: 5px 12px;
    border-radius: 99px;
    background: var(--wash);
    font-size: 11.5px;
    color: var(--text-2);
  }
</style>
