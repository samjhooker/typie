<script>
  import InlineEdit from './InlineEdit.svelte';

  let {
    onBack = () => {},
    title = 'Beta sync, Friday',
    date = 'August 22, 2026',
    kind = 'call',
  } = $props();

  const durationSec = 12 * 60 + 4;
  const speakerCount = 2;
  let query = $state('');
  let rate = $state(1);
  let playing = $state(false);
  let currentTime = $state(0); // start at the very beginning
  let tlEl = $state(null);
  let dragging = $state(false);

  const speakerNames = ['Maya', 'Sam'];
  const SP_COLORS = ['#fc5681', '#6f8ffb'];

  const turns = [
    {
      speaker: 0,
      name: 'Maya',
      time: '00:14',
      text: "alright, let's get started. everyone here?",
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '00:21',
      text: "yep, i'm here. screen's up.",
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '00:34',
      text: 'cool. so the launch is friday, two items left on the checklist.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '00:48',
      text: 'pricing page and the demo video, right?',
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '00:55',
      text: 'exactly. i can take the video this afternoon.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '01:08',
      text: "awesome. i'll handle the pricing page then.",
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '01:24',
      text: "let's sync at four to make sure everything's aligned.",
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '02:05',
      text: "sounds good. i'll also update the changelog before then.",
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '03:12',
      text: "great. anything else we're missing?",
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '03:40',
      text: 'just pricing, we need to decide on the tiers.',
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '04:58',
      text: 'free, plus, and team. i still like keeping the personal plan at zero.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '05:46',
      text: 'agreed. the whole point is it just works on your mac.',
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '06:30',
      text: 'and we should mention the 80ms thing in the video. people will feel it.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '07:22',
      text: "i'll put a hold-option shot right at the open.",
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '08:35',
      text: 'nice. i can grab b-roll of the notch listening too.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '09:50',
      text: 'cool. i will have pricing live before the four pm sync.',
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '10:40',
      text: "perfect. i think that's the whole list.",
    },
    { speaker: 1, name: 'Sam', time: '11:52', text: 'ship it.' },
  ];

  const aiSummary =
    'Aligned on launch plan. Two remaining items: pricing page (Sam) and demo video (Maya). Team sync at 4pm. Personal plan stays free; open on the 80ms hold-option moment.';

  const aiSections = [
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

  const aiQuotes = [
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
    { text: "i think that's the whole list", speaker: 'Maya', ts: '10:40' },
    { text: 'ship it', speaker: 'Sam', ts: '11:52' },
  ];

  function spColor(i) {
    return SP_COLORS[i % SP_COLORS.length];
  }

  function parseTs(ts) {
    const [m, s] = ts.split(':').map(Number);
    return m * 60 + s;
  }

  function fmtClock(sec) {
    const n = Math.max(0, Math.min(durationSec, Math.floor(sec)));
    return `${String(Math.floor(n / 60)).padStart(2, '0')}:${String(n % 60).padStart(2, '0')}`;
  }

  const playheadPct = $derived(
    Math.max(0, Math.min(100, (currentTime / durationSec) * 100))
  );

  const activeIdx = $derived.by(() => {
    let idx = -1;
    for (let i = 0; i < turns.length; i++) {
      if (parseTs(turns[i].time) <= currentTime) idx = i;
    }
    return idx;
  });

  // keep the currently-playing turn in view as the playhead advances,
  // but only when the transcript pane itself is on screen, otherwise
  // scrollIntoView would drag the whole page back to the hero demo
  let turnsEl = $state(null);
  $effect(() => {
    if (activeIdx < 0 || !turnsEl) return;
    const node = turnsEl.querySelector(`[data-idx="${activeIdx}"]`);
    if (!node) return;
    const r = turnsEl.getBoundingClientRect();
    if (r.bottom < 0 || r.top > window.innerHeight) return;
    node.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  });

  function timeFromEvent(e) {
    const el = tlEl;
    if (!el) return currentTime;
    const r = el.getBoundingClientRect();
    const x = Math.max(0, Math.min(1, (e.clientX - r.left) / r.width));
    return x * durationSec;
  }

  function onTlPointerDown(e) {
    dragging = true;
    playing = false;
    currentTime = timeFromEvent(e);
    e.currentTarget.setPointerCapture?.(e.pointerId);
  }
  function onTlPointerMove(e) {
    if (!dragging) return;
    currentTime = timeFromEvent(e);
  }
  function onTlPointerUp() {
    dragging = false;
  }

  $effect(() => {
    if (!playing) return;
    let last = performance.now();
    let raf = 0;
    const speed = 24 * (rate || 1); // ~12 min call in ~30s at 1×, faster at 1.5/2×
    const tick = (now) => {
      const dt = (now - last) / 1000;
      last = now;
      currentTime = Math.min(durationSec, currentTime + dt * speed);
      if (currentTime >= durationSec) {
        playing = false;
        return;
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  });

  // Auto-play a short stretch so the playhead is obviously alive, then let the user scrub
  $effect(() => {
    const t = setTimeout(() => {
      playing = true;
    }, 700);
    return () => clearTimeout(t);
  });
</script>

<div class="wrap">
  <div class="cols">
    <div class="content-col">
      <header class="sticky-head">
        <div class="titlerow">
          <button
            class="back-arrow"
            aria-label="back"
            onclick={onBack}>←</button
          >
          <div class="titleblock">
            <h2>
              <InlineEdit
                value={title}
                size="lg"
              />
            </h2>
            <p class="meta mono">
              {date} · {fmtClock(durationSec)} · {speakerCount} speakers · {kind ===
              'file'
                ? 'file'
                : 'call'}
            </p>
          </div>
          <div class="exports">
            <button class="btn btn-ghost small">↓ .md</button>
            <button class="btn btn-ghost small">↓ .txt</button>
          </div>
        </div>
      </header>

      <div class="filters">
        <label class="input search">
          <span class="search-icon">⌕</span>
          <input
            bind:value={query}
            placeholder="search this transcript…"
            spellcheck="false"
          />
        </label>

        <div class="legend">
          {#each speakerNames as name, i (name)}
            <span
              class="speaker pill"
              style="--c:{spColor(i)}"
            >
              <i></i>{name}
            </span>
          {/each}
        </div>
      </div>

      <div
        class="turns"
        bind:this={turnsEl}
      >
        {#each turns as turn, idx (idx)}
          <button
            class="oturn"
            class:now={idx === activeIdx}
            data-idx={idx}
            onclick={() => {
              currentTime = parseTs(turn.time);
              playing = false;
            }}
          >
            <div class="ohead">
              <span
                class="avatar"
                style="background:{spColor(turn.speaker)}">{turn.name[0]}</span
              >
              <span class="oname">{turn.name}</span>
              <span class="ts mono">{turn.time}</span>
              {#if idx === activeIdx}<span
                  class="eq"
                  aria-hidden="true"><i></i><i></i><i></i></span
                >{/if}
            </div>
            <p class="otext">{turn.text}</p>
          </button>
        {/each}
      </div>
    </div>

    <aside class="ai-rail">
      <div class="ai">
        <div class="ai-head">
          <span class="ai-badge">✦ on-device AI</span>
        </div>

        <h3 class="ai-title">{title}</h3>
        <p class="ai-summary">{aiSummary}</p>

        <h4 class="rail-kicker">breakdown</h4>
        {#each aiSections as section (section.ts)}
          <div class="ai-section">
            <button
              class="sec-head"
              onclick={() => {
                currentTime = parseTs(section.ts);
                playing = false;
              }}
            >
              <span class="sec-ts mono">{section.ts}</span>
              <span class="sec-title">{section.title}</span>
            </button>
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
          {#each aiQuotes as quote (quote.text)}
            <button
              class="quote"
              onclick={() => {
                currentTime = parseTs(quote.ts);
                playing = false;
              }}
            >
              <span class="q-text">"{quote.text}"</span>
              <span class="q-meta mono">{quote.speaker} · {quote.ts}</span>
            </button>
          {/each}
        </div>
      </div>
    </aside>
  </div>

  <div class="dock">
    <button
      class="play"
      onclick={() => (playing = !playing)}
      aria-label={playing ? 'pause' : 'play'}
    >
      {#if playing}❚❚{:else}▶{/if}
    </button>
    <span class="time mono now">{fmtClock(currentTime)}</span>

    <!-- svelte-ignore a11y_no_static_element_interactions -->
    <div
      class="tl"
      bind:this={tlEl}
      role="slider"
      aria-valuemin="0"
      aria-valuemax={durationSec}
      aria-valuenow={Math.floor(currentTime)}
      aria-label="call timeline"
      tabindex="0"
      onpointerdown={onTlPointerDown}
      onpointermove={onTlPointerMove}
      onpointerup={onTlPointerUp}
      onpointercancel={onTlPointerUp}
    >
      {#each turns as seg, i}
        {@const left = (parseTs(seg.time) / durationSec) * 100}
        {@const next =
          i < turns.length - 1 ? parseTs(turns[i + 1].time) : durationSec}
        {@const width = ((next - parseTs(seg.time)) / durationSec) * 100}
        <div
          class="seg"
          style="left:{left}%; width:{width}%; background:{spColor(
            seg.speaker
          )}"
        ></div>
      {/each}
      <div
        class="head"
        style="left:{playheadPct}%"
      >
        <i></i>
      </div>
    </div>

    <span class="time mono dim">{fmtClock(durationSec)}</span>
    <div class="rates">
      {#each [0.75, 1, 1.5, 2] as r}
        <button
          class="rate"
          class:on={rate === r}
          onclick={() => (rate = r)}>{r}×</button
        >
      {/each}
    </div>
  </div>
</div>

<style>
  .wrap {
    flex: 1;
    min-height: 0;
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background: var(--surface);
  }

  .cols {
    display: flex;
    flex-direction: row;
    flex: 1;
    min-height: 0;
    min-width: 0;
    overflow: hidden;
    align-items: stretch;
  }
  .content-col {
    min-width: 0;
    flex: 1;
    overflow-y: auto;
    overscroll-behavior: contain;
    padding: 18px 22px 16px;
    text-align: left;
  }

  .ai-rail {
    width: min(280px, 34%);
    flex-shrink: 0;
    align-self: stretch;
    max-height: 100%;
    background: var(--paper, var(--cream-100));
    border-left: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    padding: 18px 16px 24px;
    overflow-y: auto;
    overscroll-behavior: contain;
    text-align: left;
  }

  .sticky-head {
    position: sticky;
    top: 0;
    z-index: 4;
    margin: -18px -22px 12px;
    padding: 14px 22px 10px;
    background: var(--surface);
    border-bottom: 1px solid var(--line, rgba(3, 89, 77, 0.12));
  }

  .titlerow {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .back-arrow {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 28px;
    height: 28px;
    border-radius: 999px;
    color: var(--text-2);
    font-size: 16px;
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .back-arrow:hover {
    background: var(--wash);
    color: var(--ink);
  }
  .titleblock {
    flex: 1;
    min-width: 0;
    text-align: left;
  }
  h2 :global(.ie .txt) {
    white-space: normal;
  }
  h2 :global(.ie input) {
    font-size: 20px;
    font-weight: 800;
    letter-spacing: -0.02em;
  }
  .meta {
    margin-top: 3px;
    font-size: 11px;
  }
  .exports {
    display: flex;
    gap: 6px;
    flex-shrink: 0;
  }

  .filters {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
    margin-top: 2px;
  }
  .search {
    display: flex;
    align-items: center;
    gap: 7px;
    max-width: 420px;
    padding: 7px 14px;
    background: var(--cream, var(--cream-50));
    border: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    border-radius: 12px;
    font-size: 13px;
  }
  .search-icon {
    color: var(--text-3);
    flex-shrink: 0;
  }
  .search input {
    flex: 1;
    min-width: 0;
    border: none;
    outline: none;
    background: none;
    font: inherit;
    font-size: 13px;
    color: var(--ink);
  }

  .legend {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }
  .pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 999px;
    background: var(--paper, var(--cream-100));
    border: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    font-size: 12px;
    font-weight: 600;
    color: var(--ink);
  }
  .pill i {
    width: 9px;
    height: 9px;
    border-radius: 99px;
    background: var(--c);
    flex-shrink: 0;
  }

  .turns {
    margin-top: 18px;
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding-bottom: 8px;
  }

  .oturn {
    position: relative;
    padding: 9px 12px 10px;
    border-radius: 14px;
    border: 1px solid transparent;
    background: transparent;
    text-align: left;
    width: 100%;
    cursor: pointer;
    transition:
      background 0.2s var(--ease-out),
      border-color 0.2s ease;
  }
  .oturn:hover {
    background: var(--paper, var(--cream-100));
  }
  .oturn.now {
    background: rgba(252, 86, 129, 0.07);
    border-color: rgba(252, 86, 129, 0.18);
  }

  .ohead {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 4px;
  }
  .avatar {
    display: grid;
    place-items: center;
    width: 22px;
    height: 22px;
    border-radius: 99px;
    flex-shrink: 0;
    color: #fff;
    font-size: 10px;
    font-weight: 800;
  }
  .oname {
    font-size: 12.5px;
    font-weight: 700;
    color: var(--ink);
  }
  .ts {
    opacity: 0.55;
    letter-spacing: 0.05em;
    font-size: 10.5px;
  }
  .eq {
    display: inline-flex;
    align-items: flex-end;
    gap: 2px;
    height: 10px;
    margin-left: 4px;
  }
  .eq i {
    width: 2px;
    border-radius: 2px;
    background: var(--hotpink);
    height: 40%;
    animation: eq 0.7s ease-in-out infinite alternate;
  }
  .eq i:nth-child(2) {
    animation-delay: 0.15s;
    height: 90%;
  }
  .eq i:nth-child(3) {
    animation-delay: 0.3s;
    height: 60%;
  }
  @keyframes eq {
    to {
      height: 20%;
    }
  }

  .otext {
    font-size: 14px;
    line-height: 1.7;
    color: var(--text-1);
    overflow-wrap: anywhere;
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
    background: var(--ink);
    color: var(--cream-50);
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }
  .ai-title {
    font-size: 16px;
    margin: 6px 0 6px;
    color: var(--ink);
  }
  .ai-summary {
    font-size: 13px;
    line-height: 1.55;
    color: var(--text-1);
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
    width: 100%;
    text-align: left;
    padding: 6px 8px;
    border-radius: 9px;
    color: var(--hotpink);
    transition: background 0.15s var(--ease-out);
  }
  .sec-head:hover {
    background: rgba(252, 86, 129, 0.08);
  }
  .sec-ts {
    color: var(--text-3);
  }
  .sec-title {
    font-size: 13px;
    font-weight: 800;
    color: var(--ink);
  }
  .sec-points {
    list-style: none;
    margin: 2px 0 0;
    padding: 0 0 0 10px;
    border-left: 2px solid var(--line, rgba(3, 89, 77, 0.12));
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
    text-align: left;
    padding: 10px 12px;
    border-left: 3px solid var(--pink, var(--pink-100));
    border-radius: 0 10px 10px 0;
    background: rgba(252, 86, 129, 0.05);
    cursor: pointer;
    transition:
      background 0.15s var(--ease-out),
      transform 0.15s var(--spring);
  }
  .quote:hover {
    background: rgba(252, 86, 129, 0.1);
    transform: translateX(2px);
  }
  .q-text {
    font-size: 12px;
    line-height: 1.5;
    color: var(--ink);
    font-weight: 500;
  }
  .q-meta {
    color: var(--text-3);
  }

  .dock {
    flex-shrink: 0;
    padding: 10px 18px;
    display: flex;
    align-items: center;
    gap: 12px;
    background: var(--surface);
    border-top: 1px solid var(--line, rgba(3, 89, 77, 0.12));
    z-index: 6;
  }
  .play {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 36px;
    height: 36px;
    border-radius: 99px;
    background: var(--hotpink);
    color: #fff;
    box-shadow: 0 4px 12px rgba(252, 86, 129, 0.35);
    transition: transform 0.18s var(--spring);
    font-size: 14px;
  }
  .play:hover {
    transform: scale(1.07);
  }
  .play:active {
    transform: scale(0.96);
  }
  .time {
    white-space: nowrap;
    font-size: 11px;
  }
  .now {
    color: var(--ink);
    font-weight: 500;
  }
  .dim {
    color: var(--text-3);
  }

  .tl {
    position: relative;
    flex: 1;
    height: 14px;
    border-radius: 99px;
    background: rgba(3, 89, 77, 0.09);
    cursor: pointer;
    overflow: visible;
    touch-action: none;
  }
  .seg {
    position: absolute;
    top: 3px;
    bottom: 3px;
    border-radius: 99px;
    opacity: 0.75;
    pointer-events: none;
  }
  .head {
    position: absolute;
    top: -3px;
    bottom: -3px;
    width: 2.5px;
    background: var(--ink);
    border-radius: 2px;
    pointer-events: none;
    transform: translateX(-50%);
  }
  .head i {
    position: absolute;
    top: -1px;
    left: 50%;
    transform: translateX(-50%);
    width: 10px;
    height: 10px;
    border-radius: 99px;
    background: var(--ink);
    box-shadow: 0 0 0 3px rgba(19, 23, 34, 0.12);
  }
  .rates {
    display: flex;
    gap: 2px;
    flex-shrink: 0;
  }
  .rate {
    padding: 3px 8px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-3);
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .rate:hover {
    background: var(--wash);
    color: var(--ink);
  }
  .rate.on {
    background: var(--ink);
    color: #fff;
  }
</style>
