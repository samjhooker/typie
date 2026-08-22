<script>
  import { reveal } from './reveal.js';

  const bars = [0.9, 0.5, 1.1, 0.7, 1.3, 0.6, 1.0, 0.8];
</script>

<section class="features field field-cream" id="features">
  <div class="container head">
    <p class="hand kicker" use:reveal>the whole pitch, in six boxes</p>
    <h2 class="subhead" use:reveal={{ delay: 60 }}>
      Everything you need.
      <span class="mark-butter">Nothing you don't.</span>
    </h2>
  </div>

  <div class="container grid">
    <article class="card c-butter span2" use:reveal={{ delay: 80 }}>
      <p class="mono label">speed</p>
      <p class="big"><span class="grad">&lt;100&nbsp;ms</span> from lips to letters</p>
      <div class="eq" aria-hidden="true">
        {#each bars as b, i}
          <i style="animation-duration:{b}s; animation-delay:{i * 0.07}s"></i>
        {/each}
      </div>
      <p class="body">
        Faster than you can switch windows, find the mic icon, or remember what
        you were about to say. By the time your sentence ends, it's on screen.
      </p>
    </article>

    <article class="card c-pink" use:reveal={{ delay: 140 }}>
      <p class="mono label">privacy</p>
      <p class="big">0 bytes leave this Mac</p>
      <p class="body">
        Audio is processed on-device and thrown away. We can't hear you.
        There's nothing to leak, sell, or subpoena.
      </p>
    </article>

    <article class="card c-sky" use:reveal={{ delay: 200 }}>
      <p class="mono label">offline</p>
      <p class="big">Works on a plane ✈️</p>
      <p class="body">
        No server to reach, so there's no server to miss. Subway, cabin mode,
        cabin in the woods - all fine.
      </p>
    </article>

    <article class="card c-lavender" use:reveal={{ delay: 120 }}>
      <p class="mono label">everywhere</p>
      <p class="big">One key. Every app.</p>
      <p class="body">
        Mail, Slack, Notes, that cursed CRM. Hold ⌥ anywhere and speak - the
        text lands where your cursor already is.
      </p>
    </article>

    <article class="card c-mint" use:reveal={{ delay: 180 }}>
      <p class="mono label">price</p>
      <p class="big">$0. Forever. Really.</p>
      <p class="body">
        It runs on your machine and never phones home, so charging monthly for
        it would be a bit strange.
      </p>
    </article>

    <article class="card c-paper span2" use:reveal={{ delay: 240 }}>
      <div class="row">
        <div>
          <p class="mono label">setup</p>
          <p class="big">Download. Hold ⌥. Done.</p>
          <p class="body">
            ~8 MB app + ~500 MB model on first run, macOS 14+, Apple silicon.
            No account, no email,
            no onboarding carousel about your feelings.
          </p>
        </div>
        <ul class="ticks">
          <li>25 languages, zero settings</li>
          <li>No account, ever</li>
          <li>Free updates, also free</li>
        </ul>
      </div>
    </article>

    <article class="card c-sun" use:reveal={{ delay: 300 }}>
      <p class="mono label">the catch</p>
      <p class="big">There isn't one. It's free.</p>
      <p class="body">
        No trial. No "free tier". No card that quietly renews at $14.99.
        There is no billing page.
      </p>
      <p class="hand aside">(we checked twice)</p>
    </article>
  </div>
</section>

<style>
  .head {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .kicker {
    font-size: clamp(17px, 2vw, 23px);
    color: var(--green-deep);
    transform: rotate(-3deg);
  }

  .subhead {
    margin-top: 14px;
    max-width: 16ch;
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 18px;
    margin-top: 56px;
  }

  .card {
    position: relative;
    border-radius: var(--radius);
    padding: clamp(24px, 2.6vw, 34px);
    display: flex;
    flex-direction: column;
    gap: 12px;
    text-align: left;
    transition:
      transform 0.35s var(--spring),
      box-shadow 0.35s ease;
  }

  .card:hover {
    transform: translateY(-6px) rotate(-0.5deg);
    box-shadow: 0 22px 44px rgba(2, 89, 77, 0.14);
  }

  .span2 { grid-column: span 2; }

  .c-butter { background: var(--butter); color: var(--ink); }
  .c-pink { background: var(--pink); color: var(--green-deep); }
  .c-sky { background: var(--sky); color: var(--green-deep); }
  .c-lavender { background: var(--lavender); color: var(--green-deep); }
  .c-mint { background: var(--mint); color: var(--green-deep); }
  .c-sun { background: var(--sun); color: var(--green-deep); }
  .c-paper {
    background: #fff;
    color: var(--green-deep);
    border: 1px solid rgba(2, 89, 77, 0.1);
  }

  .label {
    opacity: 0.65;
  }

  .big {
    font-family: var(--display);
    font-weight: 800;
    font-size: clamp(24px, 2.6vw, 34px);
    line-height: 1.05;
    letter-spacing: -0.03em;
  }

  .grad {
    color: var(--hotpink);
    font-style: italic;
  }

  .body {
    font-size: 15px;
    line-height: 1.55;
    max-width: 52ch;
  }

  .eq {
    display: flex;
    align-items: flex-end;
    gap: 5px;
    height: 44px;
    margin-block: 4px;
  }

  .eq i {
    width: 8px;
    border-radius: 4px;
    background: var(--green);
    height: 30%;
    animation: bounce 1s ease-in-out infinite alternate;
    transform-origin: bottom;
  }

  @keyframes bounce {
    from { transform: scaleY(0.5); }
    to { transform: scaleY(1.6); }
  }

  .row {
    display: grid;
    grid-template-columns: 1.4fr 1fr;
    gap: 28px;
    align-items: center;
  }

  .row .body { max-width: none; }

  .aside {
    font-size: clamp(17px, 1.8vw, 20px);
    color: var(--green);
    transform: rotate(-3deg);
  }

  .ticks {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 12px;
    font-family: var(--display);
    font-weight: 700;
    font-size: 15px;
  }

  .ticks li::before {
    content: '✓ ';
    color: var(--hotpink);
  }

  @media (max-width: 900px) {
    .grid { grid-template-columns: 1fr 1fr; }
    .span2 { grid-column: span 2; }
  }

  @media (max-width: 620px) {
    .grid { grid-template-columns: 1fr; }
    .span2 { grid-column: auto; }
    .row { grid-template-columns: 1fr; }
  }
</style>
