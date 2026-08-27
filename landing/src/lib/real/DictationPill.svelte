<div class="pill-card">
  <div class="hero-col">
    <p class="hold">hold.</p>
    <p class="talk">talk.</p>
    <p class="done">done.</p>
  </div>
  <div class="shortcut-hint">
    <kbd>HOLD</kbd>
    <span class="shortcut-label">start speaking · release to capture</span>
  </div>
  <div class="focus-ring">
    <div class="ring r1"></div>
    <div class="ring r2"></div>
    <div class="ring r3"></div>
    <div class="mic-dot"></div>
  </div>
</div>

<style>
  .pill-card{
    position:relative;
    display:flex; flex-direction:column; align-items:center; justify-content:center;
    height:100%; min-height:200px; overflow:hidden;
    background:radial-gradient(ellipse at 50% 30%, rgba(110,232,154,.06) 0%, transparent 60%);
  }

  .hero-col{
    position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
    display:flex; flex-direction:column; align-items:center; gap:4px;
    z-index:2;
  }
  .hold,.talk,.done{
    font-family:'Bricolage Grotesque', 'Inter', system-ui, sans-serif;
    font-weight:800; line-height:1.02; letter-spacing:-.04em;
    text-align:center; color:#131722;
  }
  .hold{ font-size:clamp(28px,5vw,42px) }
  .talk{ font-size:clamp(28px,5vw,42px); color:#fc5681 }
  .done{ font-size:clamp(28px,5vw,42px) }

  .shortcut-hint{
    position:absolute; bottom:18px; left:50%; transform:translateX(-50%);
    display:flex; align-items:center; gap:8px;
    z-index:2;
  }
  kbd{
    display:inline-flex; align-items:center;
    padding:3px 9px; border-radius:5px;
    background:#131722; color:#fff;
    font-family:'JetBrains Mono', ui-monospace, monospace;
    font-size:10px; font-weight:600; letter-spacing:.12em;
    box-shadow:0 2px 6px rgba(19,23,34,.3), 0 6px 16px rgba(19,23,34,.18), inset 0 1px 0 rgba(255,255,255,.1);
  }
  .shortcut-label{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:10px; letter-spacing:.06em;
    text-transform:uppercase; color:rgba(19,23,34,.4);
  }

  .focus-ring{
    position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
    z-index:1;
  }
  .ring{
    position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
    border-radius:9999px; border:1px solid rgba(110,232,154,.12);
    animation:gentlePulse 4s ease-in-out infinite;
  }
  .r1{ width:120px; height:120px; animation-delay:0s }
  .r2{ width:180px; height:180px; animation-delay:.4s }
  .r3{ width:240px; height:240px; animation-delay:.8s }
  @keyframes gentlePulse{ 0%,100%{ opacity:.4; transform:translate(-50%,-50%) scale(1) } 50%{ opacity:.8; transform:translate(-50%,-50%) scale(1.02) } }

  .mic-dot{
    position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
    width:9px; height:9px; border-radius:99px;
    background:#131722; opacity:.6;
  }
</style>
