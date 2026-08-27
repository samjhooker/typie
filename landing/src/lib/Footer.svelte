<script>
  import Logo from './Logo.svelte';
</script>

<footer>
  <div class="container top">
    <div class="brand">
      <a href="/" aria-label="Typie home"><Logo size={22} color="#0a0a0a" /></a>
      <p class="mono">© {new Date().getFullYear()} Typie. Free. Offline. Yours.</p>
    </div>
    <nav class="cols" aria-label="footer">
      <div class="col">
        <div class="mono" style="color:#0a0a0a; margin-bottom:10px">Product</div>
        <a href="#features">Features</a>
        <a href="#how">How it works</a>
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
    <div class="mono">Built for macOS · Apple silicon · No tracking. No cloud.</div>
    <div class="mono">typie.cc</div>
  </div>
</footer>

<style>
  footer { background: #fbfbfa; border-top: 1px solid var(--line); color: #52525b; }
  .top {
    display: grid; grid-template-columns: 1.2fr auto auto auto;
    gap: 32px; padding: 36px 0 28px;
  }
  .brand p { margin-top: 10px; text-transform: none; letter-spacing: 0.02em; }
  .cols { display: contents; }
  .col { display: flex; flex-direction: column; gap: 8px; min-width: 140px; }
  .col a { font-size: 14px; color: #52525b; }
  .col a:hover { color: #0a0a0a; }
  .bottom {
    display: flex; justify-content: space-between; gap: 12px;
    border-top: 1px solid var(--line);
    padding: 14px 0 28px;
    flex-wrap: wrap;
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
