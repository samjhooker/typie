<script>
  import Robot from './Robot.svelte';
  import { pitch } from './pitchbot.svelte.js';

  /* corner chatbot for the enterprise & education pages. every sales
     CTA routes here; the bot's entire pitch is "it's free, it's on
     GitHub, go take it". */
  let { variant = 'ent' } = $props();

  const COPY = {
    ent: {
      title: 'typie enterprise sales',
      meta: 'sales headcount · 1 (a robot)',
      greeting: "hi. i handle enterprise sales. well. me and a download link.",
      pitch: "so you'd like to book a briefing. before our legal team (also me) gets involved: typie is free and open source. every seat, every feature, $0. it's all on GitHub — go take it. meeting adjourned.",
      quick: ['price?', 'security review?', 'pilot?'],
      replies: [
        '$0.00. that is my entire pricing strategy.',
        'error 402: payment required. nobody has ever triggered this error.',
        'our enterprise tier and our free tier are the same zip file.',
        'escalating to the sales department. it is a hallway. it is empty.',
        'briefing agenda: item one — it\u2019s free. q&a — see item one.',
        'i am a very small robot. my whole enterprise offering lives at github.com/samjhooker/typie.',
        'PO approved. total: nothing. procurement will barely notice.'
      ],
      fine: 'no sales team was harmed in the making of this chat'
    },
    edu: {
      title: 'typie campus sales',
      meta: 'district reps · 1 (small, plastic)',
      greeting: "hi! i handle campus licensing. by which i mean: there isn't any.",
      pitch: "booking a pilot? great news — it's already free. teachers, students, ten-thousand-seat districts: same download, $0 forever. grab it on GitHub. no forms, no quotes, no me.",
      quick: ['price?', 'FERPA?', 'quote?'],
      replies: [
        '$0 per seat. also per district. also per planet.',
        'the license is the cheerful absence of a license. take the app.',
        'our campus tier and the free download are the same app wearing a lanyard.',
        'purchase order generated. amount: one (1) smile.',
        'RFP received. answer to every line item: yes, free, offline.',
        'DPA status: no student data ever reaches us. case closed, confetti dropped.',
        'i am a very small robot. my whole district program lives at github.com/samjhooker/typie.'
      ],
      fine: 'this robot is not an accredited vendor (yet)'
    }
  };

  const c = COPY[variant];

  let draft = $state('');
  let thinking = $state(false);
  let list = $state(null);
  let msgs = $state([{ who: 'bot', text: c.greeting }]);

  let ri = Math.floor(Math.random() * c.replies.length);

  function reply() {
    const r = c.replies[ri % c.replies.length];
    ri += 1 + Math.floor(Math.random() * 2);
    return r;
  }

  function send(text) {
    const t = (text ?? draft).trim();
    if (!t || thinking) return;
    msgs = [...msgs, { who: 'you', text: t }];
    draft = '';
    thinking = true;
    setTimeout(() => {
      thinking = false;
      msgs = [...msgs, { who: 'bot', text: reply() }];
      scrollDown();
    }, 650 + Math.random() * 500);
    setTimeout(scrollDown);
  }

  function scrollDown() {
    if (list) list.scrollTop = list.scrollHeight;
  }

  // sales CTA hook: pop open and deliver the punchline
  $effect(() => {
    pitch.show = () => {
      pitch.open = true;
      thinking = true;
      setTimeout(() => {
        thinking = false;
        msgs = [...msgs, { who: 'bot', text: c.pitch }];
        setTimeout(scrollDown);
      }, 550);
      setTimeout(scrollDown);
    };
  });
</script>

