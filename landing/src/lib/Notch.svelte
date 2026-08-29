<script>
  import { reveal } from './reveal.js';
  import Robot from './Robot.svelte';
  import TalkWave from './TalkWave.svelte';
</script>

<section class="notchband">
  <div class="panel">
    <div class="copy" use:reveal>
      <p class="hand kicker">It lives in your notch.</p>
      <h2>Always there<br /><span class="nowrap">when you need it.</span></h2>
      <div class="body">
        <p>
          One shortcut. That’s it.<br />
          Hold <i class="keyhint mono">&#8997;</i>, speak, release.<br />
          Your words appear.
        </p>
        <svg class="starburst" viewBox="0 0 60 60" aria-hidden="true">
          <g stroke="var(--ink)" stroke-width="3.5" stroke-linecap="round">
            <line x1="30" y1="4" x2="30" y2="18" />
            <line x1="30" y1="42" x2="30" y2="56" />
            <line x1="4" y1="30" x2="18" y2="30" />
            <line x1="42" y1="30" x2="56" y2="30" />
            <line x1="11" y1="11" x2="21" y2="21" />
            <line x1="39" y1="39" x2="49" y2="49" />
            <line x1="49" y1="11" x2="39" y2="21" />
            <line x1="21" y1="39" x2="11" y2="49" />
          </g>
        </svg>
      </div>
    </div>

    <div class="stack" use:reveal={{ delay: 80 }} aria-hidden="true">
      <!-- idle: just the hardware camera notch -->
      <div class="lid">
        <div class="screen">
          <div class="island idle">
            <span class="cam"></span>
          </div>
        </div>
      </div>

      <!-- listening: island grows around the camera -->
      <div class="lid">
        <div class="screen">
          <div class="island live">
            <span class="bot"><Robot size={20} mood="listening" /></span>
            <span class="cam"></span>
            <span class="wave"><TalkWave n={5} color="#fc5681" /></span>
          </div>
        </div>
      </div>

      <!-- done: bot on the left, speed on the right -->
      <div class="lid">
        <div class="screen">
          <div class="island live done">
            <span class="bot"><Robot size={22} mood="done" /></span>
            <span class="cam"></span>
            <span class="ms">✓ 80ms</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<style>
  .notchband {
    padding: 0;
  }

  .panel {
    position: relative;
    display: grid;
    grid-template-columns: minmax(240px, 0.82fr) minmax(0, 1.35fr);
    gap: clamp(20px, 3vw, 40px);
    align-items: center;
    background: var(--pink-band);
    border-radius: 28px;
    overflow: hidden;
    padding: clamp(32px, 4.5vw, 56px) 0 clamp(32px, 4.5vw, 56px) clamp(28px, 4vw, 56px);
  }

  .copy {
    padding-right: 8px;
  }

  .kicker {
    font-size: clamp(22px, 2.2vw, 28px);
    color: var(--ink);
    transform: rotate(-2deg);
    margin-bottom: 16px;
  }

  h2 {
    font-size: clamp(32px, 4.2vw, 52px);
    letter-spacing: -0.035em;
    line-height: 1.05;
    color: var(--ink);
    margin-bottom: 22px;
  }

  .nowrap {
    white-space: nowrap;
  }

  .body {
    position: relative;
    display: flex;
    align-items: flex-start;
    gap: 16px;
  }

  .body p {
    font-size: clamp(16px, 1.5vw, 18px);
    line-height: 1.55;
    color: rgba(19, 23, 34, 0.68);
    max-width: 28ch;
  }

  .keyhint {
    display: inline-block;
    background: var(--ink);
    color: var(--cream);
    border-radius: 5px;
    padding: 1px 6px;
    letter-spacing: 0;
    text-transform: none;
    font-size: 12px;
    vertical-align: 1px;
  }

  .starburst {
    width: 42px;
    height: 42px;
    flex-shrink: 0;
    margin-top: 18px;
    transform: rotate(8deg);
  }

  .stack {
    display: flex;
    flex-direction: column;
    gap: 8px;
    min-width: 0;
  }

  .lid {
    background: #0c0e12;
    border-radius: 32px 0 0 0;
    padding: 11px 0 0 11px;
  }

  .screen {
    position: relative;
    height: clamp(84px, 11vw, 128px);
    border-radius: 21px 0 0 0;
    overflow: hidden;
    background:
      radial-gradient(130% 160% at 0% -10%, rgba(130, 237, 166, 0.55) 0%, transparent 52%),
      radial-gradient(110% 140% at 100% 0%, rgba(252, 86, 129, 0.28) 0%, transparent 48%),
      linear-gradient(118deg, #bcd6ff 0%, #ddd8ff 42%, #82eda6 100%);
  }

  /* islands — shared spec with Hero: UnevenRoundedRectangle continuous, bottom 10 idle → 18 expanded, shadow radius 12 y6 */
  .island {
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    background: #000;
    color: #fffdf7;
    border-radius: 0 0 10px 10px;
    overflow: hidden;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.28);
  }

  .idle {
    width: 96px;
    height: 28px;
    display: grid;
    place-items: center;
    padding-bottom: 4px;
    border-radius: 0 0 10px 10px;
  }

  .live {
    width: min(280px, 52%);
    height: 34px;
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    align-items: center;
    padding: 0 16px 4px;
    border-radius: 0 0 18px 18px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.32);
  }

  .cam {
    width: 11px;
    height: 11px;
    border-radius: 50%;
    background: radial-gradient(circle at 35% 32%, #4a5568 0 18%, #151a22 42%, #07080c 100%);
    box-shadow:
      inset 0 0 0 1px rgba(120, 130, 150, 0.4),
      0 0 0 2px #000;
    justify-self: center;
  }

  .bot {
    display: block;
    line-height: 0;
    color: var(--hotpink);
    flex-shrink: 0;
    justify-self: start;
  }

  .wave {
    display: block;
    width: 40px;
    justify-self: end;
  }

  .wave :global(.talkwave) {
    height: 14px;
    gap: 2px;
  }

  .wave :global(.talkwave i) {
    width: 2.5px;
  }

  .ms {
    font-family: var(--mono);
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.01em;
    color: var(--mint-live);
    white-space: nowrap;
    justify-self: end;
  }

  @media (max-width: 860px) {
    .panel {
      grid-template-columns: 1fr;
      gap: 28px;
      padding: 32px 0 0 24px;
    }

    .copy {
      padding-right: 24px;
    }

    .starburst {
      margin-top: 8px;
    }

    .lid {
      border-radius: 22px 0 0 0;
      padding: 8px 0 0 8px;
    }

    .screen {
      height: 78px;
      border-radius: 14px 0 0 0;
    }

    .idle {
      width: 84px;
      height: 24px;
    }

    .live {
      width: min(220px, 64%);
      height: 30px;
    }

    .ms {
      font-size: 12px;
    }
  }
</style>
