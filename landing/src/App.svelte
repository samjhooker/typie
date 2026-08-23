<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import AppsRow from './lib/AppsRow.svelte';
  import FeatureCards from './lib/FeatureCards.svelte';
  import Notch from './lib/Notch.svelte';
  import Testimonials from './lib/Testimonials.svelte';
  import CtaBanner from './lib/CtaBanner.svelte';
  import Faq from './lib/Faq.svelte';
  import Footer from './lib/Footer.svelte';
  import ChatBot from './lib/ChatBot.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';
  import { intro } from './lib/intro.svelte.js';

  const path = $state(window.location.pathname);
</script>

{#if intro.glow}
    <div class="veil" class:off={!intro.active} aria-hidden="true">
      <span
        class="glow"
        style="left:{intro.glow.x}px; top:{intro.glow.y}px"
      ></span>
    </div>
  {/if}

  {#if path === '/about'}
  <About />
{:else if path === '/privacy'}
  <Privacy />
{:else}
  <Nav />

  <main>
    <Hero />
    <AppsRow />
    <FeatureCards />
    <Notch />
    <Testimonials />
    <CtaBanner />
    <Faq />
    <Footer />
  </main>

  <ChatBot />
{/if}

<style>
  .veil {
    position: fixed;
    inset: 0;
    z-index: 300;
    pointer-events: none;
    backdrop-filter: grayscale(1);
    -webkit-backdrop-filter: grayscale(1);
    background: rgba(255, 253, 247, 0.12);
    opacity: 1;
    transition: opacity 0.9s ease;
  }

  .veil.off {
    opacity: 0;
  }

  .glow {
    position: absolute;
    width: clamp(150px, 18vw, 240px);
    aspect-ratio: 1;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    background: radial-gradient(circle, rgba(252, 86, 129, 0.85) 0%, rgba(252, 86, 129, 0.35) 45%, transparent 70%);
    animation: glowpulse 1.15s ease-in-out infinite;
  }

  @keyframes glowpulse {
    0%, 100% { transform: translate(-50%, -50%) scale(0.82); opacity: 0.85; }
    50% { transform: translate(-50%, -50%) scale(1.08); opacity: 1; }
  }
</style>
