<script>
  /* Microsoft Outlook UI — used inside the hero Mac; the reply composer receives the dictation */
  let { typed = '', listening = false, pasted = false } = $props();

  const folders = [
    { name: 'Inbox', icon: '📥', on: true, count: 3 },
    { name: 'Focused', icon: '✦' },
    { name: 'Other', icon: '◷' },
    { name: 'Sent', icon: '➤' },
    { name: 'Drafts', icon: '✎' },
    { name: 'Archive', icon: '◫' },
    { name: 'Junk', icon: '⊘' },
  ];

  const messages = [
    {
      from: 'Maya Chen',
      subj: 'Launch checklist — 2 items left',
      preview: 'Pricing page and the demo video are the only two left…',
      time: '9:41',
      on: true,
      unread: false,
    },
    {
      from: 'Sam Baker',
      subj: 'Demo video: I can take it this afternoon',
      preview: 'perfect, I will handle the pricing page then…',
      time: '9:35',
      unread: true,
    },
    {
      from: 'Design Team',
      subj: 'Hero section — looks unreal now',
      preview: 'the desktop demo is so good. shipping this…',
      time: '8:12',
      unread: true,
    },
    {
      from: 'Finance',
      subj: 'Q3 numbers are final',
      preview: 'churn held flat at 2.1 percent. great quarter…',
      time: 'Yesterday',
      unread: true,
    },
  ];

  const body = [
    "quick note before the demo — we're on track.",
    'Two items are left on the launch checklist:',
    '1. The pricing page (Sam is on it)',
    '2. The demo video (I can take it this afternoon)',
  ];
</script>

