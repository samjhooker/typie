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
      <p class="easylead">Easiest way: paste that one line in Terminal.</p>

      <a
        class="ghlink"
        href={RELEASES}
        target="_blank"
        rel="noopener"
      >
        or download from GitHub
        <ArrowUpRight size={13} />
      </a>

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
    width: min(440px, 100%);
    background: var(--surface);
    border: 1px solid var(--line-strong);
    border-radius: 20px;
    padding: 22px;
    box-shadow: 0 32px 80px -12px rgba(0, 0, 0, 0.5);
    animation: popIn 0.28s var(--spring) both;
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
    border: 1px solid var(--line);
    color: var(--hotpink);
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

  .cmdbox {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #0f1115;
    border-radius: 10px;
    padding: 12px 14px;
  }
  .cmdbox code {
    flex: 1;
    min-width: 0;
    font-family: var(--mono);
    font-size: 12.5px;
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

  .easylead {
    margin: 12px 0 0;
    font-size: 13.5px;
    font-weight: 600;
    color: var(--ink);
  }

  .ghlink {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    margin-top: 14px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-3);
    text-decoration: none;
    transition: color 0.15s ease;
  }
  .ghlink:hover {
    color: var(--hotpink);
  }

  .dl-foot {
    margin: 18px 0 0;
    text-align: center;
    font-size: 10px;
    letter-spacing: 0.08em;
    color: var(--text-3);
  }

  :global([data-theme='dark']) .dl-card {
    background: #14161f;
    border-color: rgba(255, 255, 255, 0.12);
  }
</style>
