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
      <a href="#features">Features</a>
      <a href="#languages">Languages</a>
      <a href="#pricing" class="price-link">
        <span class="struck">Pricing</span>
        <span class="freehand hand">it's free</span>
      </a>
      <a href="#faq">FAQ</a>
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
      background 0.35s var(--ease-out),
      box-shadow 0.35s var(--ease-out),
      padding 0.35s var(--ease-out);
  }

  header.scrolled {
    padding-block: 10px;
    background: color-mix(in srgb, var(--page) 88%, transparent);
    backdrop-filter: blur(18px) saturate(160%);
    -webkit-backdrop-filter: blur(18px) saturate(160%);
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
    align-items: center;
    gap: clamp(20px, 3vw, 40px);
    font-size: 15px;
    font-weight: 500;
    color: var(--ink);
  }

  .links a {
    position: relative;
    opacity: 0.82;
    transition:
      opacity 0.3s var(--ease-out),
      color 0.3s var(--ease-out);
  }

  /* sliding underline: sweeps in from the left, exits right */
  .links a::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: -5px;
    width: 100%;
    height: 2px;
    border-radius: 2px;
    background: currentColor;
    transform: scaleX(0);
    transform-origin: right;
    transition: transform 0.35s var(--snap);
  }

  .links a:hover {
    opacity: 1;
    color: var(--hotpink);
  }

  .links a:hover::after {
    transform: scaleX(1);
    transform-origin: left;
  }

  .price-link {
    position: relative;
  }

  .struck {
    text-decoration: line-through;
    text-decoration-color: var(--hotpink);
    text-decoration-thickness: 2px;
    text-underline-offset: -2px;
  }

  .freehand {
    position: absolute;
    top: calc(100% - 2px);
    left: 50%;
    font-size: 13px;
    color: var(--hotpink);
    transform: translateX(-50%) rotate(-9deg);
    white-space: nowrap;
    pointer-events: none;
  }

  @media (max-width: 860px) {
    .links {
      display: none;
    }
  }
</style>
