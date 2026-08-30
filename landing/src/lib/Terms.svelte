<script>
  import PageShell from './PageShell.svelte';
  import { reveal } from './reveal.js';

  const sections = [
    {
      h: 'The deal',
      p: 'Typie is free Mac dictation software. You can use it. We can keep making it. That is most of the contract.',
    },
    {
      h: 'It is open source',
      p: 'The code lives at github.com/samjhooker/typie, licensed under MIT. Fork it, copy it, sell it, learn from it, do whatever. Half of this was built out of other people’s open source anyway. Let’s be real.',
    },
    {
      h: 'Your words',
      p: 'Anything you dictate is yours. Typie turns speech into text on your machine. We do not claim your emails, messages, or novels. We also cannot read them.',
    },
    {
      h: 'No accounts. Ever.',
      p: 'There is no sign-in. Not Apple, not Google, not us. Typie is a standalone app on your Mac: independent, unsigned, no account to create. You can kinda trust us. We have nowhere to log you in.',
    },
    {
      h: 'As-is',
      p: 'Typie is provided as-is, with no warranty that it will catch every mumble, survive every macOS update, or make your emails better. If it breaks, restart it. If it still breaks, tell the robot. No refunds, because it costs $0.',
    },
    {
      h: 'Be decent',
      p: 'Do not use Typie to break the law or to harass people. We will not host a courtroom. We will just stop wanting you as a user.',
    },
    {
      h: 'Changes',
      p: 'We may update these terms. The current version lives on this page. Continued use after a change means you are fine with it, or at least not typing a complaint.',
    },
  ];
</script>

<svelte:head>
  <title>Terms - Typie</title>
  <meta
    name="description"
    content="Typie terms of use. Free Mac dictation, on-device, no account required."
  />
</svelte:head>

<PageShell>
  <p
    class="hand kicker"
    use:reveal
  >
    the other short one.
  </p>
  <h1
    class="subhead"
    use:reveal
  >
    Terms of use
  </h1>
  <p
    class="intro"
    use:reveal={{ delay: 60 }}
  >
    Basic rules for using Typie. Written so this URL exists. Not a novel.
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
    Last updated: August 2026 · Typie · a tiny robot with one job
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
    color: var(--text-2);
    line-height: 1.6;
  }

  .wrap {
    margin-top: 36px;
    max-width: 720px;
    display: grid;
    gap: 12px;
  }

  section {
    background: var(--surface);
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
