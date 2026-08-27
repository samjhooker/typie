<script>
  import Nav from './lib/Nav.svelte';
  import Hero from './lib/Hero.svelte';
  import AppsRow from './lib/AppsRow.svelte';
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
    <Hero />

    <!-- Key facts - front and center -->
    <section class="strip">
      <div class="container strip-inner">
        <span class="mono">the whole deal — no asterisks</span>
        <div class="logos" aria-label="key features">
          <span class="lpill"><b>100% free</b> — every feature, forever</span>
          <span class="lpill"><b>100% offline</b> — your data never leaves this Mac</span>
          <span class="lpill"><b>No account</b> — ever, not even optional</span>
          <span class="lpill"><b>Open source</b> — MIT, audit every line</span>
        </div>
      </div>
    </section>

    <!-- Works wherever you type -->
    <AppsRow />

    <!-- Testimonials - real voices -->
    <section class="testimonials field">
      <div class="container">
        <div class="sectionhead" use:reveal>
          <div class="mono">Testimonials</div>
          <h2>Don't take our word for it</h2>
        </div>
        <div class="testigrid" use:reveal={{delay:40}}>
          <article class="tcard" use:reveal>
            <p class="tquote">"I used to type 200+ Slack messages a day. Now I just talk. My wrists thank me."</p>
            <div class="tattr">
              <img src="/assets/avatar-1.webp" alt="" width="36" height="36" style="border-radius:50%; object-fit:cover;" />
              <div>
                <strong>Maya Chen</strong><br />
                <span class="mono">Founder, London · 6 months daily</span>
              </div>
            </div>
          </article>
          <article class="tcard" use:reveal={{delay:40}}>
            <p class="tquote">"The call capture is witchcraft. Recorded a 45-min sync, got speaker-separated notes before I even left the room."</p>
            <div class="tattr">
              <img src="/assets/avatar-2.webp" alt="" width="36" height="36" style="border-radius:50%; object-fit:cover;" />
              <div>
                <strong>Sam H.</strong><br />
                <span class="mono">Engineer, SF · ships on Typie</span>
              </div>
            </div>
          </article>
          <article class="tcard" use:reveal={{delay:80}}>
            <p class="tquote">"Finally, dictation that doesn't make me look like I'm talking to a broken robot. It just works — in Vim, in Figma, everywhere."</p>
            <div class="tattr">
              <img src="/assets/avatar-3.webp" alt="" width="36" height="36" style="border-radius:50%; object-fit:cover;" />
              <div>
                <strong>Priya R.</strong><br />
                <span class="mono">Designer, Berlin · keyboard snob</span>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>

    <!-- Privacy / Security — architecture, not promises -->
    <section class="security field" id="privacy">
      <div class="container">
        <div class="sectionhead" use:reveal>
          <div class="mono">Privacy</div>
          <h2>Private by architecture.<br />Not by policy.</h2>
          <p>No toggles to flip, no settings to trust. The network path simply doesn't exist.</p>
        </div>
        <div class="seccards">
          <div class="scard" use:reveal>
            <div class="scard-icon mono">⊘</div>
            <h3>Zero network egress</h3>
            <p>Mic → local model → keystrokes. Audio is discarded instantly. No telemetry, no update pings, no analytics. The binary has no network entitlements.</p>
          </div>
          <div class="scard" use:reveal={{delay:60}}>
            <div class="scard-icon mono">⌁</div>
            <h3>Verify it yourself</h3>
            <p>Pull the ethernet. Disable wifi. Airplane mode. Everything still works — dictation, call capture, summaries. That's the architecture.</p>
          </div>
          <div class="scard" use:reveal={{delay:120}}>
            <div class="scard-icon mono">◇</div>
            <h3>Open source, MIT</h3>
            <p>Every line on GitHub. Build from source, audit the model weights, contribute. No hidden code, no "trust us" required.</p>
          </div>
        </div>
        <div class="secproof" use:reveal={{delay:180}}>
          <details>
            <summary>Show me the proof →</summary>
            <div class="proofgrid">
              <div class="proof">
                <code>lsappinfo info -only entitlements com.typie.app</code>
                <p class="mono">No <code>com.apple.security.network.client</code> entitlement</p>
              </div>
              <div class="proof">
                <code>sudo lsof -p $(pgrep typie) -i</code>
                <p class="mono">Returns empty — zero open sockets</p>
              </div>
              <div class="proof">
                <code>codesign -d --entitlements :- /Applications/Typie.app</code>
                <p class="mono">Hardened runtime, no network, no JIT</p>
              </div>
            </div>
          </details>
        </div>
      </div>
    </section>

    <!-- FAQ -->
    <section class="faq field" id="faq">
      <div class="container">
        <h2 use:reveal>FAQ</h2>
        <div class="faqgrid" use:reveal={{delay:40}}>
          <details open><summary>Does my voice leave the Mac?</summary><p>No. Ever. Mic → local model → keystrokes. Audio is discarded. There is no server.</p></details>
          <details><summary>Does it work in any app?</summary><p>Yes — Slack, Mail, browsers, editors, that one CRM from 2008. If there's a cursor, it types there.</p></details>
          <details><summary>How's it different from built-in dictation?</summary><p>Speed (80 ms), accuracy, and it types into any app via real keystrokes — no dictation mode to toggle.</p></details>
          <details><summary>What about voice notes?</summary><p>Hold the shortcut, say something, let go. A sticky lands on your wall — pinnable, searchable, always one click to copy.</p></details>
          <details><summary>Do I need the internet?</summary><p>Only for the initial model download. After that, airplane mode is home.</p></details>
          <details><summary>Does a bot join my calls?</summary><p>Never. Recording is local via system audio, so no participant sees a notetaker.</p></details>
          <details><summary>Which languages?</summary><p>25 European languages via Nvidia Parakeet. More when the local model supports them well.</p></details>
          <details><summary>Can I export transcripts?</summary><p>Yes — copy as markdown, or export the full transcript with speaker labels and timestamps.</p></details>
        </div>
      </div>
    </section>

    <script>
      // FAQ accordion — only one open at a time
      let faqDetails = [];
      $effect(() => {
        const grid = document.querySelector('.faqgrid');
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

    <!-- Final CTA -->
    <section class="final">
      <div class="container finalinner" use:reveal>
        <h2>Just talk.<br /><em>It's typed.</em></h2>
        <p>Dictation, voice notes, call capture and summaries — all offline on your Mac.</p>
        <div class="actions">
          <a href="https://github.com/samjhooker/typie/releases/latest" class="btn btn-black" style="padding:14px 24px; font-size:15px">Download for Mac — free</a>
          <a href="https://github.com/samjhooker/typie" class="btn btn-white">View on GitHub</a>
        </div>
      </div>
    </section>
  </main>
  <Footer />
{/if}

<style>
  /* strip */
  .strip { border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); background: #fcfcfc; }
  .strip-inner { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 14px 0; flex-wrap: wrap; }
  .logos { display: flex; gap: 10px; flex-wrap: wrap; font-size: 12.5px; font-weight: 600; color: #3f3f46; align-items:center; }
  .logos span { background: #fff; border: 1px solid var(--line); padding: 7px 12px; border-radius: 999px; }
  .lpill b{ color:#0a0a0a }

  .sectionhead { text-align: center; max-width: 720px; margin: 0 auto; }
  .sectionhead h2 { font-size: clamp(26px, 3.6vw, 38px); font-weight: 800; }
  .sectionhead p { margin-top: 10px; color: var(--text-2); }

  /* testimonials */
  .testimonials { background: #fff; border-top: 1px solid var(--line); }
  .testigrid { display: grid; grid-template-columns: repeat(3,1fr); gap: 20px; margin-top: 28px; }
  .tcard { background: #fff; border: 1px solid var(--line); border-radius: 16px; padding: 28px 24px; transition: transform .35s var(--spring), box-shadow .35s var(--spring), border-color .25s ease; }
  .tcard:hover { transform: translateY(-6px); box-shadow: 0 20px 40px rgba(19,23,34,.1); border-color: var(--line-strong); }
  .tquote { font-size: clamp(15px, 1.6vw, 17px); line-height: 1.55; color: #131722; font-weight: 500; margin: 0 0 20px; font-family: var(--sans); position: relative; padding-left: 18px; }
  .tquote::before { content: '"'; position: absolute; left: -4px; top: -4px; font-size: 48px; color: var(--hotpink); font-family: var(--serif); line-height: 1; opacity: .6; }
  .tattr { display: flex; align-items: center; gap: 12px; }
  .tattr div { display: flex; flex-direction: column; gap: 2px; }
  .tattr strong { font-size: 14px; color: #0a0a0a; }
  .tattr .mono { font-size: 11.5px; color: var(--text-3); letter-spacing: .04em; }

  .security { background: #fff; border-top: 1px solid var(--line); }
  .seccards { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-top: 24px; }
  .scard { border: 1px solid var(--line); border-radius: 16px; padding: 26px 22px; background: #fff; position:relative; overflow:hidden; transition: transform .35s var(--spring), box-shadow .35s var(--spring), border-color .25s ease; }
  .scard:hover { transform: translateY(-4px); box-shadow: 0 14px 32px rgba(19,23,34,.08); border-color: var(--line-strong); }
  .scard-icon {
    width:38px; height:38px; display:grid; place-items:center;
    border:1px solid var(--line); border-radius:11px; background:var(--surface);
    font-size:16px; color:var(--hotpink); margin-bottom:14px;
  }
  .scard h3 { font-size: 16px; margin-bottom: 6px; }
  .scard p { font-size: 14px; color: #52525b; line-height: 1.55; }

  /* privacy proof */
  .secproof { margin-top: 28px; text-align: center; }
  .secproof details { display: inline-block; text-align: left; }
  .secproof summary { cursor: pointer; font-weight: 600; color: var(--hotpink); font-size: 13px; list-style: none; padding: 8px 16px; border: 1px solid var(--hotpink); border-radius: 999px; background: #fff; transition: background .2s ease, color .2s ease; }
  .secproof summary::-webkit-details-marker { display: none; }
  .secproof summary:hover { background: #fff5f7; }
  .secproof[open] summary { background: #fff0f3; color: #c02a4a; }
  .proofgrid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-top: 20px; text-align: left; }
  .proof { background: #0a0e1a; border: 1px solid rgba(255,255,255,.08); border-radius: 12px; padding: 16px; }
  .proof code { display: block; color: #6ee89a; font-size: 11.5px; line-height: 1.6; margin-bottom: 8px; font-family: var(--mono); white-space: pre-wrap; }
  .proof .mono { color: rgba(255,255,255,.5); font-size: 11px; }

  .faq { background: #fff; border-top: 1px solid var(--line); }
  .faq h2 { font-size: 22px; margin-bottom: 16px; font-family: var(--display); }
  .faqgrid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .faqgrid details { border: 1px solid var(--line); border-radius: 12px; padding: 14px 16px; background: #fff; transition: border-color .18s ease, box-shadow .18s ease, transform .18s var(--spring); }
  .faqgrid details:hover{ border-color:#ffd0d8; box-shadow: 0 4px 12px rgba(255,59,107,.07); transform: translateY(-1px); }
  .faqgrid details[open]{ border-color:#ff3b6b; background:#fffafd; }
  .faqgrid summary { font-weight: 700; font-size: 14px; cursor: pointer; list-style: none; font-family: var(--sans); padding-right: 28px; position: relative; }
  .faqgrid summary::-webkit-details-marker { display: none; }
  .faqgrid summary::after { content: '+'; position: absolute; right: 0; top: 0; font-size: 18px; color: var(--hotpink); font-weight: 600; transition: transform .2s var(--spring); }
  .faqgrid details[open] summary::after { transform: rotate(45deg); }
  .faqgrid p { margin-top: 10px; font-size: 13.5px; color: #52525b; line-height: 1.6; animation: faqIn .25s var(--ease-out); }
  @keyframes faqIn { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: none; } }

  .final { background: radial-gradient(ellipse 70% 60% at 50% 0%, #ffe4ea 0%, transparent 55%), linear-gradient(180deg, #fff 0%, #fef2f4 55%, #fff 100%); border-top: 1px solid var(--line); padding: 64px 0 56px; text-align: center; position:relative; overflow:hidden; }
  .final::before{ content:'✦'; position:absolute; top:18px; left:50%; transform: translateX(-180px) rotate(-8deg); font-size:22px; color:#ff3b6b; opacity:.7; }
  .final::after{ content:'✦'; position:absolute; top:22px; left:50%; transform: translateX(170px) rotate(12deg); font-size:16px; color:#7a5CFA; opacity:.5; }
  .finalinner h2 { font-size: clamp(32px, 4.6vw, 48px); line-height:0.95; }
  .finalinner h2 em { font-family: var(--serif); font-weight: 500; font-style: italic; background: linear-gradient(90deg,#ff3b6b,#7a5CFA); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
  .finalinner p { margin-top: 10px; color: #52525b; max-width:42ch; margin-inline:auto; }
  .finalinner .actions { display: flex; gap: 10px; justify-content: center; margin-top: 20px; flex-wrap: wrap; }

  @media (max-width: 920px) {
    .seccards, .faqgrid { grid-template-columns: 1fr; }
    .strip-inner { flex-direction: column; align-items: flex-start; }
  }
  @media (min-width: 921px) and (max-width: 1100px) {
    .seccards { grid-template-columns: 1fr 1fr; }
  }
</style>
