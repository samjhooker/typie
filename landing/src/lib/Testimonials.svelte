<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import Robot from './Robot.svelte';

  const featured = {
    q: '“Dictated a gnarly investor update on the Northern line with no signal and it didn’t miss a comma. WisprFlow would’ve just stared at me. My keyboard is officially unemployed.”',
    who: '★★★★★  Maya · founder, London',
    tone: '#c5daff',
    bg: '#eff4ff',
  };

  const quotes = [
    {
      q: '“The first time it split me and my cofounder into two speakers without me asking, I actually laughed. Otter charges for that.”',
      who: '★★★★★  Sam · engineer, Berlin',
      tone: '#ffd0e6',
      bg: '#fff0f6',
    },
    {
      q: '“I hold option and ramble. It gives me the sentence I meant, not the one I said. Spooky good.”',
      who: '★★★★★  Priya · product designer, NYC',
      tone: '#ffe0a8',
      bg: '#fff8e9',
    },
  ];
</script>

<section class="testimonials field pop-c">
  <div class="container">
    <h2
      class="subhead"
      use:reveal
    >
      Loved by people who
      <span class="squiggle"
        >type all day
        <svg
          viewBox="0 0 120 14"
          aria-hidden="true"
        >
          <path
            d="M4 9c22-6 44-6 56-3s34 4 56-2"
            stroke="var(--hotpink)"
          />
        </svg>
      </span>
    </h2>

    <div class="grid">
      <figure
        class="card featured"
        style="background:{featured.bg}"
        use:reveal
      >
        <div
          class="cameo left"
          aria-hidden="true"
        >
          <span class="cam-bubble hand">we definitely<br />real people</span>
          <Robot
            size={44}
            mood="thinking"
          />
        </div>
        <div class="head">
          <AssetSlot
            id="avatar-0"
            width="60px"
            round
          >
            {#snippet fallback()}
              <span
                class="avatar"
                style="background:{featured.tone}"
                aria-hidden="true"
              ></span>
            {/snippet}
          </AssetSlot>
          <blockquote>{featured.q}</blockquote>
        </div>
        <figcaption class="mono">{featured.who}</figcaption>
      </figure>

      <div class="side">
        {#each quotes as t, i}
          <figure
            class="card"
            style="background:{t.bg}"
            use:reveal={{ delay: 90 + i * 90 }}
          >
            <div class="head">
              <AssetSlot
                id={`avatar-${i + 1}`}
                width="46px"
                round
              >
                {#snippet fallback()}
                  <span
                    class="avatar sm"
                    style="background:{t.tone}"
                    aria-hidden="true"
                  ></span>
                {/snippet}
              </AssetSlot>
              <blockquote>{t.q}</blockquote>
            </div>
            <figcaption class="mono">{t.who}</figcaption>
          </figure>
        {/each}
      </div>
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
    grid-template-columns: 1.35fr 1fr;
    gap: clamp(16px, 2.4vw, 28px);
    margin-top: clamp(48px, 6.5vh, 68px);
    align-items: stretch;
  }

  .side {
    display: grid;
    grid-template-rows: 1fr 1fr;
    gap: clamp(16px, 2.4vw, 28px);
  }

  .card {
    position: relative;
    background: var(--cream);
    border: 1px solid rgba(19, 23, 34, 0.07);
    border-radius: var(--radius-card);
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.05);
    padding: clamp(22px, 2.6vw, 32px);
    display: flex;
    flex-direction: column;
    gap: 16px;
    transition:
      transform 0.45s var(--spring-snappy),
      box-shadow 0.45s var(--spring-snappy),
      border-color 0.3s var(--ease-out);
  }

  .card:hover {
    transform: translateY(-4px);
    box-shadow:
      0 16px 36px rgba(19, 23, 34, 0.09),
      0 3px 10px rgba(19, 23, 34, 0.04);
    border-color: rgba(19, 23, 34, 0.13);
  }

  /* fallback when no inline bg is set */

  .featured blockquote {
    font-size: clamp(19px, 2vw, 24px);
    line-height: 1.4;
  }

  .head {
    display: flex;
    gap: 14px;
    align-items: flex-start;
    flex: 1;
  }

  .avatar {
    display: block;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .avatar.sm {
    width: 46px;
    height: 46px;
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
    padding-left: 74px;
  }

  .side figcaption.mono {
    padding-left: 60px;
  }

  .cameo {
    position: absolute;
    top: -22px;
    line-height: 0;
    z-index: 2;
    animation: camfloat 4s var(--ease-inout) infinite;
  }

  .left {
    left: 14px;
    transform: rotate(-8deg);
    color: var(--hotpink);
  }

  @keyframes camfloat {
    0%,
    100% {
      translate: 0 0;
    }
    50% {
      translate: 0 -8px;
    }
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

    .side {
      grid-template-rows: none;
    }

    .cameo {
      display: none;
    }

    figcaption.mono {
      padding-left: 0;
    }
  }
</style>
