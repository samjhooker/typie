<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import Steps from './lib/Steps.svelte';
  import AppsRow from './lib/AppsRow.svelte';
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
    <!-- act one — the verb -->
    <Hero />

    <!-- how it works, one slim strip -->
    <Steps />

    <!-- act two — everywhere -->
    <AppsRow />

    <!-- the honest engine -->
    <Depth />

    <!-- act three — one voice -->
    <section class="quote">
      <div class="container">
        <blockquote class="bigquote" use:reveal>
          “I used to type 200+ Slack messages a day. Now I just talk. <em>My wrists thank me.</em>”
        </blockquote>
        <p class="qattr mono" use:reveal={{delay:60}}>maya chen · founder · london</p>
      </div>
    </section>

    <!-- act four — private by architecture -->
    <section class="security" id="privacy">
      <div class="container">
        <div class="sectionhead" use:reveal>
          <h2>Private by architecture.<br /><em>Not by policy.</em></h2>
          <p>No toggles to flip, no settings to trust. The network path simply doesn't exist.</p>
        </div>
        <div class="secrows" use:reveal>
          <div class="secrow">
            <span class="secicn" aria-hidden="true"><svg viewBox="0 0 16 16" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"><path d="M1.5 5.5a10 10 0 0 1 13 0M3.9 8a6.4 6.4 0 0 1 8.2 0M6.2 10.5a2.9 2.9 0 0 1 3.6 0"/><circle cx="8" cy="13" r="1.2" fill="currentColor" stroke="none"/><path d="M2 2l12 12"/></svg></span>
            <div>
              <h3>Zero network egress</h3>
              <p>Mic → model → keystrokes. No server, no telemetry — the network path doesn't exist.</p>
            </div>
          </div>
          <div class="secrow">
            <span class="secicn" aria-hidden="true"><svg viewBox="0 0 16 16" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="7" cy="7" r="5"/><path d="m11 11 3.5 3.5M5 7l1.5 1.5L9 5.5"/></svg></span>
            <div>
              <h3>Verify it yourself</h3>
              <p>Pull the ethernet. Airplane mode. Everything still works — dictation, capture, summaries.</p>
            </div>
          </div>
          <div class="secrow">
            <span class="secicn" aria-hidden="true"><svg viewBox="0 0 16 16" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5.5 4.5 2 8l3.5 3.5M10.5 4.5 14 8l-3.5 3.5"/></svg></span>
            <div>
              <h3>Open source, MIT</h3>
              <p>Every line on GitHub. Build from source, audit it. No “trust us” required.</p>
            </div>
          </div>
        </div>
        <div class="secproof" use:reveal={{delay:120}}>
          <p class="mono">verify it yourself — airplane mode · <code>lsof -p $(pgrep typie) -i</code> returns empty</p>
        </div>
      </div>
    </section>

    <!-- act five — the questions -->
    <section class="faq" id="faq">
      <div class="container">
        <h2 use:reveal>Questions, answered</h2>
        <div class="faqlist" use:reveal={{delay:40}}>
          <details open><summary>Does my voice ever touch the internet?</summary><p>No. Mic → local model → keystrokes, all on this Mac. Audio is discarded instantly — there is no server to send it to. The only download is the model itself, once.</p></details>
          <details><summary>Does it work in any app?</summary><p>Yes — Slack, Mail, browsers, editors, that one CRM from 2008. If there's a cursor, it types there.</p></details>
          <details><summary>How's it different from built-in dictation?</summary><p>Speed (80 ms), accuracy, and real keystrokes into any app — no dictation mode to toggle.</p></details>
          <details><summary>What about voice notes?</summary><p>Hold the shortcut, say something, let go. A sticky lands on your wall — pinnable, searchable, one click to copy.</p></details>
          <details><summary>Does a bot join my calls?</summary><p>Never. Recording is local via system audio — no participant sees a notetaker.</p></details>
          <details><summary>Which languages, and can I get transcripts out?</summary><p>25 European languages via Nvidia Parakeet. Transcripts copy as markdown or export with speaker labels and timestamps.</p></details>
        </div>
      </div>
    </section>

    <script>
      // FAQ accordion — only one open at a time
      let faqDetails = [];
      $effect(() => {
        const grid = document.querySelector('.faqlist');
        if (!grid) return;
        faqDetails = Array.from(grid.querySelectorAll('details'));
        faqDetails.forEach(d => {
          d.addEventListener('toggle', () => {
            if (d.open) {
              faqDetails.filter(x => x !== d).forEach(x => x.open = false);
            }
          });
        });
      });
    </script>

    <!-- final page — the ask -->
    <section class="final">
      <div class="container finalinner" use:reveal>
        <h2>Just talk.<br /><em>It's typed.</em></h2>
        <div class="actions">
          <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-black bigcta">Download for Mac — free</a>
          <a href="https://github.com/samjhooker/typie" class="quietlink">View on GitHub</a>
        </div>
        <p class="trust mono" use:reveal={{delay:120}}>no credit card — there isn't even a place to put one · signed · hardened runtime · macos 14+ · apple silicon</p>
      </div>
    </section>
  </main>
  <Footer />
{/if}

