<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import Steps from './lib/Steps.svelte';
  import AppsRow from './lib/AppsRow.svelte';
  import Comparison from './lib/Comparison.svelte';
  import Depth from './lib/Depth.svelte';
  import Footer from './lib/Footer.svelte';
  import About from './lib/About.svelte';
  import Privacy from './lib/Privacy.svelte';
  import Terms from './lib/Terms.svelte';
  import Enterprise from './enterprise/Enterprise.svelte';
  import Education from './education/Education.svelte';
  import { reveal } from './lib/reveal.js';

  const path = $state(window.location.pathname);
</script>

{#if path === '/about'}
  <About />
{:else if path === '/privacy'}
  <Privacy />
{:else if path === '/terms'}
  <Terms />
{:else if path === '/enterprise'}
  <Enterprise />
{:else if path === '/education'}
  <Education />
{:else}
  <Nav />
  <main>
    <!-- Act 1: The Verb & The Mac Experience -->
    <Hero />

    <!-- Act 2: 3-Step Physical Mechanics -->
    <Steps />

    <!-- Act 3: Any App With a Cursor -->
    <AppsRow />

    <!-- Act 4: The Local-Mac Comparison Aisle -->
    <Comparison />

    <!-- Act 5: Verified Physics & Engine -->
    <Depth />

    <!-- Act 6: Quote Break -->
    <section class="quote">
      <div class="container">
        <blockquote
          class="bigquote"
          use:reveal
        >
          “I used to type 200+ Slack messages and meeting summaries a day. Now I
          just talk. <em>My wrists thank me.</em>”
        </blockquote>
        <p
          class="qattr hand"
          use:reveal={{ delay: 60 }}
        >
          Maya Chen · Engineering Founder
        </p>
      </div>
    </section>

    <!-- Act 7: Private by Architecture -->
    <section
      class="security"
      id="privacy"
    >
      <div class="container">
        <div
          class="sectionhead"
          use:reveal
        >
          <h2>Private by architecture.<br /><em>Not by policy.</em></h2>
          <p>
            No toggles to flip, no cloud terms to trust. The network path simply
            does not exist.
          </p>
        </div>

        <div
          class="secrows"
          use:reveal={{ delay: 60 }}
        >
          <div class="secrow">
            <span
              class="secicn"
              aria-hidden="true"
            >
              <svg
                viewBox="0 0 16 16"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                ><path
                  d="M1.5 5.5a10 10 0 0 1 13 0M3.9 8a6.4 6.4 0 0 1 8.2 0M6.2 10.5a2.9 2.9 0 0 1 3.6 0"
                /><circle
                  cx="8"
                  cy="13"
                  r="1.2"
                  fill="currentColor"
                  stroke="none"
                /><path d="M2 2l12 12" /></svg
              >
            </span>
            <div>
              <h3>Zero network egress</h3>
              <p>
                Mic → Nvidia Parakeet in RAM → CGEvent keystrokes. Audio is
                discarded immediately after transcription.
              </p>
            </div>
          </div>
          <div class="secrow">
            <span
              class="secicn"
              aria-hidden="true"
            >
              <svg
                viewBox="0 0 16 16"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                ><circle
                  cx="7"
                  cy="7"
                  r="5"
                /><path d="m11 11 3.5 3.5M5 7l1.5 1.5L9 5.5" /></svg
              >
            </span>
            <div>
              <h3>Verify it yourself</h3>
              <p>
                Turn on Airplane mode or pull the Wi-Fi. Every feature continues
                to work with zero connection.
              </p>
            </div>
          </div>
          <div class="secrow">
            <span
              class="secicn"
              aria-hidden="true"
            >
              <svg
                viewBox="0 0 16 16"
                width="22"
                height="22"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                ><path d="M5.5 4.5 2 8l3.5 3.5M10.5 4.5 14 8l-3.5 3.5" /></svg
              >
            </span>
            <div>
              <h3>Open source, MIT</h3>
              <p>
                Every line of code is open on GitHub. Audit the Swift and Svelte
                sources anytime.
              </p>
            </div>
          </div>
        </div>

        <div
          class="secproof"
          use:reveal={{ delay: 100 }}
        >
          <p class="mono">
            Audit network sockets: <code>lsof -p $(pgrep typie) -i</code> returns
            empty
          </p>
        </div>
      </div>
    </section>

    <!-- Act 8: Questions Answered -->
    <section
      class="faq"
      id="faq"
    >
      <div class="container">
        <h2 use:reveal>Frequently asked questions</h2>
        <div
          class="faqlist"
          use:reveal={{ delay: 40 }}
        >
          <details open>
            <summary>Does my voice ever touch the internet?</summary>
            <p>
              No. Mic → local model → keystrokes, all on your Apple Silicon
              chip. Audio never leaves RAM and is discarded instantly. The only
              download is the 500 MB model on initial setup.
            </p>
          </details>
          <details>
            <summary>Which apps does Typie work in?</summary>
            <p>
              Any application that accepts text. Slack, Mail, Notion, VS Code,
              Cursor, Linear, Google Docs, Apple Notes, and browsers. If there's
              a cursor, it types there.
            </p>
          </details>
          <details>
            <summary
              >How is this different from built-in macOS dictation?</summary
            >
            <p>
              Speed (80 ms), higher accuracy with Nvidia Parakeet, continuous
              dictation without timeout interruptions, and a full workspace for
              voice notes and bot-free meeting recording.
            </p>
          </details>
          <details>
            <summary>Does a bot join my Zoom or Google Meet calls?</summary>
            <p>
              Never. Typie captures audio locally via macOS system audio
              loopback. No participant sees a notetaker bot because everything
              is handled on-device.
            </p>
          </details>
          <details>
            <summary>Which languages are supported?</summary>
            <p>
              25 European languages via Nvidia Parakeet. Transcripts can be
              exported with speaker diarization, timestamps, and AI-structured
              summaries.
            </p>
          </details>
        </div>
      </div>
    </section>

    <!-- Act 9: Final Call to Action -->
    <section class="final">
      <div
        class="container finalinner"
        use:reveal
      >
        <h2>Just talk.<br /><em>It's typed.</em></h2>
        <div class="actions">
          <a
            href="https://github.com/samjhooker/typie/releases/latest"
            class="btn btn-primary bigcta"
          >
            <svg
              viewBox="0 0 384 512"
              width="16"
              height="16"
              fill="currentColor"
              aria-hidden="true"
              ><path
                d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.7-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"
              /></svg
            >
            Download for Mac — Free
          </a>
          <a
            href="https://github.com/samjhooker/typie"
            class="btn btn-ghost"
            target="_blank"
            rel="noopener"
          >
            View on GitHub
          </a>
        </div>
        <p
          class="trust mono"
          use:reveal={{ delay: 100 }}
        >
          No credit card · Native Apple Silicon · macOS 14+ · MIT License
        </p>
      </div>
    </section>
  </main>
  <Footer />
{/if}

<style>
  .sectionhead {
    text-align: center;
    max-width: 760px;
    margin: 0 auto;
  }
  .sectionhead h2 {
    font-size: clamp(34px, 4.4vw, 58px);
    font-weight: 800;
    line-height: 1.02;
    color: var(--ink);
  }
  .sectionhead h2 em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    letter-spacing: -0.02em;
    color: var(--hotpink);
  }
  .sectionhead p {
    margin-top: 14px;
    color: var(--text-2);
    font-size: 16px;
  }

  /* Quote break */
  .quote {
    background: var(--pink-band);
    padding: clamp(76px, 12vh, 120px) 0;
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
  }
  .bigquote {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 500;
    font-size: clamp(26px, 3.2vw, 42px);
    line-height: 1.35;
    color: var(--ink);
    max-width: 36ch;
    margin: 0 auto;
    text-align: center;
    text-wrap: balance;
  }
  .bigquote em {
    color: var(--hotpink);
    font-weight: 600;
  }
  .qattr {
    text-align: center;
    margin-top: 24px;
    font-size: 18px;
    color: var(--text-2);
  }

  /* Security & Architecture */
  .security {
    background: var(--surface);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
    padding: clamp(80px, 12vh, 130px) 0;
  }
  .secrows {
    max-width: 760px;
    margin: 44px auto 0;
  }
  .secrow {
    display: grid;
    grid-template-columns: 48px 1fr;
    gap: 22px;
    align-items: start;
    padding: 28px 4px;
    border-bottom: 1px solid var(--line);
  }
  .secrow:last-child {
    border-bottom: none;
  }
  .secicn {
    width: 48px;
    height: 48px;
    display: grid;
    place-items: center;
    color: var(--hotpink);
    background: var(--pink);
    border-radius: 14px;
  }
  .secrow h3 {
    font-size: 19px;
    font-weight: 800;
    color: var(--ink);
    margin-bottom: 6px;
  }
  .secrow p {
    font-size: 15px;
    color: var(--text-2);
    line-height: 1.55;
  }

  .secproof {
    margin-top: 36px;
    text-align: center;
  }
  .secproof code {
    font-family: var(--mono);
    color: var(--hotpink);
    background: var(--surface-2);
    padding: 4px 10px;
    border-radius: 8px;
    border: 1px solid var(--line);
  }

  /* FAQ */
  .faq {
    background: var(--surface-2);
    padding: clamp(72px, 10vh, 120px) 0;
  }
  .faq h2 {
    font-size: clamp(32px, 4vw, 48px);
    margin-bottom: 40px;
    text-align: center;
    color: var(--ink);
  }
  .faqlist {
    max-width: 740px;
    margin: 0 auto;
  }
  .faqlist details {
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: var(--radius-md);
    margin-bottom: 12px;
    padding: 0 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
  }
  .faqlist summary {
    font-weight: 700;
    font-size: 16px;
    cursor: pointer;
    list-style: none;
    color: var(--ink);
    padding: 20px 32px 20px 0;
    position: relative;
  }
  .faqlist summary::-webkit-details-marker {
    display: none;
  }
  .faqlist summary::after {
    content: '+';
    position: absolute;
    right: 0;
    top: 18px;
    font-size: 20px;
    color: var(--hotpink);
    font-weight: 700;
    transition: transform 0.2s var(--spring);
  }
  .faqlist details[open] summary::after {
    transform: rotate(45deg);
  }
  .faqlist p {
    margin: -4px 0 22px;
    font-size: 14.5px;
    color: var(--text-2);
    line-height: 1.65;
  }

  /* Final CTA */
  .final {
    background: var(--surface);
    padding: clamp(90px, 14vh, 150px) 0;
    text-align: center;
    border-top: 1px solid var(--line);
  }
  .finalinner h2 {
    font-size: clamp(54px, 9vw, 110px);
    line-height: 0.94;
    font-weight: 900;
    color: var(--ink);
  }
  .finalinner h2 em {
    font-family: var(--serif);
    font-weight: 600;
    font-style: italic;
    color: var(--hotpink);
  }
  .finalinner .actions {
    display: flex;
    gap: 14px;
    align-items: center;
    justify-content: center;
    margin-top: 40px;
    flex-wrap: wrap;
  }
  .bigcta {
    padding: 16px 32px;
    font-size: 16.5px;
  }
  .trust {
    margin-top: 24px;
    color: var(--text-3);
    font-size: 12px;
  }

  @media (max-width: 920px) {
    .secrow {
      grid-template-columns: 40px 1fr;
    }
  }
</style>
