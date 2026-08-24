<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import AppsRow from './lib/AppsRow.svelte';
  import FeatureCards from './lib/FeatureCards.svelte';
  import Languages from './lib/Languages.svelte';
  import MetricBar from './lib/MetricBar.svelte';
  import Testimonials from './lib/Testimonials.svelte';
  import CtaBanner from './lib/CtaBanner.svelte';
  import Faq from './lib/Faq.svelte';
  import FinalCta from './lib/FinalCta.svelte';
  import Footer from './lib/Footer.svelte';
  import ChatBot from './lib/ChatBot.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';
  import Terms from './lib/Terms.svelte';
  import Enterprise from './enterprise/Enterprise.svelte';
  import Education from './education/Education.svelte';
  import { app } from './lib/state.svelte.js';

  const path = $state(window.location.pathname);

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
    <FeatureCards />
    <AppsRow />
    <Languages />
    <MetricBar />
    <Testimonials />
    <CtaBanner />
    <Faq />

    <!-- pink band runs unbroken into the footer wave -->
    <div class="tail">
      <FinalCta />
      <Footer />
    </div>
  </main>

  <ChatBot />
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


