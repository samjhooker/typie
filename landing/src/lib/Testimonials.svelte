<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import Robot from './Robot.svelte';

  const quotes = [
    {
      q: '“I genuinely forgot I was dictating.”',
      who: 'Designer',
      tone: '#c5daff'
    },
    {
      q: '“It’s basically a keyboard shortcut for my brain.”',
      who: 'Founder',
      tone: '#ffe0a8'
    },
    {
      q: '“I use it in Slack, Mail, everywhere.”',
      who: 'Engineer',
      tone: '#ffd0e6'
    }
  ];
</script>

<section class="testimonials field pop-c">
  <div class="container">
    <h2 class="subhead" use:reveal>
      Loved by people who
      <span class="squiggle">type all day
        <svg viewBox="0 0 120 14" aria-hidden="true">
          <path d="M4 9c22-6 44-6 56-3s34 4 56-2" stroke="var(--hotpink)" />
        </svg>
      </span>
    </h2>

    <div class="grid">
      {#each quotes as t, i}
        <figure class="card" use:reveal={{ delay: i * 90 }}>
          {#if i === 0}
            <div class="cameo left" aria-hidden="true">
              <span class="cam-bubble hand">we definitely<br />real people</span>
              <Robot size={44} mood="thinking" />
            </div>
          {:else if i === 2}
            <div class="cameo right" aria-hidden="true"><Robot size={44} mood="idle" /></div>
          {/if}
          <div class="head">
            <AssetSlot id={`avatar-${i}`} width="52px" round>
              {#snippet fallback()}
                <span class="avatar" style="background:{t.tone}" aria-hidden="true"></span>
              {/snippet}
            </AssetSlot>
            <blockquote>{t.q}</blockquote>
          </div>
          <figcaption class="mono">– {t.who}</figcaption>
        </figure>
      {/each}
    </div>
  </div>
</section>

<style>
  .testimonials {
    position: relative;
    overflow: visible;
    padding-top: clamp(48px, 7vh, 80px);
    padding-bottom: clamp(48px, 7vh, 80px);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: clamp(16px, 2.4vw, 28px);
    margin-top: clamp(56px, 7vh, 76px);
  }

  .card {
    position: relative;
    background: #fffdf7;
    border: 1px solid rgba(19, 23, 34, 0.07);
    border-radius: 20px;
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.05);
    padding: clamp(20px, 2.4vw, 30px);
    display: flex;
    flex-direction: column;
    gap: 18px;
  }

  .head {
    display: flex;
    gap: 14px;
    align-items: flex-start;
  }

  .avatar {
    display: block;
    width: 52px;
    height: 52px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  blockquote {
    font-size: 15.5px;
    font-weight: 600;
    line-height: 1.45;
    color: var(--ink);
    letter-spacing: -0.01em;
  }

  figcaption.mono {
    text-transform: none;
    letter-spacing: 0.04em;
  }

  .cameo {
    position: absolute;
    top: -22px;
    line-height: 0;
    z-index: 2;
    animation: camfloat 4s ease-in-out infinite;
  }

  .left {
    left: 14px;
    transform: rotate(-8deg);
    color: var(--hotpink);
  }

  .right {
    right: 10px;
    transform: rotate(9deg) scaleX(-1);
    animation-delay: 1.2s;
    color: var(--sun);
  }

  @keyframes camfloat {
    0%, 100% { translate: 0 0; }
    50% { translate: 0 -8px; }
  }

  .cam-bubble {
    position: absolute;
    top: 2px;
    left: 36px;
    background: #fff;
    border-radius: 14px;
    padding: 5px 11px 6px;
    font-size: 16px;
    line-height: 0.95;
    color: var(--ink);
    box-shadow: 0 2px 8px rgba(19, 23, 34, 0.1);
    white-space: nowrap;
    transform: rotate(7deg);
  }

  @media (max-width: 900px) {
    .grid {
      grid-template-columns: 1fr;
      margin-top: clamp(32px, 5vh, 48px);
    }

    .cameo {
      display: none;
    }
  }
</style>
