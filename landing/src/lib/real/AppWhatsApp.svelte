<script>
  /* WhatsApp Desktop UI, used inside the hero Mac; the chat composer receives the dictation */
  let { typed = '', listening = false, pasted = false } = $props();

  const chats = [
    {
      id: 1,
      name: 'Maya Chen',
      time: '9:41',
      last: 'see you at the demo 🚀',
      unread: 0,
      on: true,
      av: '#dcf8c6',
    },
    {
      id: 2,
      name: 'Sam Baker',
      time: '9:30',
      last: 'pricing page is live 🎉',
      unread: 2,
      av: '#dfeee3',
    },
    {
      id: 3,
      name: 'Design Team',
      time: '9:12',
      last: 'Maya: shipped the hero',
      unread: 0,
      av: '#cfe9f0',
    },
    {
      id: 4,
      name: 'Grandma',
      time: 'Yesterday',
      last: 'add white pepper too',
      unread: 0,
      av: '#f3e2cf',
    },
    {
      id: 5,
      name: 'Alex Rivera',
      time: 'Yesterday',
      last: 'great meeting today',
      unread: 0,
      av: '#e6d9f0',
    },
  ];

  const thread = [
    { mine: false, text: 'ok the hero section looks so good now', time: '9:38' },
    { mine: true, text: 'right?? the desktop demo sells it', time: '9:39' },
    { mine: false, text: 'and it types into every app for real', time: '9:40' },
  ];
</script>

