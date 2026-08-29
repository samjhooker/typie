<script>
  import Logo from './Logo.svelte';
  import DownloadCta from './DownloadCta.svelte';
  import Footer from './Footer.svelte';
</script>

<div class="page">
  <header>
    <div class="container bar">
      <a href="/" aria-label="Typie home"><Logo size={26} /></a>
      <div class="actions">
        <a href="/" class="back">← home</a>
        <DownloadCta kind="green" />
      </div>
    </div>
  </header>

  <main class="body">
    <div class="container">
      <slot />
    </div>
  </main>

  <Footer />
</div>

<style>
  .page {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    background: var(--page);
    color: var(--text-2);
  }

  header {
    position: sticky;
    top: 0;
    z-index: 50;
    padding-block: 14px;
    background: color-mix(in srgb, var(--page) 90%, transparent);
    backdrop-filter: blur(14px);
    -webkit-backdrop-filter: blur(14px);
    box-shadow: 0 1px 0 rgba(19, 23, 34, 0.08);
  }

  .bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
  }

  .actions {
    display: flex;
    align-items: center;
    gap: 14px;
  }

  .back {
    font-size: 14px;
    font-weight: 500;
    color: var(--ink);
    opacity: 0.72;
    transition:
      opacity 0.2s var(--ease-out),
      color 0.2s var(--ease-out);
  }

  .back:hover {
    opacity: 1;
    color: var(--hotpink);
  }

  .body {
    flex: 1;
    padding: clamp(48px, 8vh, 88px) 0 clamp(24px, 4vh, 48px);
  }

  @media (max-width: 640px) {
    .actions :global(.btn) {
      display: none;
    }
  }
</style>
