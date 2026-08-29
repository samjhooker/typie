<script>
  // The ACTUAL AI-summary rail UI from the app (DemoTranscriptDetail's right
  // column) as a standalone panel: badge, summary, breakdown, key quotes.
  // No header, no dock — just the real thing, cropped like a Stripe snippet.
  const summary =
    'Aligned on launch plan. Two remaining items: pricing page (Sam) and demo video (Maya). Team sync at 4pm. Personal plan stays free; open on the 80ms hold-option moment.';

  const sections = [
    {
      ts: '00:14',
      title: 'Kickoff',
      points: ['launch is friday', 'two items left on the checklist'],
    },
    {
      ts: '01:08',
      title: 'Task assignment',
      points: ['Sam handles pricing page', 'Maya records demo video'],
    },
    {
      ts: '01:24',
      title: 'Alignment',
      points: ['sync at 4pm', 'update changelog'],
    },
    {
      ts: '03:40',
      title: 'Pricing',
      points: ['keep personal plan free', 'plus and team tiers still TBD'],
    },
    {
      ts: '06:30',
      title: 'Demo video',
      points: ['open on hold-option', 'b-roll of the notch listening'],
    },
  ];

  const quotes = [
    {
      text: 'i can take the video this afternoon',
      speaker: 'Maya',
      ts: '00:55',
    },
    {
      text: 'the whole point is it just works on your mac',
      speaker: 'Sam',
      ts: '05:46',
    },
    { text: 'ship it', speaker: 'Sam', ts: '11:52' },
  ];
</script>

<div
  class="ai"
  aria-hidden="true"
>
  <div class="ai-head">
    <span class="ai-badge">✦ on-device AI</span>
  </div>

  <h3 class="ai-title">Launch Sync</h3>
  <p class="ai-summary">{summary}</p>

  <h4 class="rail-kicker">breakdown</h4>
  {#each sections as section (section.ts)}
    <div class="ai-section">
      <span class="sec-head">
        <span class="sec-ts mono">{section.ts}</span>
        <span class="sec-title">{section.title}</span>
      </span>
      {#if section.points.length > 0}
        <ul class="sec-points">
          {#each section.points as point}
            <li><span class="pt-text">{point}</span></li>
          {/each}
        </ul>
      {/if}
    </div>
  {/each}

  <h4 class="rail-kicker">key quotes</h4>
  <div class="ai-quotes">
    {#each quotes as quote (quote.text)}
      <span class="quote">
        <span class="q-text">"{quote.text}"</span>
        <span class="q-meta mono">{quote.speaker} · {quote.ts}</span>
      </span>
    {/each}
  </div>
</div>

<style>
  .ai {
    display: flex;
    flex-direction: column;
    text-align: left;
    background: var(--cream-100); /* the app's real cream paper */
    padding: 20px 20px 26px;
    height: 100%;
  }
  .ai-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 8px;
  }
  .ai-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    border-radius: 999px;
    background: var(--ink-app);
    color: var(--cream-50);
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }
  .ai-title {
    font-size: 16px;
    margin: 6px 0 6px;
    color: var(--ink-app);
    font-weight: 800;
    letter-spacing: -0.01em;
  }
  .ai-summary {
    font-size: 13px;
    line-height: 1.55;
    color: var(--text-2);
  }

  .rail-kicker {
    font-family: var(--mono);
    font-size: 9.5px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--text-3);
    margin: 16px 0 8px;
  }

  .ai-section {
    margin-bottom: 10px;
  }
  .sec-head {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 6px 8px;
    border-radius: 9px;
  }
  .sec-ts {
    color: var(--text-3);
  }
  .sec-title {
    font-size: 13px;
    font-weight: 800;
    color: var(--hotpink);
  }
  .sec-points {
    list-style: none;
    margin: 2px 0 0;
    padding: 0 0 0 10px;
    border-left: 2px solid var(--line);
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .pt-text {
    font-size: 12px;
    line-height: 1.5;
    color: var(--text-2);
  }

  .ai-quotes {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .quote {
    display: flex;
    flex-direction: column;
    gap: 5px;
    padding: 10px 12px;
    border-radius: 10px;
    background: rgba(252, 86, 129, 0.05);
    border: 1px solid rgba(252, 86, 129, 0.14);
  }
  .q-text {
    font-size: 12px;
    line-height: 1.5;
    color: var(--ink-app);
    font-weight: 500;
  }
  .q-meta {
    color: var(--text-3);
    font-size: 10.5px;
  }
</style>
