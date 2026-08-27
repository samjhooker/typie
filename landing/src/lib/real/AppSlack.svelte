<script>
  /* full Slack UI — used inside the hero Mac; receives the dictation replay */
  let { typed = '', listening = false } = $props()

  const channels = ['# general', '# launch', '# design', '# eng', '# deal-review']
  const dms = [
    { n: 'Maya Chen', c: '#36c5f0' },
    { n: 'Sam Baker', c: '#2eb67d' },
    { n: 'Alex', c: '#ecb22e' },
  ]
  const msgs = [
    { who: 'Maya', color: '#36c5f0', text: 'ok, who owns the Q3 close narrative?', time: '2h' },
    { who: 'Sam', color: '#2eb67d', text: 'i do — numbers are final, drafting now.', time: '1h' },
    { who: 'Maya', color: '#36c5f0', text: 'perfect. churn held flat at 2.1% right?', time: '55m' },
  ]
</script>

<div class="aslack">
  <aside class="rail">
    <div class="ws"><span class="wsic">↑</span><b>typie</b></div>
    <div class="grp">
      <p class="glabel">Channels</p>
      {#each channels as c, i}
        <div class="ci" class:on={i === 1}><span>{c}</span></div>
      {/each}
    </div>
    <div class="grp">
      <p class="glabel">Direct messages</p>
      {#each dms as d}
        <div class="ci"><span class="dot" style="background:{d.c}"></span><span>{d.n}</span></div>
      {/each}
    </div>
  </aside>

  <section class="pane">
    <header># launch<span class="chips">4 members</span></header>
    <div class="msgs">
      {#each msgs as m}
        <div class="m">
          <span class="av" style="background:{m.color}">{m.who[0]}</span>
          <div class="mbody">
            <p class="mhead"><b>{m.who}</b><span class="t">{m.time}</span></p>
            <p class="mtxt">{m.text}</p>
          </div>
        </div>
      {/each}
      {#if typed}
        <div class="m">
          <span class="av" style="background:#e01e5a">y</span>
          <div class="mbody">
            <p class="mhead"><b>you</b><span class="t">now</span></p>
            <p class="mtxt fresh">{typed}</p>
          </div>
        </div>
      {/if}
    </div>
    <div class="msginput" class:armed={listening || typed}>
      <span class="plus">+</span>
      {#if typed}
        <span class="field typed">{typed}<span class="caret"></span></span>
      {:else}
        <span class="field" class:dim={listening}>{listening ? 'listening…' : 'Message #launch'}</span>
      {/if}
      <span class="mic">🎙</span>
    </div>
  </section>
</div>

<style>
  .aslack{
    display:grid; grid-template-columns:220px 1fr; height:100%;
    background:#fff; font-family:'Inter',system-ui,sans-serif; color:#1d1c1d;
  }
  .rail{ background:#3f0e40; color:#d3c2c4; display:flex; flex-direction:column; overflow:hidden }
  .ws{ display:flex; align-items:center; gap:8px; padding:12px 14px; border-bottom:1px solid #522653; color:#fff }
  .wsic{ background:#fff; color:#3f0e40; width:22px; height:22px; border-radius:6px; display:grid; place-items:center; font-size:13px; font-weight:800 }
  .ws b{ font-size:14px }
  .grp{ padding:10px 8px 2px; display:flex; flex-direction:column; gap:1px }
  .glabel{ font-size:10px; letter-spacing:.08em; text-transform:uppercase; color:#9a7d9b; padding:2px 8px; margin-bottom:3px }
  .ci{ display:flex; align-items:center; gap:7px; padding:5px 8px; border-radius:6px; font-size:13px; color:#d3c2c4 }
  .ci.on{ background:#1164a3; color:#fff }
  .dot{ width:10px; height:10px; border-radius:50%; flex:none }

  .pane{ display:flex; flex-direction:column; min-width:0; height:100% }
  .pane header{
    display:flex; align-items:center; gap:8px;
    padding:10px 16px; border-bottom:1px solid rgba(29,28,29,.12);
    font-size:15px; font-weight:800; font-family:'Space Grotesk',sans-serif;
  }
  .chips{ font-size:11px; font-weight:500; color:#616061 }
  .msgs{ flex:1; overflow:hidden; padding:12px 16px; display:flex; flex-direction:column; gap:12px }
  .m{ display:flex; gap:10px }
  .av{ width:26px; height:26px; border-radius:6px; color:#fff; display:grid; place-items:center; font-size:11px; font-weight:800; flex:none }
  .mhead{ display:flex; align-items:baseline; gap:7px }
  .mhead b{ font-size:13px }
  .t{ font-size:11px; color:#9d9d9f }
  .mtxt{ font-size:13.5px; line-height:1.5; color:#1d1c1d }
  .fresh{ animation: msgIn .45s var(--spring, ease) both }
  @keyframes msgIn{
    0%{ opacity:0; transform:translateY(10px) scale(.92); filter:blur(1px) }
    40%{ opacity:1; transform:translateY(-2px) scale(1.02); filter:blur(0) }
    100%{ opacity:1; transform:none; filter:blur(0) }
  }

  .msginput{
    display:flex; align-items:center; gap:8px; margin:10px 16px 12px;
    border:1px solid rgba(29,28,29,.4); border-radius:8px; padding:5px 12px;
    transition:border-color .25s ease, box-shadow .25s ease;
  }
  .msginput.armed{
    border-color:#007a5a; box-shadow:0 0 0 3px rgba(0,122,90,.18);
    animation:flashIn .4s ease-out both;
  }
  @keyframes flashIn{
    0%{ box-shadow:0 0 0 0 rgba(0,122,90,.45) }
    60%{ box-shadow:0 0 0 4px rgba(0,122,90,.24) }
    100%{ box-shadow:0 0 0 3px rgba(0,122,90,.14) }
  }
  .plus{ color:#9d9d9f; font-size:15px }
  .field{ flex:1; min-width:0; font-size:12.5px; color:#9d9d9f; white-space:nowrap; overflow:hidden; position:relative }
  .field.typed{ color:#1d1c1d }
  .field.typed::after{
    content:'';
    position:absolute; inset:0;
    background:linear-gradient(90,.15em,.3em,transparent 0);
    background-size:1em 100%;
    background-repeat:no-repeat;
    animation:typeFlash .3s ease-out .2s both;
  }
  @keyframes typeFlash{
    0%{ background-position:0 0; opacity:.6 }
    100%{ background-position:100% 0; opacity:0 }
  }
  .field.dim{ color:#6d6d6f; font-style:italic }
  .caret{ display:inline-block; width:2px; height:1em; margin-left:2px; vertical-align:-0.15em; background:#007a5a; animation:blink .9s steps(1) infinite }
  @keyframes blink{ 50%{opacity:0} }
  .mic{ font-size:12.5px }

  @media (max-width:640px){
    .aslack{ grid-template-columns:1fr }
    .rail{ display:none }
  }
</style>
