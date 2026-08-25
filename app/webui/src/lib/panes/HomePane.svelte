<script>
  import { ui, local, send } from '../bridge.svelte.js'
  import { MonitorUp, ArrowRight, Pencil, ShieldCheck } from 'lucide-svelte'
  import Glyph from '../Glyph.svelte'
  import Robot from '../Robot.svelte'

  const go = (pane) => () => { local.pane = pane }

  // ── live data for the little numbers ──
  const notes = $derived(ui.notes)
  const transcripts = $derived(ui.transcripts.filter(t => !t.isMeeting))
  const meetings = $derived(ui.transcripts.filter(t => t.isMeeting))
  const transcriptMinutes = $derived(
    Math.round(transcripts.reduce((a, t) => a + (t.durationSeconds || 0), 0) / 60)
  )
  const latest = $derived(ui.history.slice(0, 3))

  const phaseLabel = $derived.by(() => {
    switch (ui.dictation.phase) {
      case 'listening':    return { text:'listening…', cls:'live' }
      case 'transcribing': return { text:'transcribing…', cls:'think' }
      default:             return null
    }
  })

  // effective screen permission — respects OS + cached grant (avoids re-asking on nav)
  const hasScreen = $derived(ui.permissions.screen || local.askedScreenPermission)
</script>

<div class="wrap">
  <header class="head">
    <h2>what are we typing today?</h2>
    <p><span class="hand hint-hand">the key is the app — everything below is just the filing cabinet</span></p>
  </header>

  <!-- ── the main character: dictation ── -->
  <section class="hero card">
    <div class="hero-key">
      <span class="kbd">{ui.settings.hotkeyShort}</span>
      <span class="trig mono-kicker">
        {ui.settings.triggerMode === 'toggle' ? 'tap · talk · tap' : ui.settings.triggerMode === 'hold' ? 'hold to talk' : 'hold or tap'}
      </span>
    </div>
    <h3>hold. talk. done.</h3>
    <p>says it wherever your cursor is — every app, zero cloud.</p>
    {#if phaseLabel}
      <span class="livepill {phaseLabel.cls}"><i></i>{phaseLabel.text}</span>
    {/if}
  </section>

  <!-- ── secondary: notes · transcripts · recordings ── -->
  <div class="grid">
    <section class="feat card vnotes">
      <div class="feat-head"><Glyph name="note" size={16} /><h4>quick note</h4></div>
      {#if notes[0]}
        <p class="peek">“{notes[0].text.length > 80 ? notes[0].text.slice(0, 80) + '…' : notes[0].text}”</p>
      {:else}
        <p>speak and it sticks to the wall.</p>
      {/if}
      <div class="acts">
        <button class="btn btn-pink small" onclick={() => send({ type:'toggleNoteRecording' })}>
          <Pencil size={12} /> new note
        </button>
        <button class="btn btn-ghost small" onclick={go('notes')}>{notes.length} on the wall <ArrowRight size={11} /></button>
      </div>
    </section>

    <section class="feat card xcripts">
      <div class="feat-head"><Glyph name="transcript" size={16} /><h4>transcribe a file</h4></div>
      <p>
        {transcripts.length === 0
          ? 'audio or video in, speaker-labeled text out.'
          : `${transcripts.length} file${transcripts.length === 1 ? '' : 's'} · ${transcriptMinutes} min captured.`}
        <span class="hand inline-hand">like otter, but offline</span>
      </p>
      <div class="acts">
        <button class="btn btn-butter small" onclick={go('library')}>open library <ArrowRight size={11} /></button>
      </div>
    </section>

    <section class="feat card recs">
      <div class="feat-head"><Glyph name="record" size={16} /><h4>call capture</h4></div>
      <p>{meetings.length === 0 ? 'save the whole call offline — every voice, split by speaker.' : `${meetings.length} call${meetings.length === 1 ? '' : 's'} captured.`}</p>
      <div class="acts">
        <button
          class="btn small"
          class:btn-mint={!ui.meeting.isCapturing}
          class:btn-stop={ui.meeting.isCapturing}
          onclick={() => {
            if (!hasScreen) send({ type:'requestScreenPermission' })
            send({ type:'toggleMeetingRecording' })
            if (!ui.meeting.isCapturing) local.pane = 'library'
          }}
        >
          {#if !hasScreen}<ShieldCheck size={12} />{:else}<MonitorUp size={12} />{/if}
          {!hasScreen ? 'grant & record' : ui.meeting.isCapturing ? 'stop capture' : 'start capture'}
        </button>
        <button class="btn btn-ghost small" onclick={go('library')}>past calls <ArrowRight size={11} /></button>
      </div>
    </section>
  </div>

  <!-- ── tiny recent activity: the robot repeats what you said ── -->
  {#if ui.history.length > 0}
    <div class="recent">
      <div class="bot">
        <Robot size={40} mood={phaseLabel ? 'listening' : 'idle'} />
        <span class="hand botname">typie heard:</span>
      </div>
      <div class="bubbles">
        {#each latest as h, i (h.id)}
          <div class="bubble" class:alt={i % 2 === 1}>{h.text}</div>
        {/each}
        <button class="more" onclick={go('history')}>
          {ui.history.length} thing{ui.history.length === 1 ? '' : 's'} you've said <ArrowRight size={11} />
        </button>
      </div>
    </div>
  {/if}

  <p class="privacy mono-kicker">● everything stays here — no cloud, ever.</p>
</div>

<style>
  .wrap{ padding:28px 32px 48px; max-width:1000px; margin:0 auto }

  .head{ margin-bottom:22px }
  .head h2{ font-size:27px }
  .hint-hand{ font-size:17px; color:var(--hotpink) }

  /* ── hero: dictation is the main character ── */
  .hero{
    position:relative;
    padding:34px 36px;
    background:var(--pink-band);
    display:flex; flex-direction:column; gap:10px;
    margin-bottom:16px;
  }
  .hero h3{
    font-size:clamp(30px, 4.5vw, 42px);
    letter-spacing:-.03em;
  }
  .hero p{ font-size:14.5px; color:var(--text-2); max-width:52ch }

  .hero-key{ display:flex; align-items:center; gap:12px; margin-bottom:2px }
  .kbd{
    font-family:var(--display); font-weight:800; font-size:26px;
    color:#fffdf7;
    padding:9px 22px;
    border-radius:13px;
    background:var(--ink);
    box-shadow:0 5px 0 rgba(11,31,27,.9);
  }
  .trig{ color:rgba(19,23,34,.55) }

  .corner{
    position:absolute; right:20px; top:16px;
    font-size:16px; color:var(--hotpink);
    transform:rotate(-3deg);
  }

  .livepill{
    position:absolute; left:36px; top:20px;
    display:inline-flex; align-items:center; gap:7px;
    padding:5px 13px; border-radius:999px;
    font-family:var(--mono); font-size:10px; letter-spacing:.08em; text-transform:uppercase;
  }
  .hero-key{ margin-top:26px }
  .livepill i{ width:7px; height:7px; border-radius:99px; background:currentColor; animation:breathe 1.2s ease-in-out infinite }
  .livepill.live{ background:var(--ink); color:#ffd3e0 }
  .livepill.think{ background:var(--ink); color:var(--sky) }
  @keyframes breathe{ 50%{ opacity:.35 } }

  /* ── secondary cards ── */
  .grid{
    display:grid; grid-template-columns:repeat(3, 1fr); gap:14px;
  }
  @media(max-width:860px){ .grid{ grid-template-columns:1fr } }

  .feat{
    padding:18px 20px;
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

  /* ── recent activity: robot + speech bubbles ── */
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
