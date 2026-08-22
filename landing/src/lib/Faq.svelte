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

<section class="field field-cream">
  <div class="container wrap">
    <div class="left">
      <p class="mono kicker" use:reveal>a few boring ones</p>
      <h2 class="subhead" use:reveal={{ delay: 40 }}>Ask it.</h2>
    </div>
    <div class="list">
      {#each items as item, i}
        <div class="row">
          <button onclick={() => (open = open === i ? -1 : i)}>
            <span>{item.q}</span>
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

  .row {
    border-top: 1px solid rgba(2, 89, 77, 0.12);
  }

  .row:last-child {
    border-bottom: 1px solid rgba(2, 89, 77, 0.12);
  }

  button {
    width: 100%;
    display: flex;
    justify-content: space-between;
    gap: 16px;
    padding: 18px 0;
    text-align: left;
    font-family: var(--display);
    font-weight: 800;
    font-size: clamp(16px, 1.8vw, 20px);
    letter-spacing: -0.02em;
    color: var(--green);
  }

  .plus {
    color: var(--hotpink);
    font-size: 20px;
    line-height: 1;
  }

  p {
    padding: 0 0 20px;
    max-width: 46ch;
    color: var(--green-deep);
    font-size: 16px;
    line-height: 1.5;
  }

  @media (max-width: 800px) {
    .wrap { grid-template-columns: 1fr; gap: 24px; }
  }
</style>
