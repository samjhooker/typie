<script>
  /* full Slack UI — used inside the hero Mac; receives the dictation replay */
  let { typed = '', listening = false, pasted = false } = $props();

  const channels = [
    '# general',
    '# launch',
    '# design',
    '# eng',
    '# deal-review',
  ];
  const dms = [
    { n: 'Maya Chen', c: '#36c5f0' },
    { n: 'Sam Baker', c: '#2eb67d' },
    { n: 'Alex', c: '#ecb22e' },
  ];
  const msgs = [
    {
      who: 'Maya',
      color: '#36c5f0',
      text: 'ok, who owns the Q3 close narrative?',
      time: '2h',
    },
    {
      who: 'Sam',
      color: '#2eb67d',
      text: 'i do — numbers are final, drafting now.',
      time: '1h',
    },
    {
      who: 'Maya',
      color: '#36c5f0',
      text: 'perfect. churn held flat at 2.1% right?',
      time: '55m',
    },
  ];
</script>

<div class="aslack">
  <aside class="rail">
    <div class="ws"><span class="wsic">↑</span><b>typie</b></div>
    <div class="grp">
      <p class="glabel">Channels</p>
      {#each channels as c, i}
        <div
          class="ci"
          class:on={i === 1}
        >
          <span>{c}</span>
        </div>
      {/each}
    </div>
    <div class="grp">
      <p class="glabel">Direct messages</p>
      {#each dms as d}
        <div class="ci">
          <span
            class="dot"
            style="background:{d.c}"
          ></span><span>{d.n}</span>
        </div>
      {/each}
    </div>
  </aside>

  <section class="pane">
    <header># launch<span class="chips">4 members</span></header>
    <div class="msgs">
      {#each msgs as m}
        <div class="m">
          <span
            class="av"
            style="background:{m.color}">{m.who[0]}</span
          >
          <div class="mbody">
            <p class="mhead"><b>{m.who}</b><span class="t">{m.time}</span></p>
            <p class="mtxt">{m.text}</p>
          </div>
        </div>
      {/each}
      {#if typed}
        <div class="m">
          <span
            class="av"
            style="background:#e01e5a">y</span
          >
          <div class="mbody">
            <p class="mhead"><b>you</b><span class="t">now</span></p>
            <p
              class="mtxt fresh"
              class:pop={pasted}
            >
              {typed}
            </p>
          </div>
        </div>
      {/if}
    </div>
    <div
      class="msginput"
      class:armed={listening || typed}
      class:pasted
    >
      <span class="plus">+</span>
      {#if typed}
        <span
          class="field typed"
          class:pop={pasted}>{typed}<span class="caret"></span></span
        >
      {:else}
        <span
          class="field"
          class:dim={listening}
          >{listening ? 'listening…' : 'Message #launch'}</span
        >
      {/if}
      <span class="mic">🎙</span>
    </div>
  </section>
</div>

<style>
  .aslack {
    display: grid;
    grid-template-columns: 220px 1fr;
    height: 100%;
    background: var(--surface);
    font-family: 'Inter', system-ui, sans-serif;
    color: #1d1c1d;
  }
  .rail {
    background: #3f0e40;
    color: #d3c2c4;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }
  .ws {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 14px;
    border-bottom: 1px solid #522653;
    color: #fff;
  }
  .wsic {
    background: var(--surface);
    color: #3f0e40;
    width: 22px;
    height: 22px;
    border-radius: 6px;
    display: grid;
    place-items: center;
    font-size: 13px;
    font-weight: 800;
  }
  .ws b {
    font-size: 14px;
  }
  .grp {
    padding: 10px 8px 2px;
    display: flex;
    flex-direction: column;
    gap: 1px;
  }
  .glabel {
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #9a7d9b;
    padding: 2px 8px;
    margin-bottom: 3px;
  }
  .ci {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 5px 8px;
    border-radius: 6px;
    font-size: 13px;
    color: #d3c2c4;
  }
  .ci.on {
    background: #1164a3;
    color: #fff;
  }
  .dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    flex: none;
  }

  .pane {
    display: flex;
    flex-direction: column;
    min-width: 0;
    height: 100%;
  }
  .pane header {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    border-bottom: 1px solid rgba(29, 28, 29, 0.12);
    font-size: 15px;
    font-weight: 800;
    font-family: 'Space Grotesk', sans-serif;
  }
  .chips {
    font-size: 11px;
    font-weight: 500;
    color: #616061;
  }
  .msgs {
    flex: 1;
    overflow: hidden;
    padding: 10px 14px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .m {
    display: flex;
    gap: 10px;
  }
  .av {
    width: 26px;
    height: 26px;
    border-radius: 6px;
    color: #fff;
    display: grid;
    place-items: center;
    font-size: 11px;
    font-weight: 800;
    flex: none;
  }
  .mhead {
    display: flex;
    align-items: baseline;
    gap: 7px;
  }
  .mhead b {
    font-size: 13px;
  }
  .t {
    font-size: 11px;
    color: #9d9d9f;
  }
  .mtxt {
    font-size: 13.5px;
    line-height: 1.5;
    color: #1d1c1d;
  }
  .fresh {
    animation: msgIn 0.5s var(--spring, ease) both;
  }
  .pop {
    animation: pastePop 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes msgIn {
    0% {
      opacity: 0;
      transform: translateY(10px) scale(0.92);
      filter: blur(1px);
    }
    40% {
      opacity: 1;
      transform: translateY(-2px) scale(1.02);
      filter: blur(0);
    }
    100% {
      opacity: 1;
      transform: none;
      filter: blur(0);
    }
  }
  @keyframes pastePop {
    0% {
      background: rgba(16, 185, 129, 0.5);
      box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.28);
      transform: scale(0.96);
      border-radius: 4px;
    }
    45% {
      background: rgba(16, 185, 129, 0.22);
      box-shadow: 0 0 0 6px rgba(16, 185, 129, 0.12);
      transform: scale(1.03);
    }
    100% {
      background: transparent;
      box-shadow: none;
      transform: none;
    }
  }

  .msginput {
    display: flex;
    align-items: center;
    gap: 7px;
    margin: 8px 12px 8px;
    border: 1px solid rgba(29, 28, 29, 0.28);
    border-radius: 7px;
    padding: 3px 10px;
    min-height: 30px;
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .msginput.armed {
    border-color: #007a5a;
    box-shadow: 0 0 0 3px rgba(0, 122, 90, 0.18);
    animation: flashIn 0.4s ease-out both;
  }
  .msginput.pasted {
    border-color: #10b981;
    box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.28);
    animation: pasteField 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes flashIn {
    0% {
      box-shadow: 0 0 0 0 rgba(0, 122, 90, 0.45);
    }
    60% {
      box-shadow: 0 0 0 4px rgba(0, 122, 90, 0.24);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(0, 122, 90, 0.14);
    }
  }
  @keyframes pasteField {
    0% {
      box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.55);
      background: rgba(16, 185, 129, 0.18);
    }
    40% {
      box-shadow: 0 0 0 6px rgba(16, 185, 129, 0.22);
      background: rgba(16, 185, 129, 0.08);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.16);
      background: transparent;
    }
  }
  .plus {
    color: #9d9d9f;
    font-size: 13px;
  }
  .field {
    flex: 1;
    min-width: 0;
    font-size: 11.5px;
    color: #9d9d9f;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
    line-height: 1.3;
  }
  .field.typed {
    color: #1d1c1d;
    font-size: 11.5px;
  }
  .field.typed::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(90, 0.15em, 0.3em, transparent 0);
    background-size: 1em 100%;
    background-repeat: no-repeat;
    animation: typeFlash 0.3s ease-out 0.2s both;
  }
  @keyframes typeFlash {
    0% {
      background-position: 0 0;
      opacity: 0.6;
    }
    100% {
      background-position: 100% 0;
      opacity: 0;
    }
  }
  .field.dim {
    color: #6d6d6f;
    font-style: italic;
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #007a5a;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  .mic {
    font-size: 12.5px;
  }

  /* ── Slack dark mode (real Slack dark theme values) ── */
  :global([data-theme='dark']) .aslack {
    background: #1a1d21;
    color: #d1d2d3;
  }
  :global([data-theme='dark']) .rail {
    background: #19171d;
    color: #ab9ba9;
  }
  :global([data-theme='dark']) .ws {
    border-bottom-color: #35373b;
    color: #ffffff;
  }
  :global([data-theme='dark']) .ci {
    color: #ababab;
  }
  :global([data-theme='dark']) .glabel {
    color: #8e7d91;
  }
  :global([data-theme='dark']) .pane header {
    border-bottom-color: rgba(255, 255, 255, 0.12);
    color: #ffffff;
  }
  :global([data-theme='dark']) .chips {
    color: #ababab;
  }
  :global([data-theme='dark']) .mtxt {
    color: #d1d2d3;
  }
  :global([data-theme='dark']) .msginput {
    background: #222529;
    border-color: rgba(255, 255, 255, 0.18);
  }
  :global([data-theme='dark']) .field.typed {
    color: #d1d2d3;
  }
  :global([data-theme='dark']) .field.dim {
    color: #6d6d6f;
  }

  @media (max-width: 640px) {
    .aslack {
      grid-template-columns: 1fr;
    }
    .rail {
      display: none;
    }
  }
</style>
