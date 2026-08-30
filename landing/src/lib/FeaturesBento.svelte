<script>
  import { reveal } from './reveal.js';
  import {
    Mic,
    StickyNote,
    FileAudio,
    PhoneCall,
    Sparkles,
    WifiOff,
    Code2,
  } from 'lucide-svelte';
  import ShellFrame from './real/ShellFrame.svelte';
  import StickyWall from './real/StickyWall.svelte';
  import TranscriptTurns from './real/TranscriptTurns.svelte';
  import AiSummaryPanel from './real/AiSummaryPanel.svelte';
  import Robot from './Robot.svelte';

  // ── who-said-what scrub data (mirrors the real 12:04 demo call) ──
  const DUR = 12 * 60 + 4;
  const SPEECH = [
    [0, '00:14'],
    [1, '00:21'],
    [0, '00:34'],
    [1, '00:48'],
    [0, '00:55'],
    [1, '01:08'],
    [0, '01:24'],
    [1, '02:05'],
    [0, '03:12'],
    [1, '03:40'],
    [0, '04:58'],
    [1, '05:46'],
    [0, '06:30'],
    [1, '07:22'],
    [0, '08:35'],
    [1, '09:50'],
    [0, '10:40'],
    [1, '11:52'],
  ];
  const SP_COLORS = ['#fc5681', '#6f8ffb'];
  function secs(ts) {
    const [m, s] = ts.split(':').map(Number);
    return m * 60 + s;
  }
  const SEGS = SPEECH.map(([s, t], i) => {
    const start = secs(t);
    const next = i < SPEECH.length - 1 ? secs(SPEECH[i + 1][1]) : DUR;
    return {
      s,
      left: (start / DUR) * 100,
      width: ((next - start) / DUR) * 100,
    };
  });
</script>

<section
  class="bento-section"
  id="features"
