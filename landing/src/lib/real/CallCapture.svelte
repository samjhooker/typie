<script>
  const dots = Array.from({ length: 12 })
</script>

<div class="call-card">
  <div class="call-inner">
    <div class="waveform">
      {#each dots as _, i}
        <span class="bar" style="animation-delay:{i * 120}ms"></span>
      {/each}
    </div>
    <p class="label">Call active</p>
    <p class="sublabel">Transcribing in real-time…</p>
  </div>
</div>

<style>
  .call-card{
    height:100%; display:flex; align-items:center; justify-content:center;
    background:linear-gradient(135deg, rgba(252,86,129,.04) 0%, rgba(111,143,251,.04) 100%);
  }
  .call-inner{ display:flex; flex-direction:column; align-items:center; gap:16px }

  .waveform{ display:flex; align-items:center; gap:3px; height:32px }
  .bar{
    width:3px; border-radius:99px;
    background:linear-gradient(to top, #fc5681, #6f8ffb);
    animation:wave 1.2s ease-in-out infinite;
  }
  .bar:nth-child(1),.bar:nth-child(12){ height:8px }
  .bar:nth-child(2),.bar:nth-child(11){ height:12px }
  .bar:nth-child(3),.bar:nth-child(10){ height:16px }
  .bar:nth-child(4),.bar:nth-child(9){ height:20px }
  .bar:nth-child(5),.bar:nth-child(8){ height:24px }
  .bar:nth-child(6),.bar:nth-child(7){ height:28px }

  @keyframes wave{
    0%,100%{ transform:scaleY(1) }
    50%{ transform:scaleY(.5) }
  }

  .label{
    font-family:'Bricolage Grotesque', 'Inter', system-ui, sans-serif;
    font-weight:700; font-size:14px; color:#131722;
  }
  .sublabel{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:10px; letter-spacing:.06em; text-transform:uppercase;
    color:rgba(19,23,34,.4);
  }
</style>
