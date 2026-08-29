<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';

  /* the airplane test: flip the wifi off and watch who survives.
     typie keeps transcribing because the model lives on the disk;
     the cloud apps lose their brains, which live in a data center */
  let online = $state(true);

  const PHRASES = [
    '…and that wraps the retro. sending notes now.',
    'gate B22, boarding in ten — typing with no bars.',
    'offline since JFK and it has not missed a word.',
  ];
  let phrase = $state(0);

  $effect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const iv = setInterval(
      () => (phrase = (phrase + 1) % PHRASES.length),
      2600
    );
    return () => clearInterval(iv);
  });

  const apps = [
    { id: 'typie', label: 'typie', local: true },
    { id: 'wisprflow', label: 'wisprflow', local: false },
    { id: 'otter', label: 'otter', local: false },
  ];
</script>

<section
  class="airplane field"
  id="offline"
>
  <div class="container">
    <p
      class="mono kicker"
      style="text-align:center"
    >
      chapter 03 · the independence test
    </p>
    <h2
      class="subhead"
      use:reveal
    >
      The <span class="squiggle"
        >airplane test
        <svg
          viewBox="0 0 120 14"
          aria-hidden="true"
        >
          <path
            d="M4 9c22-6 44-6 56-3s34 4 56-2"
            stroke="var(--ink)"
          />
        </svg>
      </span>
    </h2>
    <p
      class="lede"
      use:reveal={{ delay: 60 }}
    >
      Wifi off. Airplane mode on. Watch which apps keep their brains.
    </p>

    <!-- the switch -->
    <div
      class="switchrow"
      use:reveal={{ delay: 100 }}
    >
      <button
        class="wifi"
        role="switch"
        aria-checked={!online}
        onclick={() => (online = !online)}
      >
        <span
          class="track"
          class:off={!online}
        >
          <span class="knob"></span>
        </span>
        <span class="wlbl mono">home wifi · {online ? 'on' : 'off'}</span>
      </button>
      <p
        class="status mono"
        class:off={!online}
      >
        {#if online}
          connected · everyone works, some of them by phoning home
        {:else}
          disconnected · let's see who was faking it
        {/if}
      </p>
    </div>

    <div class="grid">
      {#each apps as a (a.id)}
        <article
          class="appcard"
          class:local={a.local}
          class:dead={!online && !a.local}
          use:reveal={{ delay: a.local ? 140 : 220 }}
        >
          <header>
            {#if a.local}
              <span class="bot"
                ><Robot
                  size={40}
                  mood={online ? 'idle' : 'listening'}
                /></span
              >
            {:else}
              <span
                class="cloudglyph"
                aria-hidden="true">{online ? '☁️' : '🌩️'}</span
              >
            {/if}
            <b>{a.label}</b>
          </header>

          <div class="body">
            {#if a.local}
              <span class="wave"
                ><TalkWave
                  n={7}
                  color="#03594d"
                /></span
              >
              {#key phrase}
                <p class="livephrase">“{PHRASES[phrase]}”</p>
              {/key}
            {:else}
              {#key online}
                <p
                  class="cloudline"
                  class:sad={!online}
                >
                  {online
                    ? 'streaming audio to the data center…'
                    : '✗ can’t reach their servers'}
                </p>
              {/key}
            {/if}
          </div>

          <footer>
            <span
              class="pill"
              class:ok={a.local || online}
              class:err={!online && !a.local}
            >
              {#if a.local}
                ● runs on your disk
              {:else if online}
                ● connected
              {:else}
                ✗ needs their server
              {/if}
            </span>
          </footer>
        </article>
      {/each}
    </div>

    <p
      class="punch hand"
      use:reveal={{ delay: 200 }}
    >
      same flight. one of these still takes notes.
    </p>
  </div>
</section>

<style>
  .airplane {
    background:
      radial-gradient(
        90% 120% at 85% -20%,
        rgba(188, 214, 255, 0.55) 0%,
        transparent 55%
      ),
      var(--paper);
  }

  .lede {
    text-align: center;
    margin-top: 14px;
    font-weight: 600;
    color: var(--text-2);
  }

  /* ---- switch ---- */
  .switchrow {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    margin-top: clamp(24px, 3.5vh, 36px);
  }

  .wifi {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 8px 18px;
    border-radius: 999px;
    background: var(--cream-50);
    border: 2px solid rgba(19, 23, 34, 0.85);
    box-shadow: 3px 3px 0 rgba(19, 23, 34, 0.85);
    transition: transform 0.2s var(--spring);
  }

  .wifi:hover {
    transform: translateY(-2px);
  }

  .track {
    position: relative;
    width: 58px;
    height: 30px;
    border-radius: 999px;
    background: var(--mint);
    border: 2px solid rgba(19, 23, 34, 0.85);
    transition: background 0.25s var(--ease-out);
  }

  .track.off {
    background: var(--hotpink);
  }

  .knob {
    position: absolute;
    top: 1px;
    left: 1px;
    width: 24px;
    height: 24px;
    border-radius: 999px;
    background: var(--cream-50);
    border: 2px solid rgba(19, 23, 34, 0.85);
    transition: transform 0.28s var(--spring);
  }

  .track.off .knob {
    transform: translateX(26px);
  }

  .wlbl {
    font-size: 12px;
    color: var(--ink);
  }

  .status {
    font-size: 12px;
    transition: color 0.25s var(--ease-out);
  }

  .status.off {
    color: #d61f4c;
  }

  /* ---- app cards ---- */
  .grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: clamp(16px, 2.4vw, 26px);
    margin-top: clamp(28px, 4vh, 44px);
    max-width: 940px;
    margin-inline: auto;
  }

  .appcard {
    display: flex;
    flex-direction: column;
    gap: 14px;
    padding: clamp(18px, 2.4vw, 26px);
    border-radius: var(--radius-card);
    border: 2px solid rgba(19, 23, 34, 0.5);
    background: var(--cream-50);
    filter: grayscale(0.2);
    transition:
      filter 0.45s var(--ease-out),
      opacity 0.45s var(--ease-out),
      transform 0.45s var(--ease-out),
      box-shadow 0.45s var(--ease-out);
  }

  /* typie: always loud, always colored */
  .appcard.local {
    background: var(--card-mint);
    border-color: var(--text-2);
    box-shadow: 4px 4px 0 rgba(19, 23, 34, 0.85);
  }

  .appcard:not(.local) {
    opacity: 0.85;
  }

  /* when wifi dies, cloud cards visibly lose themselves */
  .appcard.dead {
    filter: grayscale(1);
    opacity: 0.55;
    transform: translateY(6px) rotate(-1deg);
    animation: deadshake 0.45s var(--ease-out);
  }

  @keyframes deadshake {
    0%,
    100% {
      translate: 0 0;
    }
    25% {
      translate: -4px 0;
    }
    50% {
      translate: 4px 0;
    }
    75% {
      translate: -2px 0;
    }
  }

  header {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  header b {
    font-family: var(--mono);
    font-size: 13px;
    letter-spacing: 0.08em;
    text-transform: lowercase;
    color: var(--ink);
  }

  .bot {
    line-height: 0;
    color: var(--ink);
  }

  .cloudglyph {
    font-size: 26px;
    line-height: 1;
    filter: grayscale(1);
  }

  .body {
    flex: 1;
    min-height: 74px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 10px;
  }

  .wave :global(.talkwave) {
    height: 20px;
    gap: 3px;
  }

  .livephrase,
  .cloudline {
    font-size: 15px;
    line-height: 1.5;
    color: var(--green-deep);
    font-weight: 600;
    animation: phrase-in 0.45s var(--ease-out) both;
  }

  .cloudline {
    color: var(--text-2);
    font-family: var(--mono);
    font-size: 13px;
  }

  .cloudline.sad {
    color: #d61f4c;
    font-weight: 700;
  }

  @keyframes phrase-in {
    from {
      opacity: 0;
      transform: translateY(6px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  footer .pill {
    display: inline-flex;
    align-items: center;
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 12.5px;
    font-weight: 700;
    font-family: var(--mono);
    letter-spacing: 0.03em;
    background: var(--wash);
    color: var(--text-3);
    transition:
      background 0.3s var(--ease-out),
      color 0.3s var(--ease-out);
  }

  .pill.ok {
    background: var(--green);
    color: #fff;
  }

  .pill.err {
    background: rgba(214, 31, 76, 0.12);
    color: #d61f4c;
  }

  .punch {
    text-align: center;
    margin-top: clamp(26px, 4vh, 38px);
    font-size: clamp(22px, 2.4vw, 29px);
    color: var(--text-2);
    transform: rotate(-2deg);
  }

  @media (max-width: 780px) {
    .grid {
      grid-template-columns: 1fr;
      max-width: 420px;
    }
  }
</style>