>
  <div class="container">
    <div
      class="head"
      use:reveal
    >
      <h2>Dictate. Capture. Remember.<br /><em>All on your Mac.</em></h2>
      <p class="sub">
        No cloud, no bots, no subscriptions. Just talk, Typie handles the rest,
        locally, in milliseconds.
      </p>
    </div>

    <div class="grid">
      <!-- 03, Voice notes (full width), real wall of notes in a scrollable pane -->
      <!-- (visually 3rd, below dictate + offline; see grid order in styles) -->
      <article
        class="card c1"
        use:reveal
      >
        <div class="cardTop">
          <span
            class="icon"
            style="--c:#0f9d6a"
            ><StickyNote
              size={18}
              strokeWidth={2.2}
            /></span
          >
        </div>
        <h3>Voice notes, anywhere</h3>
        <p>
          Quick thought? Tap New Note in the app or the note button in the
          notch, ramble, let go. It’s pinned to your Typie wall, searchable,
          timestamped, local. Easy peasy.
        </p>
        <div
           class="livePreview shellPreview"
           aria-hidden="true"
         >
           <ShellFrame
             active="notes"
             sidebar={false}
           >
             <div class="wallScroll">
               <StickyWall limit={6}
               />
             </div>
           </ShellFrame>
         </div>
         <div class="inapp-caption mono">In-app · Notes: StickyWall, as you see it</div>
      </article>

      <!-- 01, Dictate into any app (left), real Mac option key -->
      <article
        class="card c2"
        use:reveal={{ delay: 70 }}
      >
        <div class="cardTop">
          <span
            class="icon"
            style="--c:#fc5681"
            ><Mic
              size={18}
              strokeWidth={2.2}
            /></span
          >
        </div>
        <h3>Dictate into any app</h3>
        <p>
          If your cursor blinks there, Typie types there. Release and real
          keystrokes land at your cursor in <b>80 ms</b>. No plugins, no
          clipboard hacks.
        </p>
        <div
          class="appsRow"
          aria-hidden="true"
        >
          <span class="appChip">Slack</span>
          <span class="appChip">Mail</span>
          <span class="appChip">Safari</span>
          <span class="appChip">Notion</span>
          <span class="appChip">VS Code</span>
          <span class="appChip">Linear</span>
        </div>
        <div
          class="demoStack"
          aria-hidden="true"
        >
          <div class="optionKey">
            <i class="optIcon">⌥</i>
            <span class="optLabel">option</span>
          </div>
          <span class="demoArrow">→</span>
          <span class="demoBubble">
            <span class="listening"><i></i><i></i><i></i></span>
            <span class="final">
              “pricing page is Sam’s, video is mine”<i class="caret"></i>
            </span>
          </span>
        </div>
        <div class="demoMeta mono">
          hold ⌥ · talk · release, 80 ms later it’s text
        </div>
      </article>

      <!-- 04, Transcribe & diarize, full width: 1/3 text left, 2/3 diarization UI right -->
      <!-- (visually 4th; see grid order in styles) -->
      <article
        class="card c3 split"
        use:reveal
      >
        <div class="cardCopy">
          <div class="cardTop">
            <span
              class="icon"
              style="--c:#6f8ffb"
              ><FileAudio
                size={18}
                strokeWidth={2.2}
              /></span
            >

          </div>
          <h3>Transcribe & diarize any file</h3>
          <p>
            Drop <code>mp3</code> <code>m4a</code> <code>wav</code>
            <code>mp4</code> onto Typie. Speakers are split, every turn is stamped,
            and markdown is ready, fully offline.
          </p>
          <div
            class="exportRow mono"
            aria-hidden="true"
          >
            <span class="exChip">↓ .md</span>
            <span class="exChip">↓ .txt</span>
            <span class="exChip">↓ .srt</span>
          </div>
        </div>
        <div class="previewWrap">
           <div
             class="livePreview transcriptPreview shellPreview"
             aria-hidden="true"
           >
             <ShellFrame
               active="library"
               sidebar={false}
             >
               <div class="tpLegend">
                 <span class="spPill"
                   ><i style="background:{SP_COLORS[0]}"></i>Maya</span
                 >
                 <span class="spPill"
                   ><i style="background:{SP_COLORS[1]}"></i>Sam</span
                 >
                 <span class="tpHint mono">diarized on-device</span>
               </div>
               <div class="tpTurns">
                 <TranscriptTurns />
               </div>
               <div class="tpScrub">
                 <span class="tpTime mono">00:00</span>
                 <div class="tpTrack">
                   {#each SEGS as seg, i (i)}
                     <div
                       class="tpSeg"
                       style="left:{seg.left}%; width:{seg.width}%; background:{SP_COLORS[
                         seg.s
                       ]}"
                     ></div>
                   {/each}
                   <i class="tpHead"></i>
                 </div>
                 <span class="tpTime mono">12:04</span>
               </div>
             </ShellFrame>
           </div>
           <div class="inapp-caption mono">In-app · Transcript: speaker turns, searchable</div>
         </div>
      </article>

      <!-- 06, Capture any call, Dialpad-style call app in the foreground -->
      <!-- (visually 6th; see grid order in styles) -->
      <article
        class="card c4"
        use:reveal={{ delay: 70 }}
      >
        <div class="cardTop">
          <span
            class="icon"
            style="--c:#f97316"
            ><PhoneCall
              size={18}
              strokeWidth={2.2}
            /></span
          >

        </div>
        <h3>Capture any call or meeting</h3>
        <p>
          Records system audio going <em>in</em> and <em>out</em> of your Mac, Zoom,
          Meet, FaceTime, no bot ever joins. Attendees see nothing.
        </p>
        <div
          class="livePreview callPreview"
          aria-hidden="true"
        >
          <!-- real app anatomy: natural hardware notch (camera only) → expands into recording island -->
          <div class="notchAnim">
            <span class="notchCam"></span>
            <span class="notchRobot"
              ><Robot
                size={13}
                mood="listening"
              /></span
            >
            <span class="notchIcons">
              <span class="nWave"><i></i><i></i><i></i><i></i></span>
              <span
                class="callRec"
                title="recording call"
              >
                <svg
                  viewBox="0 0 16 16"
                  width="12"
                  height="12"
                  ><rect
                    x="2.5"
                    y="2.5"
                    width="11"
                    height="11"
                    fill="none"
                    stroke="#4ade80"
                    stroke-width="1.8"
                  /><rect
                    x="6"
                    y="6"
                    width="4"
                    height="4"
                    fill="#4ade80"
                  /></svg
                >
              </span>
              <span class="recLabel mono"><i class="recDot"></i>REC 00:12</span>
            </span>
          </div>
          <!-- Dialpad-inspired call app window in the foreground -->
          <div class="callWin">
            <div class="dwSide">
              <div class="dwActiveBar">Active Calls</div>
              <div class="dwActive">
                <span class="dwAv">M</span>
                <span class="dwWho">
                  <strong>Maya Chen</strong>
                  <i class="mono">12:53</i>
                </span>
                <span class="dwGlyphs">
                  <svg
                    viewBox="0 0 16 16"
                    width="11"
                    height="11"
                    fill="none"
                    stroke="#ef4444"
                    stroke-width="1.6"
                    ><path
                      d="M3 6c1.5 4 8.5 4 10 0M3 6l-1.2 2.4M13 6l1.2 2.4"
                      stroke-linecap="round"
                    /></svg
                  >
                  <svg
                    viewBox="0 0 16 16"
                    width="11"
                    height="11"
                    fill="none"
                    stroke="#8b5cf6"
                    stroke-width="1.6"
                    ><path
                      d="M2 9v-2M5 10V6M8 11V5M11 10V6M14 9V7"
                      stroke-linecap="round"
                    /></svg
                  >
                </span>
              </div>
              <ul class="dwNav">
                <li>Inbox</li>
                <li>Contacts</li>
                <li>All channels</li>
              </ul>
            </div>
            <div class="dwMain">
              <span class="dwAvatar">M</span>
              <span class="dwName">Maya Chen</span>
              <span class="dwPhone mono">(604) 649-0504</span>
              <span class="dwTimer mono">12:53</span>
              <div class="dwBtns">
                <span class="dwBtn"
                  ><svg
                    viewBox="0 0 24 24"
                    width="12"
                    height="12"
                    fill="none"
                    stroke="#3f4450"
                    stroke-width="1.8"
                    ><rect
                      x="3"
                      y="6"
                      width="13"
                      height="12"
                      rx="2"
                    /><path d="m16 10 5-3v10l-5-3z" /></svg
                  ></span
                >
                <span class="dwBtn rec"
                  ><svg
                    viewBox="0 0 24 24"
                    width="12"
                    height="12"
                    fill="none"
                    stroke="#4ade80"
                    stroke-width="1.8"
                    ><rect
                      x="4"
                      y="4"
                      width="16"
                      height="16"
                      rx="2"
                    /><rect
                      x="9"
                      y="9"
                      width="6"
                      height="6"
                      fill="#4ade80"
                      stroke="none"
                    /></svg
                  ></span
                >
                <span class="dwBtn"
                  ><svg
                    viewBox="0 0 24 24"
                    width="12"
                    height="12"
                    fill="none"
                    stroke="#3f4450"
                    stroke-width="1.8"
                    stroke-linecap="round"
                    ><rect
                      x="9"
                      y="3"
                      width="6"
                      height="11"
                      rx="3"
                    /><path d="M5 11a7 7 0 0 0 14 0M12 18v3" /></svg
                  ></span
                >
                <span class="dwBtn"
                  ><svg
                    viewBox="0 0 24 24"
                    width="12"
                    height="12"
                    fill="#3f4450"
                    ><rect
                      x="7"
                      y="6"
                      width="3.6"
                      height="12"
                      rx="1.2"
                    /><rect
                      x="13.4"
                      y="6"
                      width="3.6"
                      height="12"
                      rx="1.2"
                    /></svg
                  ></span
                >
                <span class="dwBtn end"
                  ><svg
                    viewBox="0 0 24 24"
                    width="13"
                    height="13"
                    fill="#fff"
                    ><path
                      d="M3 9a13 13 0 0 1 18 0v6l-4 1-2-3a8 8 0 0 0-6 0l-2 3-4-1z"
                    /></svg
                  ></span
                >
              </div>
            </div>
          </div>
          <div class="notchCaption mono">
            hardware notch → recording island · 0 bytes sent
          </div>
        </div>
      </article>

      <!-- 05, AI summaries, 50/50: text left, the app's actual AI panel right -->
      <article
        class="card c5 split"
        use:reveal
      >
        <div class="cardCopy">
          <div class="cardTop">
            <span
              class="icon"
              style="--c:#c88cfd"
              ><Sparkles
                size={18}
                strokeWidth={2.2}
              /></span
            >

          </div>
          <h3>AI summaries, timestamps & actions</h3>
          <p>
            On-device Apple Intelligence turns the transcript into a clean
            breakdown: sections by timestamp, key quotes, and action items. Jump
            to <span
              class="mono"
              style="color:var(--hotpink);font-weight:700">06:30</span
            >
            and you’re there.
          </p>
          <div
            class="actRow"
            aria-hidden="true"
          >
            <span class="actChip">✓ Finish pricing page</span>
            <span class="actChip">✓ Record demo video</span>
            <span class="actChip">✓ Sync at 4pm</span>
          </div>
        </div>
        <div class="previewWrap">
           <div
             class="livePreview aiPreview shellPreview"
             aria-hidden="true"
           >
             <ShellFrame active="library">
               <AiSummaryPanel />
             </ShellFrame>
           </div>
           <div class="inapp-caption mono">In-app · AI summary: on-device breakdown</div>
         </div>
      </article>

      <!-- 02, Fully offline, plain command, no terminal chrome -->
      <!-- (visually 3rd, right of dictate; see grid order in styles) -->
      <article
        class="card c6"
        use:reveal={{ delay: 70 }}
      >
        <div class="cardTop">
          <span
            class="icon"
            style="--c:#0f9d6a"
            ><WifiOff
              size={18}
              strokeWidth={2.2}
            /></span
          >

        </div>
        <h3>100% offline after first download</h3>
        <p>
          One 500 MB model download. After that: airplane mode, no Wi-Fi,
          underground, every feature works. No server exists to receive your
          voice.
        </p>
        <div
          class="cmd"
          aria-hidden="true"
        >
          <span class="cmdLabel mono">try it yourself, watch the packets</span>
          <code class="cmdLine mono"
            ><span class="tprompt">$</span> lsof -i -a -p $(pgrep -x Typie)</code
          >
          <span class="cmdOut mono"
            >(no output), zero open connections, in or out</span
          >
        </div>
      </article>

      <!-- 07, Free & OSS, full width closer -->
      <article
        class="card c7"
        use:reveal
      >
        <div class="cardTop">
          <span
            class="icon"
            style="--c:#111827"
            ><Code2
              size={18}
              strokeWidth={2.2}
            /></span
          >

        </div>
        <h3>Free & open source</h3>
        <p>
          MIT on GitHub. No account, no credit card, no limits. Audit the Swift
          + Svelte source whenever you want. We can add your graphic here, just
          ask.
        </p>
        <div class="ossRow">
          <a
            class="btn btn-ghost small"
            href="https://github.com/samjhooker/typie"
            target="_blank"
            rel="noopener">View source</a
          >
          <span class="mono muted">typie.cc · MIT</span>
        </div>
      </article>
    </div>
  </div>
