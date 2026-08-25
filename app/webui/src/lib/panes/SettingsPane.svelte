<script>
  import { ui, send } from '../bridge.svelte.js'
  import Keycap from '../Keycap.svelte'
  import TriggerPicker from '../TriggerPicker.svelte'
  import Toggle from '../Toggle.svelte'
  import { FolderOpen, Mic, History, Rocket, Lock, AudioLines } from 'lucide-svelte'

  function fmtBytes(b){
    if (!b) return '0 mb'
    const gb = b / 1024 ** 3
    return gb >= 1 ? `${gb.toFixed(1)} gb` : `${Math.round(b / 1024 ** 2)} mb`
  }
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Settings</h2>
      <p>a few switches, no account, no cloud. <span class="hand hint-hand">set it and forget it</span></p>
    </div>
  </header>

  <!-- dictation -->
  <section class="card">
    <h3><span class="ico" style="background:var(--pink); color:var(--hotpink)"><Mic size={15} /></span> dictation</h3>
    <div class="keyblock">
      <Keycap />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>trigger style</strong>
        <span>how your key behaves when you press it</span>
      </div>
      <TriggerPicker />
    </div>
    <div class="row">
      <div class="rowtxt">
        <History size={14} />
        <strong>save history</strong>
        <span>keep past dictations in the history pane</span>
      </div>
      <Toggle setting="historyEnabled" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <Rocket size={14} />
        <strong>launch at login</strong>
        <span>typie waits in the menu bar from boot</span>
      </div>
      <Toggle setting="launchAtLogin" />
    </div>
  </section>

  <!-- audio -->
  <section class="card">
    <h3><span class="ico" style="background:var(--lavender); color:var(--violet-ink)"><AudioLines size={15} /></span> audio</h3>
    <div class="row">
      <div class="rowtxt">
        <strong>keep voice note audio</strong>
        <span>store the raw wav alongside each note (uses more disk)</span>
      </div>
      <Toggle setting="notesKeepAudio" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>mix mic into meetings</strong>
        <span>record your voice too, not just the call</span>
      </div>
      <Toggle setting="meetingMixMic" />
    </div>
    <div class="row">
      <div class="rowtxt">
        <strong>save transcript audio</strong>
        <span>keep recordings so you can scrub transcripts word-by-word</span>
      </div>
      <Toggle setting="transcriptsKeepAudio" />
    </div>
  </section>

  <!-- storage -->
  <section class="card">
    <h3><span class="ico" style="background:var(--card-mint); color:var(--green-deep)"><FolderOpen size={15} /></span> storage</h3>
    <div class="row">
      <div class="rowtxt">
        <strong>{fmtBytes(ui.storage.usedBytes)} used</strong>
        <span>notes, transcripts and models, all under typie's folder</span>
      </div>
      <button class="btn btn-ghost small" onclick={() => send({ type:'revealStorage' })}>
        <FolderOpen size={13} /> reveal in finder
      </button>
    </div>
  </section>

  <!-- privacy -->
  <section class="card privacy">
    <h3><span class="ico" style="background:var(--mint); color:var(--green-deep)"><Lock size={15} /></span> privacy</h3>
    <p class="pledge">
      audio goes mic → model → garbage collector. nothing is uploaded, ever.
      delete the app and nothing remains. that's not a policy — it's the architecture.
    </p>
  </section>
</div>

<style>
  .wrap{ padding:28px 32px 48px; max-width:760px; margin:0 auto }

  .head{ margin-bottom:22px }
  .head h2{ font-size:26px }
  .head p{ font-size:13px; color:var(--text-3); margin-top:4px }
  .hint-hand{ font-size:16px; color:var(--mint-live); margin-left:8px }

  section{ padding:22px 24px; margin-bottom:16px; display:flex; flex-direction:column; gap:18px }

  h3{ display:flex; align-items:center; gap:10px; font-size:14px; letter-spacing:-.01em }
  .ico{
    display:inline-grid; place-items:center;
    width:28px; height:28px; border-radius:9px; flex-shrink:0;
  }

  .keyblock{
    padding:16px;
    background:var(--paper);
    border-radius:16px;
    border:1px solid var(--line);
  }

  .row{
    display:flex; align-items:center; justify-content:space-between; gap:20px;
  }
  .rowtxt{
    display:flex; align-items:center; gap:8px; flex-wrap:wrap;
    font-size:13.5px; color:var(--ink);
  }
  .rowtxt strong{ font-weight:700 }
  .rowtxt span{
    flex-basis:100%; font-size:11.5px; color:var(--text-3); margin-left:22px;
  }
  .rowtxt svg{ color:var(--text-3); flex-shrink:0 }

  .privacy{ background:var(--card-mint); border-color:transparent }
  .pledge{ font-size:13.5px; line-height:1.65; color:var(--green-deep) }
</style>
