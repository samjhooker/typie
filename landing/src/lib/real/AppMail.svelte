<script>
  /* full Mail UI — used inside the hero Mac; the reply composer receives the dictation */
  let { typed = '', listening = false } = $props()

  const mailboxes = [
    { name: 'Inbox', count: 3, on: true, icon: '▣' },
    { name: 'VIP', icon: '★' },
    { name: 'Flagged', icon: '◈' },
    { name: 'Sent', icon: '➤' },
    { name: 'Drafts', icon: '✎' },
    { name: 'Archive', icon: '◫' },
  ]

  const messages = [
    { from: 'Maya Chen', subj: 'Launch checklist — 2 items left', preview: 'Pricing page and the demo video are the only two left…', time: '9:41', on: true, unread: false },
    { from: 'Sam Baker', subj: 'Demo video: I can take it this afternoon', preview: 'perfect, I will handle the pricing page then…', time: '9:35', unread: true },
    { from: 'Design Team', subj: 'Hero section — looks unreal now', preview: 'the desktop demo is so good. shipping this…', time: '8:12', unread: true },
    { from: 'Finance', subj: 'Q3 numbers are final', preview: 'churn held flat at 2.1 percent. great quarter…', time: 'Yesterday', unread: true },
  ]

  const body = [
    "quick note before the demo — we're on track.",
    "Two items are left on the launch checklist:",
    "1. The pricing page (Sam is on it)",
    "2. The demo video (I can take it this afternoon)",
  ]
</script>

<div class="amail">
  <aside class="boxes">
    <div class="title-bar"><span class="ttl">Mailboxes</span></div>
    {#each mailboxes as mb}
      <div class="mbox" class:on={mb.on}>
        <span class="bi">{mb.icon}</span>
        <span class="bn">{mb.name}</span>
        {#if mb.count}<b class="cnt">{mb.count}</b>{/if}
      </div>
    {/each}
  </aside>

  <section class="mlist">
    <div class="search">⌕ Search in "Inbox"</div>
    {#each messages as m}
      <div class="mrow" class:on={m.on} class:unread={m.unread}>
        <div class="mfrom">{m.from}</div>
        <div class="msubj">{m.subj}</div>
        <p class="mprev">{m.preview}</p>
        <span class="mtime">{m.time}</span>
      </div>
    {/each}
  </section>

  <article class="reading">
    <div class="rhead">
      <button class="tool">Reply</button>
      <button class="tool">→</button>
      <button class="tool">🗑</button>
    </div>
    <h4>Launch checklist — 2 items left</h4>
    <p class="rfrom">From: <b>Maya Chen</b> &lt;maya@typie.cc&gt;</p>
    <p class="rto">To: Sam Baker, you</p>
    <div class="rbody">
      {#each body as para}
        <p>{para}</p>
      {/each}
    </div>
    <div class="reply" class:armed={listening || typed}>
      {#if typed}
        <p class="rtext">{typed}<span class="caret"></span></p>
      {:else}
        <p class="rph">{listening ? 'listening…' : 'click here to reply'}</p>
      {/if}
    </div>
  </article>
</div>

<style>
  .amail{
    display:grid; grid-template-columns:180px 240px 1fr; height:100%;
    background:#f5f5f7; font-family:'Inter',system-ui,sans-serif; color:#1c1c1e;
  }
  .boxes{ background:#e8e8ed; border-right:1px solid rgba(0,0,0,.08); padding:10px 8px; display:flex; flex-direction:column; gap:2px }
  .title-bar{ display:flex; align-items:center; justify-content:space-between; padding:2px 6px 8px }
  .ttl{ font-size:13px; font-weight:700 }
  .mbox{ display:flex; align-items:center; gap:7px; padding:6px 8px; border-radius:8px; font-size:12.5px }
  .mbox.on{ background:#0a84ff; color:#fff }
  .bi{ width:15px; text-align:center }
  .cnt{ margin-left:auto; background:rgba(120,120,128,.2); border-radius:99px; padding:0 7px; font-size:10px }
  .mbox.on .cnt{ background:rgba(255,255,255,.3) }

  .mlist{ background:#fff; border-right:1px solid rgba(0,0,0,.08); overflow:hidden }
  .search{ font-size:11px; color:#8e8e93; padding:9px 12px; border-bottom:1px solid rgba(0,0,0,.06) }
  .mrow{ position:relative; padding:8px 12px 6px; border-bottom:1px solid rgba(0,0,0,.05) }
  .mrow.on{ background:rgba(10,132,255,.12) }
  .mrow.unread .mfrom{ font-weight:700 }
  .mfrom{ font-size:12px }
  .msubj{ font-size:12px; font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
  .mprev{ font-size:11px; color:#8e8e93; white-space:nowrap; overflow:hidden; text-overflow:ellipsis }
  .mtime{ position:absolute; top:8px; right:12px; font-size:10px; color:#8e8e93 }

  .reading{ padding:10px 14px 8px; overflow:hidden; background:rgba(255,255,255,.6); display:flex; flex-direction:column; min-width:0 }
  .rhead{ display:flex; gap:6px; margin-bottom:12px }
  .tool{ font-size:12px; color:#0a84ff; background:#fff; border:1px solid rgba(0,0,0,.12); border-radius:7px; padding:4px 10px }
  .reading h4{ font-size:16px; font-weight:700; margin-bottom:2px }
  .rfrom{ font-size:12px; color:#3c3c43 }
  .rto{ font-size:11px; color:#8e8e93; margin:2px 0 10px }
  .rbody{ flex:1; overflow:hidden; font-size:12px; line-height:1.5; color:#1c1c1e; display:flex; flex-direction:column; gap:6px }

  .reply{
    flex:none; margin-top:8px;
    border:1px solid rgba(0,0,0,.13); border-radius:8px;
    background:#fff; padding:6px 10px; min-height:28px;
    transition:border-color .25s ease, box-shadow .25s ease;
  }
  .reply.armed{
    border-color:#0a84ff; box-shadow:0 0 0 3px rgba(10,132,255,.18);
    animation:flashIn .4s ease-out both;
  }
  @keyframes flashIn{
    0%{ box-shadow:0 0 0 0 rgba(10,132,255,.5) }
    60%{ box-shadow:0 0 0 4px rgba(10,132,255,.24) }
    100%{ box-shadow:0 0 0 3px rgba(10,132,255,.14) }
  }
  .rtext{ font-size:11.5px; line-height:1.4; color:#1c1c1e }
  .rph{ font-size:11.5px; color:#8e8e93; font-style:italic }
  .caret{ display:inline-block; width:2px; height:1em; margin-left:2px; vertical-align:-0.15em; background:#0a84ff; animation:blink .9s steps(1) infinite }
  @keyframes blink{ 50%{opacity:0} }

  @media (max-width:900px){
    .amail{ grid-template-columns:240px 1fr }
    .boxes{ display:none }
  }
  @media (max-width:560px){
    .amail{ grid-template-columns:1fr }
    .mlist{ display:none }
  }
</style>
