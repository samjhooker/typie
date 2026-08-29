<script>
  import { reveal } from './reveal.js';
  import { Mic, MoveRight, CornerDownLeft } from 'lucide-svelte';
</script>

<section
  class="steps-section"
  aria-label="How typie works"
>
  <div class="container row">
    <div
      class="step"
      use:reveal
    >
      <span class="step-num mono">01</span>
      <span
        class="key"
        aria-hidden="true">⌥</span
      >
      <div class="txt">
        <h3>Hold the key</h3>
        <p>Press Option in any app, from Slack to your IDE.</p>
      </div>
    </div>

    <span
      class="arrow"
      aria-hidden="true"
      ><MoveRight
        size={18}
        strokeWidth={1.8}
      /></span
    >

    <div
      class="step"
      use:reveal={{ delay: 80 }}
    >
      <span class="step-num mono">02</span>
      <span
        class="ic"
        aria-hidden="true"
        ><Mic
          size={20}
          strokeWidth={2}
        /></span
      >
      <div class="txt">
        <h3>Speak naturally</h3>
        <p>Talk at your pace. Nvidia Parakeet transcribes in RAM.</p>
      </div>
    </div>

    <span
      class="arrow"
      aria-hidden="true"
      ><MoveRight
        size={18}
        strokeWidth={1.8}
      /></span
    >

    <div
      class="step"
      use:reveal={{ delay: 160 }}
    >
      <span class="step-num mono">03</span>
      <span
        class="ic done"
        aria-hidden="true"
        ><CornerDownLeft
          size={20}
          strokeWidth={2}
        /></span
      >
      <div class="txt">
        <h3>It's typed</h3>
        <p>Release. Keystrokes land at your cursor in 80 milliseconds.</p>
      </div>
    </div>
  </div>
</section>

<style>
  .steps-section {
    padding: 24px 0 32px;
  }
  .row {
    display: flex;
    align-items: center;
    gap: 24px;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    padding: 20px 28px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
  }

  .step {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 16px;
    min-width: 0;
  }
  .step-num {
    color: var(--hotpink);
    font-weight: 700;
    font-size: 12px;
  }

  .key {
    flex: none;
    width: 44px;
    height: 44px;
    display: grid;
    place-items: center;
    background: var(--surface-2);
    border: 1px solid var(--line-strong);
    border-bottom-width: 3px;
    border-radius: 12px;
    font-family: var(--sans);
    font-size: 20px;
    font-weight: 800;
    color: var(--ink);
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
  }

  .ic {
    flex: none;
    width: 44px;
    height: 44px;
    display: grid;
    place-items: center;
    background: var(--pink);
    color: var(--hotpink);
    border-radius: 12px;
  }
  .ic.done {
    background: var(--card-mint);
    color: #059669;
  }

  .txt h3 {
    font-size: 15.5px;
    font-weight: 800;
    margin-bottom: 2px;
    color: var(--ink);
  }
  .txt p {
    font-size: 13px;
    line-height: 1.45;
    color: var(--text-3);
  }

  .arrow {
    flex: none;
    color: var(--line-strong);
    opacity: 0.6;
  }

  @media (max-width: 890px) {
    .row {
      flex-direction: column;
      align-items: stretch;
      gap: 16px;
      padding: 20px;
    }
    .arrow {
      transform: rotate(90deg);
      justify-content: center;
      display: flex;
    }
    .steps-section {
      padding: 12px 0 20px;
    }
  }
</style>
