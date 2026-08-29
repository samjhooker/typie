<script>
  import PageShell from './PageShell.svelte';
  import { reveal } from './reveal.js';

  const sections = [
    {
      h: 'The short version',
      p: 'We collect nothing about what you say. Dictation happens on your Mac. There are no accounts, so there is nothing to breach. The rest is just the same sentence in more words.',
    },
    {
      h: 'Audio',
      p: 'Your speech is processed on-device and discarded as soon as it becomes text. It is never recorded, stored, uploaded, or listened to - including by us. There is no server for it to go to.',
    },
    {
      h: 'What stays on your Mac',
      p: 'The speech model (downloaded once) and whatever you typed. Uninstall Typie and that goes with it.',
    },
    {
      h: 'No accounts. Ever.',
      p: 'There is no sign-in. Not Apple, not Google, not us. Typie is a standalone app on your Mac: independent, unsigned. We do not know who you are. You can kinda trust us.',
    },
    {
      h: 'Data we do not collect',
      p: 'No analytics, no telemetry, no crash phoning-home, no cookies, no ad SDKs, no “partners”. The app has nowhere to call.',
    },
    {
      h: 'Changes',
      p: 'If this policy ever changes we will update this page. We cannot email you about it, because we do not know who you are. That is the point.',
    },
  ];
</script>

<svelte:head>
  <title>Privacy - Typie</title>
  <meta
    name="description"
    content="Typie privacy policy: dictation is on-device. We do not collect your voice, documents, or a profile of you."
  />
</svelte:head>

<PageShell>
  <p class="hand kicker" use:reveal>the short one.</p>
  <h1 class="subhead" use:reveal>Privacy policy</h1>
  <p class="intro" use:reveal={{ delay: 60 }}>
    Typie is built so your voice never leaves your computer. This page exists because people ask for
    one.
  </p>

  <div class="wrap">
    {#each sections as s, i}
      <section use:reveal={{ delay: i * 50 }}>
        <h2>{s.h}</h2>
        <p>{s.p}</p>
      </section>
    {/each}
  </div>

  <p class="fine mono">
    Last updated: August 2026 · Questions: the robot on the home page knows as much as we do.
  </p>
</PageShell>

<style>
  .kicker {
    text-align: left;
    font-size: clamp(20px, 2.2vw, 26px);
    color: var(--hotpink);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  .subhead {
    text-align: left;
  }

  .intro {
    margin-top: 16px;
    max-width: 40rem;
    color: rgba(19, 23, 34, 0.68);
    line-height: 1.6;
  }

  .wrap {
    margin-top: 36px;
    max-width: 720px;
    display: grid;
    gap: 12px;
  }

  section {
    background: #fff;
    border: 1px solid rgba(19, 23, 34, 0.07);
    border-radius: var(--radius-card);
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.04);
    padding: 22px 26px;
  }

  h2 {
    font-size: clamp(18px, 1.8vw, 22px);
    color: var(--ink);
    letter-spacing: -0.02em;
  }

  p {
    margin-top: 8px;
    color: var(--text-2);
    line-height: 1.65;
  }

  .fine {
    margin-top: 28px;
    opacity: 0.65;
    text-transform: none;
    letter-spacing: 0.04em;
  }
</style>
