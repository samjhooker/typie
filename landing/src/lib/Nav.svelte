<script>
  import Logo from './Logo.svelte';
  let scrolled = $state(false);
</script>

<svelte:window onscroll={() => (scrolled = window.scrollY > 8)} />

<header class:scrolled>
  <div class="container bar">
    <a href="/" class="brand" aria-label="Typie home">
      <Logo size={26} color="#0a0a0a" />
    </a>

    <nav class="links" aria-label="primary">
      <a href="#use-cases">Everywhere</a>
      <a href="#privacy">Privacy</a>
      <a href="#faq">FAQ</a>
    </nav>

    <div class="right">
      <a href="https://github.com/samjhooker/typie" class="ghostlink">GitHub</a>
      <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-black navcta">
        Download for Mac
      </a>
    </div>
  </div>
</header>

<style>
  header {
    position: fixed;
    top: 0; left: 0; right: 0;
    z-index: 100;
    background: rgba(255,255,255,0.82);
    backdrop-filter: blur(12px) saturate(140%);
    -webkit-backdrop-filter: blur(12px) saturate(140%);
    border-bottom: 1px solid transparent;
    transition: border-color 0.2s ease, background 0.2s ease;
  }
  header.scrolled {
    border-color: var(--line);
    background: rgba(255,255,255,0.94);
  }
  .bar {
    display: flex; align-items: center; justify-content: space-between;
    gap: 16px;
    height: 56px;
  }
  .brand { display: inline-flex; align-items: center; line-height: 0; }

  .links {
    display: flex; align-items: center; gap: 28px;
    font-size: 13.5px; font-weight: 500; color: #18181b;
  }
  .links a { opacity: 0.78; transition: opacity 0.15s ease; }
  .links a:hover { opacity: 1; }

  .right { display: flex; align-items: center; gap: 16px; }
  .ghostlink {
    font-size: 13.5px; font-weight: 500; color: #52525b;
    display: inline-flex; align-items: center;
  }
  .ghostlink:hover { color: #0a0a0a; }
  .navcta { padding: 9px 16px; font-size: 13.5px; }

  @media (max-width: 860px) {
    .links { display: none; }
    .ghostlink { display: none; }
  }
</style>