</section>

<style>
  .bento-section {
    padding: clamp(64px, 9vh, 100px) 0;
    background: var(--surface-2);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
  }
  .head {
    text-align: center;
    max-width: 740px;
    margin: 0 auto 36px;
  }
  h2 {
    font-size: clamp(30px, 4vw, 48px);
    font-weight: 800;
    line-height: 1.03;
    color: var(--ink);
  }
  h2 em {
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    color: var(--hotpink);
  }
  .sub {
    margin-top: 12px;
    font-size: 15.5px;
    line-height: 1.6;
    color: var(--text-2);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    grid-auto-rows: minmax(180px, auto);
    gap: 16px;
    max-width: 1100px;
    margin: 0 auto;
  }
  .card {
    background-color: var(--surface);
    /* stage texture, faint dot grid, the card reads as a mat */
    background-image: radial-gradient(
      rgba(19, 23, 34, 0.05) 1px,
      transparent 1px
    );
    background-size: 18px 18px;
    border: 1px solid var(--line);
    border-radius: var(--radius-card);
    padding: 22px 20px 16px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
    min-width: 0;
    overflow: hidden;
  }
  /* no hover lift, deliberate */
  .card:hover {
    border-color: var(--line);
    box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
    transform: none;
  }
  /* visual order: [dictate | offline] → voice notes (full) → transcribe (full)
     → [ai summaries | capture any call] → free & OSS (full). DOM order kept,
     layout sequence driven by grid order. */
  .c1 {
    grid-column: span 12;
    order: 2;
  }
  .c2 {
    grid-column: span 7;
    order: 0;
    background-color: var(--card-mint);
  }
  .c3 {
    grid-column: span 12;
    order: 3;
  }
  .c4 {
    grid-column: span 6;
    order: 5;
    background-color: #fff7ed;
  }
  .c5 {
    grid-column: span 6;
    order: 4;
    background-color: #faf5ff;
  }
  .c6 {
    grid-column: span 5;
    order: 1;
  }
  .c7 {
    grid-column: span 12;
    order: 6;
    background-color: var(--ink);
    color: #f8fafc;
  }

  .c7 h3 {
    color: #fff;
  }
  .c7 p {
    color: rgba(248, 250, 252, 0.82);
  }
  .c7 .muted {
    color: rgba(255, 255, 255, 0.55);
  }

  /* horizontal split cards, text left, UI right */
  .split {
    flex-direction: row;
    align-items: stretch;
    gap: 20px;
    padding: 22px;
  }
  .cardCopy {
    flex: 1 1 0;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .c3 .cardCopy {
    flex: 1 1 30%;
    max-width: 320px;
  }
  .c3 .livePreview {
    flex: 2 1 0;
  }
  .c5 .cardCopy,
  .c5 .livePreview {
    flex: 1 1 0;
  }

  .exportRow {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: auto;
    padding-top: 6px;
  }
  .exChip {
    padding: 3px 9px;
    border-radius: 7px;
    background: var(--surface-2);
    border: 1px solid var(--line);
    font-size: 10px;
    font-weight: 600;
    color: var(--text-2);
  }
  .actRow {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
    margin-top: auto;
    padding-top: 6px;
  }
  .actChip {
    padding: 4px 11px;
    border-radius: 999px;
    background: rgba(252, 86, 129, 0.07);
    border: 1px solid rgba(252, 86, 129, 0.2);
    font-size: 11px;
    font-weight: 600;
    color: var(--ink);
  }

  .cardTop {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .icon {
    width: 30px;
    height: 30px;
    border-radius: 9px;
    display: grid;
    place-items: center;
    background: var(--surface);
    color: var(--c);
    border: 1px solid var(--line);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }
  .c2 .icon,
  .c5 .icon {
    background: var(--surface);
  }
  .c7 .icon {
    background: rgba(255, 255, 255, 0.1);
    border-color: rgba(255, 255, 255, 0.14);
    color: #fff;
  }
  h3 {
    font-size: 16.5px;
    font-weight: 800;
    letter-spacing: -0.02em;
    color: var(--ink);
    line-height: 1.25;
  }
  p {
    font-size: 13.5px;
    line-height: 1.55;
    color: var(--text-2);
  }
  p b {
    color: var(--ink);
  }
  p kbd {
    font-family: var(--mono);
    font-size: 11px;
    font-weight: 700;
    padding: 2px 6px;
    border-radius: 6px;
    background: var(--surface-2);
    border: 1px solid var(--line);
    border-bottom-width: 2px;
  }
  p code {
    font-family: var(--mono);
    font-size: 11px;
    padding: 2px 6px;
    border-radius: 6px;
    background: var(--surface-2);
    border: 1px solid var(--line);
  }

  /* ── 01, voice notes: scrollable wall inside shell ── */
  .wallScroll {
    height: 100%;
    overflow-y: auto;
    padding: 14px 14px 16px;
    scrollbar-width: thin;
    scrollbar-color: var(--line-strong) transparent;
  }
  .wallScroll::-webkit-scrollbar {
    width: 6px;
  }
  .wallScroll::-webkit-scrollbar-track {
    background: transparent;
  }
  .wallScroll::-webkit-scrollbar-thumb {
    background: var(--line-strong);
    border-radius: 99px;
  }
  .wallScroll :global(.sticky) {
    min-height: 104px;
  }
  .wallScroll :global(.txt) {
    font-size: 12.5px;
    line-height: 1.5;
  }

  /* ── 02, dictate: real black Mac option key + blinking cursor ── */
  .appsRow {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }
  .appChip {
    padding: 4px 11px;
    border-radius: 999px;
    background: var(--surface);
    border: 1px solid var(--line);
    font-size: 11px;
    font-weight: 700;
    color: var(--text-2);
    white-space: nowrap;
  }
  .demoStack {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: auto; /* center the demo group in the card's free space */
    padding-top: 6px;
  }
  /* real Mac option keycap: square, heavily rounded, ⌥ top-right, label bottom */
  .optionKey {
    position: relative;
    width: 78px;
    height: 78px;
    background: linear-gradient(180deg, #1a1d23 0%, #0f1115 100%);
    border: 1px solid #2d333f;
    border-bottom-width: 4px;
    border-radius: 22px;
    box-shadow:
      0 4px 12px rgba(0, 0, 0, 0.18),
      inset 0 1px 0 rgba(255, 255, 255, 0.08);
    display: block;
    flex: none;
  }
  .optIcon {
    position: absolute;
    top: 7px;
    right: 9px;
    font-size: 17px;
    font-style: normal;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.8);
    line-height: 1;
  }
  .optLabel {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 9px;
    text-align: center;
    font-family: var(--sans);
    font-size: 12.5px;
    font-weight: 600;
    color: #fff;
    letter-spacing: -0.01em;
    text-transform: lowercase;
  }
  .demoArrow {
    color: var(--text-3);
    font-weight: 700;
    font-size: 16px;
    flex: none;
  }
  .demoBubble {
    flex: 1;
    min-width: 0;
    position: relative;
    background: var(--surface);
    border: 1px solid var(--line);
    padding: 10px 14px;
    border-radius: 999px;
    font-size: 12.5px;
    font-weight: 600;
    color: var(--ink);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    display: grid;
    min-height: 37px;
  }
  /* press-and-pop loop: key down → listening → release → text pops in */
  .listening,
  .final {
    grid-area: 1 / 1;
    align-self: center;
  }
  .listening {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding-left: 4px;
    animation: listenIn 3.2s ease-in-out infinite;
  }
  .listening i {
    width: 5px;
    height: 5px;
    border-radius: 99px;
    background: var(--hotpink);
    animation: dotPulse 0.7s ease-in-out infinite alternate;
  }
  .listening i:nth-child(2) {
    animation-delay: 0.12s;
  }
  .listening i:nth-child(3) {
    animation-delay: 0.24s;
  }
  .listening i:nth-child(4) {
    animation-delay: 0.24s;
  }
  .listening i:nth-child(4) {
    animation-delay: 0.24s;
  }
  .listening i:nth-child(3) {
    animation-delay: 0.12s;
  }
  @keyframes dotPulse {
    to {
      opacity: 0.25;
      transform: scale(0.72);
    }
  }
  .final {
    color: var(--ink);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    opacity: 0;
    transform: translateY(4px) scale(0.97);
    transform-origin: left center;
    animation: textPop 3.2s var(--ease-out) infinite;
  }
  @keyframes textPop {
    0%,
    40% {
      opacity: 0;
      transform: translateY(4px) scale(0.97);
    }
    46%,
    88% {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
    94%,
    100% {
      opacity: 0;
      transform: translateY(0) scale(0.99);
    }
  }
  .listening {
    animation: listenFade 3.2s ease-in-out infinite;
  }
  @keyframes listenFade {
    0%,
    8% {
      opacity: 1;
    }
    30%,
    40% {
      opacity: 1;
    }
    38%,
    100% {
      opacity: 0;
    }
  }
  .caret {
    display: inline-block;
    width: 2px;
    height: 13px;
    margin-left: 3px;
    background: var(--hotpink);
    vertical-align: -2px;
    animation: blink 1.05s steps(1) infinite;
  }
  @keyframes blink {
    50% {
      opacity: 0;
    }
  }
  /* the key itself presses down and springs back, synced with the text pop.
     pressed = unmistakable: hot-pink face + glow, like the hero's optkey */
  .optionKey {
    animation: keyPress 3.2s var(--ease-out) infinite;
  }
  @keyframes keyPress {
    0% {
      transform: translateY(0);
      background: linear-gradient(180deg, #1a1d23 0%, #0f1115 100%);
      border-color: #2d333f;
      box-shadow:
        0 4px 12px rgba(0, 0, 0, 0.18),
        inset 0 1px 0 rgba(255, 255, 255, 0.08);
      border-bottom-width: 4px;
    }
    10%,
    30% {
      transform: translateY(3px);
      background: linear-gradient(180deg, #ff7a9c 0%, var(--hotpink) 100%);
      border-color: #ff9db6;
      box-shadow:
        0 1px 4px rgba(0, 0, 0, 0.45),
        0 0 24px var(--hotpink-glow);
      border-bottom-width: 1px;
    }
    34% {
      background: linear-gradient(180deg, #ff7a9c 0%, var(--hotpink) 100%);
      border-color: #ff9db6;
    }
    44%,
    100% {
      transform: translateY(0);
      background: linear-gradient(180deg, #1a1d23 0%, #0f1115 100%);
      border-color: #2d333f;
      box-shadow:
        0 4px 12px rgba(0, 0, 0, 0.18),
        inset 0 1px 0 rgba(255, 255, 255, 0.08);
      border-bottom-width: 4px;
    }
  }
  .demoMeta {
    font-size: 10px;
    letter-spacing: 0.05em;
    color: var(--text-3);
    padding: 2px 2px 4px;
    margin-bottom: auto; /* balances the group vertically */
  }

  /* ── live previews (no window chrome, just the UI component) ── */
  .livePreview {
    position: relative;
    margin-top: 0;
    background: transparent;
    border: none;
    border-radius: 14px;
    overflow: hidden;
    min-height: 160px;
    display: flex;
    flex-direction: column;
    box-shadow: none;
  }
  /* ── 03, transcript: legend + turns + scrub along the bottom ── */
  .transcriptPreview {
    min-height: 340px;
  }
  .tpLegend {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 14px 14px 0;
    flex: none;
  }
  .spPill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 3px 10px;
    border-radius: 999px;
    background: var(--surface-2);
    border: 1px solid var(--line);
    font-size: 11px;
    font-weight: 700;
    color: var(--ink);
  }
  .spPill i {
    width: 8px;
    height: 8px;
    border-radius: 99px;
    flex: none;
  }
  .tpHint {
    margin-left: 6px;
    font-size: 10px;
    color: var(--text-3);
  }
  .tpTurns {
    position: relative;
    height: 236px;
    overflow-y: auto; /* scrollable, a real pane, not a static crop */
    max-width: 560px;
    width: 100%;
    margin: 0 auto;
    padding-top: 8px;
    scrollbar-width: thin;
    scrollbar-color: rgba(19, 23, 34, 0.22) transparent;
  }
  .tpTurns::-webkit-scrollbar {
    width: 6px;
  }
  .tpTurns::-webkit-scrollbar-track {
    background: transparent;
  }
  .tpTurns::-webkit-scrollbar-thumb {
    background: rgba(19, 23, 34, 0.18);
    border-radius: 99px;
  }
  .tpTurns::after {
    content: '';
    position: sticky;
    bottom: 0;
    display: block;
    height: 34px;
    margin-top: -34px;
    background: linear-gradient(
      to bottom,
      transparent,
      var(--wbody, var(--surface))
    );
    pointer-events: none;
  }
  .tpScrub {
    flex: none;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px 12px;
    background: var(--surface);
    border-top: 1px solid var(--line);
    margin-top: auto;
  }
  .tpTime {
    font-size: 10px;
    color: var(--text-3);
    flex: none;
  }
  .tpTrack {
    position: relative;
    flex: 1;
    height: 12px;
    border-radius: 99px;
    background: rgba(3, 89, 77, 0.09);
    overflow: hidden;
  }
  .tpSeg {
    position: absolute;
    top: 2px;
    bottom: 2px;
    border-radius: 99px;
    opacity: 0.8;
  }
  .tpHead {
    position: absolute;
    top: -1px;
    bottom: -1px;
    width: 2.5px;
    background-color: var(--ink);
    border-radius: 2px;
    transform: translateX(-50%);
    animation: scrub 26s linear infinite;
  }
  @keyframes scrub {
    from {
      left: 0%;
    }
    to {
      left: 100%;
    }
  }

  /* ── 04, capture: sunset screen, notch island, Dialpad-style call app ── */
  .callPreview {
    min-height: 350px;
    background: linear-gradient(
      165deg,
      #f59e0b 0%,
      #fb923c 18%,
      #f472b6 48%,
      #c084fc 78%,
      #818cf8 100%
    );
    border-color: rgba(0, 0, 0, 0.12);
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 0;
  }
  .notchAnim {
    position: relative;
    display: grid;
    place-items: center;
    width: 96px; /* natural hardware notch, per notchSpec.band.idleW */
    height: 30px;
    background: #000;
    border-radius: 0 0 10px 10px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.28);
    animation: notchGrow 3.6s ease-in-out infinite;
  }
  @keyframes notchGrow {
    0%,
    16% {
      width: 96px;
    }
    26%,
    72% {
      width: 264px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.38);
    }
    82%,
    100% {
      width: 96px;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.28);
    }
  }
  .notchCam {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: radial-gradient(
      circle at 35% 32%,
      #4a5568 0 18%,
      #151a22 42%,
      #07080c 100%
    );
    box-shadow:
      inset 0 0 0 1px rgba(120, 130, 150, 0.35),
      0 0 0 2px #000;
  }
  .notchRobot,
  .notchIcons {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    opacity: 0;
    animation: wingIn 3.6s ease-in-out infinite;
  }
  .notchRobot {
    left: 12px;
    color: var(--hotpink);
    display: grid;
    place-items: center;
  }
  .notchIcons {
    right: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  @keyframes wingIn {
    0%,
    16% {
      opacity: 0;
    }
    26%,
    72% {
      opacity: 1;
    }
    82%,
    100% {
      opacity: 0;
    }
  }
  .nWave {
    display: flex;
    align-items: center;
    gap: 2px;
    height: 14px;
  }
  .nWave i {
    width: 2.2px;
    border-radius: 2px;
    background: var(--hotpink);
    height: 40%;
    animation: nwp 0.6s ease-in-out infinite alternate;
  }
  .nWave i:nth-child(2) {
    height: 85%;
    animation-delay: 0.1s;
  }
  .nWave i:nth-child(3) {
    height: 100%;
    animation-delay: 0.2s;
  }
  .nWave i:nth-child(4) {
    height: 60%;
    animation-delay: 0.3s;
  }
  @keyframes nwp {
    to {
      height: 25%;
    }
  }
  .callRec {
    display: grid;
    place-items: center;
    flex: none;
  }
  .recLabel {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 9.5px;
    font-weight: 700;
    color: #e5e7eb;
    white-space: nowrap;
  }
  .recDot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--error);
    flex: none;
    animation: recblink 1s steps(1) infinite;
  }
  @keyframes recblink {
    50% {
      opacity: 0.3;
    }
  }

  /* Dialpad-inspired call window, centered in the display */
  .callWin {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    width: 448px;
    display: flex;
    background: var(--surface);
    border-radius: 14px;
    box-shadow:
      0 32px 64px -12px rgba(0, 0, 0, 0.45),
      0 12px 28px -6px rgba(0, 0, 0, 0.32);
    overflow: hidden;
    text-align: left;
  }
  .dwSide {
    flex: none;
    width: 118px;
    background: #f5f5f7;
    border-right: 1px solid rgba(19, 23, 34, 0.08);
    padding-bottom: 10px;
  }
  .dwActiveBar {
    background: linear-gradient(90deg, #34d67a, #7be495);
    color: #0b3d24;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 0.04em;
    padding: 6px 9px;
  }
  .dwActive {
    display: flex;
    align-items: center;
    gap: 7px;
    padding: 9px 9px;
    background: var(--surface);
    border-bottom: 1px solid rgba(19, 23, 34, 0.07);
  }
  .dwAv {
    display: grid;
    place-items: center;
    width: 24px;
    height: 24px;
    border-radius: 99px;
    background: var(--ink-app);
    color: #fff;
    font-size: 10px;
    font-weight: 800;
    flex: none;
  }
  .dwWho {
    display: flex;
    flex-direction: column;
    min-width: 0;
    flex: 1;
    line-height: 1.3;
  }
  .dwWho strong {
    font-size: 10px;
    font-weight: 700;
    color: var(--ink-app);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .dwWho i {
    font-style: normal;
    font-size: 9px;
    color: var(--text-3);
  }
  .dwGlyphs {
    display: flex;
    gap: 3px;
    flex: none;
  }
  .dwNav {
    list-style: none;
    margin: 8px 0 0;
    padding: 0 10px;
    display: flex;
    flex-direction: column;
    gap: 9px;
  }
  .dwNav li {
    font-size: 10px;
    font-weight: 600;
    color: var(--text-3);
  }
  .dwNav li:first-child {
    color: var(--ink-app);
  }
  .dwMain {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    padding: 16px 12px 12px;
  }
  .dwAvatar {
    display: grid;
    place-items: center;
    width: 54px;
    height: 54px;
    border-radius: 99px;
    background: radial-gradient(circle at 32% 30%, #4b5563, #111827 70%);
    color: #f8fafc;
    font-size: 21px;
    font-weight: 800;
    margin-bottom: 3px;
    box-shadow:
      0 0 0 3px rgba(255, 255, 255, 0.9),
      0 4px 12px rgba(19, 23, 34, 0.25);
  }
  .dwName {
    font-size: 13px;
    font-weight: 800;
    color: var(--ink-app);
    letter-spacing: -0.01em;
  }
  .dwPhone {
    font-size: 10px;
    color: var(--text-3);
  }
  .dwTimer {
    font-size: 11.5px;
    color: var(--text-2);
    font-weight: 600;
  }
  .dwBtns {
    display: flex;
    gap: 6px;
    margin-top: 7px;
  }
  .dwBtn {
    display: grid;
    place-items: center;
    width: 28px;
    height: 28px;
    border-radius: 99px;
    background: var(--surface);
    border: 1px solid rgba(19, 23, 34, 0.12);
    box-shadow: 0 1px 4px rgba(19, 23, 34, 0.1);
  }
  .dwBtn.rec {
    border-color: rgba(74, 222, 128, 0.6);
  }
  .dwBtn.end {
    background: var(--error);
    border-color: var(--error);
  }
  .notchCaption {
    margin-top: auto;
    text-align: center;
    padding: 6px 10px 10px;
    font-size: 10px;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.85);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.35);
  }

  /* dark mode: same deep-sunset gradient as the hero's big screen,
     and the call window mock runs the real app's dark palette */
  :global([data-theme='dark']) .callPreview {
    background: linear-gradient(
      165deg,
      #a83232 0%,
      #831843 20%,
      #4c1d95 50%,
      #1e1b4b 80%,
      #090d16 100%
    );
    border-color: rgba(255, 255, 255, 0.14);
  }
  :global([data-theme='dark']) .callWin {
    background: #14161f;
  }
  :global([data-theme='dark']) .dwSide {
    background: #1b1e2a;
    border-right-color: rgba(255, 255, 255, 0.08);
  }
  :global([data-theme='dark']) .dwActive {
    background: #1d2029;
    border-bottom-color: rgba(255, 255, 255, 0.08);
  }
  :global([data-theme='dark']) .dwWho i,
  :global([data-theme='dark']) .dwNav li,
  :global([data-theme='dark']) .dwPhone {
    color: rgba(247, 246, 244, 0.55);
  }
  :global([data-theme='dark']) .dwTimer {
    color: rgba(247, 246, 244, 0.75);
  }
  :global([data-theme='dark']) .dwBtn {
    background: #1d2029;
    border-color: rgba(255, 255, 255, 0.14);
  }

  /* ── 05, AI summaries: the app's actual AI panel, scrollable ── */
  .aiPreview {
    min-height: 340px;
  }
  .aiPreview :global(.ai) {
    position: absolute;
    inset: 0;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: rgba(19, 23, 34, 0.22) transparent;
  }
  .aiPreview :global(.ai)::-webkit-scrollbar {
    width: 6px;
  }
  .aiPreview :global(.ai)::-webkit-scrollbar-track {
    background: transparent;
  }
  .aiPreview :global(.ai)::-webkit-scrollbar-thumb {
    background: rgba(19, 23, 34, 0.18);
    border-radius: 99px;
  }

  /* ── shell framing, in-app shell (no window chrome) ── */
  .shellPreview {
    padding: 0;
    background: transparent;
    border: none;
    box-shadow: none;
    min-height: 320px;
    height: 320px;
    display: flex;
    flex-direction: column;
  }
  .transcriptPreview.shellPreview {
    height: 360px;
    min-height: 360px;
  }
  .aiPreview.shellPreview {
    height: 360px;
    min-height: 360px;
  }
  .previewWrap {
    display: flex;
    flex-direction: column;
    gap: 6px;
    min-width: 0;
  }
  .c3 .previewWrap {
    flex: 2 1 0;
  }
  .c5 .previewWrap {
    flex: 1 1 0;
  }
  .inapp-caption {
    font-size: 10px;
    letter-spacing: 0.06em;
    color: var(--text-3);
    padding: 0 2px;
  }
  .inapp-caption::before {
    content: '●';
    color: var(--hotpink);
    margin-right: 6px;
    font-size: 7px;
    vertical-align: 1px;
  }
  /* wall inside shell should fill shell main */
  .shellPreview .wallScroll {
    height: 100%;
    min-height: 0;
  }
  .shellPreview :global(.shell-frame) {
    flex: 1;
    min-height: 0;
    height: 100%;
  }

  /* ── 06, offline: plain command, no terminal chrome ── */
  .cmd {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    gap: 6px;
    background: #0f1115;
    border-radius: 12px;
    padding: 12px 14px;
    box-shadow: 0 8px 22px rgba(0, 0, 0, 0.25);
  }
  .cmdLabel {
    font-size: 8.5px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--mint-live);
  }
  .cmdLine {
    font-size: 11px;
    color: #e5e7eb;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .cmdOut {
    font-size: 10px;
    color: #757989;
  }
  .tprompt {
    color: var(--mint-live);
    margin-right: 4px;
  }

  /* ── 07, OSS ── */
  .ossRow {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: auto;
    flex-wrap: wrap;
    padding-top: 6px;
  }
  .ossRow .btn {
    background: var(--surface);
    color: var(--ink);
    border-color: rgba(255, 255, 255, 0.2);
  }
  .ossRow .btn:hover {
    background: #f8fafc;
  }

  /* ── dark mode: landing chrome AND product demos invert together ── */
  :global([data-theme='dark']) .card {
    box-shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
    background-image: radial-gradient(
      rgba(255, 255, 255, 0.045) 1px,
      transparent 1px
    );
  }
  /* tinted cards unify to the one dark elevated surface */
  :global([data-theme='dark']) .c2,
  :global([data-theme='dark']) .c4,
  :global([data-theme='dark']) .c5 {
    background-color: var(--card-blue);
  }
  :global([data-theme='dark']) .c2 .icon,
  :global([data-theme='dark']) .c5 .icon {
    background: var(--surface);
  }
  :global([data-theme='dark']) .c7 {
    background: #0a0c12;
    border-color: rgba(255, 255, 255, 0.14);
  }
  :global([data-theme='dark']) .c7 .ossRow .btn {
    background: #14161f;
  }
  :global([data-theme='dark']) .livePreview {
    border-color: rgba(255, 255, 255, 0.14);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45);
  }
  :global([data-theme='dark']) .wallPane {
    border-color: rgba(255, 255, 255, 0.12);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
  }
  :global([data-theme='dark']) .cmd {
    box-shadow: 0 8px 22px rgba(0, 0, 0, 0.5);
  }
  :global([data-theme='dark']) .appChip {
    background: rgba(255, 255, 255, 0.04);
  }
  :global([data-theme='dark']) .actChip {
    background: rgba(252, 86, 129, 0.12);
    border-color: rgba(252, 86, 129, 0.3);
  }

  @media (max-width: 980px) {
    .grid {
      grid-template-columns: 1fr 1fr;
    }
    .c1,
    .c2,
    .c3,
    .c4,
    .c5,
    .c6,
    .c7 {
      grid-column: span 1;
    }
    .c1,
    .c3,
    .c7 {
      grid-column: span 2;
    }
  }
  @media (max-width: 720px) {
    .split {
      flex-direction: column;
    }
    .c3 .cardCopy {
      max-width: none;
    }
    /* phones: no scrollable-inside-scrollable — panes grow with the
       page, the outer document owns all scrolling */
    .shellPreview,
    .transcriptPreview.shellPreview,
    .aiPreview.shellPreview {
      height: auto;
      min-height: 0;
    }
    .wallScroll,
    .tpTurns,
    .aiPreview :global(.ai) {
      height: auto;
      max-height: none;
      overflow: visible;
    }
    .aiPreview :global(.ai) {
      position: static;
      inset: auto;
    }
    .aiPreview {
      min-height: 0;
    }
    .tpTurns::after {
      display: none;
    }
  }
  @media (max-width: 640px) {
    .grid {
      grid-template-columns: 1fr;
    }
    .c1,
    .c2,
    .c3,
    .c4,
    .c5,
    .c6,
    .c7 {
      grid-column: span 1;
    }
    .demoStack {
      flex-wrap: wrap;
    }
    .callWin {
      width: 320px;
    }
  }
</style>
