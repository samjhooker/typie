<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import DownloadCta from './DownloadCta.svelte';
</script>

<section class="ctaband field" id="pricing">
  <div class="container">
    <div class="banner" use:reveal>
      <div class="copy">
        <h2>Your voice. Anywhere.</h2>
        <p class="sub">Download Typie for Mac</p>

        <div class="cta">
          <DownloadCta kind="green" big />
        </div>

        <p class="specs mono">macOS 14+ · Apple Silicon</p>
      </div>

      <!-- illustrated scene along the bottom edge -->
      <div class="scene" aria-hidden="true">
        <AssetSlot id="cta-scene" width="100%">
          {#snippet fallback()}
            <svg viewBox="0 0 1200 220" preserveAspectRatio="xMidYMax slice">
              <!-- sparkles -->
              <g fill="#fffdf7" opacity="0.9">
                <path d="m150 40 3.5 8 8 3.5-8 3.5-3.5 8-3.5-8-8-3.5 8-3.5z" />
                <path d="m320 18 2.6 6 6 2.6-6 2.6-2.6 6-2.6-6-6-2.6 6-2.6z" />
                <path d="m900 30 2.6 6 6 2.6-6 2.6-2.6 6-2.6-6-6-2.6 6-2.6z" />
                <path d="m1060 52 3.5 8 8 3.5-8 3.5-3.5 8-3.5-8-8-3.5 8-3.5z" />
              </g>

              <!-- back hill -->
              <path d="M0 160c160-70 330-80 520-30s420 50 680-20v110H0Z" fill="#7cc98f" />

              <!-- front hill -->
              <path d="M0 200c200-60 400-56 600-16s400 36 600-10v46H0Z" fill="#4da76c" />

              <!-- trees -->
              <g>
                <rect x="236" y="118" width="8" height="26" rx="3" fill="#8a5a3b" />
                <circle cx="240" cy="104" r="24" fill="#3e9159" />
                <rect x="948" y="128" width="7" height="22" rx="3" fill="#8a5a3b" />
                <circle cx="951.5" cy="116" r="19" fill="#57b374" />
              </g>

              <!-- little house -->
              <g>
                <rect x="1084" y="126" width="44" height="34" rx="4" fill="#fffdf7" />
                <path d="M1078 130l28-22 28 22z" fill="#e2574c" />
                <rect x="1098" y="142" width="14" height="18" rx="2" fill="#5b7cfa" />
              </g>
            </svg>
          {/snippet}
        </AssetSlot>
      </div>
    </div>
  </div>
</section>

<style>
  .banner {
    position: relative;
    background: var(--butter);
    border-radius: 28px;
    padding: clamp(44px, 6vw, 72px) clamp(24px, 4vw, 64px) clamp(96px, 11vw, 140px);
    text-align: center;
    overflow: hidden;
  }

  h2 {
    font-size: clamp(28px, 3.4vw, 42px);
    letter-spacing: -0.03em;
    color: var(--ink);
  }

  .sub {
    margin-top: 12px;
    font-weight: 600;
    color: rgba(19, 23, 34, 0.75);
  }

  .cta {
    margin-top: 24px;
    display: flex;
    justify-content: center;
  }

  .specs {
    margin-top: 16px;
    color: rgba(19, 23, 34, 0.55);
  }

  .scene {
    position: absolute;
    inset-inline: 0;
    bottom: -2px;
    line-height: 0;
    pointer-events: none;
  }
</style>
