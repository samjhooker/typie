<script>
  import { reveal } from './reveal.js';

  const langs = [
    { flag: '🇧🇬', en: 'Bulgarian', nat: 'български', greet: 'Здрасти.' },
    { flag: '🇭🇷', en: 'Croatian', nat: 'hrvatski', greet: 'Bok.' },
    { flag: '🇨🇿', en: 'Czech', nat: 'čeština', greet: 'Ahoj.' },
    { flag: '🇩🇰', en: 'Danish', nat: 'dansk', greet: 'Hej.' },
    { flag: '🇳🇱', en: 'Dutch', nat: 'Nederlands', greet: 'Hoi.' },
    { flag: '🇬🇧', en: 'English', nat: 'English', greet: 'hey.' },
    { flag: '🇪🇪', en: 'Estonian', nat: 'eesti', greet: 'Tere.' },
    { flag: '🇫🇮', en: 'Finnish', nat: 'suomi', greet: 'Moi.' },
    { flag: '🇫🇷', en: 'French', nat: 'français', greet: 'Bonjour.' },
    { flag: '🇩🇪', en: 'German', nat: 'Deutsch', greet: 'Guten Tag.' },
    { flag: '🇬🇷', en: 'Greek', nat: 'ελληνικά', greet: 'Γεια σου.' },
    { flag: '🇭🇺', en: 'Hungarian', nat: 'magyar', greet: 'Szia.' },
    { flag: '🇮🇹', en: 'Italian', nat: 'italiano', greet: 'Ciao.' },
    { flag: '🇱🇻', en: 'Latvian', nat: 'latviešu', greet: 'Sveiki.' },
    { flag: '🇱🇹', en: 'Lithuanian', nat: 'lietuvių', greet: 'Labas.' },
    { flag: '🇲🇹', en: 'Maltese', nat: 'Malti', greet: 'Ħelow.' },
    { flag: '🇵🇱', en: 'Polish', nat: 'polski', greet: 'Cześć.' },
    { flag: '🇵🇹', en: 'Portuguese', nat: 'português', greet: 'Olá.' },
    { flag: '🇷🇴', en: 'Romanian', nat: 'română', greet: 'Salut.' },
    { flag: '🇸🇰', en: 'Slovak', nat: 'slovenčina', greet: 'Ahoj.' },
    { flag: '🇸🇮', en: 'Slovenian', nat: 'slovenščina', greet: 'Živjo.' },
    { flag: '🇪🇸', en: 'Spanish', nat: 'español', greet: 'Hola.' },
    { flag: '🇸🇪', en: 'Swedish', nat: 'svenska', greet: 'Hej.' },
    { flag: '🇷🇺', en: 'Russian', nat: 'русский', greet: 'Привет.' },
    { flag: '🇺🇦', en: 'Ukrainian', nat: 'українська', greet: 'Привіт.' }
  ];

  let greet = $state('');
  let greetFrom = $state('');
  let timer;

  function say(l) {
    clearTimeout(timer);
    greetFrom = l.en;
    const full = l.greet;
    greet = '';
    let i = 0;
    const step = () => {
      greet = full.slice(0, ++i);
      if (i < full.length) timer = setTimeout(step, 36);
    };
    step();
  }

  function chipReveal(node, params) {
    const api = reveal(node, params);
    function settled(e) {
      if (e.propertyName === 'opacity') {
        node.style.transitionDelay = '';
        node.removeEventListener('transitionend', settled);
      }
    }
    node.addEventListener('transitionend', settled);
    return {
      destroy() {
        node.removeEventListener('transitionend', settled);
        api.destroy();
      }
    };
  }
</script>

<section class="languages field field-sky">
  <div class="container head">
    <p class="hand kicker" use:reveal>no language settings. none.</p>
    <h2 class="subhead" use:reveal={{ delay: 60 }}>
      Fluent in basically everything you speak
    </h2>
    <p class="greet" aria-live="polite">
      {#if greet}
        <span class="mono">{greetFrom}</span>
        {greet}<span class="caret"></span>
      {:else}
        <span class="mono sub">25 languages · 0 of them uploaded anywhere</span>
      {/if}
    </p>
  </div>
  <div class="chips">
    {#each langs as l, i}
      <button class="chip b{i % 5}" use:chipReveal={{ delay: i * 28 }} onpointerenter={() => say(l)}>
        <span class="flag">{l.flag}</span>
        <span class="en">{l.en}</span>
        <span class="nat hand">{l.nat}</span>
      </button>
    {/each}
    <div class="more hand" use:chipReveal={{ delay: langs.length * 28 }}>+ way more every update</div>
  </div>
  <p class="hand foot" use:reveal>yes, even maltese.</p>
</section>

<style>
  .languages {
    text-align: center;
    overflow: hidden;
  }

  .head {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .kicker {
    font-size: clamp(17px, 2vw, 23px);
    color: var(--green-deep);
    transform: rotate(-3deg);
  }

  h2 {
    margin: 14px 0 0;
    max-width: 18ch;
  }

  .greet {
    margin-top: 20px;
    min-height: 1.6em;
    font-family: var(--display);
    font-weight: 800;
    font-size: clamp(20px, 3vw, 28px);
    color: var(--green);
  }

  .caret {
    display: inline-block;
    width: 3px;
    height: 0.85em;
    margin-left: 4px;
    background: var(--hotpink);
    vertical-align: -2px;
    animation: caret 0.8s steps(1) infinite;
  }

  .chips {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    align-items: center;
    gap: 12px;
    max-width: 1100px;
    margin: 40px auto 0;
    padding-inline: 24px;
  }

  .chip,
  .more {
    opacity: 0;
    transform: translateY(18px);
    transition:
      opacity 0.7s ease,
      transform 0.25s var(--spring),
      box-shadow 0.25s ease;
  }

  .chip.visible,
  .more.visible {
    opacity: 1;
    transform: none;
  }

  .chip:hover {
    transform: translateY(-5px) scale(1.05);
    box-shadow: 0 12px 26px rgba(2, 89, 77, 0.16);
  }

  .b0 { background: var(--mint); }
  .b1 { background: var(--butter); }
  .b2 { background: var(--cream); }
  .b3 { background: var(--lavender); }
  .b4 { background: var(--lime); }

  .chip {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
    padding: 14px 18px;
    border-radius: 22px;
  }

  .chip:nth-child(odd) { border-radius: 999px; }

  .flag { font-size: 26px; line-height: 1; }

  .en {
    font-family: var(--display);
    font-weight: 800;
    text-transform: uppercase;
    font-size: 12px;
    letter-spacing: 0.06em;
    color: var(--ink);
  }

  .nat {
    font-size: 13px;
    color: rgba(2, 89, 77, 0.75);
  }

  .more {
    padding: 15px 21px;
    background: transparent;
    border: 2px dashed rgba(2, 89, 77, 0.45);
    border-radius: 999px;
    color: var(--green-deep);
    font-size: 14px;
  }

  .foot {
    display: inline-block;
    margin-top: 36px;
    font-size: clamp(16px, 1.9vw, 21px);
    color: var(--green-deep);
    transform: rotate(2deg);
  }
</style>