<div class="awhats">
  <!-- left rail -->
  <aside class="rail">
    <div class="railhead">
      <span class="av-me"></span>
      <div class="railico">
        <svg
          viewBox="0 0 24 24"
          width="16"
          height="16"
          fill="none"
          stroke="#54656f"
          stroke-width="1.8"
          stroke-linecap="round"
        >
          <circle cx="11" cy="11" r="7" />
          <path d="m16 16 4 4" />
        </svg>
        <svg
          viewBox="0 0 24 24"
          width="16"
          height="16"
          fill="none"
          stroke="#54656f"
          stroke-width="1.8"
          stroke-linecap="round"
        >
          <path d="M4 6h12M4 12h12M4 18h8" />
        </svg>
      </div>
    </div>
    <div class="chatlist">
      {#each chats as c}
        <div
          class="crow"
          class:on={c.on}
        >
          <span
            class="av"
            style="background:{c.av}">{c.name[0]}</span
          >
          <div class="meta">
            <div class="top">
              <b>{c.name}</b><span class="t">{c.time}</span>
            </div>
            <p class="last">{c.last}</p>
          </div>
          {#if c.unread}
            <span class="badge">{c.unread}</span>
          {/if}
        </div>
      {/each}
    </div>
  </aside>

  <!-- chat pane -->
  <section class="pane">
    <header class="phead">
      <span class="av sm">M</span>
      <div class="phmeta">
        <b>Maya Chen</b>
        <span>online</span>
      </div>
      <span class="ph-icons">
        <svg
          viewBox="0 0 24 24"
          width="16"
          height="16"
          fill="none"
          stroke="#54656f"
          stroke-width="1.8"
        >
          <path d="M15 5l4 4-4 4M19 9H8a4 4 0 0 0-4 4v2" />
        </svg>
        <svg
          viewBox="0 0 24 24"
          width="16"
          height="16"
          fill="none"
          stroke="#54656f"
          stroke-width="1.8"
        >
          <circle cx="5" cy="12" r="1.6" />
          <circle cx="12" cy="12" r="1.6" />
          <circle cx="19" cy="12" r="1.6" />
        </svg>
      </span>
    </header>

    <div class="bubbles">
      <span class="daychip">TODAY</span>
      {#each thread as m}
        <div
          class="bub"
          class:mine={m.mine}
        >
          <p>{m.text}</p>
          <span class="tm"
            >{m.time}<i>{#if m.mine}✓✓{/if}</i></span
          >
        </div>
      {/each}
      {#if typed}
        <div
          class="bub mine fresh"
          class:pop={pasted}
        >
          <p>{typed}</p>
          <span class="tm">9:41<i>✓</i></span>
        </div>
      {/if}
    </div>

    <div
      class="composer"
      class:armed={listening || typed}
      class:pasted
    >
      <span class="cico">😀</span>
      {#if typed}
        <span
          class="field typed"
          class:pop={pasted}>{typed}<span class="caret"></span></span
        >
      {:else}
        <span class="field" class:dim={listening}
          >{listening ? 'listening…' : 'Type a message'}</span
        >
      {/if}
      <span class="cico paperclip">
        <svg
          viewBox="0 0 24 24"
          width="17"
          height="17"
          fill="none"
          stroke="#54656f"
          stroke-width="1.8"
          stroke-linecap="round"
        >
          <path
            d="M21 11l-8.5 8.5a4.5 4.5 0 0 1-6.4-6.4L14 5.2a3 3 0 0 1 4.3 4.3L9.8 18"
          />
        </svg>
      </span>
      <span class="mic" class:live={listening}>🎙</span>
    </div>
  </section>
</div>

<style>
  .awhats {
    display: grid;
    grid-template-columns: 240px 1fr;
    height: 100%;
    background: #f0f2f5;
    font-family: 'Inter', system-ui, sans-serif;
    color: #111b21;
  }
  .rail {
    background: var(--surface);
    border-right: 1px solid #e9edef;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }
  .railhead {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 9px 12px;
    background: #f0f2f5;
    border-bottom: 1px solid #e9edef;
  }
  .av-me {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: linear-gradient(135deg, #25d366, #128c7e);
  }
  .railico {
    display: flex;
    gap: 14px;
  }
  .chatlist {
    flex: 1;
    overflow: hidden;
  }
  .crow {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 8px 12px;
    border-bottom: 1px solid #f0f2f5;
    position: relative;
  }
  .crow.on {
    background: #f0f2f5;
  }
  .av {
    flex: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    color: #41525c;
    font-size: 15px;
    font-weight: 700;
  }
  .av.sm {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, #dcf8c6, #c8f0c2);
    color: #075e54;
  }
  .meta {
    flex: 1;
    min-width: 0;
  }
  .top {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 8px;
  }
  .top b {
    font-size: 13.5px;
    font-weight: 500;
    color: #111b21;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .t {
    font-size: 11px;
    color: #667781;
    flex: none;
  }
  .last {
    font-size: 12.5px;
    color: #667781;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin-top: 1px;
  }
  .badge {
    background: #25d366;
    color: #fff;
    border-radius: 99px;
    font-size: 10px;
    font-weight: 700;
    min-width: 18px;
    height: 18px;
    display: grid;
    place-items: center;
    padding: 0 5px;
    flex: none;
  }

  .pane {
    display: flex;
    flex-direction: column;
    min-width: 0;
    background: #efeae2;
    background-image: radial-gradient(rgba(0, 0, 0, 0.035) 1px, transparent 0);
    background-size: 22px 22px;
  }
  .phead {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 14px;
    background: #f0f2f5;
    border-bottom: 1px solid #e9edef;
  }
  .phmeta {
    display: flex;
    flex-direction: column;
    flex: 1;
  }
  .phmeta b {
    font-size: 13.5px;
    font-weight: 500;
  }
  .phmeta span {
    font-size: 11.5px;
    color: #25d366;
  }
  .ph-icons {
    display: flex;
    gap: 18px;
    align-items: center;
  }

  .bubbles {
    flex: 1;
    overflow: hidden;
    padding: 14px 16px 6px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .daychip {
    align-self: center;
    background: var(--surface);
    color: #54656f;
    font-size: 10.5px;
    font-weight: 500;
    padding: 4px 12px;
    border-radius: 99px;
    box-shadow: 0 1px 0.5px rgba(11, 20, 26, 0.13);
    margin-bottom: 6px;
  }
  .bub {
    align-self: flex-start;
    max-width: 78%;
    background: var(--surface);
    border-radius: 8px 8px 8px 2px;
    padding: 6px 9px 7px;
    box-shadow: 0 1px 0.5px rgba(11, 20, 26, 0.13);
  }
  .bub.mine {
    align-self: flex-end;
    background: #d9fdd3;
    border-radius: 8px 8px 2px 8px;
  }
  .bub p {
    font-size: 13.5px;
    line-height: 1.45;
    color: #111b21;
  }
  .tm {
    display: block;
    text-align: right;
    font-size: 10px;
    color: #667781;
    margin-top: 1px;
  }
  .tm i {
    font-style: normal;
    margin-left: 3px;
    color: #53bdeb;
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
    }
    40% {
      opacity: 1;
      transform: translateY(-2px) scale(1.02);
    }
    100% {
      transform: none;
    }
  }
  @keyframes pastePop {
    0% {
      filter: brightness(1.3);
      transform: scale(0.94);
    }
    45% {
      filter: brightness(1.1);
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
    gap: 9px;
    margin: 0 16px 12px;
    background: var(--surface);
    border-radius: 12px;
    padding: 9px 14px;
    min-height: 50px;
    border: 1px solid transparent;
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .composer.armed {
    border-color: #25d366;
    box-shadow: 0 0 0 3px rgba(37, 211, 102, 0.18);
    animation: flashIn 0.4s ease-out both;
  }
  .composer.pasted {
    border-color: #25d366;
    box-shadow: 0 0 0 4px rgba(37, 211, 102, 0.28);
    animation: pasteField 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes flashIn {
    0% {
      box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.5);
    }
    60% {
      box-shadow: 0 0 0 5px rgba(37, 211, 102, 0.24);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(37, 211, 102, 0.14);
    }
  }
  @keyframes pasteField {
    0% {
      box-shadow: 0 0 0 0 rgba(37, 211, 102, 0.55);
      background: rgba(37, 211, 102, 0.15);
    }
    40% {
      box-shadow: 0 0 0 6px rgba(37, 211, 102, 0.22);
    }
    100% {
      box-shadow: 0 0 0 3px rgba(37, 211, 102, 0.16);
    }
  }
  .cico {
    font-size: 17px;
    color: #54656f;
    line-height: 1;
  }
  .cico.paperclip {
    display: grid;
    place-items: center;
  }
  .field {
    flex: 1;
    min-width: 0;
    font-size: 14.5px;
    color: #8696a0;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
    line-height: 1.3;
  }
  .field.typed {
    color: #111b21;
  }
  .field.dim {
    color: #667781;
    font-style: italic;
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #25d366;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  .mic {
    font-size: 14px;
    color: #54656f;
  }
  .mic.live {
    color: #25d366;
    animation: micpulse 0.8s ease-in-out infinite alternate;
  }
  @keyframes micpulse {
    to {
      transform: scale(1.15);
    }
  }

  @media (max-width: 640px) {
    .awhats {
      grid-template-columns: 1fr;
    }
    .rail {
      display: none;
    }
  }

  /* ── WhatsApp dark mode (real WA dark: #0B141A chat, #202C33 chrome,
     #005C4B outgoing bubbles, #E9EDEF text) ── */
  :global([data-theme='dark']) .awhats {
    background: #0b141a;
    color: #e9edef;
  }
  :global([data-theme='dark']) .rail {
    background: #111b21;
    border-right-color: #222d34;
  }
  :global([data-theme='dark']) .railhead,
  :global([data-theme='dark']) .phead {
    background: #202c33;
    border-bottom-color: #222d34;
  }
  :global([data-theme='dark']) .crow {
    border-bottom-color: #1d282f;
  }
  :global([data-theme='dark']) .crow.on {
    background: #202c33;
  }
  :global([data-theme='dark']) .top b {
    color: #e9edef;
  }
  :global([data-theme='dark']) .t,
  :global([data-theme='dark']) .last {
    color: #8696a0;
  }
  :global([data-theme='dark']) .pane {
    background: #0b141a;
    background-image: radial-gradient(
      rgba(255, 255, 255, 0.04) 1px,
      transparent 0
    );
  }
  :global([data-theme='dark']) .daychip {
    background: #182229;
    color: #8696a0;
    box-shadow: none;
  }
  :global([data-theme='dark']) .bub {
    background: #202c33;
    box-shadow: 0 1px 0.5px rgba(0, 0, 0, 0.3);
  }
  :global([data-theme='dark']) .bub.mine {
    background: #005c4b;
  }
  :global([data-theme='dark']) .bub p {
    color: #e9edef;
  }
  :global([data-theme='dark']) .tm {
    color: #8696a0;
  }
  :global([data-theme='dark']) .composer {
    background: #2a3942;
  }
  :global([data-theme='dark']) .field.typed {
    color: #e9edef;
  }
  :global([data-theme='dark']) .field.dim {
    color: #8696a0;
  }
</style>
