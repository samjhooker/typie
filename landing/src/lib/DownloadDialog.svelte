<script>
  import {
    downloadDialog,
    closeDownloadDialog,
  } from './download.svelte.js';
  import Robot from './Robot.svelte';
  import { X, Terminal, Copy, Check, ArrowUpRight } from 'lucide-svelte';

  const CMD = 'curl -fsSL https://typie.cc/install.sh | bash';
  const RELEASES = 'https://github.com/samjhooker/typie/releases/latest';

  let copied = $state(false);

  function close() {
    closeDownloadDialog();
    copied = false;
  }

  function onKey(e) {
    if (e.key === 'Escape') close();
  }

  async function copy() {
    try {
      await navigator.clipboard.writeText(CMD);
      copied = true;
      setTimeout(() => (copied = false), 1800);
    } catch {
      // clipboard unavailable (insecure context) — user can select manually
    }
  }
</script>

<svelte:window onkeydown={downloadDialog.open ? onKey : undefined} />

{#if downloadDialog.open}
  <div
    class="dl-backdrop"
    role="presentation"
    onclick={(e) => {
      if (e.target === e.currentTarget) close();
    }}
  >
    <div
      class="dl-card"
      role="dialog"
      aria-modal="true"
      aria-label="Download typie"
    >
      <header class="dl-head">
        <span class="dl-bot"><Robot
            size={18}
            mood="idle"
          /></span>
        <h3>Get typie on your Mac</h3>
        <button
          class="dl-x"
          type="button"
          onclick={close}
          aria-label="Close"
        >
          <X size={17} />
        </button>
      </header>

      <!-- option 1: terminal one-liner -->
      <div class="opt primary">
        <div class="opt-head">
          <span class="opt-ic"><Terminal size={16} /></span>
          <div class="opt-titles">
            <b>Easiest: paste one line in Terminal</b>
            <span class="opt-badge">no Gatekeeper prompt</span>
          </div>
        </div>
        <div class="cmdbox">
          <code class="mono">{CMD}</code>
          <button
            class="copybtn"
            type="button"
            onclick={copy}
            aria-label="Copy install command"
          >
            {#if copied}<Check
                size={14}
                color="#10b981"
              />{:else}<Copy size={14} />{/if}
            {copied ? 'copied' : 'copy'}
          </button>
        </div>
        <p class="opt-note">
          Downloads the latest build, installs it to /Applications and skips
          the security prompt entirely. Then just open typie.
        </p>
      </div>

      <div class="or mono">or</div>

      <!-- option 2: github download -->
      <div class="opt">
        <div class="opt-head">
          <span class="opt-ic gh"><ArrowUpRight size={16} /></span>
          <div class="opt-titles">
            <b>Download from GitHub</b>
            <span class="opt-badge dim">typie.dmg</span>
          </div>
        </div>
        <a
          class="ghbtn"
          href={RELEASES}
          target="_blank"
          rel="noopener"
        >
          Open GitHub releases
          <ArrowUpRight size={14} />
        </a>
        <p class="opt-note">
          Drag typie into Applications. First launch only: right-click the app
          and choose Open, or use “Open Anyway” in Privacy &amp; Security.
        </p>
      </div>

      <p class="dl-foot mono">free · MIT · Apple Silicon · macOS 14+</p>
    </div>
  </div>
{/if}

<style>
  .dl-backdrop {
    position: fixed;
    inset: 0;
    z-index: 300;
    background: rgba(10, 12, 18, 0.55);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    display: grid;
    place-items: center;
    padding: 20px;
    animation: fadeIn 0.2s ease both;
  }
  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  .dl-card {
    width: min(460px, 100%);
    background: var(--surface);
    border: 1px solid var(--line-strong);
    border-radius: 20px;
    padding: 22px;
    box-shadow: 0 32px 80px -12px rgba(0, 0, 0, 0.5);
    animation: popIn 0.28s var(--spring) both;
    max-height: calc(100vh - 40px);
    overflow-y: auto;
  }
  @keyframes popIn {
    from {
      opacity: 0;
      transform: translateY(14px) scale(0.97);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  .dl-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
  }
  .dl-bot {
    display: grid;
    place-items: center;
    width: 34px;
    height: 34px;
    border-radius: 10px;
    background: var(--pink);
    color: var(--ink);
    flex: none;
  }
  .dl-head h3 {
    flex: 1;
    font-family: var(--display);
    font-size: 18px;
    font-weight: 800;
    letter-spacing: -0.02em;
    color: var(--ink);
  }
  .dl-x {
    display: grid;
    place-items: center;
    width: 30px;
    height: 30px;
    border-radius: 99px;
    border: 1px solid var(--line);
    background: transparent;
    color: var(--text-2);
    cursor: pointer;
    transition: 0.15s ease;
  }
  .dl-x:hover {
    border-color: var(--hotpink);
    color: var(--hotpink);
  }

  .opt {
    border: 1px solid var(--line);
    border-radius: 14px;
    padding: 14px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    background: var(--surface-2);
  }
  .opt.primary {
    border-color: rgba(252, 86, 129, 0.4);
    box-shadow: 0 0 0 3px rgba(252, 86, 129, 0.08);
  }
  .opt-head {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .opt-ic {
    display: grid;
    place-items: center;
    width: 30px;
    height: 30px;
    border-radius: 9px;
    background: var(--ink-app);
    color: #fff;
    flex: none;
  }
  .opt-ic.gh {
    background: #111827;
  }
  .opt-titles {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    min-width: 0;
  }
  .opt-titles b {
    font-size: 14px;
    font-weight: 800;
    color: var(--ink);
    letter-spacing: -0.01em;
  }
  .opt-badge {
    font-family: var(--mono);
    font-size: 9.5px;
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--hotpink);
    background: rgba(252, 86, 129, 0.1);
    border: 1px solid rgba(252, 86, 129, 0.25);
    padding: 2px 7px;
    border-radius: 99px;
    white-space: nowrap;
  }
  .opt-badge.dim {
    color: var(--text-3);
    background: var(--surface);
    border-color: var(--line);
  }

  .cmdbox {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #0f1115;
    border-radius: 10px;
    padding: 10px 12px;
  }
  .cmdbox code {
    flex: 1;
    min-width: 0;
    font-family: var(--mono);
    font-size: 12px;
    color: #e5e7eb;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .copybtn {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    flex: none;
    font-family: var(--mono);
    font-size: 11px;
    font-weight: 700;
    color: #e5e7eb;
    background: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 7px;
    padding: 5px 9px;
    cursor: pointer;
    transition: 0.15s ease;
  }
  .copybtn:hover {
    background: rgba(255, 255, 255, 0.14);
  }
  .opt-note {
    font-size: 12.5px;
    line-height: 1.55;
    color: var(--text-2);
  }

  .or {
    text-align: center;
    font-size: 10px;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: var(--text-3);
    margin: 2px 0;
  }

  .ghbtn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    padding: 10px 16px;
    border-radius: var(--radius-pill);
    background: var(--ink);
    color: #f8fafc;
    font-size: 13.5px;
    font-weight: 700;
    text-decoration: none;
    transition: transform 0.18s var(--spring);
  }
  .ghbtn:hover {
    transform: translateY(-1px);
  }

  .dl-foot {
    margin: 14px 0 0;
    text-align: center;
    font-size: 10px;
    letter-spacing: 0.08em;
    color: var(--text-3);
  }

  :global([data-theme='dark']) .dl-card {
    background: #14161f;
    border-color: rgba(255, 255, 255, 0.12);
  }
  :global([data-theme='dark']) .opt {
    background: rgba(255, 255, 255, 0.03);
  }
  :global([data-theme='dark']) .ghbtn {
    background: #f8fafc;
    color: var(--ink);
  }
</style>