<div class="aout">
  <!-- Outlook blue sidebar -->
  <aside class="side">
    <button class="newbtn">
      <span class="plus">+</span>
      New mail
    </button>
    <div class="acct">
      <span class="acct-ic">✉</span>
      <div class="acct-meta">
        <b>typie.cc</b>
        <span>Maya Chen</span>
      </div>
    </div>
    <div class="folders">
      {#each folders as f}
        <div
          class="frow"
          class:on={f.on}
        >
          <span class="fic">{f.icon}</span>
          <span class="fn">{f.name}</span>
          {#if f.count}<b class="fc">{f.count}</b>{/if}
        </div>
      {/each}
    </div>
  </aside>

  <!-- message list -->
  <section class="mlist">
    <div class="mlhead">
      <span class="mlh-title">Inbox</span>
      <span class="mlh-filters">
        <span class="filt on">Focused</span>
        <span class="filt">Other</span>
      </span>
    </div>
    <div class="search">
      <span class="si">⌕</span><span>Search mail and people</span>
    </div>
    {#each messages as m}
      <div
        class="mrow"
        class:on={m.on}
        class:unread={m.unread}
      >
        <span
          class="flag"
          class:on={!m.unread}
        ></span>
        <div class="mfrom">
          <b>{m.from}</b><span class="mtime">{m.time}</span>
        </div>
        <div class="msubj">{m.subj}</div>
        <p class="mprev">{m.preview}</p>
      </div>
    {/each}
  </section>

  <!-- reading pane -->
  <article class="reading">
    <div class="rhead">
      <button class="tool primary">Reply</button>
      <button class="tool">Reply all</button>
      <button class="tool">Forward</button>
      <span class="rspace"></span>
      <button class="tool icon">🗑</button>
      <button class="tool icon">⚑</button>
    </div>
    <h4>Launch checklist — 2 items left</h4>
    <div class="rmeta">
      <span class="rav">M</span>
      <div>
        <p class="rfrom"><b>Maya Chen</b> &lt;maya@typie.cc&gt;</p>
        <p class="rto">To: Sam Baker, you</p>
      </div>
      <span class="rtime mono">9:41 AM</span>
    </div>
    <div class="rbody">
      {#each body as para}
        <p>{para}</p>
      {/each}
    </div>
    <div
      class="reply"
      class:armed={listening || typed}
      class:pasted
    >
      {#if typed}
        <p class="rtext pop">{typed}<span class="caret"></span></p>
      {:else}
        <p class="rph">{listening ? 'listening…' : 'Type a reply'}</p>
      {/if}
    </div>
  </article>
</div>

<style>
  .aout {
    display: grid;
    grid-template-columns: 168px 244px 1fr;
    height: 100%;
    background: var(--surface);
    font-family: 'Inter', system-ui, sans-serif;
    color: #323130;
  }

  /* sidebar — true Outlook blue (not Teams green) */
  .side {
    background: #0f6cbd;
    color: #fff;
    padding: 12px 10px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    overflow: hidden;
  }
  .newbtn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 9px 12px;
    background: #0078d4;
    border-radius: 6px;
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
  }
  .newbtn .plus {
    font-size: 16px;
    line-height: 1;
  }
  .acct {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 0 4px;
  }
  .acct-ic {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: #0078d4;
    display: grid;
    place-items: center;
    font-size: 14px;
  }
  .acct-meta b {
    display: block;
    font-size: 12.5px;
    font-weight: 600;
  }
  .acct-meta span {
    font-size: 11px;
    opacity: 0.78;
  }
  .folders {
    display: flex;
    flex-direction: column;
    gap: 1px;
  }
  .frow {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 7px 10px;
    border-radius: 4px;
    font-size: 12.5px;
    color: #fff;
  }
  .frow.on {
    background: rgba(255, 255, 255, 0.16);
  }
  .fic {
    width: 16px;
    text-align: center;
    font-size: 12px;
  }
  .fc {
    margin-left: auto;
    background: rgba(255, 255, 255, 0.22);
    border-radius: 99px;
    padding: 0 7px;
    font-size: 10px;
  }

  /* message list */
  .mlist {
    background: #faf9f8;
    border-right: 1px solid #edebe9;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  .mlhead {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 14px 8px;
  }
  .mlh-title {
    font-size: 15px;
    font-weight: 600;
    color: #201f1e;
  }
  .mlh-filters {
    display: flex;
    gap: 12px;
  }
  .filt {
    font-size: 12.5px;
    color: #605e5c;
    padding-bottom: 4px;
  }
  .filt.on {
    color: #0f6cbd;
    border-bottom: 2px solid #0f6cbd;
    font-weight: 600;
  }
  .search {
    display: flex;
    align-items: center;
    gap: 7px;
    background: var(--surface);
    border: 1px solid #edebe9;
    border-radius: 4px;
    padding: 6px 10px;
    margin: 0 14px 6px;
    font-size: 12px;
    color: #605e5c;
  }
  .mrow {
    position: relative;
    padding: 9px 14px 8px 10px;
    border-bottom: 1px solid #edebe9;
    display: grid;
    grid-template-columns: 6px 1fr;
    gap: 8px;
  }
  .mrow.on {
    background: rgba(15, 108, 189, 0.08);
    box-shadow: inset 4px 0 0 #0f6cbd;
  }
  .flag {
    align-self: start;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #0f6cbd;
    margin-top: 3px;
  }
  .flag:not(.on) {
    background: transparent;
    border: 1px solid #c8c6c4;
  }
  .mfrom {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 6px;
  }
  .mfrom b {
    font-size: 12.5px;
    font-weight: 400;
    color: #201f1e;
  }
  .mrow.unread .mfrom b {
    font-weight: 700;
  }
  .mtime {
    font-size: 11px;
    color: #605e5c;
  }
  .msubj {
    font-size: 12.5px;
    font-weight: 600;
    color: #201f1e;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .mrow.unread .msubj {
    font-weight: 700;
  }
  .mprev {
    font-size: 12px;
    color: #605e5c;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  /* reading pane */
  .reading {
    padding: 14px 18px 12px;
    overflow: hidden;
    background: var(--surface);
    display: flex;
    flex-direction: column;
    min-width: 0;
  }
  .rhead {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 16px;
    flex-wrap: wrap;
  }
  .rspace {
    flex: 1;
  }
  .tool {
    font-size: 12.5px;
    color: #201f1e;
    background: #faf9f8;
    border: 1px solid #edebe9;
    border-radius: 4px;
    padding: 6px 12px;
    cursor: pointer;
  }
  .tool.primary {
    background: #0f6cbd;
    color: #fff;
    border-color: #0f6cbd;
  }
  .tool.icon {
    padding: 6px 8px;
  }
  .reading h4 {
    font-size: 19px;
    font-weight: 600;
    color: #201f1e;
    margin-bottom: 14px;
  }
  .rmeta {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 14px;
  }
  .rav {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: linear-gradient(135deg, #0078d4, #0f6cbd);
    color: #fff;
    display: grid;
    place-items: center;
    font-size: 14px;
    font-weight: 700;
    flex: none;
  }
  .rfrom {
    font-size: 12.5px;
    color: #323130;
  }
  .rto {
    font-size: 11.5px;
    color: #605e5c;
    margin-top: 2px;
  }
  .rtime {
    margin-left: auto;
    font-size: 11.5px;
    color: #605e5c;
  }
  .rbody {
    flex: 1;
    overflow: hidden;
    font-size: 13px;
    line-height: 1.6;
    color: #201f1e;
    display: flex;
    flex-direction: column;
    gap: 7px;
  }

  .reply {
    flex: none;
    margin-top: 10px;
    border: 1px solid #edebe9;
    border-top: 2px solid #0f6cbd;
    border-radius: 6px 6px 4px 4px;
    background: #faf9f8;
    padding: 10px 12px;
    min-height: 50px;
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .reply.armed {
    border-color: #0f6cbd;
    box-shadow: 0 0 0 3px rgba(15, 108, 189, 0.18);
    animation: flashIn 0.4s ease-out both;
  }
  .reply.pasted {
    border-color: #0f6cbd;
    animation: pasteField 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes flashIn {
    0% {
      box-shadow: 0 0 0 0 rgba(15, 108, 189, 0.5);
    }
    60% {
      box-shadow: 0 0 0 4px rgba(15, 108, 189, 0.24);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(15, 108, 189, 0.14);
    }
  }
  @keyframes pasteField {
    0% {
      box-shadow: 0 0 0 0 rgba(15, 108, 189, 0.55);
      background: rgba(15, 108, 189, 0.16);
    }
    40% {
      box-shadow: 0 0 0 6px rgba(15, 108, 189, 0.22);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(15, 108, 189, 0.16);
      background: #faf9f8;
    }
  }
  .rtext {
    font-size: 13px;
    line-height: 1.5;
    color: #201f1e;
  }
  .rtext.pop {
    animation: pastePop 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
    border-radius: 4px;
  }
  @keyframes pastePop {
    0% {
      background: rgba(15, 108, 189, 0.22);
      transform: scale(0.96);
    }
    45% {
      background: rgba(15, 108, 189, 0.12);
      transform: scale(1.02);
    }
    100% {
      background: transparent;
      transform: none;
    }
  }
  .rph {
    font-size: 13px;
    color: #605e5c;
    font-style: italic;
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #0f6cbd;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }

  @media (max-width: 980px) {
    .aout {
      grid-template-columns: 244px 1fr;
    }
    .side {
      display: none;
    }
  }
  @media (max-width: 560px) {
    .aout {
      grid-template-columns: 1fr;
    }
    .mlist {
      display: none;
    }
  }

  /* ── Outlook dark mode (Fluent dark: #1f1f1f surfaces, #f3f2f1 text) ──
     real Outlook dark: everything near-black — blue is reserved for the
     top bar, selected rows, and accents */
  :global([data-theme='dark']) .aout {
    background: #1f1f1f;
    color: #f3f2f1;
  }
  :global([data-theme='dark']) .side {
    background: #1b1a19;
    color: #f3f2f1;
    border-right: 1px solid #323130;
  }
  :global([data-theme='dark']) .frow.on {
    background: #0f6cbd; /* selected folder = blue, like the real app */
    color: #fff;
  }
  :global([data-theme='dark']) .mlist {
    background: #1b1a19;
    border-right-color: #323130;
  }
  :global([data-theme='dark']) .mlh-title,
  :global([data-theme='dark']) .mfrom b,
  :global([data-theme='dark']) .msubj,
  :global([data-theme='dark']) .reading h4,
  :global([data-theme='dark']) .rfrom,
  :global([data-theme='dark']) .rbody {
    color: #f3f2f1;
  }
  :global([data-theme='dark']) .filt,
  :global([data-theme='dark']) .mtime,
  :global([data-theme='dark']) .mprev,
  :global([data-theme='dark']) .rto,
  :global([data-theme='dark']) .rtime {
    color: #a19f9d;
  }
  :global([data-theme='dark']) .search {
    background: #323130;
    border-color: #3b3a39;
    color: #a19f9d;
  }
  :global([data-theme='dark']) .mrow {
    border-bottom-color: #292827;
  }
  :global([data-theme='dark']) .mrow.on {
    background: rgba(15, 108, 189, 0.18);
  }
  :global([data-theme='dark']) .flag:not(.on) {
    border-color: #605e5c;
  }
  :global([data-theme='dark']) .reading {
    background: #1f1f1f;
  }
  :global([data-theme='dark']) .tool {
    background: #323130;
    border-color: #3b3a39;
    color: #f3f2f1;
  }
  :global([data-theme='dark']) .reply {
    background: #292827;
    border-color: #3b3a39;
  }
</style>
