<script>
  import { reveal } from './reveal.js';

  const items = [
    {
      q: 'What is Typie?',
      a: 'A tiny robot in your Mac menu bar. Hold a key, say the thing, it’s typed. No window. No account.'
    },
    {
      q: 'What do I need to run it?',
      a: 'A Mac. Apple silicon, macOS 14+. It lives in the menu bar with one key.'
    },
    {
      q: 'What do I have to download?',
      a: '~500 MB on first install - that’s the model, not bloat. After that it runs offline forever. There is no server to miss.'
    },
    {
      q: 'Where does my voice go?',
      a: 'It doesn’t. Audio is processed on your Mac and thrown away. We can’t hear you. We don’t want to.'
    },
    {
      q: 'Can I remap the key?',
      a: 'Yes. If you’re freaky like that.'
    },
    {
      q: 'Why is it free?',
      a: 'Honestly? Payment infrastructure is expensive and I couldn\'t be bothered. $0 means $0.'
    }
  ];

  let open = $state(0);
</script>

<section class="field field-cream" id="faq">
  <div class="container wrap">
    <div class="left">
      <p class="mono kicker" use:reveal>a few boring ones</p>
      <h2 class="subhead" use:reveal={{ delay: 40 }}>Ask<br />it.</h2>
      <p class="hand note" use:reveal={{ delay: 100 }}>the robot answers everything else →</p>
    </div>
    <div class="list">
      {#each items as item, i}
        <div class="row" class:open={open === i}>
          <button onclick={() => (open = open === i ? -1 : i)} aria-expanded={open === i}>
            <span class="q"><i class="arr">→</i>{item.q}</span>
            <span class="plus">{open === i ? '–' : '+'}</span>
          </button>
          {#if open === i}
            <p>{item.a}</p>
          {/if}
        </div>
      {/each}
    </div>
  </div>
</section>

<style>
  .wrap {
    display: grid;
    grid-template-columns: 0.7fr 1.3fr;
    gap: 64px;
    align-items: start;
  }

  .note {
    margin-top: 18px;
    font-size: clamp(17px, 2vw, 22px);
    color: var(--hotpink);
    transform: rotate(-2deg);
  }

  .list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .row {
    border: 2px solid rgba(19, 23, 34, 0.14);
    border-radius: 24px;
    padding: 4px 24px;
    background: transparent;
    transition:
      background 0.25s ease,
      border-color 0.25s ease,
      box-shadow 0.25s ease,
      transform 0.25s var(--spring);
  }

  .row:hover {
    border-color: rgba(19, 23, 34, 0.45);
    transform: translateX(4px);
  }

  .row.open {
    background: var(--cream);
    border-color: var(--ink);
    box-shadow: 6px 6px 0 rgba(252, 86, 129, 0.35);
    transform: none;
  }

  button {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    padding: 16px 0;
    text-align: left;
    font-family: var(--display);
    font-weight: 700;
    font-size: clamp(17px, 1.9vw, 21px);
    letter-spacing: -0.01em;
    color: var(--ink);
  }

  .q {
    display: inline-flex;
    align-items: center;
    gap: 14px;
  }

  .arr {
    font-style: normal;
    color: var(--hotpink);
    font-size: 20px;
    transition: transform 0.3s var(--spring);
    display: inline-block;
  }

  .row.open .arr {
    transform: rotate(90deg);
  }

  .plus {
    color: var(--hotpink);
    font-size: 22px;
    line-height: 1;
  }

  p {
    padding: 0 0 20px 38px;
    max-width: 52ch;
    color: rgba(19, 23, 34, 0.75);
    font-size: 15.5px;
    line-height: 1.55;
  }

  @media (max-width: 800px) {
    .wrap { grid-template-columns: 1fr; gap: 24px; }
    p { padding-left: 34px; }
  }
</style>
