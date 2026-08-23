<script>
  import Logo from './Logo.svelte';
  import DownloadCta from './DownloadCta.svelte';

  let scrolled = $state(false);
</script>

<svelte:window onscroll={() => (scrolled = window.scrollY > 24)} />

<header class:scrolled>
  <div class="container bar">
    <a href="#top" class="word" aria-label="Typie home">
      <Logo size={26} />
    </a>

    <nav class="links" aria-label="primary">
      <a href="#how">How it works</a>
      <a href="#features">Features</a>
      <a href="#use-cases">Use cases</a>
      <a href="#pricing">Pricing</a>
    </nav>

    <DownloadCta kind="green" />
  </div>
</header>

<style>
  header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 110;
    padding-block: 18px;
    background: transparent;
    transition:
      background 0.3s ease,
      box-shadow 0.3s ease,
      padding 0.3s ease;
  }

  header.scrolled {
    padding-block: 10px;
    background: rgba(255, 253, 247, 0.9);
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

  .links {
    display: flex;
    gap: clamp(20px, 3vw, 40px);
    font-size: 15px;
    font-weight: 500;
    color: var(--ink);
  }

  .links a {
    position: relative;
    opacity: 0.82;
    transition: opacity 0.2s ease, color 0.2s ease;
  }

  .links a:hover {
    opacity: 1;
    color: var(--hotpink);
  }

  @media (max-width: 860px) {
    .links {
      display: none;
    }
  }
</style>