<style>
  .sectionhead { text-align: center; max-width: 760px; margin: 0 auto; }
  .sectionhead h2 { font-size: clamp(34px, 4.4vw, 58px); font-weight: 800; line-height: 1.02; }
  .sectionhead h2 em { font-family: var(--serif); font-style: italic; font-weight: 600; letter-spacing: -0.02em; color: var(--hotpink); }
  .sectionhead p { margin-top: 14px; color: var(--text-2); font-size: 16px; }

  /* act three — one voice, a quiet band */
  .quote { background: linear-gradient(180deg, var(--paper) 0%, var(--pink-band) 22%, var(--pink-band) 78%, var(--paper) 100%); padding: clamp(76px, 12vh, 130px) 0; }
  .bigquote {
    font-family: var(--serif); font-style: italic; font-weight: 500;
    font-size: clamp(26px, 3.2vw, 42px); line-height: 1.35;
    color: var(--ink); max-width: 36ch; margin: 0 auto; text-align: center; text-wrap: balance;
  }
  .bigquote em { color: var(--hotpink); }
  .qattr { text-align: center; margin-top: 20px; text-transform: none; letter-spacing: 0.06em; }

  /* act four — security on white, quiet rows, proof one click away */
  .security { background: #fff; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); min-height: 94svh; display: flex; align-items: center; }
  .secrows { max-width: 760px; margin: 44px auto 0; }
  .secrow {
    display: grid; grid-template-columns: 44px 1fr; gap: 20px; align-items: start;
    padding: 30px 4px; border-bottom: 1px solid var(--line);
  }
  .secrow:last-child { border-bottom: none; }
  .secicn {
    width:44px; height:44px; display:grid; place-items:center;
    color: var(--hotpink); background: var(--pink); border-radius: 13px;
  }
  .secrow h3 { font-size: 18px; margin-bottom: 5px; }
  .secrow p { font-size: 14.5px; color: #52525b; line-height: 1.55; }

  /* privacy proof — one quiet line, no theater */
  .secproof { margin-top: 30px; text-align: center; }
  .secproof .mono { text-transform: none; letter-spacing: .05em; opacity: .6; }
  .secproof code { font-family: var(--mono); color: var(--text-2); }

  /* act five — questions */
  .faq { background: var(--paper); padding: clamp(72px, 10vh, 116px) 0; }
  .faq h2 { font-size: clamp(30px, 3.4vw, 44px); margin-bottom: 36px; text-align: center; }
  .faqlist { max-width: 720px; margin: 0 auto; }
  .faqlist details { border-bottom: 1px solid var(--line); padding: 0 4px; }
  .faqlist summary { font-weight: 700; font-size: 15.5px; cursor: pointer; list-style: none; font-family: var(--sans); color: var(--ink); padding: 16px 32px 8px 0; position: relative; }
  .faqlist summary::-webkit-details-marker { display: none; }
  .faqlist summary::after { content: '+'; position: absolute; right: 6px; top: 13px; font-size: 18px; color: var(--hotpink); font-weight: 600; transition: transform .2s var(--spring); }
  .faqlist details[open] summary::after { transform: rotate(45deg); }
  .faqlist p { margin: -2px 0 20px; font-size: 14.5px; color: #52525b; line-height: 1.6; max-width: 62ch; animation: faqIn .25s var(--ease-out); }
  @keyframes faqIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: none; } }

  /* the final page — huge, calm, one ask */
  .final { background: linear-gradient(180deg, var(--paper) 0%, var(--pink-band) 24%, var(--pink-band) 82%, #fff 100%); min-height: 94svh; display: flex; align-items: center; text-align: center; }
  .finalinner h2 { font-size: clamp(52px, 9vw, 116px); line-height: 0.94; }
  .finalinner h2 em { font-family: var(--serif); font-weight: 600; font-style: italic; color: var(--hotpink); }
  .finalinner .actions { display: flex; gap: 12px; align-items: center; justify-content: center; margin-top: 36px; flex-wrap: wrap; }
  .bigcta { padding: 16px 28px; font-size: 16px; }
  .trust { margin-top: 22px; text-transform: none; letter-spacing: 0.05em; opacity: 0.6; }
  .quietlink {
    font-size:13.5px; font-weight:600; color:var(--text-3);
    transition: color .2s ease;
  }
  .quietlink:hover { color:var(--ink); }

  @media (max-width: 920px) {
    .secrow { grid-template-columns: 36px 1fr; }
  }
</style>
