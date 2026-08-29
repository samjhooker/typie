<script>
  /* full Google Docs UI — used inside the hero Mac; the doc receives the dictation */
  let { typed = '', listening = false, pasted = false } = $props();

  const paras = [
    { cls: 'title', text: 'Launch plan' },
    { cls: 'sub', text: 'Friday ship · owned by everyone' },
    { cls: 'body', text: 'Two items left before we ship: the pricing page and the demo video.' },
    { cls: 'body', text: "Everything else is locked. Let's sync at 4 to make sure nothing slips." },
  ];
</script>

<div class="adocs">
  <div class="topbar">
    <div class="doctitle">Launch plan 🍃</div>
    <div class="spacer"></div>
    <span class="star">★</span>
    <span class="comment">💬 0</span>
    <span class="share">Share</span>
  </div>
  <div class="toolbar">
    <span class="file">File</span><span>Edit</span><span>View</span><span>Insert</span><span
      >Format</span
    ><span>Tools</span>
    <span class="spacer"></span>
    <span class="tbtool">100%</span>
  </div>
  <div class="canvas-scroll">
    <div class="page">
      {#each paras as p}
        <p class={p.cls}>{p.text}</p>
      {/each}
      {#if typed}
        <p class="body fresh" class:pop={pasted}>{typed}<span class="caret"></span></p>
      {:else if listening}
        <p class="body listening">listening…</p>
      {/if}
    </div>
  </div>
</div>

<style>
  .adocs {
    height: 100%;
    background: #eee;
    font-family: 'Inter', system-ui, sans-serif;
    color: #1f1f1f;
    display: flex;
    flex-direction: column;
  }
  .topbar {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 16px;
    background: #edf2fa;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
  }
  .doctitle {
    font-size: 15px;
    font-weight: 500;
    color: #444746;
  }
  .spacer {
    flex: 1;
  }
  .star,
  .comment {
    color: #444746;
    font-size: 12px;
  }
  .share {
    background: #c2e7ff;
    color: #001d35;
    border-radius: 99px;
    padding: 5px 16px;
    font-size: 12px;
    font-weight: 600;
  }

  .toolbar {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 6px 16px;
    background: #fff;
    border-bottom: 1px solid rgba(0, 0, 0, 0.12);
    font-size: 12px;
    color: #444746;
  }
  .file {
    font-weight: 600;
  }

  .canvas-scroll {
    flex: 1;
    overflow: hidden;
    padding: 12px 0 0;
  }
  .page {
    width: min(420px, 84%);
    margin: 0 auto;
    background: #fff;
    min-height: auto;
    padding: 20px 28px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.18);
    display: flex;
    flex-direction: column;
    gap: 10px;
    border-radius: 6px;
  }
  .title {
    font-size: 20px;
    font-weight: 600;
    font-family: 'Bricolage Grotesque', sans-serif;
    color: #1f1f1f;
    margin-bottom: 1px;
  }
  .sub {
    font-size: 11px;
    color: #5f6368;
  }
  .body {
    font-size: 12.5px;
    line-height: 1.6;
    color: #202124;
  }
  .listening {
    color: #9aa0a6;
    font-style: italic;
  }
  .fresh {
    animation: fadeup 0.45s var(--spring, ease) both;
  }
  .pop {
    animation: pastePop 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
    border-radius: 4px;
    box-decoration-break: clone;
    -webkit-box-decoration-break: clone;
  }
  @keyframes fadeup {
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
      transform: scale(0.97);
    }
    45% {
      background: rgba(16, 185, 129, 0.2);
      transform: scale(1.015);
    }
    100% {
      background: transparent;
      transform: none;
    }
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #1a73e8;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
</style>
