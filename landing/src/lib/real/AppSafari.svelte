<script>
  /* Safari UI, dictation pastes the spoken query straight into the Google search box */
  let { typed = '', listening = false, pasted = false } = $props();

  const suggestions = [
    'launch checklist template',
    'launch checklist excel',
    'launch checklist notion',
    'launch checklist for startups',
  ];

  const matched = suggestions.filter((s) =>
    typed ? s.toLowerCase().includes(typed.toLowerCase().split(' ')[0]) : false
  );
  let shown = $derived(typed ? (matched.length ? matched : suggestions) : []);
</script>

<div class="asafari">
  <!-- Safari toolbar -->
  <div class="tb">
    <div class="navbtns">
      <span class="nb disabled">‹</span>
      <span class="nb disabled">›</span>
    </div>
    <div
      class="addr"
      class:armed={listening || typed}
      class:pasted
    >
      <span class="lock">🔒</span>
      <span class="url">www.google.com</span>
      <span class="reload">⟳</span>
    </div>
    <div class="tbtools">
      <span class="tbt">⊕</span>
      <span class="tbt">⧉</span>
    </div>
  </div>

  <!-- google page -->
  <div class="page">
    <div class="glogo">
      <span class="g-let b">G</span>
      <span class="g-let r">o</span>
      <span class="g-let y">o</span>
      <span class="g-let b">g</span>
      <span class="g-let g">l</span>
      <span class="g-let r">e</span>
    </div>

    <div
      class="searchbox"
      class:armed={listening || typed}
      class:pasted
    >
      <span class="sb-ic">⌕</span>
      {#if typed}
        <span
          class="sb-field typed"
          class:pop={pasted}>{typed}<span class="caret"></span></span
        >
      {:else}
        <span class="sb-field" class:dim={listening}
          >{listening ? 'listening…' : 'Search Google or type a URL'}</span
        >
      {/if}
      <span class="sb-mic" class:live={listening}>🎙</span>
      {#if pasted && shown.length}
        <div class="suggest">
          {#each shown.slice(0, 4) as s}
            <div class="sug-row">
              <span class="sug-ic">⌕</span><span class="sug-t">{s}</span>
            </div>
          {/each}
        </div>
      {/if}
    </div>

    <div class="gbtns">
      <span class="gbtn">Google Search</span>
      <span class="gbtn">I'm Feeling Lucky</span>
    </div>

    {#if pasted}
      <div class="results fade-in">
        <p class="res-count">
          About 1,420,000 results (0.42 seconds)
        </p>
        <div class="res">
          <span class="res-url">notion.so › templates › launch-checklist</span>
          <h4>Launch checklist, Notion Template</h4>
          <p class="res-snippet">
            A ready-to-use launch checklist for startups. {typed}
          </p>
        </div>
        <div class="res">
          <span class="res-url">exceljet.io › templates › launch</span>
          <h4>How to build a launch checklist in Excel</h4>
          <p class="res-snippet">
            Step-by-step guide and a free template for your launch.
          </p>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  .asafari {
    height: 100%;
    background: var(--surface);
    font-family: 'Inter', system-ui, sans-serif;
    color: #202124;
    display: flex;
    flex-direction: column;
  }

  /* toolbar */
  .tb {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 12px;
    background: #f5f5f7;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    flex: none;
  }
  .navbtns {
    display: flex;
    gap: 6px;
  }
  .nb {
    width: 24px;
    height: 24px;
    border-radius: 6px;
    display: grid;
    place-items: center;
    color: #5f6368;
    font-size: 15px;
    background: rgba(0, 0, 0, 0.04);
  }
  .nb.disabled {
    opacity: 0.3;
  }
  .addr {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    background: var(--surface);
    border: 1px solid rgba(0, 0, 0, 0.14);
    border-radius: 999px;
    padding: 6px 14px;
    font-size: 13px;
    color: #5f6368;
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .addr.armed {
    border-color: #0a84ff;
    box-shadow: 0 0 0 3px rgba(10, 132, 255, 0.16);
  }
  .addr.pasted {
    border-color: #10b981;
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.18);
  }
  .lock {
    font-size: 10px;
  }
  .url {
    flex: 1;
    font-weight: 500;
    color: #202124;
  }
  .reload {
    font-size: 13px;
    color: #5f6368;
  }
  .tbtools {
    display: flex;
    gap: 6px;
  }
  .tbt {
    width: 24px;
    height: 24px;
    border-radius: 6px;
    display: grid;
    place-items: center;
    color: #5f6368;
    font-size: 13px;
    background: rgba(0, 0, 0, 0.04);
  }

  .page {
    flex: 1;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 22px 16px 14px;
    gap: 18px;
  }

  .glogo {
    display: flex;
    font-family: 'Space Grotesk', system-ui, sans-serif;
    font-size: 38px;
    font-weight: 700;
    letter-spacing: -0.02em;
  }
  .g-let.b {
    color: #4285f4;
  }
  .g-let.r {
    color: #ea4335;
  }
  .g-let.y {
    color: #fbbc05;
  }
  .g-let.g {
    color: #34a853;
  }

  .searchbox {
    position: relative;
    width: min(86%, 440px);
    display: flex;
    align-items: center;
    gap: 12px;
    background: var(--surface);
    border: 1px solid #dfe1e5;
    border-radius: 999px;
    padding: 11px 18px;
    box-shadow: 0 1px 6px rgba(32, 33, 36, 0.06);
    transition:
      border-color 0.25s ease,
      box-shadow 0.25s ease;
  }
  .searchbox.armed {
    border-color: #0a84ff;
    box-shadow: 0 1px 6px rgba(32, 33, 36, 0.08),
      0 0 0 3px rgba(10, 132, 255, 0.16);
  }
  .searchbox.pasted {
    border-color: #10b981;
    box-shadow: 0 1px 6px rgba(32, 33, 36, 0.08),
      0 0 0 3px rgba(16, 185, 129, 0.18);
  }
  .sb-ic {
    color: #9aa0a6;
    font-size: 16px;
  }
  .sb-field {
    flex: 1;
    min-width: 0;
    font-size: 15px;
    color: #9aa0a6;
    white-space: nowrap;
    overflow: hidden;
    position: relative;
  }
  .sb-field.typed {
    color: #202124;
  }
  .sb-field.dim {
    color: #5f6368;
    font-style: italic;
  }
  .sb-mic {
    color: #5f6368;
    font-size: 16px;
  }
  .sb-mic.live {
    color: #0a84ff;
    animation: micpulse 0.8s ease-in-out infinite alternate;
  }
  @keyframes micpulse {
    to {
      transform: scale(1.18);
    }
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 1em;
    margin-left: 2px;
    vertical-align: -0.15em;
    background: #4285f4;
    animation: blink 0.9s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }

  .suggest {
    position: absolute;
    left: 0;
    right: 0;
    top: calc(100% + 6px);
    background: var(--surface);
    border: 1px solid #dfe1e5;
    border-radius: 14px;
    padding: 8px 0;
    box-shadow: 0 6px 20px rgba(32, 33, 36, 0.14);
    z-index: 4;
  }
  .sug-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 7px 18px;
    font-size: 14px;
    color: #202124;
  }
  .sug-row:first-child {
    background: #f5f5f7;
  }
  .sug-ic {
    color: #9aa0a6;
    font-size: 14px;
  }

  .gbtns {
    display: flex;
    gap: 10px;
  }
  .gbtn {
    background: #f8f9fa;
    border: 1px solid #f8f9fa;
    border-radius: 4px;
    padding: 9px 16px;
    font-size: 13.5px;
    color: #3c4043;
    cursor: pointer;
  }
  .gbtn:hover {
    border-color: #dadce0;
    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
  }

  .results {
    width: min(86%, 440px);
    text-align: left;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .res-count {
    font-size: 11.5px;
    color: #70757a;
  }
  .res-url {
    display: block;
    font-size: 11px;
    color: #202124;
    margin-bottom: 1px;
  }
  .res h4 {
    font-size: 16px;
    font-weight: 600;
    color: #1a0dab;
    line-height: 1.3;
  }
  .res-snippet {
    font-size: 12px;
    line-height: 1.5;
    color: #4d5156;
  }
  .fade-in {
    animation: fadeIn 0.35s var(--ease-out);
  }
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(8px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }
  .pop {
    animation: pastePop 0.6s cubic-bezier(0.22, 1, 0.36, 1) both;
  }
  @keyframes pastePop {
    0% {
      background: rgba(10, 132, 255, 0.18);
    }
    100% {
      background: transparent;
    }
  }

  /* ── Safari + Google dark mode (Safari chrome #1E1E1E/#2B2B2D,
     Google dark #202124 page, #E8EAED text, #303134 search) ── */
  :global([data-theme='dark']) .asafari {
    background: #202124;
    color: #e8eaed;
  }
  :global([data-theme='dark']) .tb {
    background: #2b2b2d;
    border-bottom-color: rgba(255, 255, 255, 0.1);
  }
  :global([data-theme='dark']) .addr {
    background: rgba(255, 255, 255, 0.08);
    color: #e8eaed;
  }
  :global([data-theme='dark']) .url,
  :global([data-theme='dark']) .sugg {
    color: #e8eaed;
  }
  :global([data-theme='dark']) .field,
  :global([data-theme='dark']) .placeholder {
    color: #9aa0a6;
  }
  :global([data-theme='dark']) .page {
    background: #202124;
  }
  :global([data-theme='dark']) .gtitle {
    color: #e8eaed;
  }
  :global([data-theme='dark']) .gbtn {
    background: #303134;
    color: #e8eaed;
  }

  /* dark, round 2: searchbox, suggestions, results */
  :global([data-theme='dark']) .searchbox {
    background: #303134;
    border-color: #5f6368;
    box-shadow: none;
  }
  :global([data-theme='dark']) .sb-field.typed {
    color: #e8eaed;
  }
  :global([data-theme='dark']) .suggest {
    background: #303134;
  }
  :global([data-theme='dark']) .sug-t {
    color: #e8eaed;
  }
  :global([data-theme='dark']) .res-count {
    color: #9aa0a6;
  }
  :global([data-theme='dark']) .res-url {
    color: #bdc1c6;
  }
  :global([data-theme='dark']) .res h4 {
    color: #8ab4f8;
  }
  :global([data-theme='dark']) .res-snippet {
    color: #bdc1c6;
  }

  /* dark, round 3: suggestion rows + result buttons */
  :global([data-theme='dark']) .sug-row:first-child {
    background: #3c4043;
  }
  :global([data-theme='dark']) .gbtn {
    background: #303134;
    border-color: #303134;
    color: #e8eaed;
  }
</style>
