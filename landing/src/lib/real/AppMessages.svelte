<script>
  /* full Messages UI — used inside the hero Mac; the conversation receives the dictation */
  let { typed = '', listening = false, pasted = false } = $props();

  const convos = [
    {
      id: 1,
      name: 'Maya Chen',
      color: '#34c759',
      av: 'MC',
      time: '9:41',
      last: 'see you at the demo',
    },
    {
      id: 2,
      name: 'Sam Baker',
      color: '#af52de',
      av: 'SB',
      time: '9:30',
      last: 'pricing page is live 🎉',
    },
    {
      id: 3,
      name: 'Design Team',
      color: '#007aff',
      av: '#',
      time: '9:12',
      last: 'Maya: shipped the hero',
    },
    {
      id: 4,
      name: 'Grandma',
      color: '#ff9500',
      av: 'G',
      time: 'Yesterday',
      last: 'add white pepper too',
    },
    {
      id: 5,
      name: 'Alex Rivera',
      color: '#30b0c7',
      av: 'AR',
      time: 'Yesterday',
      last: 'great meeting today',
    },
  ];

  const thread = [
    {
      mine: false,
      text: 'ok the hero section looks so good now',
      time: '9:38',
    },
    { mine: true, text: 'right?? the desktop demo sells it', time: '9:39' },
    { mine: false, text: 'and it types into every app for real', time: '9:40' },
  ];
</script>

<div class="amsg">
  <aside class="list">
    <div class="search">⌕ Search</div>
    {#each convos as c}
      <div
        class="row"
        class:on={c.id === 1}
      >
        <span
          class="av"
          style="background:{c.color}">{c.av}</span
        >
        <div class="meta">
          <div class="top"><b>{c.name}</b><span class="t">{c.time}</span></div>
          <p class="last">{c.last}</p>
        </div>
      </div>
    {/each}
  </aside>

  <section class="chat">
    <header>
      <span
        class="av sm"
        style="background:#34c759">MC</span
      >
      <div>
        <b>Maya Chen</b>
        <p>iMessage</p>
      </div>
      <span class="facetime">▶</span>
    </header>

    <div class="bubbles">
      {#each thread as m}
        <div
          class="bub"
          class:mine={m.mine}
        >
          <p>{m.text}</p>
          <span class="tm"
            >{m.time}{#if m.mine}<i>✓✓</i>{/if}</span
          >
        </div>
      {/each}
      {#if typed}
        <div
          class="bub mine fresh"
          class:pop={pasted}
        >
          <p>{typed}</p>
          <span class="tm">9:41<i>✓✓</i></span>
        </div>
      {/if}
    </div>

    <div
      class="composer"
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
          class:dim={listening}>{listening ? 'listening…' : 'iMessage'}</span
        >
      {/if}
      <span class="mic">🎙</span>
    </div>
  </section>
</div>

<style>
  .amsg {
    display: grid;
    grid-template-columns: 255px 1fr;
    height: 100%;
    background: #f6f6f6;
    font-family: 'Inter', system-ui, sans-serif;
    color: #1c1c1e;
  }
  .list {
    background: #f2f2f7;
    border-right: 1px solid rgba(0, 0, 0, 0.08);
    padding: 10px 8px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    overflow: hidden;
  }
  .search {
    font-size: 11px;
    color: #8e8e93;
    background: rgba(120, 120, 128, 0.12);
    border-radius: 7px;
    padding: 5px 10px;
    margin-bottom: 8px;
  }
  .row {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 6px 8px;
    border-radius: 9px;
  }
  .row.on {
    background: rgba(0, 0, 0, 0.08);
  }
  .av {
    flex: none;
    width: 34px;
    height: 34px;
    border-radius: 50%;
    color: #fff;
    display: grid;
    place-items: center;
    font-size: 11px;
    font-weight: 700;
  }
  .av.sm {
    width: 28px;
    height: 28px;
    font-size: 10px;
  }
  .meta {
    min-width: 0;
    flex: 1;
  }
  .top {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 6px;
  }
  .top b {
    font-size: 12.5px;
    font-weight: 600;
  }
  .t {
    font-size: 10px;
    color: #8e8e93;
  }
  .last {
    font-size: 11px;
    color: #8e8e93;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .chat {
    display: flex;
    flex-direction: column;
    min-width: 0;
    height: 100%;
  }
  header {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 8px 14px;
    background: rgba(255, 255, 255, 0.7);
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  }
  header b {
    font-size: 12.5px;
  }
  header p {
    font-size: 10px;
    color: #8e8e93;
  }
  .facetime {
    margin-left: auto;
    color: #007aff;
    font-size: 12px;
  }

  .bubbles {
    flex: 1;
    overflow: hidden;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }
  .bub {
    align-self: flex-start;
    max-width: 78%;
    background: rgba(255, 255, 255, 0.9);
    border-radius: 16px 16px 16px 5px;
    padding: 8px 11px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  }
  .bub.mine {
    align-self: flex-end;
    background: #0a7cff;
    color: #fff;
    border-radius: 16px 16px 5px 16px;
  }
  .bub p {
    font-size: 13px;
    line-height: 1.4;
  }
  .tm {
    display: block;
    text-align: right;
    font-size: 9px;
    opacity: 0.65;
    margin-top: 2px;
  }
  .tm i {
    font-style: normal;
    margin-left: 3px;
  }
  .fresh {
    animation: msgIn 0.45s var(--spring, ease) both;
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
      filter: brightness(1.35);
      transform: scale(0.94);
    }
    45% {
      filter: brightness(1.12);
      transform: scale(1.04);
    }
    100% {
      filter: none;
      transform: none;
    }
  }

  .composer {
    display: flex;
    align-items: center;
    gap: 7px;
    margin: 0 10px 8px;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 16px;
    padding: 3px 10px;
    min-height: 28px;
    border: 1px solid rgba(0, 0, 0, 0.1);
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .composer.armed {
    border-color: #0b84fe;
    box-shadow: 0 0 0 3px rgba(11, 132, 254, 0.18);
    animation: flashIn 0.4s ease-out both;
  }
  .composer.pasted {
    border-color: #10b981;
    animation: pasteField 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes flashIn {
    0% {
      box-shadow: 0 0 0 0 rgba(11, 132, 254, 0.5);
    }
    60% {
      box-shadow: 0 0 0 4px rgba(11, 132, 254, 0.24);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(11, 132, 254, 0.14);
    }
  }
  @keyframes pasteField {
    0% {
      box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.55);
      background: rgba(16, 185, 129, 0.2);
    }
    40% {
      box-shadow: 0 0 0 6px rgba(16, 185, 129, 0.22);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.16);
      background: rgba(255, 255, 255, 0.95);
    }
  }
  .plus {
    color: #007aff;
    font-size: 13px;
    font-weight: 700;
  }
  .field {
    flex: 1;
    min-width: 0;
    font-size: 11px;
    color: #8e8e93;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
    line-height: 1.3;
  }
  .field.typed {
    color: #1c1c1e;
    font-size: 11px;
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
    color: #6d6d72;
    font-style: italic;
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #0b84fe;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  .mic {
    font-size: 12px;
  }

  @media (max-width: 640px) {
    .amsg {
      grid-template-columns: 1fr;
    }
    .list {
      display: none;
    }
  }
</style>
