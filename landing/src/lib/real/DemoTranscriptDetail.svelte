<script>
  import InlineEdit from './InlineEdit.svelte'

  const title = 'Beta sync — Friday'
  const date = 'August 22, 2026'
  const duration = '12:04'
  const speakerCount = 2
  const isMeeting = true
  let query = $state('')
  let rate = $state(1)

  const speakerNames = ['Maya', 'Sam']
  const SP_COLORS = ['#fc5681', '#6f8ffb']

  const turns = [
    { speaker:0, name:'Maya', time:'02:14', text:'and the launch checklist is basically done?' },
    { speaker:1, name:'Sam', time:'02:18', text:'two items left. pricing page and the demo video.' },
    { speaker:0, name:'Maya', time:'02:24', text:'perfect. i can take the video this afternoon.' },
    { speaker:1, name:'Sam', time:'02:31', text:"awesome. i'll handle the pricing page then." },
    { speaker:0, name:'Maya', time:'02:38', text:"let's sync at 4 to make sure everything's aligned." },
    { speaker:1, name:'Sam', time:'02:44', text:"sounds good. i'll also update the changelog." },
    { speaker:0, name:'Maya', time:'02:51', text:"great. anything else we're missing?" },
    { speaker:1, name:'Sam', time:'02:56', text:'just the pricing — we need to decide on the tiers.' },
  ]

  const aiSummary = 'Aligned on launch plan. Two remaining items: pricing page (Sam) and demo video (Maya). Team sync at 4pm.'

  const aiSections = [
    { ts:'02:14', title:'Checklist review', points:['all items complete except pricing and video'] },
    { ts:'02:31', title:'Task assignment', points:['Sam handles pricing page', 'Maya records demo video'] },
    { ts:'02:38', title:'Alignment', points:['sync at 4pm', 'update changelog'] },
  ]

  const aiQuotes = [
    { text:'perfect. i can take the video', speaker:'Maya', ts:'02:24' },
    { text:'just the pricing — we need to decide on the tiers', speaker:'Sam', ts:'02:56' },
  ]

  function spColor(i){ return SP_COLORS[i % SP_COLORS.length] }

  let playing = $state(false)

  let { onBack = () => {} } = $props()
</script>

