<script>
  import Glyph from './Glyph.svelte';
  import InlineEdit from './InlineEdit.svelte';
  import SortSeg from './SortSeg.svelte';

  const SORTS = [
    { id: 'newest', label: 'newest' },
    { id: 'oldest', label: 'oldest' },
    { id: 'longest', label: 'longest' },
  ];
  let sortBy = $state('newest');
  let query = $state('');

  const transcripts = [
    {
      id: 't1',
      fileName: 'Beta sync — Friday',
      date: 'today',
      durationSeconds: 724,
      speakerCount: 2,
      isMeeting: true,
      preview: 'and the checklist is done? two items — pricing and video',
      isNew: true,
    },
    {
      id: 't2',
      fileName: 'Quick voice note',
      date: 'today',
      durationSeconds: 5,
      speakerCount: 1,
      isMeeting: false,
      preview: "don't forget to ship the beta",
      isNew: true,
    },
    {
      id: 't3',
      fileName: 'Team standup',
      date: 'yesterday',
      durationSeconds: 512,
      speakerCount: 3,
      isMeeting: true,
      preview: 'weekly sync — action items and blockers',
      isNew: false,
    },
    {
      id: 't4',
      fileName: 'Customer interview — Maya',
      date: '2 days ago',
      durationSeconds: 1335,
      speakerCount: 2,
      isMeeting: true,
      preview: 'user research session about onboarding flow',
      isNew: false,
    },
    {
      id: 't5',
      fileName: 'Podcast recording draft',
      date: '3 days ago',
      durationSeconds: 2710,
      speakerCount: 2,
      isMeeting: false,
      preview: 'the voice is the interface — discussing the future of input',
      isNew: false,
    },
    {
      id: 't6',
      fileName: 'Recipe from grandma',
      date: '4 days ago',
      durationSeconds: 90,
      speakerCount: 1,
      isMeeting: false,
      preview: "grandma's secret — add miso, white pepper, and a pinch of sugar",
      isNew: false,
    },
  ];

  function fmtDur(s) {
    const n = Math.round(s || 0);
    return n > 0 ? `${Math.floor(n / 60)}m ${String(n % 60).padStart(2, '0')}s` : '';
  }

  let { onSelect = () => {} } = $props();
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Library</h2>
      <p>
        every conversation, saved forever. <span class="hand hint-hand"
          >nothing ever leaves this mac</span
        >
      </p>
    </div>
  </header>

  <div class="actions">
    <div class="dropzone">
      <div class="dz-head">
        <span class="ico"><Glyph name="transcript" size={17} /></span>
        <h3>drop anything</h3>
      </div>
      <p class="mono">mp3 · m4a · wav · mp4 — or click to browse</p>
      <span class="hand dz-hand">several at once is fine</span>
    </div>

    <div class="reccard">
      <div class="dz-head">
        <span class="ico call-ico"><Glyph name="record" size={15} /></span>
        <h3>capture a call</h3>
      </div>
      <p>
        saves the whole conversation offline — their side from your Mac's sound, yours mixed right
        in — then transcribes and splits the speakers.
      </p>
      <div class="acts">
        <button class="btn small btn-mint">start capture</button>
      </div>
      <span class="hand rec-hand">blip blip blip → full transcript</span>
    </div>
  </div>

  <div class="lib-head">
    <h3>All conversations <span class="count">{transcripts.length}</span></h3>
    <div class="lib-tools">
      <SortSeg options={SORTS} bind:value={sortBy} />
      <label class="input search">
        <span class="search-icon">⌕</span>
        <input bind:value={query} placeholder="search…" spellcheck="false" />
      </label>
    </div>
  </div>

  <div class="grid">
    {#each transcripts as item (item.id)}
      <button class="tcard card" onclick={onSelect}>
        <div class="top">
          <span class="ico" class:meeting={item.isMeeting}>
            <Glyph name={item.isMeeting ? 'record' : 'transcript'} size={15} />
          </span>
          <span class="chips">
            {#if item.isNew}
              <span class="chip new">new</span>
            {/if}
          </span>
        </div>
        <h4><InlineEdit value={item.fileName} /></h4>
        <p class="meta">
          {item.date}{item.durationSeconds > 1
            ? ` · ${fmtDur(item.durationSeconds)}`
            : ''}{item.speakerCount > 0 ? ` · ${item.speakerCount} spk` : ''}
        </p>
        <p class="peek">{item.preview}</p>
        <span class="acts">
          <span class="icon-btn" title="export markdown">↓</span>
          <span class="icon-btn" title="delete">🗑</span>
        </span>
      </button>
    {/each}
  </div>
</div>

<style>
  .wrap {
    padding: 28px 32px 40px;
    max-width: 1200px;
    margin: 0 auto;
  }

  .head {
    margin-bottom: 20px;
  }
  .head h2 {
    font-size: 26px;
  }
  .head p {
    font-size: 13px;
    color: var(--text-3);
    margin-top: 4px;
  }
  .hint-hand {
    font-size: 16px;
    color: var(--hotpink);
    margin-left: 8px;
  }

  .actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 22px;
  }
  @media (max-width: 900px) {
    .actions {
      grid-template-columns: 1fr;
    }
  }

  .dropzone {
    min-height: 170px;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
    gap: 8px;
    padding: 20px 24px;
    border: 2px dashed var(--line-strong);
    border-radius: 24px;
    background: var(--paper);
    cursor: pointer;
    transition:
      border-color 0.2s var(--ease-out),
      background 0.2s var(--ease-out),
      transform 0.2s var(--spring);
  }
  .dropzone:hover {
    border-color: var(--hotpink);
    background: rgba(252, 86, 129, 0.05);
    transform: scale(1.005);
  }
  .dz-head {
    display: flex;
    align-items: center;
    gap: 10px;
    width: 100%;
  }
  .dz-head h3 {
    font-size: 18px;
  }
  .ico {
    display: inline-grid;
    place-items: center;
    width: 34px;
    height: 34px;
    border-radius: 11px;
    background: var(--lavender);
    color: var(--violet-ink);
  }
  .call-ico {
    background: var(--pink);
    color: var(--hotpink);
  }
  .dropzone p {
    font-size: 11px;
  }
  .dz-hand {
    font-size: 15px;
    color: var(--text-3);
    transform: rotate(-1deg);
    display: inline-block;
  }

  .reccard {
    min-height: 170px;
    padding: 20px 24px;
    border-radius: 24px;
    background: linear-gradient(120deg, var(--cream) 45%, var(--card-mint));
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
    gap: 8px;
    transition: background 0.3s var(--ease-out);
  }
  .reccard p {
    font-size: 12.5px;
    color: var(--text-2);
    max-width: 52ch;
  }
  .acts {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .rec-hand {
    font-size: 15px;
    color: var(--mint-live);
    transform: rotate(-2deg);
    display: inline-block;
  }

  .btn-mint {
    background: var(--green-deep);
    color: #fffdf7;
    box-shadow: 0 4px 12px rgba(2, 69, 60, 0.3);
  }
  .btn-mint:hover {
    box-shadow: 0 8px 18px rgba(2, 69, 60, 0.38);
  }

  .lib-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
    margin: 6px 0 16px;
    flex-wrap: wrap;
  }
  .lib-head h3 {
    font-size: 17px;
  }
  .lib-tools {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .count {
    font-family: var(--mono);
    font-size: 11px;
    color: var(--text-3);
    vertical-align: 2px;
    margin-left: 4px;
  }
  .search {
    display: flex;
    align-items: center;
    gap: 7px;
    max-width: 260px;
    padding: 8px 15px;
    background: var(--cream);
    border: 1px solid var(--line);
    border-radius: 12px;
  }
  .search-icon {
    color: rgba(19, 23, 34, 0.35);
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

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 16px;
  }

  .tcard {
    position: relative;
    text-align: left;
    cursor: pointer;
    padding: 18px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    border-radius: var(--radius-card);
    transition:
      transform 0.2s var(--spring),
      box-shadow 0.2s var(--ease-out),
      border-color 0.2s var(--ease-out);
  }
  .tcard:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 24px rgba(19, 23, 34, 0.09);
    border-color: var(--line-strong);
  }
  .tcard .top {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .ico {
    display: inline-grid;
    place-items: center;
    width: 36px;
    height: 36px;
    border-radius: 12px;
    background: var(--lavender);
    color: var(--violet-ink);
  }
  .ico.meeting {
    background: var(--pink);
    color: var(--hotpink);
  }
  .chips {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .chip.new {
    background: var(--card-mint);
    color: var(--green-deep);
    font-weight: 700;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 11px;
  }

  .tcard h4 {
    font-size: 14.5px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .meta {
    font-family: var(--mono);
    font-size: 10.5px;
    letter-spacing: 0.04em;
    color: var(--text-3);
  }
  .peek {
    font-size: 12.5px;
    color: var(--text-3);
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .acts {
    position: absolute;
    top: 12px;
    right: 12px;
    display: flex;
    gap: 2px;
    opacity: 0;
    transition: opacity 0.18s var(--ease-out);
    background: var(--cream);
    border-radius: 9px;
  }
  .tcard:hover .acts,
  .tcard:focus-within .acts {
    opacity: 1;
  }
  .icon-btn {
    display: inline-grid;
    place-items: center;
    width: 26px;
    height: 26px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 12px;
    transition: background 0.15s var(--ease-out);
  }
  .icon-btn:hover {
    background: rgba(19, 23, 34, 0.07);
  }
</style>
