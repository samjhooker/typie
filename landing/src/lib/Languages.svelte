<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  const langs = [
    { n: 'Bulgarian', native: 'Български' },
    { n: 'Croatian', native: 'Hrvatski' },
    { n: 'Czech', native: 'Čeština' },
    { n: 'Danish', native: 'Dansk' },
    { n: 'Dutch', native: 'Nederlands' },
    { n: 'English', native: 'English' },
    { n: 'Estonian', native: 'Eesti' },
    { n: 'Finnish', native: 'Suomi' },
    { n: 'French', native: 'Français' },
    { n: 'German', native: 'Deutsch' },
    { n: 'Greek', native: 'Ελληνικά' },
    { n: 'Hungarian', native: 'Magyar' },
    { n: 'Italian', native: 'Italiano' },
    { n: 'Latvian', native: 'Latviešu' },
    { n: 'Lithuanian', native: 'Lietuvių' },
    { n: 'Maltese', native: 'Malti' },
    { n: 'Polish', native: 'Polski' },
    { n: 'Portuguese', native: 'Português' },
    { n: 'Romanian', native: 'Română' },
    { n: 'Slovak', native: 'Slovenčina' },
    { n: 'Slovenian', native: 'Slovenščina' },
    { n: 'Spanish', native: 'Español' },
    { n: 'Swedish', native: 'Svenska' },
    { n: 'Russian', native: 'Русский' },
    { n: 'Ukrainian', native: 'Українська' },
  ];
</script>

<section
  class="langs field"
  id="languages"
>
  <div class="container">
    <h2
      class="subhead"
      use:reveal
    >
      25 languages.
      <span class="squiggle"
        >No cloud.
        <svg
          viewBox="0 0 120 14"
          aria-hidden="true"
        >
          <path
            d="M4 9c22-6 44-6 56-3s34 4 56-2"
            stroke="var(--hotpink)"
          />
        </svg>
      </span>
    </h2>
    <p
      class="lede"
      use:reveal={{ delay: 60 }}
    >
      Fast, accurate transcription that runs <strong
        >entirely on your Mac</strong
      >. Your audio is processed locally and never uploaded.
    </p>

    <div
      class="wrap"
      use:reveal={{ delay: 100 }}
    >
      <span
        class="peek"
        aria-hidden="true"
        ><Robot
          size={44}
          mood="idle"
        /></span
      >
      <ul class="board">
        {#each langs as lang}
          <li
            class="card"
            lang={lang.n}
          >
            <span class="native">{lang.native}</span>
            <span class="name">{lang.n}</span>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</section>

<style>
  .langs {
    position: relative;
    overflow-x: hidden;
    padding-top: clamp(48px, 7vh, 80px);
    padding-bottom: clamp(48px, 7vh, 80px);
  }

  h2 {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    column-gap: 0.28em;
  }

  .lede {
    margin: 22px auto 0;
    max-width: 44rem;
    text-align: center;
    color: var(--text-2);
    line-height: 1.6;
    font-size: clamp(16px, 1.5vw, 18px);
  }

  .lede strong {
    color: var(--ink);
    font-weight: 700;
  }

  .wrap {
    position: relative;
    margin-top: clamp(32px, 4.5vh, 48px);
    min-width: 0;
    max-width: 100%;
    overflow: hidden;
  }

  .board {
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px 10px;
    width: 100%;
    min-width: 0;
    max-width: 100%;
  }

  .peek {
    position: absolute;
    top: -42px;
    right: clamp(8px, 6vw, 80px);
    z-index: 2;
    line-height: 0;
    color: var(--hotpink);
    transform: rotate(10deg);
    animation: peeksneak 5s var(--ease-inout) infinite;
  }

  @keyframes peeksneak {
    0%,
    100% {
      transform: rotate(10deg) translateY(0);
    }
    50% {
      transform: rotate(6deg) translateY(6px);
    }
  }

  .card {
    position: relative;
    z-index: 0;
    min-width: 0;
    max-width: 100%;
    box-sizing: border-box;
    background: var(--surface);
    border-radius: 999px;
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.06);
    padding: 10px 18px 11px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1px;
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.3s var(--ease-out);
  }

  .card:hover {
    z-index: 3;
    transform: translateY(-4px) scale(1.05);
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.12);
  }

  .native {
    font-size: 15.5px;
    font-weight: 700;
    color: var(--ink);
    text-align: center;
    line-height: 1.25;
    white-space: nowrap;
  }

  .name {
    font-size: 11.5px;
    font-weight: 500;
    color: var(--text-3);
    text-align: center;
    line-height: 1.2;
    white-space: nowrap;
  }

  @media (max-width: 640px) {
    h2 {
      flex-direction: column;
      align-items: center;
      row-gap: 2px;
    }

    .card {
      padding: 8px 14px 9px;
    }

    .native {
      font-size: 14.5px;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .peek {
      animation: none;
    }
  }
</style>
