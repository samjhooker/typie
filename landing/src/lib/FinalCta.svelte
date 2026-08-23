<script>
  import { reveal } from './reveal.js';
  import DownloadCta from './DownloadCta.svelte';
  import Robot from './Robot.svelte';
</script>

<section class="finalcta field-pink-band">
  <div class="container inner" use:reveal>
    <span class="bot" aria-hidden="true"><Robot size={72} mood="idle" /></span>
    <h2>Just talk.<br /><span class="accent">It’s typed.</span></h2>
    <p class="sub">Hold ⌥. Say the thing. It’s typed, wherever your cursor is.</p>
    <div class="ctarow">
      <DownloadCta kind="green" big label="Download Typie for free" />
    </div>
    <p class="micro mono">macOS 14+ · Apple silicon · 25 languages · nothing leaves your Mac</p>
  </div>
</section>

<style>
  .finalcta {
    padding: clamp(56px, 8vh, 96px) 0 clamp(64px, 9vh, 104px);
    background: var(--pink-band);
    color: var(--ink);
    text-align: center;
  }

  .inner {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 18px;
  }

  .bot {
    line-height: 0;
    color: var(--hotpink);
    animation: botwave 4s var(--ease-inout) infinite;
  }

  @keyframes botwave {
    0%, 100% { transform: rotate(-6deg); }
    50% { transform: rotate(5deg) translateY(-4px); }
  }

  h2 {
    font-size: clamp(36px, 4.6vw, 60px);
    letter-spacing: -0.03em;
    line-height: 1.02;
  }

  .sub {
    max-width: 40ch;
    font-size: clamp(16px, 1.6vw, 19px);
    font-weight: 600;
    color: rgba(19, 23, 34, 0.72);
  }

  .ctarow {
    margin-top: 10px;
  }

  .micro {
    margin-top: 4px;
  }

  @media (prefers-reduced-motion: reduce) {
    .bot {
      animation: none;
    }
  }
</style>
