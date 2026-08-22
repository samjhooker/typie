<script>
  import PageShell from './PageShell.svelte';
  import { reveal } from './reveal.js';

  const sections = [
    {
      h: 'the short version',
      p: 'We collect nothing. Your voice never leaves your Mac. There is no account, so there are no accounts to breach. This is the whole policy - everything below is just detail.'
    },
    {
      h: 'audio',
      p: 'Typie processes your speech on-device. The audio is thrown away the moment it becomes text. It is never recorded, stored, uploaded, or heard by anyone - including us, because there is no us listening. There is no server.'
    },
    {
      h: 'data we collect',
      p: 'None. No analytics, no telemetry, no crash reports, no cookies, no trackers. The app has no way to phone home because it has nothing to phone and nowhere to call.'
    },
    {
      h: 'what stays on your machine',
      p: 'The speech model (~500 MB, downloaded once) and whatever you dictated. That\'s it. Uninstall Typie and all of it goes with it.'
    },
    {
      h: 'third parties',
      p: 'There are no third parties. No ad networks, no SDKs, no "partners". Reading this section took you longer than building it took us.'
    },
    {
      h: 'changes to this policy',
      p: 'If this policy ever changes, something has gone hilariously wrong - there is literally nothing to change. But if it does, we\'d have no way to email you about it, because we don\'t know who you are. And honestly? Beautiful.'
    }
  ];
</script>

<svelte:head>
  <title>Privacy - typie</title>
  <meta name="description" content="Typie's privacy policy: we collect nothing. Your voice is processed on your Mac and never leaves it." />
</svelte:head>

<PageShell>
  <h1 class="subhead" use:reveal>privacy policy</h1>
  <p class="hand tag" use:reveal={{ delay: 80 }}>the shortest one you'll ever read.</p>

  <div class="wrap">
    {#each sections as s, i}
      <section use:reveal={{ delay: i * 60 }}>
        <h2>{s.h}</h2>
        <p>{s.p}</p>
      </section>
    {/each}
  </div>

  <p class="fine mono">last updated: never, really · questions? the robot in the corner knows as much as we do.</p>
</PageShell>

<style>
  .tag {
    font-size: clamp(20px, 2.4vw, 27px);
    color: var(--green-deep);
    transform: rotate(-2deg);
    margin-top: 10px;
  }

  .wrap {
    margin-top: 44px;
    max-width: 720px;
  }

  section {
    background: rgba(249, 248, 244, 0.75);
    border: 1px solid rgba(2, 89, 77, 0.1);
    border-radius: var(--radius);
    padding: 26px 30px;
    margin-bottom: 16px;
  }

  h2 {
    font-size: clamp(19px, 2vw, 24px);
    color: var(--green-deep);
    letter-spacing: -0.02em;
    text-transform: capitalize;
  }

  p {
    margin-top: 10px;
    color: var(--green-deep);
    line-height: 1.6;
  }

  .fine {
    margin-top: 26px;
    opacity: 0.7;
  }
</style>
