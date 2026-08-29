<script>
  import Logo from './Logo.svelte';
  import { onMount } from 'svelte';
  import { Sun, Moon } from 'lucide-svelte';

  let scrolled = $state(false);
  let progress = $state(0);
  let active = $state('');
  let isDark = $state(false);

  const CHAPTERS = ['apps', 'compare', 'engine', 'privacy', 'faq'];

  onMount(() => {
    // initialize theme
    const saved = localStorage.getItem('typie-theme');
    const prefersDark = window.matchMedia(
      '(prefers-color-scheme: dark)'
    ).matches;
    if (saved === 'dark' || (!saved && prefersDark)) {
      isDark = true;
      document.documentElement.dataset.theme = 'dark';
    } else {
      isDark = false;
      document.documentElement.dataset.theme = 'light';
    }

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

    // set initial nav visibility based on Hero demo position
    const demo = document.getElementById('demo');
    if (demo) scrolled = demo.getBoundingClientRect().bottom < 80;

    return () => io.disconnect();
  });

  function toggleTheme() {
    isDark = !isDark;
    const theme = isDark ? 'dark' : 'light';
    document.documentElement.dataset.theme = theme;
    localStorage.setItem('typie-theme', theme);
  }
</script>

<svelte:window
  onscroll={() => {
    const demo = document.getElementById('demo');
    if (demo) {
      const bottom = demo.getBoundingClientRect().bottom;
      scrolled = bottom < 80;
    } else {
      scrolled = window.scrollY > 400;
    }
    const max = document.documentElement.scrollHeight - innerHeight;
    progress = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
  }}
/>

<!-- Quiet corner theme toggle when at the very top -->
<div
  class="top-corner-bar"
  class:fade-out={scrolled}
>
  <div class="container top-corner-inner">
    <a
      href="/"
      class="corner-brand"
      aria-label="Typie home"
    >
      <Logo size={22} />
    </a>
    <button
      class="theme-btn corner"
      onclick={toggleTheme}
      aria-label={isDark ? 'Switch to Light mode' : 'Switch to Dark mode'}
      title={isDark ? 'Switch to Light mode' : 'Switch to Dark mode'}
    >
      {#if isDark}
        <Sun
          size={16}
          strokeWidth={2}
        />
      {:else}
        <Moon
          size={16}
          strokeWidth={2}
        />
      {/if}
    </button>
  </div>
</div>

<!-- Scroll-Revealed Floating Glass Navbar -->
<header
  class="floating-nav"
  class:visible={scrolled}
>
  <div class="nav-pill">
    <a
      href="/"
      class="brand"
      aria-label="Typie home"
    >
      <Logo size={20} />
    </a>

    <nav
      class="links"
      aria-label="primary"
    >
      <a
        href="#apps"
        class:active={active === 'apps'}>Everywhere</a
      >
      <a
        href="#compare"
        class:active={active === 'compare'}>Comparison</a
      >
      <a
        href="#engine"
        class:active={active === 'engine'}>Engine</a
      >
      <a
        href="#privacy"
        class:active={active === 'privacy'}>Privacy</a
      >
      <a
        href="#faq"
        class:active={active === 'faq'}>FAQ</a
      >
    </nav>

    <div class="right">
      <button
        class="theme-btn"
        onclick={toggleTheme}
        aria-label={isDark ? 'Switch to Light mode' : 'Switch to Dark mode'}
        title={isDark ? 'Switch to Light mode' : 'Switch to Dark mode'}
      >
        {#if isDark}
          <Sun
            size={15}
            strokeWidth={2}
          />
        {:else}
          <Moon
            size={15}
            strokeWidth={2}
          />
        {/if}
      </button>

      <a
        href="https://github.com/samjhooker/typie/releases/latest"
        class="btn btn-primary navcta"
      >
        <svg
          viewBox="0 0 384 512"
          width="12"
          height="12"
          fill="currentColor"
          aria-hidden="true"
          ><path
            d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"
          /></svg
        >
        Download
      </a>
    </div>

    <!-- Scroll Progress Indicator on the Pill -->
    <div
      class="pill-progress"
      aria-hidden="true"
    >
      <i style="width:{progress * 100}%"></i>
    </div>
  </div>
</header>

<style>
  /* Static top bar at hero start — ultra light & airy */
  .top-corner-bar {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    z-index: 40;
    padding: 24px 0;
    transition:
      opacity 0.25s ease,
      transform 0.25s ease;
  }
  .top-corner-bar.fade-out {
    opacity: 0;
    pointer-events: none;
    transform: translateY(-8px);
  }
  .top-corner-inner {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .corner-brand {
    line-height: 0;
  }

  /* Floating Glass Pill Navbar — appears on scroll */
  .floating-nav {
    position: fixed;
    top: 16px;
    left: 0;
    right: 0;
    z-index: 100;
    display: flex;
    justify-content: center;
    pointer-events: none;
    transform: translateY(-100px);
    opacity: 0;
    transition:
      transform 0.35s var(--spring),
      opacity 0.25s ease;
  }
  .floating-nav.visible {
    transform: translateY(0);
    opacity: 1;
    pointer-events: auto;
  }

  .nav-pill {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 28px;
    padding: 7px 14px 7px 18px;
    background: rgba(255, 255, 255, 0.88);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid var(--line-strong);
    border-radius: var(--radius-pill);
    box-shadow: 0 12px 36px rgba(0, 0, 0, 0.12);
    overflow: hidden;
  }
  :root[data-theme='dark'] .nav-pill {
    background: rgba(20, 22, 31, 0.9);
    border-color: rgba(255, 255, 255, 0.14);
    box-shadow: 0 14px 40px rgba(0, 0, 0, 0.45);
  }

  .brand {
    display: inline-flex;
    align-items: center;
    line-height: 0;
  }

  .links {
    display: flex;
    align-items: center;
    gap: 20px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-2);
  }
  .links a {
    transition: color 0.15s ease;
    position: relative;
    padding: 4px 0;
  }
  .links a:hover {
    color: var(--ink);
  }
  .links a::before {
    content: '';
    position: absolute;
    left: 50%;
    bottom: -1px;
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: var(--hotpink);
    transform: translateX(-50%) scale(0);
    transition: transform 0.2s var(--spring);
  }
  .links a.active {
    color: var(--ink);
  }
  .links a.active::before {
    transform: translateX(-50%) scale(1);
  }

  .right {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .theme-btn {
    display: inline-grid;
    place-items: center;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--surface-2);
    color: var(--ink);
    border: 1px solid var(--line);
    transition:
      transform 0.15s var(--spring),
      border-color 0.15s ease;
    cursor: pointer;
  }
  .theme-btn:hover {
    transform: rotate(15deg);
    border-color: var(--hotpink);
  }
  .theme-btn.corner {
    width: 36px;
    height: 36px;
    background: var(--surface);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
  }

  .navcta {
    padding: 7px 14px;
    font-size: 12.5px;
    gap: 5px;
  }

  /* Thin bottom progress bar */
  .pill-progress {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 0;
    height: 2px;
  }
  .pill-progress i {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, var(--hotpink), #ff8fab);
    transition: width 0.08s linear;
  }

  @media (max-width: 768px) {
    .links {
      display: none;
    }
    .nav-pill {
      gap: 16px;
    }
  }
</style>
