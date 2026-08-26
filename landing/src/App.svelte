<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import Ticker from './lib/Ticker.svelte';
  import ShelfShowcase from './lib/ShelfShowcase.svelte';
  import Superpowers from './lib/Superpowers.svelte';
  import Verdict from './lib/Verdict.svelte';
  import AppsRow from './lib/AppsRow.svelte';
  import Languages from './lib/Languages.svelte';
  import MetricBar from './lib/MetricBar.svelte';
  import Testimonials from './lib/Testimonials.svelte';
  import Faq from './lib/Faq.svelte';
  import FinalCta from './lib/FinalCta.svelte';
  import Footer from './lib/Footer.svelte';
  import ChatBot from './lib/ChatBot.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';
  import Terms from './lib/Terms.svelte';
  import Enterprise from './enterprise/Enterprise.svelte';
  import Education from './education/Education.svelte';
  import HoldCursor from './lib/HoldCursor.svelte';
  import { app } from './lib/state.svelte.js';
  import { sound, blip } from './lib/sound.svelte.js';

  const path = $state(window.location.pathname);

  /* ---- page-wide hold: the site itself obeys the product's gesture ---- */
  let holding = $state(false);
  let holdTimer;

  /* the hold is desktop-pointer delight only; vestibular-safe users opt out */
  const HOLD_OK =
    matchMedia('(pointer: fine)').matches &&
    !matchMedia('(prefers-reduced-motion: reduce)').matches;

  function onDown(e) {
    if (!HOLD_OK) return;
    if (!e.isTrusted || e.button !== 0) return;
    if (e.target?.closest?.('a, button, input, textarea, select, [role="switch"], [role="tab"]')) return;
    clearTimeout(holdTimer);
    holdTimer = setTimeout(() => {
      holding = true;
      document.documentElement.classList.add('is-holding');
      blip(660);
    }, 170);
  }

  function onUp() {
    clearTimeout(holdTimer);
    if (holding) {
      holding = false;
      document.documentElement.classList.remove('is-holding');
      blip(340, 0.1);
    }
  }

  /* ---- mood morph: the page washes tint as chapters scroll past ---- */
  $effect(() => {
    const moods = {
      top: '#fffdf7',
      notch: '#f3effc',
      features: '#fffcf0',
      versus: '#fdf8ee'
    };
    const els = Object.keys(moods)
      .map((id) => document.getElementById(id))
      .filter(Boolean);
    const io = new IntersectionObserver(
      (entries) => {
        for (const en of entries) {
          if (en.isIntersecting) {
            document.documentElement.style.setProperty('--page', moods[en.target.id]);
          }
        }
      },
      { rootMargin: '-42% 0px -52% 0px' }
    );
    els.forEach((el) => io.observe(el));
    return () => io.disconnect();
  });

  /* Geist + Geist Mono are only used by /enterprise - inject on demand
     so root-landing visitors never download them */
  $effect(() => {
    if (path !== '/enterprise' || document.getElementById('fonts-enterprise')) return;
    const link = Object.assign(document.createElement('link'), {
      id: 'fonts-enterprise',
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&family=Geist+Mono:wght@400;500&display=swap',
    });
    document.head.appendChild(link);
  });

  $effect(() => {
    const live = app.mood === 'listening';
    const typed = app.mood === 'done';
    document.documentElement.classList.toggle('is-listening', live);
    document.documentElement.classList.toggle('is-typed', typed);
    return () => {
      document.documentElement.classList.remove('is-listening', 'is-typed');
    };
  });
</script>

<svelte:window
  onpointerdown={onDown}
  onpointerup={onUp}
  onpointercancel={onUp}
  onblur={onUp}
/>

{#if path === '/about'}
  <About />
{:else if path === '/privacy'}
  <Privacy />
{:else if path === '/terms'}
  <Terms />
{:else if path === '/enterprise'}
  <Enterprise />
{:else if path === '/education'}
  <Education />
{:else}
  <Nav />

  <main>
    <Hero />
    <Ticker />
    <ShelfShowcase />
    <Superpowers />
    <Verdict />
    <MetricBar />
    <AppsRow />
    <Languages />
    <Testimonials />
    <Faq />

    <!-- pink band runs unbroken into the footer wave -->
    <div class="tail">
      <FinalCta />
      <Footer />
    </div>
  </main>

  <ChatBot />
  <HoldCursor />
{/if}

<style>
  /* the wave's transparent half shows this instead of page cream,
     so the pink section flows straight into the footer */
  .tail {
    background: var(--pink-band);
  }

  .tail :global(footer) {
    margin-top: 0;
  }
</style>