<div class="pitchbot pb-{variant}">
  {#if pitch.open}
    <div class="panel">
      <header>
        <span class="hbot"><Robot size={32} mood={thinking ? 'thinking' : 'idle'} /></span>
        <div class="ht">
          <strong>{c.title}</strong>
          <span class="mono">{c.meta}</span>
        </div>
        <button class="x" onclick={() => (pitch.open = false)} aria-label="Close chat">–</button>
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
        {#each c.quick as q}
          <button onclick={() => send(q)} disabled={thinking}>{q}</button>
        {/each}
      </div>

      <form
        onsubmit={(e) => {
          e.preventDefault();
          send();
        }}
      >
        <input bind:value={draft} placeholder="negotiate with the robot" aria-label="Message typie sales" />
        <button class="send" type="submit" disabled={thinking || !draft.trim()}>↑</button>
      </form>

      <a
        class="gh"
        href="https://github.com/samjhooker/typie/releases/latest"
        target="_blank"
        rel="noreferrer"
      >
        it's free · download from GitHub ↗
      </a>

      <p class="fine mono">{c.fine}</p>
    </div>
  {/if}

  <button
    class="fab"
    onclick={() => (pitch.open = !pitch.open)}
    aria-label={pitch.open ? 'Close sales chat' : 'Open sales chat'}
  >
    {#if pitch.open}
      ✕
    {:else}
      <Robot size={38} mood={thinking ? 'listening' : 'idle'} />
    {/if}
  </button>
</div>

<style>
  .pitchbot {
    position: fixed;
    right: 20px;
    bottom: 20px;
    z-index: 140;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 12px;
  }

  .mono {
    font-family: ui-monospace, 'SF Mono', SFMono-Regular, Menlo, monospace;
  }

  /* ---- fab ---- */

  .fab {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 17px;
    transition:
      transform 0.3s var(--ease-out, ease-out),
      box-shadow 0.3s var(--ease-out, ease-out);
  }

  .fab :global(.robot) {
    display: block;
  }

  .pb-ent .fab {
    background: #10131a;
    border: 1px solid rgba(52, 211, 153, 0.4);
    box-shadow: 0 14px 34px rgba(0, 0, 0, 0.5);
    color: #34d399;
  }

  .pb-ent .fab :global(.robot) {
    color: #34d399;
  }

  .pb-edu .fab {
    background: #fffdf6;
    border: 2px solid rgba(22, 56, 43, 0.85);
    box-shadow: 0 14px 34px rgba(22, 56, 43, 0.24);
    color: #16382b;
  }

  .pb-edu .fab :global(.robot) {
    color: #fc5681;
  }

  .fab:hover {
    transform: translateY(-4px) rotate(-6deg);
  }

  /* ---- panel ---- */

  .panel {
    width: min(340px, calc(100vw - 32px));
    border-radius: 20px;
    overflow: hidden;
    animation: pb-pop 0.35s cubic-bezier(0.2, 1.4, 0.35, 1);
    text-align: left;
  }

  @keyframes pb-pop {
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
    padding: 13px 16px;
    border-bottom: 1px solid rgba(128, 128, 128, 0.16);
  }

  .hbot {
    display: block;
    line-height: 0;
  }

  .ht strong {
    display: block;
    font-weight: 700;
    font-size: 14px;
    line-height: 1.15;
  }

  .ht span {
    font-size: 10px !important;
  }

  .x {
    margin-left: auto;
    align-self: flex-start;
    width: 28px;
    height: 28px;
    border-radius: 50%;
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
    max-width: 86%;
    padding: 9px 13px;
    border-radius: 16px;
    font-size: 13.5px;
    line-height: 1.45;
    animation: pb-msg 0.25s ease both;
  }

  @keyframes pb-msg {
    from {
      opacity: 0;
      transform: translateY(6px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .msg.you {
    align-self: flex-end;
    border-bottom-right-radius: 4px;
  }

  .msg.bot {
    align-self: flex-start;
    border-bottom-left-radius: 4px;
  }

  .dots {
    letter-spacing: 0.2em;
  }

  .quick {
    display: flex;
    gap: 6px;
    padding: 0 14px 10px;
    flex-wrap: wrap;
  }

  .quick button {
    font-family: inherit;
    font-size: 11px;
    padding: 5px 11px;
    border-radius: 999px;
    transition: background 0.2s ease;
  }

  form {
    display: flex;
    gap: 8px;
    padding: 0 14px 10px;
  }

  input {
    flex: 1;
    min-width: 0;
    border-radius: 999px;
    padding: 9px 15px;
    font: inherit;
    font-size: 13.5px;
    outline: none;
    transition: border-color 0.2s ease;
  }

  .send {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    font-size: 15px;
    flex-shrink: 0;
    transition: transform 0.2s ease;
  }

  .send:hover:not(:disabled) {
    transform: scale(1.08);
  }

  .send:disabled {
    opacity: 0.4;
    cursor: default;
  }

  .gh {
    margin: 0 14px 8px;
    display: block;
    text-align: center;
    text-decoration: none;
    font-weight: 600;
    font-size: 13px;
    padding: 10px 14px;
    border-radius: 999px;
  }

  .fine {
    padding: 0 16px 12px;
    font-size: 9px !important;
    opacity: 0.55;
    text-align: center;
  }

  /* ================= enterprise (dark) ================= */

  .pb-ent .panel {
    background: #10131a;
    border: 1px solid rgba(237, 239, 242, 0.14);
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    color: #edeff2;
  }

  .pb-ent header {
    background: #0d1017;
  }

  .pb-ent .ht strong {
    color: #edeff2;
  }

  .pb-ent .ht span {
    color: rgba(237, 239, 242, 0.56);
  }

  .pb-ent .x {
    background: rgba(237, 239, 242, 0.08);
    color: #edeff2;
  }

  .pb-ent .msg.bot {
    background: #171c26;
    border: 1px solid rgba(237, 239, 242, 0.1);
    color: #edeff2;
  }

  .pb-ent .msg.you {
    background: #34d399;
    color: #06251a;
  }

  .pb-ent .dots {
    color: rgba(237, 239, 242, 0.45);
  }

  .pb-ent .quick button {
    background: rgba(52, 211, 153, 0.1);
    border: 1px solid rgba(52, 211, 153, 0.25);
    color: #6ee7b7;
  }

  .pb-ent .quick button:hover:not(:disabled) {
    background: rgba(52, 211, 153, 0.22);
  }

  .pb-ent input {
    border: 1px solid rgba(237, 239, 242, 0.18);
    background: #0d1017;
    color: #edeff2;
  }

  .pb-ent input:focus {
    border-color: rgba(52, 211, 153, 0.6);
  }

  .pb-ent input::placeholder {
    color: rgba(237, 239, 242, 0.35);
  }

  .pb-ent .send {
    background: #34d399;
    color: #06251a;
    border: none;
  }

  .pb-ent .gh {
    background: #34d399;
    color: #06251a;
  }

  .pb-ent .gh:hover {
    filter: brightness(1.08);
  }

  /* ================= education (paper) ================= */

  .pb-edu .panel {
    background: #fffdf6;
    border: 1px solid rgba(22, 56, 43, 0.16);
    box-shadow: 0 30px 70px rgba(22, 56, 43, 0.28);
    color: #16382b;
  }

  .pb-edu header {
    background: #ddf2df;
  }

  .pb-edu .hbot :global(.robot) {
    color: #fc5681;
  }

  .pb-edu .ht strong {
    color: #16382b;
  }

  .pb-edu .ht span {
    color: rgba(22, 56, 43, 0.64);
  }

  .pb-edu .x {
    background: rgba(22, 56, 43, 0.07);
    color: #16382b;
  }

  .pb-edu .msg.bot {
    background: #ffffff;
    border: 1px solid rgba(22, 56, 43, 0.12);
    color: #16382b;
  }

  .pb-edu .msg.you {
    background: #fc5681;
    color: #fffdf6;
  }

  .pb-edu .dots {
    color: rgba(22, 56, 43, 0.45);
  }

  .pb-edu .quick button {
    background: rgba(130, 237, 166, 0.3);
    border: none;
    color: #16382b;
  }

  .pb-edu .quick button:hover:not(:disabled) {
    background: rgba(130, 237, 166, 0.6);
  }

  .pb-edu input {
    border: 1.5px solid rgba(22, 56, 43, 0.18);
    background: #ffffff;
    color: #16382b;
  }

  .pb-edu input:focus {
    border-color: #fc5681;
  }

  .pb-edu input::placeholder {
    color: rgba(22, 56, 43, 0.4);
  }

  .pb-edu .send {
    background: #16382b;
    color: #f3efe3;
    border: none;
  }

  .pb-edu .send:hover:not(:disabled) {
    background: #fc5681;
  }

  .pb-edu .gh {
    background: #16382b;
    color: #f3efe3;
  }

  .pb-edu .gh:hover {
    background: #fc5681;
  }
</style>
