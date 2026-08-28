<script>
  import Logo from './Logo.svelte';
  import { onMount } from 'svelte';

  let scrolled = $state(false);
  let progress = $state(0);
  let active = $state('');

  const CHAPTERS = ['use-cases', 'engine', 'privacy', 'faq'];

  onMount(() => {
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) active = e.target.id;
        }
      },
      { rootMargin: '-38% 0px -52% 0px' }
    );
    CHAPTERS.forEach((id) => {
      const el = document.getElementById(id);
      if (el) io.observe(el);
    });
    return () => io.disconnect();
  });
</script>

<svelte:window
  onscroll={() => {
    scrolled = window.scrollY > 8;
    const max = document.documentElement.scrollHeight - innerHeight;
    progress = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
  }}
/>

<header class:scrolled>
  <div class="container bar">
    <a href="/" class="brand" aria-label="Typie home">
      <Logo size={26} color="#0a0a0a" />
    </a>

    <nav class="links" aria-label="primary">
      {#each [['use-cases', 'Everywhere'], ['engine', 'Engine'], ['privacy', 'Privacy'], ['faq', 'FAQ']] as [id, label] (id)}
        <a href="#{id}" class:active={active === id}>{label}</a>
      {/each}
    </nav>

    <div class="right">
      <a href="https://github.com/samjhooker/typie" class="ghostlink">GitHub</a>
      <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-black navcta">
        <i class="pulse" aria-hidden="true"></i>
        Download for Mac
      </a>
    </div>
  </div>
  <div class="progress" aria-hidden="true"><i style="width:{progress * 100}%"></i></div>
</header>

<style>
  header {
    position: fixed;
    top: 0; left: 0; right: 0;
    z-index: 100;
    background: rgba(251, 249, 246, 0.8);
    backdrop-filter: blur(14px) saturate(140%);
    -webkit-backdrop-filter: blur(14px) saturate(140%);
    border-bottom: 1px solid transparent;
    transition: border-color 0.2s ease, background 0.2s ease;
  }
  header.scrolled {
    border-color: var(--line);
    background: rgba(251, 249, 246, 0.92);
  }
  .bar {
    display: flex; align-items: center; justify-content: space-between;
    gap: 16px;
    height: 58px;
  }
  .brand { display: inline-flex; align-items: center; line-height: 0; }

  .links {
    display: flex; align-items: center; gap: 30px;
    font-size: 13.5px; font-weight: 500; color: #18181b;
  }
  .links a { opacity: 0.66; transition: opacity 0.15s ease; position: relative; padding: 4px 0; }
  .links a:hover { opacity: 1; }
  .links a::before {
    content: '';
    position: absolute; left: 50%; bottom: -2px;
    width: 4px; height: 4px; border-radius: 50%;
    background: var(--hotpink);
    transform: translateX(-50%) scale(0);
    transition: transform 0.25s var(--spring);
  }
  .links a.active { opacity: 1; }
  .links a.active::before { transform: translateX(-50%) scale(1); }

  .right { display: flex; align-items: center; gap: 16px; }
  .ghostlink {
    font-size: 13.5px; font-weight: 500; color: #52525b;
    display: inline-flex; align-items: center;
  }
  .ghostlink:hover { color: #0a0a0a; }
  .navcta { padding: 9px 16px; font-size: 13.5px; }
  .pulse {
    width: 6px; height: 6px; border-radius: 50%;
    background: var(--hotpink);
    animation: navpulse 2.2s ease-in-out infinite;
  }
  @keyframes navpulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.45; transform: scale(0.8); } }

  /* scroll progress — a hairline that reads the page with you */
  .progress { position: absolute; left: 0; right: 0; bottom: -1px; height: 2px; }
  .progress i {
    display: block; height: 100%;
    background: linear-gradient(90deg, var(--hotpink), #ff8fab);
    transition: width 0.08s linear;
  }

  @media (max-width: 860px) {
    .links { display: none; }
    .ghostlink { display: none; }
  }
</style>
