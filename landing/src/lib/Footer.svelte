<script>
  import Logo from './Logo.svelte';

  const year = new Date().getFullYear();
</script>

<footer>
  <div class="container top">
    <div class="brand">
      <a href="/" aria-label="Typie home"><Logo size={24} /></a>
      <p class="tag">just talk. <em>it's typed.</em></p>
    </div>
    <nav class="cols" aria-label="footer">
      <div class="col">
        <div class="col-title mono">Product</div>
        <a href="#demo">The Mac Experience</a>
        <a href="#apps">Everywhere</a>
        <a href="#compare">Comparison</a>
        <a href="#engine">Engine</a>
      </div>
      <div class="col">
        <div class="col-title mono">Privacy</div>
        <a href="#privacy">Zero Cloud Architecture</a>
        <a href="/privacy">Privacy Policy</a>
        <a href="/terms">Terms of Use</a>
      </div>
      <div class="col">
        <div class="col-title mono">Resources</div>
        <a href="https://github.com/samjhooker/typie/releases/latest" target="_blank" rel="noopener"
          >Releases</a
        >
        <a href="https://github.com/samjhooker/typie" target="_blank" rel="noopener">GitHub (MIT)</a
        >
        <a href="mailto:hello@typie.cc">Contact</a>
      </div>
    </nav>
  </div>
  <div class="container bottom">
    <div class="mono">© {year} Typie · Built for macOS · Apple Silicon native</div>
    <div class="mono">typie.cc</div>
  </div>
  <div class="ghost" aria-hidden="true">typie</div>
</footer>

<style>
  footer {
    background: var(--surface);
    border-top: 1px solid var(--line);
    color: var(--text-2);
    overflow: hidden;
    position: relative;
  }
  .top {
    display: grid;
    grid-template-columns: 1.4fr auto auto auto;
    gap: 32px;
    padding: 48px 0 32px;
  }
  .tag {
    margin-top: 14px;
    font-family: var(--serif);
    font-style: italic;
    font-weight: 500;
    font-size: 17px;
    color: var(--ink);
  }
  .tag em {
    color: var(--hotpink);
  }
  .cols {
    display: contents;
  }
  .col {
    display: flex;
    flex-direction: column;
    gap: 10px;
    min-width: 140px;
  }
  .col-title {
    color: var(--ink);
    font-weight: 700;
    margin-bottom: 6px;
  }
  .col a {
    font-size: 14px;
    color: var(--text-2);
    transition: color 0.15s ease;
  }
  .col a:hover {
    color: var(--hotpink);
  }
  .bottom {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    border-top: 1px solid var(--line);
    padding: 18px 0 32px;
    flex-wrap: wrap;
    font-size: 12px;
    color: var(--text-3);
  }
  .ghost {
    font-family: var(--display);
    font-weight: 800;
    letter-spacing: -0.04em;
    font-size: clamp(96px, 18vw, 260px);
    line-height: 0.78;
    color: var(--hotpink);
    opacity: 0.04;
    text-align: center;
    user-select: none;
    pointer-events: none;
    margin-bottom: -0.06em;
  }
  @media (max-width: 860px) {
    .top {
      grid-template-columns: 1fr 1fr;
    }
    .brand {
      grid-column: 1 / -1;
    }
  }
  @media (max-width: 560px) {
    .top {
      grid-template-columns: 1fr;
    }
    .cols {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
    }
  }
</style>
