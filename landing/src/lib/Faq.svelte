<script>
  import { reveal } from './reveal.js';

  const items = [
    {
      q: 'How is Typie different from built-in dictation?',
      a: 'Speed and accuracy. Words land in under 100 milliseconds, right where your cursor is, in any app. No dictation mode to switch on and off.',
    },
    {
      q: 'Does my voice ever leave my Mac?',
      a: 'No. Audio is processed on your Mac by the built-in model, then thrown away. We can’t hear you. We don’t want to. There is no server to send it to.',
    },
    {
      q: 'Can Typie record my Zoom or phone calls?',
      a: 'Yes. Call capture records straight from your Mac’s system audio - so it works with Zoom, Meet, Slack huddles, FaceTime, whatever. It can mix in your mic too, so both sides of the call end up in one track, split by speaker.',
    },
    {
      q: 'How do the meeting summaries work?',
      a: 'Apple Intelligence runs entirely on your Mac (macOS 26+) and writes the title, executive summary, key points and verbatim quotes from your transcript. No cloud round-trip, no bot in your calendar invites. On older macOS you still get the full transcript, speaker labels and export.',
    },
    {
      q: 'Does a bot join my meetings like Otter?',
      a: 'Never. Nothing joins anything. The recording happens locally on your machine, so private calls stay private and nobody sees “notetaker” appear in the participant list.',
    },
    {
      q: 'Does it work in any app?',
      a: 'Anywhere text can go: Slack, Mail, browsers, editors, spreadsheets, that one ancient CRM. If there’s a cursor, Typie types there.',
    },
    {
      q: 'Why is it free?',
      a: 'Honestly? Payment infrastructure is expensive and I couldn’t be bothered. $0 means $0 - not a free tier, not a trial, not “free for now”.',
    },
    {
      q: 'What do I have to download?',
      a: '~500 MB on first install - that’s the model, not bloat. After that it runs offline forever. There is no server to miss.',
    },
    {
      q: 'Are you supporting more languages?',
      a: 'Not at this time. Typie uses NVIDIA’s Parakeet model for transcription, which is trained heavily on European languages. That’s the set we ship today.',
    },
  ];

  let open = $state(0);
</script>

<section
  class="field field-cream"
  id="faq"
>
  <div class="container wrap">
    <div class="left">
      <h2 use:reveal>Frequently<br />asked<br />questions</h2>
      <svg
        class="starburst"
        viewBox="0 0 60 60"
        aria-hidden="true"
      >
        <g
          stroke="var(--hotpink)"
          stroke-width="3.5"
          stroke-linecap="round"
        >
          <line
            x1="30"
            y1="4"
            x2="30"
            y2="18"
          />
          <line
            x1="30"
            y1="42"
            x2="30"
            y2="56"
          />
          <line
            x1="4"
            y1="30"
            x2="18"
            y2="30"
          />
          <line
            x1="42"
            y1="30"
            x2="56"
            y2="30"
          />
          <line
            x1="11"
            y1="11"
            x2="21"
            y2="21"
          />
          <line
            x1="39"
            y1="39"
            x2="49"
            y2="49"
          />
          <line
            x1="49"
            y1="11"
            x2="39"
            y2="21"
          />
          <line
            x1="21"
            y1="39"
            x2="11"
            y2="49"
          />
        </g>
      </svg>
    </div>

    <div
      class="list"
      use:reveal={{ delay: 60 }}
    >
      {#each items as item, i}
        <div
          class="row"
          class:open={open === i}
        >
          <button
            onclick={() => (open = open === i ? -1 : i)}
            aria-expanded={open === i}
          >
            <span class="plus">{open === i ? '−' : '+'}</span>
            <span class="q">{item.q}</span>
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
    grid-template-columns: 0.8fr 1.2fr;
    gap: clamp(40px, 6vw, 96px);
    align-items: start;
  }

  h2 {
    font-size: clamp(34px, 3.6vw, 48px);
    font-weight: 800;
    letter-spacing: -0.03em;
    line-height: 1.08;
    color: var(--ink);
  }

  .starburst {
    width: 52px;
    height: 52px;
    margin-top: 26px;
    margin-left: 8px;
    transform: rotate(12deg);
    animation: twirl 9s linear infinite;
  }

  @keyframes twirl {
    to {
      transform: rotate(372deg);
    }
  }

  .list {
    display: flex;
    flex-direction: column;
  }

  .row {
    border-bottom: 1px solid rgba(19, 23, 34, 0.12);
    padding: 6px 4px;
    transition: background-color 0.3s var(--ease-out);
  }

  .row:hover {
    background: rgba(252, 86, 129, 0.04);
  }

  .row:first-child {
    border-top: 1px solid rgba(19, 23, 34, 0.12);
  }

  button {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 0;
    text-align: left;
    font-size: clamp(15px, 1.5vw, 17px);
    font-weight: 600;
    letter-spacing: -0.01em;
    color: var(--ink);
  }

  .plus {
    color: var(--hotpink);
    font-size: 22px;
    line-height: 1;
    width: 22px;
    flex-shrink: 0;
    transition: transform 0.3s var(--spring);
  }

  /* glyph swaps + to −; a spring scale pulse sells the toggle
     without rotating the minus into an unreadable bar */
  .row.open .plus {
    transform: scale(1.25);
  }

  p {
    padding: 0 0 20px 38px;
    max-width: 54ch;
    color: var(--text-2);
    font-size: 15px;
    line-height: 1.6;
    /* spring settle on expand — answers arrive, don't blink in */
    animation: faq-in 0.5s var(--spring-snappy);
  }

  @keyframes faq-in {
    from {
      opacity: 0;
      transform: translateY(-8px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (max-width: 800px) {
    .wrap {
      grid-template-columns: 1fr;
      gap: 24px;
    }

    p {
      padding-left: 38px;
    }
  }
</style>
