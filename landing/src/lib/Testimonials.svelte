<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  const quotes = [
    {
      q: '“I genuinely forgot I was dictating.”',
      who: 'Designer',
      tone: '#c9d8f5'
    },
    {
      q: '“It’s basically a keyboard shortcut for my brain.”',
      who: 'Founder',
      tone: '#f5d9c2'
    },
    {
      q: '“I use it in Slack, Mail, everywhere.”',
      who: 'Engineer',
      tone: '#d3ead7'
    }
  ];
</script>

<section class="testimonials field">
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
          <div class="head">
            <AssetSlot id={`avatar-${i}`} width="52px">
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

    <!-- robot cameos peeking in from the edges -->
    <div class="cameo left" aria-hidden="true"><Robot size={44} mood="thinking" /></div>
    <div class="cameo right" aria-hidden="true"><Robot size={44} mood="idle" eye="#f5a623" /></div>
  </div>
</section>

<style>
  .testimonials {
    position: relative;
    overflow: visible;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: clamp(16px, 2.4vw, 28px);
    margin-top: clamp(32px, 5vh, 52px);
  }

  .card {
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
    top: -10px;
    line-height: 0;
  }

  .left {
    left: -14px;
    transform: rotate(-12deg);
  }

  .right {
    right: -14px;
    transform: rotate(10deg) scaleX(-1);
  }

  @media (max-width: 900px) {
    .grid {
      grid-template-columns: 1fr;
    }

    .cameo {
      display: none;
    }
  }
</style>
