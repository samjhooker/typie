<script>
  import Logo from './Logo.svelte';
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

    <a href="#get" class="btn btn-green cta">Download for free</a>
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
    padding: 8px 8px 8px 18px;
    background: rgba(249, 248, 244, 0.9);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border-radius: 999px;
    border: 1px solid rgba(2, 89, 77, 0.1);
    box-shadow: 0 10px 40px rgba(2, 89, 77, 0.14);
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
    font-weight: 700;
    font-size: 13.5px;
    letter-spacing: 0.02em;
    color: var(--green-deep);
    padding: 8px 13px;
    border-radius: 999px;
    transition: background 0.2s ease, transform 0.25s var(--spring);
  }

  .links a:hover {
    background: rgba(130, 237, 166, 0.45);
    transform: translateY(-1px);
  }

  .pricing {
    position: relative;
    text-decoration: line-through;
    text-decoration-color: var(--hotpink);
    text-decoration-thickness: 2.5px;
  }

  .pricing i {
    position: absolute;
    top: -7px;
    right: -14px;
    font-size: 13px;
    font-weight: 700;
    color: var(--hotpink);
    transform: rotate(8deg);
    pointer-events: none;
    white-space: nowrap;
  }

  .cta {
    padding: 11px 20px;
    font-size: 13px;
    flex-shrink: 0;
  }

  @media (max-width: 860px) {
    .links { display: none; }
  }

  @media (max-width: 480px) {
    .cta { padding: 10px 14px; font-size: 12px; }
  }
</style>
