<script>
  import Robot from './Robot.svelte';
  import { chat } from './chat.svelte.js';

  const SALES_PITCH =
    "hi. i'm sales. everything is free and works fully offline. we don't do anything with your data - it doesn't leave your machine, so there's nothing to hand over. so... there's really nothing left to negotiate. welcome aboard.";

  let draft = $state('');
  let thinking = $state(false);
  let list = $state(null);
  let msgs = $state([{ who: 'bot', text: 'hi. i handle support. well. me and one sentence.' }]);

  const REPLIES = [
    "it's free and works fully offline.",
    "error 418: i am a teapot. also: it's free and works fully offline.",
    "your question has been escalated to the cloud team. joke's on you - there is no cloud.",
    '$0.00. that is my answer to most things.',
    'have you tried holding the option key? that fixes most problems, including this one.',
    "i am a very small robot. my entire knowledge base is: it's free and works fully offline.",
    'ticket created. priority: low. price: still $0.',
    'works offline. works free. works on planes.',
    "query not recognized. defaulting to: it's free and works fully offline.",
    'we trained our model on zero of your data, because there was no training. it just knows things. locally.',
    "beep boop. translation: it's free and works fully offline.",
  ];

  const QUICK = ['price?', 'privacy?', 'offline?'];
  let ri = Math.floor(Math.random() * REPLIES.length);

  function reply() {
    const r = REPLIES[ri % REPLIES.length];
    ri += 1 + Math.floor(Math.random() * 2);
    return r;
  }

  function send(text) {
    const t = (text ?? draft).trim();
    if (!t || thinking) return;
    msgs = [...msgs, { who: 'you', text: t }];
    draft = '';
    thinking = true;
    setTimeout(
      () => {
        thinking = false;
        msgs = [...msgs, { who: 'bot', text: reply() }];
        scrollDown();
      },
      650 + Math.random() * 500
    );
    setTimeout(scrollDown);
  }

  function scrollDown() {
    if (list) list.scrollTop = list.scrollHeight;
  }

  // contact-sales hook: pop open and pitch
  $effect(() => {
    chat.sales = () => {
      chat.open = true;
      thinking = true;
      setTimeout(() => {
        thinking = false;
        msgs = [...msgs, { who: 'bot', text: SALES_PITCH }];
        setTimeout(scrollDown);
      }, 550);
      setTimeout(scrollDown);
    };
  });
</script>

