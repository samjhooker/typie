<script>
  const items = [
    { time:'14:22', text:'and the checklist is done?', isCall:true, spk:2, dur:'12m' },
    { time:'14:08', text:'quick voice note — don\'t forget to ship', isCall:false },
    { time:'09:42', text:'okay so the plan is we ship the beta friday — two items left', isCall:false, lat:'42ms' },
    { time:'09:40', text:'follow up email to send after the call', isCall:false, lat:'38ms' },
    { time:'Yesterday', text:'recipe note — grandma said add white pepper', isCall:false, lat:'51ms' },
  ]
</script>

<div class="lib">
  <div class="libhead">
    <div class="search-bar">
      <span class="search-icon">⌕</span>
      <span class="search-text">Search dictations…</span>
    </div>
    <span class="count">80 items</span>
  </div>
  <div class="rows">
    {#each items as item}
      <div class="row" class:call={item.isCall}>
        <span class="time">{item.time}</span>
        <p class="text">{item.text}</p>
        {#if item.isCall}
          <span class="chip">{item.spk} spk · {item.dur}</span>
        {:else if item.lat}
          <span class="lat">{item.lat}</span>
        {/if}
      </div>
    {/each}
  </div>
</div>

<style>
  .lib{ display:flex; flex-direction:column; gap:10px }
  .libhead{
    display:flex; justify-content:space-between; align-items:center;
    padding:10px 14px; background:#fbfbfa;
    border:1px solid rgba(3,89,77,.12); border-radius:12px;
  }
  .search-bar{ display:flex; align-items:center; gap:7px; font-size:13px }
  .search-icon{ color:rgba(19,23,34,.35) }
  .search-text{ color:rgba(19,23,34,.4) }
  .count{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:11px; color:rgba(19,23,34,.4);
  }

  .rows{ display:flex; flex-direction:column; gap:8px }

  .row{
    display:flex; gap:12px; align-items:center;
    padding:11px 14px;
    border:1px solid rgba(3,89,77,.08); border-radius:12px;
    background:#fff;
    transition:border-color .15s ease, transform .15s var(--spring, ease);
    cursor:pointer;
  }
  .row:hover{ border-color:rgba(3,89,77,.18); transform:translateY(-1px) }
  .row.call{ background:rgba(253,248,238,.6) }

  .time{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:12px; color:rgba(19,23,34,.5); min-width:52px;
  }
  .text{ flex:1; font-size:13.5px; color:#131722; }
  .text b{ font-family:'IBM Plex Mono', ui-monospace, monospace; font-size:10px; background:#f4f4f5; padding:2px 6px; border-radius:999px; }

  .lat{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:10px; padding:4px 9px; border-radius:999px;
    background:#fff6d6; border:1px solid #e7e5e4;
  }
  .chip{
    font-family:'IBM Plex Mono', ui-monospace, monospace;
    font-size:10px; padding:4px 9px; border-radius:999px;
    background:#e8f5ee; border:1px solid #d1e7d6;
  }
</style>
