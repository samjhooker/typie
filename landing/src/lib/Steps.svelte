<script>
  import { reveal } from './reveal.js';
  import { Mic, MoveRight, CornerDownLeft } from 'lucide-svelte';
</script>

<!-- how it works — one slim strip, three steps, no theater -->
<section class="steps" aria-label="how typie works">
  <div class="container row">
    <div class="step" use:reveal>
      <span class="n mono">01</span>
      <span class="key" aria-hidden="true">⌥</span>
      <div class="txt">
        <h3>Hold the key</h3>
        <p>Press and hold option — anywhere on your Mac.</p>
      </div>
    </div>

    <span class="arrow" aria-hidden="true"><MoveRight size={18} strokeWidth={1.6} /></span>

    <div class="step" use:reveal={{ delay: 80 }}>
      <span class="n mono">02</span>
      <span class="ic" aria-hidden="true"><Mic size={20} strokeWidth={1.8} /></span>
      <div class="txt">
        <h3>Say the thing</h3>
        <p>Talk at your pace. The island listens, offline.</p>
      </div>
    </div>

    <span class="arrow" aria-hidden="true"><MoveRight size={18} strokeWidth={1.6} /></span>

    <div class="step" use:reveal={{ delay: 160 }}>
      <span class="n mono">03</span>
      <span class="ic" aria-hidden="true"><CornerDownLeft size={20} strokeWidth={1.8} /></span>
      <div class="txt">
        <h3>It's typed</h3>
        <p>Let go. Real keystrokes land in your app — 80&nbsp;ms later.</p>
      </div>
    </div>
  </div>
</section>

<style>
  .steps { padding: 6px 0 4px; }
  .row {
    display: flex;
    align-items: center;
    gap: 20px;
  }

  .step {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 14px;
    min-width: 0;
  }
  .n { opacity: 0.45; }

  .key {
    flex: none;
    width: 46px; height: 46px;
    display: grid; place-items: center;
    background: #fff;
    border: 1px solid var(--line-strong);
    border-bottom-width: 3px;
    border-radius: 12px;
    font-family: var(--sans);
    font-size: 21px;
    font-weight: 800;
    color: var(--ink);
    box-shadow: 0 2px 6px rgba(19,23,34,.06);
  }
  .ic {
    flex: none;
    width: 46px; height: 46px;
    display: grid; place-items: center;
    background: var(--pink);
    color: var(--hotpink);
    border-radius: 12px;
  }

  .txt h3 { font-size: 15px; font-weight: 700; margin-bottom: 2px; }
  .txt p { font-size: 13px; line-height: 1.5; color: var(--text-3); }

  .arrow { flex: none; color: var(--line-strong); }

  @media (max-width: 860px) {
    .row { flex-direction: column; align-items: stretch; gap: 14px; }
    .arrow { transform: rotate(90deg); justify-content: center; display: flex; }
    .steps { padding: 10px 0 14px; }
  }
</style>