<div class="chatbot">
  {#if chat.open}
    <div class="panel">
      <header>
        <span class="hbot"><Robot size={34} mood={thinking ? 'thinking' : 'idle'} /></span>
        <div class="ht">
          <strong>typie support</strong>
          <span class="mono">avg response · &lt;100 ms*</span>
        </div>
        <button class="x" onclick={() => (chat.open = false)} aria-label="Close chat">–</button>
      </header>

      <div class="msgs" bind:this={list}>
        {#each msgs as m}
          <p class="msg {m.who}">{m.text}</p>
        {/each}
        {#if thinking}
          <p class="msg bot dots">···</p>
        {/if}
      </div>

      <div class="quick">
        {#each QUICK as q}
          <button onclick={() => send(q)} disabled={thinking}>{q}</button>
        {/each}
      </div>

      <form
        onsubmit={(e) => {
          e.preventDefault();
          send();
        }}
      >
        <input
          bind:value={draft}
          placeholder="type a voice message (with your hands)"
          aria-label="Message typie support"
        />
        <button class="send" type="submit" disabled={thinking || !draft.trim()}>↑</button>
      </form>

      <p class="fine mono">*response time is comedic, not contractual</p>
    </div>
  {/if}

  <button
    class="fab"
    onclick={() => (chat.open = !chat.open)}
    aria-label={chat.open ? 'Close support chat' : 'Open support chat'}
  >
    {#if chat.open}
      ✕
    {:else}
      <Robot size={40} mood={thinking ? 'listening' : 'idle'} />
    {/if}
  </button>
</div>

<style>
  .chatbot {
    position: fixed;
    right: 20px;
    bottom: 20px;
    z-index: 130;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 12px;
  }

  .fab {
    width: 62px;
    height: 62px;
    border-radius: 50%;
    background: var(--cream);
    border: 2px solid rgba(3, 43, 37, 0.9);
    box-shadow: 0 14px 34px rgba(3, 43, 37, 0.28);
    display: grid;
    place-items: center;
    font-size: 18px;
    color: var(--green-deep);
    transition:
      transform 0.3s var(--spring),
      box-shadow 0.3s var(--ease-out);
    overflow: visible;
  }

  .fab :global(.robot) {
    display: block;
    color: var(--hotpink);
  }

  .fab:hover {
    transform: translateY(-4px) rotate(-6deg);
    box-shadow: 0 20px 44px rgba(3, 43, 37, 0.32);
  }

  .panel {
    width: min(340px, calc(100vw - 32px));
    background: var(--cream);
    border: 1px solid rgba(3, 43, 37, 0.14);
    border-radius: 24px;
    overflow: hidden;
    box-shadow: 0 30px 70px rgba(3, 43, 37, 0.3);
    animation: pop-in 0.35s cubic-bezier(0.2, 1.4, 0.35, 1);
    text-align: left;
  }

  @keyframes pop-in {
    from {
      opacity: 0;
      transform: translateY(16px) scale(0.94);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 14px 16px;
    background: var(--mint);
    border-bottom: 1px solid rgba(3, 43, 37, 0.12);
  }

  .hbot {
    display: block;
    line-height: 0;
    color: var(--hotpink);
  }

  .ht strong {
    display: block;
    font-family: var(--display);
    font-weight: 800;
    font-size: 15px;
    color: var(--green-deep);
    line-height: 1.1;
  }

  .ht span {
    font-size: 10px !important;
    color: var(--green);
  }

  .x {
    margin-left: auto;
    align-self: flex-start;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: rgba(249, 248, 244, 0.7);
    color: var(--green-deep);
    font-size: 16px;
    line-height: 1;
  }

  .msgs {
    max-height: 240px;
    overflow-y: auto;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .msg {
    max-width: 85%;
    padding: 9px 13px;
    border-radius: 16px;
    font-size: 13.5px;
    line-height: 1.45;
    animation: msg-in 0.25s ease both;
  }

  @keyframes msg-in {
    from {
      opacity: 0;
      transform: translateY(6px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .msg.bot {
    background: #fff;
    border: 1px solid rgba(3, 43, 37, 0.1);
    color: var(--green-deep);
    align-self: flex-start;
    border-bottom-left-radius: 4px;
  }

  .msg.you {
    background: var(--hotpink);
    color: var(--cream);
    align-self: flex-end;
    border-bottom-right-radius: 4px;
  }

  .dots {
    letter-spacing: 0.2em;
    color: rgba(3, 89, 77, 0.5);
  }

  .quick {
    display: flex;
    gap: 6px;
    padding: 0 14px 10px;
  }

  .quick button {
    font-family: var(--mono);
    font-size: 11px;
    padding: 5px 11px;
    border-radius: 999px;
    background: rgba(130, 237, 166, 0.3);
    color: var(--green-deep);
    transition: background 0.2s var(--ease-out);
  }

  .quick button:hover:not(:disabled) {
    background: rgba(130, 237, 166, 0.6);
  }

  form {
    display: flex;
    gap: 8px;
    padding: 0 14px 8px;
  }

  input {
    flex: 1;
    min-width: 0;
    border: 1.5px solid rgba(3, 43, 37, 0.18);
    border-radius: 999px;
    padding: 9px 15px;
    font: inherit;
    font-size: 13.5px;
    color: var(--ink);
    background: #fff;
    outline: none;
    transition: border-color 0.2s var(--ease-out);
  }

  input:focus {
    border-color: var(--hotpink);
  }

  .send {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: var(--green);
    color: var(--cream);
    font-size: 15px;
    transition:
      background 0.2s var(--ease-out),
      transform 0.2s var(--spring);
  }

  .send:hover:not(:disabled) {
    background: var(--hotpink);
    transform: scale(1.08);
  }

  .send:disabled {
    opacity: 0.4;
    cursor: default;
  }

  .fine {
    padding: 0 16px 12px;
    font-size: 9px !important;
    opacity: 0.55;
  }
</style>
