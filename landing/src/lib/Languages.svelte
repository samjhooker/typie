<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';

  const langs = [
    { n: 'Bulgarian', flag: '🇧🇬' },
    { n: 'Croatian', flag: '🇭🇷' },
    { n: 'Czech', flag: '🇨🇿' },
    { n: 'Danish', flag: '🇩🇰' },
    { n: 'Dutch', flag: '🇳🇱' },
    { n: 'English', flag: '🇬🇧' },
    { n: 'Estonian', flag: '🇪🇪' },
    { n: 'Finnish', flag: '🇫🇮' },
    { n: 'French', flag: '🇫🇷' },
    { n: 'German', flag: '🇩🇪' },
    { n: 'Greek', flag: '🇬🇷' },
    { n: 'Hungarian', flag: '🇭🇺' },
    { n: 'Italian', flag: '🇮🇹' },
    { n: 'Latvian', flag: '🇱🇻' },
    { n: 'Lithuanian', flag: '🇱🇹' },
    { n: 'Maltese', flag: '🇲🇹' },
    { n: 'Polish', flag: '🇵🇱' },
    { n: 'Portuguese', flag: '🇵🇹' },
    { n: 'Romanian', flag: '🇷🇴' },
    { n: 'Slovak', flag: '🇸🇰' },
    { n: 'Slovenian', flag: '🇸🇮' },
    { n: 'Spanish', flag: '🇪🇸' },
    { n: 'Swedish', flag: '🇸🇪' },
    { n: 'Russian', flag: '🇷🇺' },
    { n: 'Ukrainian', flag: '🇺🇦' }
  ];

  const spins = [1.4, -2.2, 2, -1.1, 0.6, -1.8, 1.2, -0.4, 2.1, -1.6, 0.8, 1.9, -2, 1.1, -0.7, 1.6, -1.4, 0.3, 2.2, -1.9, -0.8, 1.5, 0.5, -1.2, 1.8];
  const nudges = [0, 7, -5, 4, -3, 8, 2, -6, 5, -4, 7, -2, 3, 6, -7, 1, -5, 4, 8, -3, 2, -6, 5, -1, 3];
</script>

<section class="langs field" id="languages">
  <div class="container">
    <p class="hand kicker" use:reveal>nvidia parakeet, on your mac</p>
    <h2 class="subhead" use:reveal>
      25 languages.
      <span class="squiggle">No cloud.
        <svg viewBox="0 0 120 14" aria-hidden="true">
          <path d="M4 9c22-6 44-6 56-3s34 4 56-2" stroke="var(--hotpink)" />
        </svg>
      </span>
    </h2>
    <p class="lede" use:reveal={{ delay: 60 }}>
      Typie transcribes with <strong>NVIDIA Parakeet</strong>, a speech model that runs on your Mac. It’s trained heavily on European languages. This is the set we ship today.
    </p>

    <div class="wrap" use:reveal={{ delay: 100 }}>
      <span class="peek" aria-hidden="true"><Robot size={44} mood="idle" /></span>
      <ul class="board">
    {#each langs as lang, i}
      {#if i === 8}
        <li class="break" aria-hidden="true"></li>
        <li class="shim mid" aria-hidden="true"></li>
      {:else if i === 16}
        <li class="break" aria-hidden="true"></li>
      {/if}
      <li class="card" style="--spin:{spins[i]}deg; --nudge:{nudges[i]}px">
        <span class="flag" aria-hidden="true">{lang.flag}</span>
        <span class="name">{lang.n}</span>
      </li>
    {/each}
    <li class="shim last" aria-hidden="true"></li>
      </ul>
    </div>
  </div>
</section>

<style>
  .langs {
    position: relative;
    overflow-x: hidden;
    padding-top: clamp(56px, 8vh, 96px);
    padding-bottom: clamp(56px, 8vh, 96px);
  }

  .kicker {
    text-align: center;
    font-size: clamp(20px, 2vw, 24px);
    color: var(--hotpink);
    transform: rotate(-2deg);
    margin-bottom: 10px;
  }

  h2 {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    column-gap: 0.28em;
  }

  .lede {
    margin: 22px auto 0;
    max-width: 42rem;
    text-align: center;
    color: rgba(19, 23, 34, 0.68);
    line-height: 1.6;
    font-size: clamp(15px, 1.4vw, 17px);
  }

  .lede strong {
    color: var(--ink);
    font-weight: 700;
  }

  .wrap {
    position: relative;
    margin-top: clamp(44px, 6vh, 68px);
    min-width: 0;
    max-width: 100%;
    overflow: hidden;
  }

  .board {
    list-style: none;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 10px;
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
    animation: peeksneak 5s ease-in-out infinite;
  }

  @keyframes peeksneak {
    0%, 100% { transform: rotate(10deg) translateY(0); }
    50% { transform: rotate(6deg) translateY(6px); }
  }

  .break,
  .shim {
    display: none;
    height: 0;
    margin: 0;
    padding: 0;
    overflow: hidden;
    pointer-events: none;
  }

  .shim.mid {
    flex-basis: 56px;
  }

  .shim.last {
    flex-basis: 40px;
  }

  .card {
    position: relative;
    z-index: 0;
    min-width: 0;
    max-width: 100%;
    width: auto;
    box-sizing: border-box;
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.06);
    padding: 16px 10px 14px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    transform: rotate(var(--spin)) translateY(var(--nudge));
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.3s ease;
  }

  .card:hover {
    z-index: 3;
    transform: translateY(-6px) scale(1.07) rotate(-1.2deg);
    box-shadow: 0 14px 30px rgba(19, 23, 34, 0.12);
  }

  .flag {
    font-size: 48px;
    line-height: 1;
    filter: drop-shadow(0 2px 4px rgba(19, 23, 34, 0.14));
  }

  .name {
    font-size: 12.5px;
    font-weight: 600;
    color: var(--ink);
    text-align: center;
    line-height: 1.2;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  @media (max-width: 640px) {
    .flag {
      font-size: 40px;
    }

    .card {
      padding: 14px 8px 12px;
    }

    .card:nth-last-child(2) {
      grid-column: 2;
    }

    h2 {
      flex-direction: column;
      align-items: center;
      row-gap: 2px;
    }
  }

  @media (min-width: 641px) {
    .board {
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 12px;
    }
  }

  @media (min-width: 981px) {
    .board {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      align-content: flex-start;
      gap: 14px 12px;
    }

    .break {
      display: block;
      flex-basis: 100%;
    }

    .shim {
      display: block;
      flex: 0 0 0;
    }

    .card {
      flex: 0 0 auto;
      width: 118px;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .peek {
      animation: none;
    }
  }
</style>
