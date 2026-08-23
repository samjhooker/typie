<script>
  import Logo from './Logo.svelte';
  import Robot from './Robot.svelte';

  const cols = [
    {
      h: 'Product',
      links: [
        { l: 'Features', h: '#features' },
        { l: 'Use cases', h: '#use-cases' },
        { l: 'Pricing', h: '#pricing' }
      ]
    },
    {
      h: 'Resources',
      links: [
        { l: 'FAQ', h: '#faq' },
        { l: 'Privacy', h: '/privacy' },
        { l: 'Terms', h: '/about' }
      ]
    },
    {
      h: 'Company',
      links: [
        { l: 'About', h: '/about' },
        { l: 'Contact', h: '#faq' }
      ]
    }
  ];
</script>

<footer>
  <!-- robot peeking over the wave -->
  <div class="peek" aria-hidden="true">
    <Robot size={64} mood="idle" />
  </div>

  <svg class="wave" viewBox="0 0 1440 90" preserveAspectRatio="none" aria-hidden="true">
    <path
      d="M0 60C240 10 480 4 720 26s480 34 720 8v56H0Z"
      fill="var(--footer-green)"
    />
  </svg>

  <div class="body">
    <div class="container grid">
      <div class="brand">
        <a href="#top" aria-label="Typie home">
          <Logo size={24} color="#fffdf7" />
        </a>
        <p class="mono">© {new Date().getFullYear()} Typie. All rights reserved.</p>
      </div>

      <nav class="cols" aria-label="footer">
        {#each cols as col}
          <div class="col">
            <h3>{col.h}</h3>
            <ul>
              {#each col.links as link}
                <li><a href={link.h}>{link.l}</a></li>
              {/each}
            </ul>
          </div>
        {/each}
      </nav>

      <div class="social" aria-label="social links">
        <a href="https://x.com" aria-label="Typie on X">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.7 3H21l-7.2 8.2L22.2 21h-6.6l-5.2-6.1L4.5 21H1.2l7.7-8.8L1.8 3h6.8l4.7 5.5L17.7 3Zm-1.2 16h1.9L6.9 4.9H4.9L16.5 19Z"/></svg>
        </a>
        <a href="https://github.com/samjhooker/typie" aria-label="Typie on GitHub">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a10 10 0 0 0-3.16 19.49c.5.09.68-.22.68-.48v-1.7c-2.78.61-3.37-1.34-3.37-1.34-.45-1.15-1.11-1.46-1.11-1.46-.9-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.89 1.52 2.34 1.08 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.64 0 0 .84-.27 2.75 1.02a9.58 9.58 0 0 1 5 0c1.91-1.29 2.75-1.02 2.75-1.02.55 1.37.2 2.39.1 2.64.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85V21c0 .27.18.58.69.48A10 10 0 0 0 12 2Z"/></svg>
        </a>
      </div>
    </div>
  </div>
</footer>

<style>
  footer {
    position: relative;
    margin-top: clamp(40px, 6vh, 80px);
    color: rgba(255, 253, 247, 0.85);
  }

  .peek {
    position: absolute;
    right: clamp(20px, 8vw, 140px);
    top: -14px;
    z-index: 2;
    line-height: 0;
  }

  .wave {
    display: block;
    width: 100%;
    height: clamp(48px, 7vw, 90px);
  }

  .body {
    background: var(--footer-green);
    padding: clamp(28px, 4vw, 48px) 0 clamp(36px, 5vw, 56px);
    margin-top: -1px;
  }

  .grid {
    display: grid;
    grid-template-columns: 1.2fr repeat(3, auto) auto;
    gap: clamp(28px, 4vw, 64px);
    align-items: start;
  }

  .brand p.mono {
    margin-top: 14px;
    color: rgba(255, 253, 247, 0.55);
    text-transform: none;
    letter-spacing: 0.03em;
  }

  .cols {
    display: contents;
  }

  .col h3 {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    margin-bottom: 12px;
    color: #fffdf7;
  }

  ul {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 8px;
    font-size: 14.5px;
  }

  ul a {
    opacity: 0.78;
    transition: opacity 0.2s ease, color 0.2s ease;
  }

  ul a:hover {
    opacity: 1;
    color: var(--butter);
  }

  .social {
    display: flex;
    gap: 16px;
    justify-self: end;
  }

  .social a {
    opacity: 0.8;
    transition: opacity 0.2s ease, transform 0.2s var(--spring);
    line-height: 0;
  }

  .social a:hover {
    opacity: 1;
    transform: translateY(-2px);
  }

  .social svg {
    width: 20px;
    height: 20px;
  }

  @media (max-width: 860px) {
    .grid {
      grid-template-columns: 1fr 1fr;
    }

    .brand {
      grid-column: 1 / -1;
    }

    .social {
      justify-self: start;
      grid-column: 1 / -1;
    }
  }
</style>
