<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import Features from './lib/Features.svelte';
  import Languages from './lib/Languages.svelte';
  import Manifesto from './lib/Manifesto.svelte';
  import Pricing from './lib/Pricing.svelte';
  import Faq from './lib/Faq.svelte';
  import Finale from './lib/Finale.svelte';
  import ChatBot from './lib/ChatBot.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';

  const path = $state(window.location.pathname);
</script>

{#if path === '/about'}
  <About />
{:else if path === '/privacy'}
  <Privacy />
{:else}
  <Nav />

  <main>
    <Hero />
    <Features />
    <Languages />
    <Manifesto />
    <Pricing />
    <Faq />
    <Finale />
  </main>

  <ChatBot />
{/if}
