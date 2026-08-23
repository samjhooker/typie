<script>
  import { reveal } from './reveal.js';
  import AssetSlot from './AssetSlot.svelte';
  import { nsSvg } from './svgid.js';

  import slack from 'thesvg/slack';
  import chrome from 'thesvg/chrome';
  import vscode from 'thesvg/visual-studio-code';

  /* simple inline marks for apps without brand svgs in the set */
  const messenger =
    '<svg viewBox="0 0 24 24" fill="none"><path d="M12 3C7 3 3 6.8 3 11.4c0 2.6 1.3 5 3.4 6.5V21l3.2-1.7c.8.2 1.6.3 2.4.3 5 0 9-3.8 9-8.4S17 3 12 3Z" fill="url(#mg)"/><path d="m6.8 13.8 2.6-4 2.7 2.2 2.5-2.2 2.6 4" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/><defs><linearGradient id="mg" x1="3" y1="12" x2="21" y2="12"><stop stop-color="#00B2FF"/><stop offset="1" stop-color="#006AFF"/></linearGradient></defs></svg>';

  const notes =
    '<svg viewBox="0 0 24 24" fill="none"><rect x="4" y="3" width="16" height="18" rx="3" fill="#fff" stroke="#e2b93b" stroke-width="1.4"/><rect x="4" y="3" width="16" height="5.5" rx="2.4" fill="#f7cf47"/><path d="M8 12.5h8M8 16h5" stroke="#d9a520" stroke-width="1.5" stroke-linecap="round"/></svg>';

  const mail =
    '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" fill="#3b82f6"/><path d="m4.5 7.5 7.5 6 7.5-6" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>';

  const apps = [
    { n: 'Messenger', s: messenger },
    { n: 'Slack', s: slack.svg },
    { n: 'Notes', s: notes },
    { n: 'Mail', s: mail },
    { n: 'Chrome', s: chrome },
    { n: 'VS Code', s: vscode.svg }
  ];
</script>

<section class="apps field" id="use-cases">
  <div class="container">
    <h2 class="subhead" use:reveal>
      Works <span class="squiggle">wherever
        <svg viewBox="0 0 120 14" aria-hidden="true">
          <path d="M4 9c22-6 44-6 56-3s34 4 56-2" stroke="var(--periwinkle)" />
        </svg>
      </span>
      you type</h2>

    <AssetSlot id="apps-row" width="100%">
      {#snippet fallback()}
        <ul class="row" use:reveal={{ delay: 80 }}>
          {#each apps as app}
            <li class="card">
              <i class="ic">{@html nsSvg(app.s, `app-${app.n}`)}</i>
              <span>{app.n}</span>
            </li>
          {/each}
          <li class="card any">
            <i class="plus">+</i>
            <span>Any app</span>
          </li>
        </ul>
      {/snippet}
    </AssetSlot>
  </div>
</section>

<style>
  .row {
    list-style: none;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: clamp(10px, 1.4vw, 18px);
    margin-top: clamp(32px, 5vh, 52px);
  }

  .card {
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 2px 10px rgba(19, 23, 34, 0.06);
    padding: clamp(16px, 2vw, 26px) 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    font-weight: 600;
    color: var(--ink);
    transition: transform 0.25s var(--spring), box-shadow 0.25s ease;
  }

  .card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 24px rgba(19, 23, 34, 0.1);
  }

  .ic {
    width: clamp(30px, 3.4vw, 44px);
    height: clamp(30px, 3.4vw, 44px);
    line-height: 0;
  }

  .ic :global(svg) {
    width: 100%;
    height: 100%;
  }

  .any {
    border: 2px dashed rgba(19, 23, 34, 0.28);
    box-shadow: none;
    background: transparent;
  }

  .any:hover {
    border-color: var(--ink);
    box-shadow: none;
  }

  .plus {
    font-style: normal;
    font-size: 30px;
    font-weight: 500;
    line-height: clamp(30px, 3.4vw, 44px);
    color: rgba(19, 23, 34, 0.65);
  }

  @media (max-width: 900px) {
    .row {
      grid-template-columns: repeat(4, 1fr);
    }
  }

  @media (max-width: 560px) {
    .row {
      grid-template-columns: repeat(3, 1fr);
    }

    .any {
      display: none;
    }
  }
</style>
