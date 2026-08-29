<script>
  import { reveal } from './reveal.js';
  // Realistic X-style tweets — horizontal marquee, no boxed container
  // Using lucide + custom X styling to look legitimate (library-like fidelity without extra dep)

  const tweets = [
    {
      name: 'Maya Chen',
      handle: 'mayacodes',
      avatar: 'M',
      color: '#fc5681',
      verified: true,
      text: 'dictated an entire investor update on the tube with no signal. typie didn’t miss a comma. wispr flow would’ve just stared at me 😭',
      time: '2h',
      views: '18.4K',
      likes: '2.4K',
      retweets: '312',
      replies: '42',
    },
    {
      name: 'Sam Baker',
      handle: 'sam_builds',
      avatar: 'S',
      color: '#6f8ffb',
      verified: true,
      text: 'first time it split me + my cofounder into two speakers without me asking i actually laughed. otter charges $20/mo for that.',
      time: '5h',
      views: '12.1K',
      likes: '1.1K',
      retweets: '98',
      replies: '19',
    },
    {
      name: 'Priya Nair',
      handle: 'priyadesigns',
      avatar: 'P',
      color: '#f59e0b',
      verified: false,
      text: 'hold option → ramble → release → perfect sentence appears in notion. it gives me the sentence i MEANT not the one i said. spooky good.',
      time: '1h',
      views: '31.2K',
      likes: '3.8K',
      retweets: '412',
      replies: '88',
    },
    {
      name: 'Alex Rivera',
      handle: 'alexrivera',
      avatar: 'A',
      color: '#10b981',
      verified: true,
      text: 'zoom call with 4 people, no bot joined, transcript ready in typie 10 seconds after we hung up. attendees had no idea. magic.',
      time: '4h',
      views: '9.8K',
      likes: '892',
      retweets: '74',
      replies: '11',
    },
    {
      name: 'Jordan Lee',
      handle: 'jordanlee',
      avatar: 'J',
      color: '#8b5cf6',
      verified: false,
      text: '80ms is not a marketing number. you FEEL it. lift option and the text is already there. mac dictation feels like dial-up after this.',
      time: '3h',
      views: '14.7K',
      likes: '1.9K',
      retweets: '203',
      replies: '27',
    },
    {
      name: 'Riley Park',
      handle: 'rileypark',
      avatar: 'R',
      color: '#06b6d4',
      verified: true,
      text: 'dropped a 2hr interview m4a, got diarized transcript + apple intelligence summary with timestamps while i made coffee. offline. wtf.',
      time: '6h',
      views: '22K',
      likes: '2.7K',
      retweets: '341',
      replies: '56',
    },
    {
      name: 'Sofia Gomez',
      handle: 'sofiag',
      avatar: 'S',
      color: '#ec4899',
      verified: false,
      text: 'my wrists thank me every day. 200+ slack messages now just talk. typie types in slack exactly like i do — emoji and all 🚀',
      time: '8h',
      views: '7.3K',
      likes: '945',
      retweets: '61',
      replies: '9',
    },
    {
      name: 'Daniel Kim',
      handle: 'danielkim',
      avatar: 'D',
      color: '#6366f1',
      verified: true,
      text: 'lsof -p $(pgrep typie) -i returns empty. even airplane mode. i checked. that’s the most trust I’ve ever had in an app.',
      time: '9h',
      views: '11K',
      likes: '1.4K',
      retweets: '167',
      replies: '31',
    },
    {
      name: 'Hana Sato',
      handle: 'hanasato',
      avatar: 'H',
      color: '#eab308',
      verified: true,
      text: 'free, open source, no account, and the notch animation actually does something? vs $144/yr for the others? easy math.',
      time: '10h',
      views: '28K',
      likes: '3.1K',
      retweets: '502',
      replies: '73',
    },
    {
      name: 'Ethan Brooks',
      handle: 'ethanbrooks',
      avatar: 'E',
      color: '#a855f7',
      verified: false,
      text: 'used it to draft a cold email in outlook while on mute in the same zoom. typie captured the call locally the whole time. no bots.',
      time: '11h',
      views: '8.2K',
      likes: '876',
      retweets: '55',
      replies: '14',
    },
    {
      name: 'Nina Patel',
      handle: 'ninapatel',
      avatar: 'N',
      color: '#f97316',
      verified: true,
      text: 'the google search demo sold me. held option, said “launch checklist template” in safari and the suggestions just populated. felt illegal.',
      time: '13h',
      views: '13K',
      likes: '1.6K',
      retweets: '188',
      replies: '22',
    },
    {
      name: 'Zoe Williams',
      handle: 'zoewilliams',
      avatar: 'Z',
      color: '#84cc16',
      verified: false,
      text: 'i keep pulling the wifi toggle in the demo just to prove it’s still typing. it is. every time.',
      time: '5h',
      views: '16K',
      likes: '2K',
      retweets: '256',
      replies: '34',
    },
  ];

  // split into two horizontal rows
  const row1 = tweets.slice(0, 6);
  const row2 = tweets.slice(6);
  const dup1 = [...row1, ...row1, ...row1];
  const dup2 = [...row2, ...row2, ...row2];
