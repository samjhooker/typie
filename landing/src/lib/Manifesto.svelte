<script>
  import Robot from './Robot.svelte';
  import { reveal } from './reveal.js';
</script>

<section class="manifesto field field-cream">
  <div class="container">
    <div class="panel">
      <h2 class="l1" use:reveal>Your voice is yours.</h2>
      <h2 class="l2" use:reveal={{ delay: 80 }}>It never leaves your Mac.</h2>
      <p class="l3" use:reveal={{ delay: 160 }}>
        No cloud. No training. No account. No “we updated our privacy policy” emails.
        There is nothing to update. There is no cloud.
      </p>
      <div class="row" use:reveal={{ delay: 240 }}>
        <div class="glyph" aria-hidden="true">
          <Robot mood="idle" size={150} />
        </div>
        <p class="hand note">just a robot with one job</p>
      </div>
    </div>
  </div>
</section>

<style>
  .manifesto {
    padding-block: clamp(24px, 4vh, 48px);
  }

  .panel {
    background: var(--hotpink);
    border-radius: var(--radius);
    padding: clamp(48px, 7vw, 88px) clamp(28px, 6vw, 72px);
    box-shadow: 0 8px 0 rgba(19, 23, 34, 0.85);
  }

  h2 {
    margin: 0;
    font-size: clamp(34px, 5.6vw, 76px);
    letter-spacing: -0.01em;
    text-transform: uppercase;
    line-height: 0.98;
  }

  .l1 { color: var(--cream); }
  .l2 { color: var(--green-deep); }

  .l3 {
    margin-top: 22px;
    max-width: 52ch;
    font-size: clamp(16px, 1.8vw, 20px);
    line-height: 1.5;
    color: rgba(255, 253, 247, 0.95);
  }

  .row {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-top: 32px;
  }

  .glyph {
    color: #f9f8f4;
    line-height: 0;
  }

  .note {
    font-size: clamp(16px, 1.8vw, 20px);
    color: var(--green-deep);
    transform: rotate(-3deg);
  }
</style>
