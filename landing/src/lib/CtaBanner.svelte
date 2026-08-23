<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import DownloadCta from './DownloadCta.svelte';

  const SAME = [
    'Fully offline',
    'Unlimited usage',
    'No account, no card'
  ];

  const plans = [
    {
      name: 'Free',
      price: '$0',
      period: 'forever',
      blurb: 'Everything Typie can do. Forever.',
      popular: false,
      cta: 'download',
      label: 'Get Typie'
    },
    {
      name: 'Pro',
      price: '$0',
      period: 'also forever',
      blurb: 'The exact same as Free. We added a badge.',
      popular: true,
      cta: 'download',
      label: 'Get Pro'
    }
  ];
</script>

<section class="ctaband field" id="pricing">
  <div class="container">
    <div class="banner" use:reveal>
      <div class="copy">
        <p class="hand kicker">pricing, sort of</p>
        <h2>Your voice. Anywhere.</h2>
        <p class="sub">Two plans. One price. It’s $0.</p>
      </div>

      <div class="plans">
        {#each plans as p}
          <article class="plan" class:popular={p.popular}>
            {#if p.popular}
              <span class="badge">Most popular</span>
            {/if}
            <h3>{p.name}</h3>
            <p class="price">{p.price}<small>/{p.period}</small></p>
            <p class="blurb">{p.blurb}</p>
            <ul>
              {#each SAME as f}
                <li><span>✓</span>{f}</li>
              {/each}
            </ul>
            <DownloadCta kind={p.popular ? 'butter' : 'ghost'} label={p.label} />
          </article>
        {/each}
      </div>

      <p class="specs mono">macOS 14+ · Apple Silicon · still $0</p>

      <div class="scene" aria-hidden="true">
        <AssetSlot id="cta-scene" width="100%">
          {#snippet fallback()}
            <svg viewBox="0 0 1200 200" preserveAspectRatio="xMidYMax slice">
              <defs>
                <clipPath id="cta-tl"><rect x="-40" y="-36" width="40" height="80" /></clipPath>
                <clipPath id="cta-tr"><rect x="-40" y="-36" width="40" height="80" /></clipPath>
              </defs>

              <!-- left hills, back to front -->
              <path d="M0 200V78c28-18 72-8 118 22 40 26 78 70 128 100H0Z" fill="#8fd49a" />
              <path d="M0 200V128c70-38 150-28 238 8 48 20 92 40 148 64H0Z" fill="#c5e6b8" />
              <path d="M0 200V118c38-28 88-24 128 10 22 20 44 48 78 72H0Z" fill="#4eae6e" />
              <path d="M0 200V148c48-36 110-28 168 12 28 20 54 28 86 40H0Z" fill="#3e9a5c" />

              <!-- right hills -->
              <path d="M1200 200V128c-70-42-150-28-230 10-40 20-78 40-130 62h360Z" fill="#c5e6b8" />
              <path d="M1200 200V150c-50-32-110-22-168 8-32 16-62 28-98 42h266Z" fill="#7ec98c" />
              <path d="M1200 200V158c-42-24-96-16-148 14-22 14-44 22-70 28h218Z" fill="#3e9a5c" />

              <!-- left tree -->
              <g transform="translate(248 86)">
                <path d="M1 86V38M1 50l-11-20M1 46l12-18" fill="none" stroke="#8a5a32" stroke-width="3.4" stroke-linecap="round" />
                <g>
                  <ellipse cx="-8" cy="10" rx="20" ry="18" fill="#8fc86e" />
                  <ellipse cx="10" cy="8" rx="18" ry="17" fill="#8fc86e" />
                  <ellipse cx="1" cy="-6" rx="16" ry="15" fill="#8fc86e" />
                  <ellipse cx="-2" cy="18" rx="15" ry="13" fill="#8fc86e" />
                </g>
                <g clip-path="url(#cta-tl)">
                  <ellipse cx="-8" cy="10" rx="20" ry="18" fill="#5aa34c" />
                  <ellipse cx="10" cy="8" rx="18" ry="17" fill="#5aa34c" />
                  <ellipse cx="1" cy="-6" rx="16" ry="15" fill="#5aa34c" />
                  <ellipse cx="-2" cy="18" rx="15" ry="13" fill="#5aa34c" />
                </g>
              </g>

              <!-- right tree -->
              <g transform="translate(968 100)">
                <path d="M0 72V32M0 44l-10-18M0 40l11-16" fill="none" stroke="#8a5a32" stroke-width="3" stroke-linecap="round" />
                <g>
                  <ellipse cx="-7" cy="8" rx="17" ry="16" fill="#9ed48a" />
                  <ellipse cx="9" cy="7" rx="16" ry="15" fill="#9ed48a" />
                  <ellipse cx="1" cy="-5" rx="14" ry="13" fill="#9ed48a" />
                </g>
                <g clip-path="url(#cta-tr)">
                  <ellipse cx="-7" cy="8" rx="17" ry="16" fill="#6bb25c" />
                  <ellipse cx="9" cy="7" rx="16" ry="15" fill="#6bb25c" />
                  <ellipse cx="1" cy="-5" rx="14" ry="13" fill="#6bb25c" />
                </g>
              </g>

              <!-- house -->
              <g transform="translate(1048 86)">
                <path d="M34 36l22 8v32l-22-7Z" fill="#3d54d0" />
                <path d="M6 36h28v32H6Z" fill="#5470f5" />
                <path d="M22 8l36 28-22 8L6 36Z" fill="#e24a3c" />
                <path d="M6 36l16-28 12 6-16 22Z" fill="#ef5b4a" />
                <g stroke="#c43b30" stroke-width="1.2" fill="none">
                  <path d="M12 30l24 10" />
                  <path d="M16 24l24 10" />
                  <path d="M20 18l22 9" />
                </g>
                <rect x="42" y="10" width="7" height="12" rx="1" fill="#d44538" />
                <path d="M16 48c0-5 4-9 8-9s8 4 8 9v20H16Z" fill="#2c3f9e" />
                <path d="M20 44c0-3 2.4-5 4-5s4 2 4 5v6h-8Z" fill="#f3e4b0" />
                <rect x="42" y="44" width="6" height="6" rx="1" fill="#f3e4b0" />
                <rect x="42" y="54" width="6" height="6" rx="1" fill="#f3e4b0" />
              </g>
            </svg>
          {/snippet}
        </AssetSlot>
      </div>
    </div>
  </div>
</section>

<style>
  .ctaband {
    padding-top: clamp(28px, 4vh, 48px);
    padding-bottom: clamp(40px, 6vh, 64px);
  }

  .banner {
    position: relative;
    background: var(--butter);
    border-radius: 28px;
    padding: clamp(36px, 5vw, 56px) clamp(20px, 3.5vw, 48px) clamp(150px, 18vw, 210px);
    overflow: hidden;
  }

  .copy {
    text-align: center;
    margin-bottom: clamp(32px, 4.5vw, 48px);
  }

  .kicker {
    font-size: clamp(20px, 2vw, 24px);
    color: var(--ink);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  h2 {
    font-size: clamp(28px, 3.4vw, 42px);
    letter-spacing: -0.03em;
    color: var(--ink);
  }

  .sub {
    margin-top: 10px;
    font-weight: 600;
    color: rgba(19, 23, 34, 0.72);
  }

  .plans {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
    align-items: stretch;
    position: relative;
    z-index: 1;
    max-width: 760px;
    margin-inline: auto;
  }

  .plan {
    background: #fffdf7;
    border-radius: 22px;
    padding: 28px 22px 24px;
    display: flex;
    flex-direction: column;
    text-align: left;
    box-shadow: 0 8px 24px rgba(19, 23, 34, 0.08);
    position: relative;
  }

  .plan.popular {
    background: var(--ink);
    color: #fffdf7;
    transform: translateY(-10px);
  }

  .badge {
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--hotpink);
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 5px 12px;
    border-radius: 999px;
    white-space: nowrap;
  }

  h3 {
    font-size: 15px;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    margin-bottom: 8px;
  }

  .popular h3 {
    color: var(--butter);
  }

  .price {
    font-family: var(--display);
    font-size: clamp(40px, 4vw, 52px);
    font-weight: 800;
    letter-spacing: -0.04em;
    line-height: 1;
  }

  .price small {
    display: inline-block;
    margin-left: 6px;
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0;
    color: rgba(19, 23, 34, 0.5);
    vertical-align: 8px;
  }

  .popular .price small {
    color: rgba(255, 253, 247, 0.55);
  }

  .blurb {
    margin: 10px 0 18px;
    font-size: 14px;
    line-height: 1.45;
    color: rgba(19, 23, 34, 0.68);
    min-height: 2.9em;
  }

  .popular .blurb {
    color: rgba(255, 253, 247, 0.75);
  }

  ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 22px;
    flex: 1;
  }

  li {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    font-size: 14px;
    font-weight: 500;
  }

  li span {
    color: var(--hotpink);
    font-weight: 800;
    line-height: 1.2;
  }

  .plan :global(.btn) {
    width: 100%;
  }

  .specs {
    margin-top: 22px;
    text-align: center;
    color: rgba(19, 23, 34, 0.55);
    position: relative;
    z-index: 1;
  }

  .scene {
    position: absolute;
    inset-inline: 0;
    bottom: -1px;
    line-height: 0;
    pointer-events: none;
    z-index: 0;
  }

  .scene :global(img) {
    width: 100%;
    height: auto;
    display: block;
  }

  @media (max-width: 860px) {
    .plans {
      grid-template-columns: 1fr;
      max-width: 400px;
      margin-inline: auto;
    }

    .plan.popular {
      transform: none;
    }
  }
</style>
