<script>
  import Logo from './Logo.svelte';

  const year = new Date().getFullYear();
</script>

<footer>
  <div class="container top">
    <div class="brand">
      <a href="/" aria-label="Typie home"><Logo size={22} color="#0a0a0a" /></a>
      <p class="tag">just talk. <em>it's typed.</em></p>
    </div>
    <nav class="cols" aria-label="footer">
      <div class="col">
        <div class="mono" style="color:#0a0a0a; margin-bottom:10px">Product</div>
        <a href="#use-cases">Everywhere</a>
        <a href="#engine">Engine</a>
        <a href="#privacy">Privacy</a>
        <a href="#faq">FAQ</a>
      </div>
      <div class="col">
        <div class="mono" style="color:#0a0a0a; margin-bottom:10px">Legal</div>
        <a href="/privacy">Privacy</a>
        <a href="/terms">Terms</a>
        <a href="https://github.com/samjhooker/typie">GitHub</a>
      </div>
      <div class="col">
        <div class="mono" style="color:#0a0a0a; margin-bottom:10px">Links</div>
        <a href="https://github.com/samjhooker/typie/releases/latest">Releases</a>
        <a href="/education">Education</a>
        <a href="/enterprise">Enterprise</a>
        <a href="mailto:hello@typie.cc">hello@typie.cc</a>
      </div>
    </nav>
  </div>
  <div class="container bottom">
    <div class="mono">© {year} typie · built for macOS · apple silicon</div>
    <div class="mono">typie.cc</div>
  </div>
  <div class="ghost" aria-hidden="true">typie</div>
</footer>

<style>
  footer {
    background: #fff;
    border-top: 1px solid var(--line);
    color: #52525b;
    overflow: hidden;
    position: relative;
  }
  .top {
    display: grid; grid-template-columns: 1.4fr auto auto auto;
    gap: 32px; padding: 44px 0 32px;
  }
  .tag {
    margin-top: 12px;
    font-family: var(--serif); font-style: italic; font-weight: 500;
    font-size: 17px; color: var(--ink);
  }
  .tag em { color: var(--hotpink); }
  .cols { display: contents; }
  .col { display: flex; flex-direction: column; gap: 8px; min-width: 140px; }
  .col a { font-size: 14px; color: #52525b; transition: color .15s ease; }
  .col a:hover { color: #0a0a0a; }
  .bottom {
    display: flex; justify-content: space-between; gap: 12px;
    border-top: 1px solid var(--line);
    padding: 16px 0 30px;
    flex-wrap: wrap;
  }
  .ghost {
    font-family: var(--display); font-weight: 800; letter-spacing: -0.04em;
    font-size: clamp(96px, 18vw, 260px); line-height: 0.78;
    color: var(--hotpink); opacity: 0.05;
    text-align: center; user-select: none; pointer-events: none;
    margin-bottom: -0.06em;
  }
  @media (max-width: 860px) {
    .top { grid-template-columns: 1fr 1fr; }
    .brand { grid-column: 1 / -1; }
  }
  @media (max-width: 560px) {
    .top { grid-template-columns: 1fr; }
    .cols { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
  }
</style>
