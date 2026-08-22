<script>
  import { reveal } from './reveal.js';
  import { chat } from './chat.svelte.js';
  import DownloadCta from './DownloadCta.svelte';

  const plans = [
    {
      name: 'Free',
      cls: 'card-paper',
      price: '$0',
      per: '/forever',
      was: null,
      badge: null,
      btnCls: 'btn-green',
      btnText: 'Download',
      feats: [
        'Unlimited offline transcription, forever',
        '<100 ms latency · 100% local · zero cloud',
        'No account. No email. No nothing.',
        'Every language (all 25 ↑)',
        'Every future update - also free'
      ]
    },
    {
      name: 'Pro',
      cls: 'card-hotpink',
      price: '$0',
      per: '/forever',
      was: '(was $0)',
      badge: 'most popular*',
      btnCls: 'btn-butter',
      btnText: 'Download (seriously)',
      feats: [
        'Everything in Free (which was already everything)',
        'Same app. Same speed. Same price: $0.',
        'A warm feeling of being a Pro user',
        'Priority support* (*also free, also a robot)'
      ]
    },
    {
      name: 'Enterprise',
      cls: 'card-paper',
      price: '$0',
      per: '/seat*',
      was: null,
      badge: null,
      btnCls: 'btn-green',
      btnText: 'Contact sales**',
      feats: [
        'Everything in Pro (still… everything)',
        'Unlimited seats × $0 = $0',
        'SSO - nobody asked, but sure, it\'s free',
        'A dedicated account robot who says "it\'s free"'
      ]
    }
  ];

  let shown = $state(['$…', '$…', '$…']);
  let timers = [];

  const starts = [84, 129, 999];

  function countDown() {
    starts.forEach((start, i) => {
      timers.push(setTimeout(() => {
        let v = start;
        const tick = () => {
          if (v <= 0) {
            shown[i] = '$0';
            return;
          }
          // fast collapse, then a comedic crawl to zero
          if (v > 40) {
            v = Math.round(v * 0.58) - Math.floor(Math.random() * 5);
          } else {
            v = Math.max(0, v - (3 + Math.floor(Math.random() * 9)));
          }
          shown[i] = `$${v}`;
          timers.push(setTimeout(tick, v > 40 ? 34 : 85));
        };
        tick();
      }, i * 220));
    });
  }

  function onView(node) {
    const io = new IntersectionObserver(
      ([e]) => {
        if (!e.isIntersecting) return;
        io.disconnect();
        if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
          shown = ['$0', '$0', '$0'];
          return;
        }
        countDown();
      },
      { threshold: 0.3 }
    );
    io.observe(node);
    return {
      destroy() {
        io.disconnect();
        timers.forEach(clearTimeout);
      }
    };
  }
</script>

<section class="pricing field field-lavender" id="pricing">
  <div class="container">
    <p class="kicker mono" use:reveal>· pricing ·</p>
    <h2 class="subhead" use:reveal={{ delay: 80 }}>
      Pick your plan.
    </h2>
    <p class="hand aside" use:reveal={{ delay: 120 }}>(they’re all the same)</p>
    <p class="mono sub" use:reveal={{ delay: 160 }}>free means free. we checked the dictionary.</p>

    <div class="grid" use:onView>
      {#each plans as plan, i}
        <article class="card {plan.cls}" use:reveal={{ delay: 150 }}>
          {#if plan.badge}
            <span class="badge">{plan.badge}</span>
          {/if}
          <span class="plan">{plan.name}</span>
          <div class="price-row">
            <span class="price">{shown[i]}</span>
            <span class="per">
              {plan.per}
              {#if plan.was}<s>{plan.was}</s>{/if}
            </span>
          </div>
          <ul>
            {#each plan.feats as f}
              <li>{f}</li>
            {/each}
          </ul>
          {#if plan.name === 'Enterprise'}
            <button class="btn {plan.btnCls} cta" onclick={() => chat.sales()}>{plan.btnText}</button>
          {:else}
            <DownloadCta label={plan.btnText} kind={plan.name === 'Pro' ? 'butter' : 'green'} class="cta" />
          {/if}
        </article>
      {/each}
    </div>

    <p class="fine mono" use:reveal={{ delay: 250 }}>
      *most popular by default. it tied with the other two.<br />
      **the sales team is one robot. he will tell you it’s free.
    </p>
  </div>
</section>

<style>
  .pricing {
    text-align: center;
  }

  .aside {
    font-size: clamp(16px, 2vw, 22px);
    color: var(--hotpink);
    transform: rotate(-3deg);
    margin-top: 10px;
  }

  .sub { margin-top: 14px; }

  .pricing :global(.mono),
  .pricing .mono {
    color: rgba(19, 23, 34, 0.55);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    align-items: stretch;
    max-width: 1100px;
    margin: 48px auto 0;
    text-align: left;
  }

  .card {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 16px;
    border-radius: var(--radius);
    padding: 34px 30px;
    transition: transform 0.3s var(--spring), box-shadow 0.3s ease;
  }

  .card:hover {
    transform: translateY(-6px);
  }

  .card-paper {
    background: var(--cream);
    color: var(--ink);
    border: 2px solid rgba(19, 23, 34, 0.12);
  }

  .card-hotpink {
    background: var(--hotpink);
    color: var(--cream);
    z-index: 2;
    box-shadow: 0 8px 0 rgba(19, 23, 34, 0.85);
  }

  .badge {
    position: absolute;
    top: -16px;
    left: 50%;
    transform: translateX(-50%) rotate(-4deg);
    background: var(--green-deep);
    color: var(--cream);
    font-family: var(--display);
    font-weight: 800;
    text-transform: uppercase;
    font-size: 11px;
    letter-spacing: 0.08em;
    padding: 8px 16px;
    border-radius: 999px;
    white-space: nowrap;
  }

  .plan {
    font-family: var(--display);
    font-weight: 800;
    text-transform: uppercase;
    font-size: 13px;
    letter-spacing: 0.14em;
    opacity: 0.85;
  }

  .price-row {
    display: flex;
    align-items: baseline;
    gap: 12px;
    position: relative;
  }

  .price {
    font-family: var(--display);
    font-weight: 900;
    font-size: clamp(56px, 6vw, 84px);
    line-height: 1;
    cursor: default;
  }

  .per {
    font-family: var(--mono);
    font-size: 12px;
    opacity: 0.8;
    display: flex;
    flex-direction: column;
    gap: 2px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 10px;
    font-size: 14.5px;
    line-height: 1.45;
  }

  li::before {
    content: '✓ ';
    font-weight: 700;
  }

  .card-paper li::before {
    color: var(--hotpink);
  }

  .card-hotpink li::before {
    color: var(--butter);
  }

  .cta {
    margin-top: auto;
    justify-content: center;
  }

  .fine {
    margin-top: 36px;
    font-size: 11.5px !important;
    line-height: 2;
  }

  @media (max-width: 900px) {
    .grid {
      grid-template-columns: 1fr;
      max-width: 460px;
    }
  }
</style>