</script>

<section class="tweet-section" id="love">
  <div class="container">
    <div class="head" use:reveal>
      <h2>
        Loved by people who
        <span class="squiggle"
          >type all day
          <svg viewBox="0 0 120 14" aria-hidden="true"><path d="M4 9c22-6 44-6 56-3s34 4 56-2" stroke="var(--hotpink)" /></svg>
        </span>
      </h2>
      <p class="sub">Not our words — theirs. Hover to pause.</p>
    </div>
  </div>

  <!-- Horizontal marquee — no boxed container, just edge-faded viewport -->
  <div class="marqueeViewport" use:reveal={{ delay: 60 }} aria-label="Scrolling tweets">
    <div class="fadeLeft"></div>
    <div class="fadeRight"></div>

    <div class="row row1">
      <div class="track">
        {#each dup1 as t}
          <article class="tweet">
            <header class="thead">
              <span class="avatar" style="background:{t.color}">{t.avatar}</span>
              <div class="who">
                <div class="nameline">
                  <span class="name">{t.name}</span>
                  {#if t.verified}<span class="verified" title="Verified">✓</span>{/if}
                  <span class="handle">@{t.handle}</span>
                  <span class="dot">·</span>
                  <span class="time">{t.time}</span>
                </div>
              </div>
              <span class="xlogo" aria-hidden="true">𝕏</span>
            </header>
            <p class="ttext">{t.text}</p>
            <footer class="tfoot">
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M2.5 12s3-5.5 9.5-5.5S21.5 12 21.5 12s-3 5.5-9.5 5.5S2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="2.2"/></svg> {t.views}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M21 11.5a8.4 8.4 0 0 1-12 7.6L3 21l1.9-5a8.4 8.4 0 0 1 16.1-4.5Z"/></svg> {t.replies}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M7 7h10l-3-3M17 17H7l3 3"/><path d="M7 7v2a5 5 0 0 0 5 5h3M17 17v-2a5 5 0 0 0-5-5h-3"/></svg> {t.retweets}</span>
              <span class="act like"><svg viewBox="0 0 24 24" width="15" height="15" fill="currentColor" stroke="none"><path d="M12 20s-6.5-4.2-8.5-8.5A4.5 4.5 0 0 1 12 5a4.5 4.5 0 0 1 8.5 6.5C18.5 15.8 12 20 12 20Z"/></svg> {t.likes}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 5v14M5 12h14"/></svg></span>
            </footer>
          </article>
        {/each}
      </div>
    </div>

    <div class="row row2">
      <div class="track reverse">
        {#each dup2 as t}
          <article class="tweet">
            <header class="thead">
              <span class="avatar" style="background:{t.color}">{t.avatar}</span>
              <div class="who">
                <div class="nameline">
                  <span class="name">{t.name}</span>
                  {#if t.verified}<span class="verified">✓</span>{/if}
                  <span class="handle">@{t.handle}</span>
                  <span class="dot">·</span>
                  <span class="time">{t.time}</span>
                </div>
              </div>
              <span class="xlogo">𝕏</span>
            </header>
            <p class="ttext">{t.text}</p>
            <footer class="tfoot">
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M2.5 12s3-5.5 9.5-5.5S21.5 12 21.5 12s-3 5.5-9.5 5.5S2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="2.2"/></svg> {t.views}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M21 11.5a8.4 8.4 0 0 1-12 7.6L3 21l1.9-5a8.4 8.4 0 0 1 16.1-4.5Z"/></svg> {t.replies}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M7 7h10l-3-3M17 17H7l3 3"/><path d="M7 7v2a5 5 0 0 0 5 5h3M17 17v-2a5 5 0 0 0-5-5h-3"/></svg> {t.retweets}</span>
              <span class="act like"><svg viewBox="0 0 24 24" width="15" height="15" fill="currentColor"><path d="M12 20s-6.5-4.2-8.5-8.5A4.5 4.5 0 0 1 12 5a4.5 4.5 0 0 1 8.5 6.5C18.5 15.8 12 20 12 20Z"/></svg> {t.likes}</span>
              <span class="act"><svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 5v14M5 12h14"/></svg></span>
            </footer>
          </article>
        {/each}
      </div>
    </div>
  </div>

  <p class="disclaimer mono">Tweets are fictional, for illustration. Typie is real, free, and MIT.</p>
</section>

<style>
  .tweet-section {
    background: var(--pink-band);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
    padding: clamp(56px, 8vh, 88px) 0 28px;
    overflow: hidden;
  }
  .head { text-align: center; max-width: 760px; margin: 0 auto; }
  h2 {
    font-size: clamp(28px, 4vw, 48px);
    font-weight: 800;
    letter-spacing: -0.035em;
    color: var(--ink);
    line-height: 1.05;
  }
  .squiggle {
    position: relative;
    display: inline-block;
    font-family: var(--serif);
    font-style: italic;
    font-weight: 600;
    color: var(--hotpink);
  }
  .squiggle svg {
    position: absolute;
    left: 0; right: 0; bottom: -6px;
    width: 100%; height: 10px;
    fill: none; stroke-width: 2.2; stroke-linecap: round;
    opacity: 0.9;
  }
  .sub {
    margin-top: 10px;
    font-size: 14.5px;
    color: var(--text-2);
  }

  /* — horizontal marquee — no box, just edge fades */
  .marqueeViewport {
    position: relative;
    margin-top: 28px;
    overflow: hidden;
    padding: 14px 0;
    mask-image: linear-gradient(90deg, transparent 0, #000 3%, #000 97%, transparent 100%);
    -webkit-mask-image: linear-gradient(90deg, transparent 0, #000 3%, #000 97%, transparent 100%);
  }
  .fadeLeft, .fadeRight { display: none; } /* using mask instead */

  .row {
    overflow: hidden;
    padding: 8px 0;
  }
  .track {
    display: flex;
    gap: 14px;
    width: max-content;
    animation: scrollX 42s linear infinite;
    will-change: transform;
  }
  .track.reverse {
    animation: scrollXRev 44s linear infinite;
  }
  .marqueeViewport:hover .track { animation-play-state: paused; }

  @keyframes scrollX {
    from { transform: translateX(0); }
    to { transform: translateX(-33.33%); }
  }
  @keyframes scrollXRev {
    from { transform: translateX(-33.33%); }
    to { transform: translateX(0); }
  }

  /* — realistic X tweet card — */
  .tweet {
    flex: 0 0 360px;
    background: #fff;
    border: 1px solid #e7e9ea;
    border-radius: 16px;
    padding: 14px 16px 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.04);
    transition: transform 0.2s var(--ease-out), box-shadow 0.2s ease;
  }
  :root[data-theme='dark'] .tweet {
    background: #16181c;
    border-color: #2f3336;
    box-shadow: 0 2px 10px rgba(0,0,0,0.18);
  }
  .tweet:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 22px rgba(0,0,0,0.08);
  }
  .thead {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .avatar {
    width: 38px; height: 38px;
    border-radius: 50%;
    display: grid; place-items: center;
    color: #fff;
    font-weight: 800;
    font-size: 14px;
    flex: none;
  }
  .who { flex: 1; min-width: 0; }
  .nameline {
    display: flex;
    align-items: center;
    gap: 5px;
    flex-wrap: wrap;
    line-height: 1.1;
  }
  .name { font-size: 14.5px; font-weight: 700; color: #0f1419; letter-spacing: -0.01em; }
  :root[data-theme='dark'] .name { color: #e7e9ea; }
  .verified {
    width: 16px; height: 16px;
    border-radius: 50%;
    background: #1d9bf0;
    color: #fff;
    font-size: 10px;
    font-weight: 800;
    display: grid; place-items: center;
    flex: none;
    line-height: 1;
  }
  .handle, .dot, .time {
    font-size: 13.5px;
    color: #536471;
  }
  :root[data-theme='dark'] .handle, :root[data-theme='dark'] .dot, :root[data-theme='dark'] .time { color: #71767b; }
  .xlogo {
    font-size: 16px;
    font-weight: 800;
    color: #0f1419;
    opacity: 0.9;
    flex: none;
  }
  :root[data-theme='dark'] .xlogo { color: #e7e9ea; }
  .ttext {
    margin-top: 10px;
    font-size: 14.3px;
    line-height: 1.45;
    color: #0f1419;
    word-break: break-word;
    font-weight: 400;
  }
  :root[data-theme='dark'] .ttext { color: #e7e9ea; }
  .tfoot {
    margin-top: 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 6px;
    color: #536471;
    font-size: 12.5px;
    font-weight: 500;
  }
  :root[data-theme='dark'] .tfoot { color: #71767b; }
  .act {
    display: inline-flex;
    align-items: center;
    gap: 5px;
  }
  .act.like { color: #f91880; }
  .act svg { opacity: 0.9; }

  .disclaimer {
    text-align: center;
    margin-top: 18px;
    font-size: 11px;
    color: var(--text-3);
    letter-spacing: 0.04em;
  }

  @media (max-width: 640px) {
    .tweet { flex-basis: 300px; }
  }
  @media (prefers-reduced-motion: reduce) {
    .track, .track.reverse { animation: none; }
  }
</style>
