<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import AppsRow from './lib/AppsRow.svelte';
  import FeatureCards from './lib/FeatureCards.svelte';
  import Languages from './lib/Languages.svelte';
  import Testimonials from './lib/Testimonials.svelte';
  import CtaBanner from './lib/CtaBanner.svelte';
  import Faq from './lib/Faq.svelte';
  import Footer from './lib/Footer.svelte';
  import ChatBot from './lib/ChatBot.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';
  import Terms from './lib/Terms.svelte';
  import { app } from './lib/state.svelte.js';

  const path = $state(window.location.pathname);

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
{:else}
  <Nav />

  <main>
    <Hero />
    <AppsRow />
    <FeatureCards />
    <Languages />
    <Testimonials />
    <CtaBanner />
    <Faq />
    <Footer />
  </main>

  <ChatBot />
{/if}


