<script>
  import Glyph from './Glyph.svelte'
  import Robot from './Robot.svelte'

  const notesCount = 12
  const transcriptCount = 8
  const transcriptMinutes = 47
  const meetingCount = 3
  const history = [
    'okay so the plan is we ship friday',
    'follow up email about the pricing page',
    "don't forget the demo at 3pm",
  ]
</script>

<div class="wrap">
  <header class="head">
    <h2>what are we typing today?</h2>
    <p><span class="hand hint-hand">the key is the app — everything below is just the filing cabinet</span></p>
  </header>

  <section class="hero card">
    <div class="hero-key">
      <span class="kbd">⌥</span>
      <span class="trig mono">hold to talk</span>
    </div>
    <h3>hold. talk. done.</h3>
    <p>says it wherever your cursor is — every app, zero cloud.</p>
  </section>

  <div class="grid">
    <section class="feat card vnotes">
      <div class="feat-head"><Glyph name="note" size={16} /><h4>quick note</h4></div>
      <p class="peek">"podcast idea — the voice is the interface, not the keyboard"</p>
      <div class="acts">
        <button class="btn btn-pink small">new note</button>
        <button class="btn btn-ghost small">{notesCount} on the wall →</button>
      </div>
    </section>

    <section class="feat card xcripts">
      <div class="feat-head"><Glyph name="transcript" size={16} /><h4>transcribe a file</h4></div>
      <p>{transcriptCount} files · {transcriptMinutes} min captured. <span class="hand inline-hand">like otter, but offline</span></p>
      <div class="acts">
        <button class="btn btn-ghost small">open library →</button>
      </div>
    </section>

    <section class="feat card recs">
      <div class="feat-head"><Glyph name="record" size={16} /><h4>call capture</h4></div>
      <p>{meetingCount} calls captured.</p>
      <div class="acts">
        <button class="btn small btn-mint">start capture</button>
        <button class="btn btn-ghost small">past calls →</button>
      </div>
    </section>
  </div>

  <div class="recent">
    <div class="bot">
      <Robot size={40} mood="idle" />
      <span class="hand botname">typie heard:</span>
    </div>
    <div class="bubbles">
      {#each history as text, i (i)}
        <div class="bubble" class:alt={i % 2 === 1}>{text}</div>
      {/each}
      <button class="more">3 things you've said →</button>
    </div>
  </div>

  <p class="privacy mono">● everything stays here — no cloud, ever.</p>
</div>

<style>
  .wrap{ padding:28px 32px 48px; max-width:1000px; margin:0 auto }

  .head{ margin-bottom:22px }
  .head h2{ font-size:27px }
  .hint-hand{ font-size:17px; color:var(--hotpink) }

  .hero{
    position:relative;
    padding:34px 36px;
    background:var(--pink-band);
    border-radius:var(--radius-card);
    display:flex; flex-direction:column; gap:10px;
    margin-bottom:16px;
  }
  .hero h3{
    font-size:clamp(30px, 4.5vw, 42px);
    letter-spacing:-.03em;
  }
  .hero p{ font-size:14.5px; color:var(--text-2); max-width:52ch }

  .hero-key{ display:flex; align-items:center; gap:12px; margin-bottom:2px; margin-top:26px }
  .kbd{
    font-family:var(--display); font-weight:800; font-size:26px;
    color:#fffdf7;
    padding:9px 22px;
    border-radius:13px;
    background:var(--ink);
    box-shadow:0 5px 0 rgba(11,31,27,.9);
  }
  .trig{ color:rgba(19,23,34,.55) }

  .grid{
    display:grid; grid-template-columns:repeat(3, 1fr); gap:14px;
  }
  @media(max-width:860px){ .grid{ grid-template-columns:1fr } }

  .feat{
    padding:18px 20px;
    border-radius:var(--radius-card);
    display:flex; flex-direction:column; gap:8px;
    transition:transform .25s var(--spring), box-shadow .25s var(--ease-out);
  }
  .feat:hover{ transform:translateY(-3px); box-shadow:0 12px 26px rgba(19,23,34,.09) }
  .feat-head{ display:flex; align-items:center; gap:8px; color:var(--ink) }
  .feat-head h4{ font-size:15px }
  .feat p{ font-size:12.5px; color:var(--text-2) }
  .peek{ font-style:italic }
  .inline-hand{ font-size:14px; color:var(--periwinkle); white-space:nowrap }

  .vnotes{ background:var(--card-cream) }
  .xcripts{ background:var(--card-blue) }
  .recs{ background:var(--card-mint) }

  .acts{ display:flex; align-items:center; gap:8px; margin-top:auto; padding-top:6px; flex-wrap:wrap }

  .btn-mint{
    background:var(--green-deep); color:#fffdf7;
    box-shadow:0 4px 12px rgba(2,69,60,.3);
  }
  .btn-mint:hover{ box-shadow:0 8px 18px rgba(2,69,60,.38) }

  .recent{
    margin-top:24px;
    padding:18px 20px;
    border-radius:var(--radius-card);
    border:1px solid var(--line);
    background:var(--paper);
    display:flex; align-items:flex-start; gap:16px;
  }
  .bot{
    display:flex; flex-direction:column; align-items:center; gap:2px;
    flex-shrink:0; width:56px;
  }
  .botname{ font-size:13px; color:var(--text-3) }

  .bubbles{
    flex:1; min-width:0;
    display:flex; flex-direction:column; gap:8px; align-items:flex-start;
  }
  .bubble{
    position:relative;
    max-width:85%;
    padding:7px 14px;
    background:#fffdf7;
    border:1px solid var(--line-strong);
    border-radius:14px 14px 14px 4px;
    box-shadow:0 2px 6px rgba(19,23,34,.05);
    font-size:12.5px; color:var(--text-1);
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    transform:rotate(-.4deg);
    transition:transform .22s var(--spring), box-shadow .22s var(--ease-out);
  }
  .bubble::before{
    content:''; position:absolute; left:-5.5px; bottom:7px;
    width:9px; height:9px;
    background:inherit;
    border-left:1px solid var(--line-strong);
    border-bottom:1px solid var(--line-strong);
    transform:rotate(45deg);
  }
  .bubble.alt{ transform:rotate(.45deg); background:var(--card-cream); border-radius:14px 14px 4px 14px }
  .bubble.alt::before{ left:auto; right:-5.5px; bottom:auto; top:7px; border:none; border-right:1px solid var(--line-strong); border-top:1px solid var(--line-strong); transform:rotate(45deg) }
  .bubble:hover{ transform:translateY(-2px) rotate(0deg); box-shadow:0 6px 14px rgba(19,23,34,.09) }
  .more{
    flex-shrink:0;
    display:inline-flex; align-items:center; gap:7px;
    padding:8px 15px; border-radius:999px;
    font-family:var(--mono); font-size:10.5px; letter-spacing:.06em; text-transform:uppercase;
    color:var(--hotpink);
    transition:background .18s var(--ease-out), transform .25s var(--spring);
  }
  .more:hover{ background:rgba(252,86,129,.09); transform:translateX(-2px) }

  .privacy{ margin-top:26px; color:var(--green-deep); opacity:.65 }
</style>
