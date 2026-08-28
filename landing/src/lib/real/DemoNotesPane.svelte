<script>
  import SortSeg from './SortSeg.svelte'

  /* optional note appended by landing demos (the fresh one that just landed) */
  let { extra = null } = $props()

  const SORTS = [
    { id:'newest', label:'newest' },
    { id:'oldest', label:'oldest' },
  ]
  let sortBy = $state('newest')
  let query = $state('')

  const baseNotes = [
    { id:'1', text:'podcast idea — the voice is the interface, not the keyboard', pinned:true, date:'today', dur:'12s' },
    { id:'2', text:'standup — we ship friday, two things left: pricing and video', pinned:false, date:'yesterday', dur:'8s' },
    { id:'3', text:"grandma's recipe — add miso, trust me, white pepper too", pinned:false, date:'2 days ago', dur:'21s' },
    { id:'4', text:'follow up with Maya on pricing page before the demo', pinned:true, date:'3 days ago', dur:'14s' },
    { id:'5', text:"don't forget: hold option, don't click the mic icon", pinned:false, date:'today', dur:'5s' },
    { id:'6', text:'idea — offline is a feature, not a fallback', pinned:false, date:'today', dur:'9s' },
  ]

  const notes = $derived(extra ? [extra, ...baseNotes] : baseNotes)

  const tints = [
    { bg:'var(--card-cream)',  pin:'var(--sun)' },
    { bg:'var(--card-lavender)', pin:'var(--purple)' },
    { bg:'var(--card-mint)',   pin:'var(--mint-live)' },
    { bg:'var(--pink-band)',   pin:'var(--hotpink)' },
    { bg:'var(--card-blue)',   pin:'var(--periwinkle)' },
  ]
  const rots = ['-0.7deg', '0.5deg', '-0.4deg', '0.8deg', '-0.9deg', '0.3deg']

  function look(id){
    let h = 0
    for (const c of id) h = (h * 31 + c.charCodeAt(0)) >>> 0
    return { tint: tints[h % tints.length], rot: rots[h % rots.length] }
  }
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Notes</h2>
      <p>voice notes — captured, pinned, searchable <span class="hand hint-hand">your pocket for thoughts</span></p>
    </div>
    <div class="tools">
      <SortSeg options={SORTS} bind:value={sortBy} />
      <label class="input search">
        <span class="search-icon">⌕</span>
        <input bind:value={query} placeholder="search notes…" spellcheck="false" />
      </label>
    </div>
  </header>

  <div class="wall">
    {#each notes as note (note.id)}
      {@const { tint, rot } = look(note.id)}
      <article class="sticky" class:fresh={extra && note.id === extra.id} style="background:{tint.bg}; rotate:{rot}" class:pinned={note.pinned}>
        <p class="txt">{note.text}</p>
        <footer>
          <span class="meta">{note.date} · {note.dur}</span>
          <span class="acts">
            <button class="icon-btn" title="copy">📋</button>
            <button class="icon-btn" title={note.pinned ? 'unpin' : 'pin'}>{note.pinned ? '📌' : '📍'}</button>
            <button class="icon-btn" title="delete">🗑</button>
          </span>
        </footer>
        {#if note.pinned}
          <span class="pin" style="background:{tint.pin}"></span>
        {/if}
      </article>
    {/each}
  </div>

  <p class="privacy mono">● everything stays on this mac — no cloud.</p>
</div>

<style>
  .wrap{ padding:28px 32px 40px; max-width:1200px; margin:0 auto }

  .head{ display:flex; align-items:flex-end; justify-content:space-between; gap:16px; margin-bottom:22px; flex-wrap:wrap }
  .head h2{ font-size:26px }
  .head p{ font-size:13px; color:var(--text-3); margin-top:4px }
  .hint-hand{ font-size:16px; color:var(--hotpink); margin-left:8px }
  .tools{ display:flex; align-items:center; gap:10px; flex-wrap:wrap }
  .search{
    display:flex; align-items:center; gap:7px;
    max-width:230px; padding:8px 15px;
    background:var(--cream);
    border:1px solid var(--line); border-radius:12px;
    font-size:13px;
  }
  .search-icon{ color:rgba(19,23,34,.35); flex-shrink:0 }
  .search input{
    flex:1; min-width:0; border:none; outline:none; background:none;
    font:inherit; font-size:13px; color:var(--ink);
  }

  .wall{
    display:grid; grid-template-columns:repeat(auto-fill, minmax(240px, 1fr));
    gap:18px; align-items:start;
  }
  .sticky{
    position:relative;
    padding:18px 18px 12px;
    border-radius:4px 18px 6px 20px;
    box-shadow:0 3px 12px rgba(19,23,34,.08);
    display:flex; flex-direction:column; gap:14px; min-height:150px;
    transition:transform .22s var(--spring), box-shadow .22s var(--ease-out);
    cursor:pointer;
  }
  .sticky:hover{ transform:translateY(-3px) rotate(0deg)!important; box-shadow:0 10px 22px rgba(19,23,34,.13) }
  /* fresh note that just landed — always at top-left, physically springs in so you SEE it arrive */
  .sticky.fresh{
    order: -1;
    animation: landIn .62s cubic-bezier(.16,1,.3,1) both;
    box-shadow: 0 10px 28px rgba(252,86,129,.14), 0 3px 12px rgba(19,23,34,.10);
    border: 1.5px solid rgba(252,86,129,.22);
  }
  @keyframes landIn{
    0%{ opacity:0; transform:translateY(28px) scale(.82) rotate(-5deg); filter: blur(2px); }
    50%{ opacity:1; transform:translateY(-4px) scale(1.02) rotate(1.5deg); filter: blur(0); }
    100%{ opacity:1; transform:none; filter: blur(0); }
  }
  .sticky.pinned{ outline:2px solid rgba(19,23,34,.08) }

  .pin{
    position:absolute; top:-7px; left:50%; transform:translateX(-50%);
    width:14px; height:14px; border-radius:99px;
    box-shadow:0 2px 4px rgba(19,23,34,.25), inset 0 -2px 3px rgba(255,255,255,.4);
  }

  .txt{
    flex:1; white-space:pre-wrap; word-break:break-word;
    color:var(--ink); font-size:14px; line-height:1.55;
  }

  footer{ display:flex; align-items:center; justify-content:space-between }
  .meta{ font-family:var(--mono); font-size:10px; letter-spacing:.05em; text-transform:uppercase; color:rgba(19,23,34,.45) }
  .acts{ display:flex; gap:2px; opacity:0; transition:opacity .18s var(--ease-out) }
  .sticky:hover .acts, .sticky:focus-within .acts{ opacity:1 }
  .icon-btn{
    display:inline-grid; place-items:center;
    width:26px; height:26px; border-radius:8px;
    cursor:pointer; font-size:12px;
    transition:background .15s var(--ease-out);
  }
  .icon-btn:hover{ background:rgba(19,23,34,.07) }

  .privacy{ margin-top:26px; color:var(--green-deep); opacity:.65 }
</style>
