<script>
  import Logo from './Logo.svelte';

  export let title = '';
</script>

<div class="page">
  <header class="top">
    <div class="bar">
      <a href="/"><Logo size={22} /></a>
      <a href="/" class="btn btn-ghost home">← back home</a>
    </div>
  </header>

  <main class="field field-mint body">
    <div class="container">
      <slot />
    </div>
  </main>

  <footer>
    <p>typie - a tiny robot with one job · © 2026 · no clouds were involved</p>
    <nav>
      <a href="/">home</a>
      <a href="/about">about</a>
      <a href="/privacy">privacy</a>
    </nav>
  </footer>
</div>

<style>
  .page {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .top {
    position: sticky;
    top: 0;
    z-index: 50;
    background: rgba(249, 248, 244, 0.9);
    backdrop-filter: blur(16px);
    border-bottom: 1px solid rgba(2, 89, 77, 0.08);
  }

  .bar {
    width: min(1180px, calc(100% - 40px));
    margin-inline: auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0;
  }

  .home {
    font-size: 12px;
    padding: 10px 18px;
  }

  .body {
    flex: 1;
  }

  footer {
    background: var(--ink);
    color: var(--cream);
    padding: 28px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    font-size: 13.5px;
  }

  footer nav {
    display: flex;
    gap: 18px;
  }

  footer a:hover {
    color: var(--mint);
  }
</style>