<div class="wrap">
  <div class="cols">
    <div class="content-col">
      <header class="sticky-head">
        <div class="titlerow">
          <button class="back-arrow" aria-label="back" onclick={onBack}>←</button>
          <div class="titleblock">
            <h2><InlineEdit value={title} size="lg" /></h2>
            <p class="meta mono">{date} · {duration} · {speakerCount} speakers · call</p>
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
          <input bind:value={query} placeholder="search this transcript…" spellcheck="false" />
        </label>

        <div class="legend">
          {#each speakerNames as name, i (name)}
            <span class="speaker pill" style="--c:{spColor(i)}">
              <i></i>{name}
            </span>
          {/each}
        </div>
      </div>

      <div class="turns">
        {#each turns as turn, idx (idx)}
          <div class="oturn">
            <div class="ohead">
              <span class="avatar" style="background:{spColor(turn.speaker)}">{turn.name[0]}</span>
              <span class="oname">{turn.name}</span>
              <span class="ts mono">{turn.time}</span>
            </div>
            <p class="otext">{turn.text}</p>
          </div>
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
            <button class="sec-head">
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
            <div class="quote">
              <span class="q-text">"{quote.text}"</span>
              <span class="q-meta mono">{quote.speaker} · {quote.ts}</span>
            </div>
          {/each}
        </div>
      </div>
    </aside>
  </div>

  <div class="dock">
    <button class="play" onclick={() => playing = !playing}>
      {#if playing}❚❚{:else}▶{/if}
    </button>
    <span class="time mono now">02:14</span>

    <div class="tl">
      {#each turns as seg, i}
        {@const left = (i / turns.length) * 100}
        {@const width = 100 / turns.length}
        <div class="seg" style="left:{left}%; width:{width}%; background:{spColor(seg.speaker)}"></div>
      {/each}
      <div class="head" style="left:45%"><i></i></div>
    </div>

    <span class="time mono dim">{duration}</span>
    <div class="rates">
      {#each [0.75, 1, 1.5, 2] as r}
        <button class="rate" class:on={rate === r} onclick={() => rate = r}>{r}×</button>
      {/each}
    </div>
  </div>
</div>

<style>
  .wrap{ padding:24px 32px 80px; max-width:880px; margin:0 auto; flex:1; min-height:100%; display:flex; flex-direction:column }

  .cols{ display:flex; flex-direction:column; flex:1; min-height:0 }
  .cols{ flex-direction:row; gap:0; align-items:stretch; flex:1; min-height:0; overflow:hidden; }
  .content-col{ min-width:0; flex:1; overflow-y:auto; overscroll-behavior:contain; padding:24px 32px 80px; }

  .ai-rail{
    position:relative; top:auto; right:auto; bottom:auto; z-index:5;
    width:340px; flex-shrink:0; align-self:stretch; max-height:100%;
    background:var(--paper);
    border-left:1px solid var(--line);
    padding:24px 20px 100px;
    overflow-y:auto; overscroll-behavior:contain;
  }

  .sticky-head{
    position:sticky; top:0; z-index:30;
    margin:-24px -32px 14px; padding:16px 32px 12px;
    background:#fff;
    backdrop-filter:blur(12px);
    border-bottom:1px solid var(--line);
  }

  .titlerow{ display:flex; align-items:center; gap:14px }
  .back-arrow{
    display:grid; place-items:center; flex-shrink:0;
    width:32px; height:32px; border-radius:999px;
    color:var(--text-2); font-size:18px;
    transition:background .15s var(--ease-out), color .15s var(--ease-out);
  }
  .back-arrow:hover{ background:rgba(19,23,34,.06); color:var(--ink) }
  .titleblock{ flex:1; min-width:0 }
  h2 :global(.ie .txt){ white-space:normal }
  h2 :global(.ie input){ font-size:22px; font-weight:800; letter-spacing:-.02em }
  .meta{ margin-top:4px }
  .exports{ display:flex; gap:8px; flex-shrink:0 }

  .filters{ display:flex; flex-direction:column; align-items:flex-start; gap:12px; margin-top:2px }
  .search{
    display:flex; align-items:center; gap:7px;
    max-width:420px; padding:8px 15px;
    background:var(--cream);
    border:1px solid var(--line); border-radius:12px;
    font-size:13px;
  }
  .search-icon{ color:rgba(19,23,34,.35); flex-shrink:0 }
  .search input{
    flex:1; min-width:0; border:none; outline:none; background:none;
    font:inherit; font-size:13px; color:var(--ink);
  }

  .legend{ display:flex; flex-wrap:wrap; gap:8px; margin-top:14px }
  .pill{
    display:inline-flex; align-items:center; gap:6px;
    padding:4px 12px; border-radius:999px;
    background:var(--paper); border:1px solid var(--line);
    font-size:12px; font-weight:600; color:var(--ink);
  }
  .pill i{ width:9px; height:9px; border-radius:99px; background:var(--c); flex-shrink:0 }

  .turns{ margin-top:26px; display:flex; flex-direction:column; gap:6px; padding-bottom:8px }

  .oturn{
    position:relative;
    padding:10px 14px 11px;
    border-radius:14px;
    border:1px solid transparent;
    transition:background .2s var(--ease-out);
  }
  .oturn:hover{ background:var(--paper) }

  .ohead{ display:flex; align-items:center; gap:9px; margin-bottom:5px }
  .avatar{
    display:grid; place-items:center;
    width:24px; height:24px; border-radius:99px; flex-shrink:0;
    color:#fff; font-size:11px; font-weight:800;
    letter-spacing:0;
  }
  .oname{ font-size:13px; font-weight:700; color:var(--ink) }
  .ts{ opacity:.55; letter-spacing:.05em }

  .otext{ font-size:15px; line-height:1.85; color:var(--text-1); user-select:text; overflow-wrap:anywhere }

  /* ── AI rail ── */
  .ai-head{ display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:8px }
  .ai-badge{ display:inline-flex; align-items:center; gap:6px; padding:4px 10px; border-radius:999px; background:var(--ink); color:#fffdf7; font-family:var(--mono); font-size:10px; letter-spacing:.08em; text-transform:uppercase }
  .ai-title{ font-size:18px; margin:6px 0 6px }
  .ai-summary{ font-size:13.5px; line-height:1.6; color:var(--text-1); user-select:text }

  .rail-kicker{
    font-family:var(--mono); font-size:9.5px; letter-spacing:.14em; text-transform:uppercase;
    color:var(--text-3); margin:14px 0 8px;
  }

  .ai-section{ margin-bottom:10px }
  .sec-head{
    display:flex; align-items:center; gap:7px; width:100%; text-align:left;
    padding:6px 9px; border-radius:9px;
    color:var(--hotpink);
    transition:background .15s var(--ease-out);
  }
  .sec-head:hover{ background:rgba(252,86,129,.08) }
  .sec-ts{ color:var(--text-3) }
  .sec-title{ font-size:13px; font-weight:800; color:var(--ink) }
  .sec-points{ list-style:none; margin:2px 0 0; padding:0 0 0 10px; border-left:2px solid var(--line); display:flex; flex-direction:column; gap:2px }
  .pt-text{ font-size:12px; line-height:1.5; color:var(--text-2) }

  .ai-quotes{ display:flex; flex-direction:column; gap:8px }
  .quote{
    display:flex; flex-direction:column; gap:5px; text-align:left;
    padding:10px 12px;
    border-left:3px solid var(--pink);
    border-radius:0 10px 10px 0;
    background:rgba(252,86,129,.05);
    transition:background .15s var(--ease-out), transform .15s var(--spring);
  }
  .quote:hover{ background:rgba(252,86,129,.1); transform:translateX(2px) }
  .q-text{ font-size:12px; line-height:1.5; color:var(--ink); font-weight:500 }
  .q-meta{ color:var(--text-3) }

  /* ── dock ── */
  .dock{
    position:sticky; bottom:0; z-index:5;
    margin-top:auto;
    margin-left:-32px; margin-right:-32px; margin-bottom:-80px;
    padding:11px 32px;
    display:flex; align-items:center; gap:13px;
    background:#fff;
    border-top:1px solid var(--line);
  }
  .play{
    display:grid; place-items:center; flex-shrink:0;
    width:42px; height:42px; border-radius:99px;
    background:var(--hotpink); color:#fff;
    box-shadow:0 4px 12px rgba(252,86,129,.35);
    transition:transform .18s var(--spring);
    font-size:16px;
  }
  .play:hover{ transform:scale(1.07) }
  .play:active{ transform:scale(.96) }
  .time{ white-space:nowrap }
  .now{ color:var(--ink); font-weight:500 }
  .dim{ color:var(--text-3) }

  .tl{
    position:relative; flex:1; height:14px; border-radius:99px;
    background:rgba(3,89,77,.09); cursor:pointer;
    overflow:hidden;
  }
  .tl::before{ content:''; position:absolute; inset:0 }
  .seg{
    position:absolute; top:3px; bottom:3px;
    border-radius:99px; opacity:.75;
  }
  .head{
    position:absolute; top:-2px; bottom:-2px; width:2.5px;
    background:var(--ink); border-radius:2px;
    pointer-events:none;
  }
  .head i{
    position:absolute; top:-1px; left:50%; transform:translateX(-50%);
    width:9px; height:9px; border-radius:99px;
    background:var(--ink);
  }
  .rates{ display:flex; gap:2px; flex-shrink:0 }
  .rate{
    padding:3px 8px; border-radius:999px;
    font-family:var(--mono); font-size:10px; color:var(--text-3);
    transition:background .15s var(--ease-out), color .15s var(--ease-out);
  }
  .rate:hover{ background:rgba(19,23,34,.06); color:var(--ink) }
  .rate.on{ background:var(--ink); color:#fff }
</style>
