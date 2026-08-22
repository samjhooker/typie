<script>
  import Logo from './Logo.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import { app } from './state.svelte.js';

  const status = $derived(
    app.mood === 'listening' ? 'rec'
    : app.mood === 'typing' ? 'typing'
    : app.mood === 'done' && app.lastMs != null ? `${app.lastMs}ms`
    : ''
  );
</script>

<header>
  <div class="pill">
    <a href="#top" class="word" aria-label="Typie home">
      <Logo size={24} />
    </a>

    {#if status}
      <span class="live mono"><i></i>{status}</span>
    {/if}

    <nav class="links">
      <a href="#how">How</a>
      <a href="#features">Features</a>
      <a href="#pricing" class="pricing">Pricing<i class="hand">it's free</i></a>
      <a href="#faq">FAQ</a>
    </nav>

    <DownloadCta class="cta" />
  </div>
</header>

<style>
  header {
    position: fixed;
    top: 16px;
    left: 0;
    right: 0;
    z-index: 110;
    display: flex;
    justify-content: center;
    pointer-events: none;
    padding-inline: 16px;
  }

  .pill {
    pointer-events: auto;
    width: min(1120px, 100%);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 8px 8px 8px 20px;
    background: rgba(255, 253, 247, 0.94);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border-radius: 999px;
    border: 2px solid var(--ink);
    box-shadow: 0 5px 0 rgba(19, 23, 34, 0.85);
  }

  .word {
    display: inline-flex;
    align-items: center;
    min-width: 0;
    flex-shrink: 0;
  }

  .live {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--hotpink);
    letter-spacing: 0.12em;
    text-transform: uppercase;
    animation: stamp 0.35s var(--spring);
  }

  .live i {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--hotpink);
    animation: pulse 1s ease-in-out infinite;
  }

  @keyframes pulse {
    50% { opacity: 0.3; }
  }

  .links {
    display: flex;
    gap: 4px;
    margin-left: auto;
  }

  .links a {
    font-family: var(--display);
    font-weight: 800;
    font-size: 13px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--ink);
    padding: 8px 14px;
    border-radius: 999px;
    transition: background 0.2s ease, transform 0.25s var(--spring), box-shadow 0.2s ease;
  }

  .links a:hover {
    background: var(--butter);
    box-shadow: 0 3px 0 rgba(19, 23, 34, 0.7);
    transform: translateY(-2px) rotate(-1deg);
  }

  .pricing {
    position: relative;
    text-decoration: line-through;
    text-decoration-color: var(--hotpink);
    text-decoration-thickness: 2.5px;
  }

  .pricing i {
    position: absolute;
    top: -9px;
    right: -18px;
    font-size: 14px;
    font-weight: 700;
    color: var(--hotpink);
    transform: rotate(10deg);
    pointer-events: none;
    white-space: nowrap;
  }

  .pill :global(a.cta) {
    padding: 11px 18px;
    font-size: 12.5px;
    flex-shrink: 0;
    box-shadow: none;
  }

  .pill :global(a.cta:hover),
  .pill :global(a.cta:active) {
    box-shadow: none;
    transform: none;
    rotate: none;
  }

  .pill :global(.apl) {
    width: 14px;
    height: 14px;
    margin-top: -1px;
  }

  @media (max-width: 860px) {
    .links { display: none; }
  }

  @media (max-width: 480px) {
    .pill :global(a.cta) { padding: 10px 14px; font-size: 11.5px; }
  }
</style>
