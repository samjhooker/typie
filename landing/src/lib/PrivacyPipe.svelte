<script>
  import { reveal } from './reveal.js';

  /* the entire privacy policy, drawn as a pipe. audio goes in, nothing comes out */
  const stops = [
    { icon: '🎙️', label: 'your mic' },
    { icon: '🧠', label: 'the model', note: '~500 MB, lives on your disk' },
    { icon: '🗑️', label: 'garbage collector' },
    { icon: '🚫', label: 'no server', note: 'there is no server' },
  ];
</script>

<section
  class="pipeband"
  id="privacy"
>
  <div
    class="container inner"
    use:reveal
  >
    <p class="mono kicker">the entire privacy policy</p>
    <h2>
      Your voice goes<br /><span class="accent">here → here → gone.</span>
    </h2>

    <div
      class="pipe"
      role="img"
      aria-label="audio flows from your microphone through the on-device model to the garbage collector. no server exists."
    >
      {#each stops as s, i}
        <div
          class="stop"
          style="--i:{i}"
        >
          <span class="ico">{s.icon}</span>
          <span class="lbl">{s.label}</span>
          {#if s.note}<span class="note mono">{s.note}</span>{/if}
        </div>
        {#if i < stops.length - 1}
          <span
            class="flow"
            aria-hidden="true"><i></i><i></i><i></i></span
          >
        {/if}
      {/each}
    </div>

    <ul class="nevers">
      <li>no account</li>
      <li>no cloud</li>
      <li>no telemetry</li>
      <li>no subscription</li>
      <li>no way for us to hear you</li>
    </ul>

    <p class="pledge hand">not a policy — it's the architecture.</p>
  </div>
</section>

<style>
  .pipeband {
    background: var(--green-deep);
    color: #eafff2;
    padding: clamp(60px, 9vh, 104px) 0;
    overflow: hidden;
  }

  .inner {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .kicker {
    color: rgba(234, 255, 242, 0.6);
  }

  h2 {
    margin-top: 14px;
    font-size: clamp(32px, 4.4vw, 54px);
    letter-spacing: -0.03em;
    line-height: 1.04;
    color: #fffdf7;
  }

  h2 .accent {
    color: var(--mint);
  }

  .pipe {
    display: flex;
    align-items: stretch;
    justify-content: center;
    flex-wrap: wrap;
    gap: clamp(10px, 2vw, 18px);
    margin-top: clamp(30px, 5vh, 48px);
  }

  .stop {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    min-width: 118px;
    padding: 18px 20px 14px;
    border-radius: 18px;
    background: rgba(255, 253, 247, 0.07);
    border: 1.5px solid rgba(255, 253, 247, 0.18);
    animation: stop-in 0.6s var(--spring) both;
    animation-delay: calc(var(--i) * 130ms);
  }

  @keyframes stop-in {
    from {
      opacity: 0;
      transform: translateY(14px) scale(0.94);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .ico {
    font-size: 30px;
    line-height: 1;
  }

  .lbl {
    font-weight: 700;
    font-size: 15px;
    color: #fffdf7;
  }

  .note {
    font-size: 10px;
    color: rgba(234, 255, 242, 0.55);
    text-transform: none;
    letter-spacing: 0.04em;
  }

  .flow {
    display: flex;
    align-items: center;
    gap: 5px;
    align-self: center;
  }

  .flow i {
    width: 7px;
    height: 7px;
    border-radius: 999px;
    background: var(--mint);
    animation: dotflow 1.15s var(--ease-inout) infinite;
    animation-delay: calc(var(--i, 0) * 0s + 0.12s);
  }

  .flow i:nth-child(2) {
    animation-delay: 0.24s;
  }
  .flow i:nth-child(3) {
    animation-delay: 0.36s;
  }

  @keyframes dotflow {
    0%,
    100% {
      opacity: 0.2;
      transform: scale(0.7);
    }
    45% {
      opacity: 1;
      transform: scale(1.15);
    }
  }

  .nevers {
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
    margin-top: clamp(30px, 5vh, 44px);
    padding: 0;
  }

  .nevers li {
    padding: 8px 18px;
    border-radius: 999px;
    border: 1.5px dashed rgba(234, 255, 242, 0.4);
    font-weight: 600;
    font-size: 14.5px;
    color: rgba(234, 255, 242, 0.85);
    transition:
      border-color 0.25s var(--ease-out),
      color 0.25s var(--ease-out);
  }

  .nevers li:hover {
    border-color: var(--mint);
    color: var(--mint);
  }

  .pledge {
    margin-top: clamp(24px, 4vh, 36px);
    font-size: clamp(22px, 2.4vw, 29px);
    color: var(--mint-live);
    transform: rotate(-2deg);
  }
</style>
