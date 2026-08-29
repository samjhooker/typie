<script>
  import { reveal } from './reveal.js';
  import DemoShell from './real/DemoShell.svelte';
</script>

<section
  class="showcase field"
  id="showcase"
>
  <div
    class="container"
    use:reveal
  >
    <div class="shhead">
      <p class="mono">Inside the app</p>
      <h2>The workspace,<br /><em>on your Mac.</em></h2>
      <p class="sub">
        Not a mockup. This is the actual app — sidebar, panes, transcription,
        AI. Try it.
      </p>
      <div class="nav-pills">
        <span class="pill">Home</span>
        <span class="pill">Notes</span>
        <span class="pill">Library</span>
        <span class="pill">Stats</span>
      </div>
    </div>

    <div class="macmini">
      <div class="lidmini">
        <div
          class="wallpaper"
          aria-hidden="true"
        >
          <span class="streak s1"></span><span class="streak s2"></span>
        </div>
        <div class="notchmini"><span class="botmini">⬢</span></div>
        <div class="win">
          <div class="winbar">
            <span class="dots"><i></i><i></i><i></i></span>
            <span class="mono">typie</span>
            <span
              class="mono"
              style="opacity:.45">offline</span
            >
          </div>
          <div class="winbody">
            <DemoShell />
          </div>
        </div>
      </div>
      <div class="basemini"><i></i></div>
    </div>
    <p class="mono hint">
      All of this runs on your Mac. Pull the wifi — it still works.
    </p>
  </div>
</section>

<style>
  .showcase {
    background: var(--surface);
    border-top: 1px solid var(--line);
    border-bottom: 1px solid var(--line);
  }
  .shhead {
    text-align: center;
    max-width: 760px;
    margin: 0 auto;
  }
  .shhead h2 {
    font-size: clamp(28px, 4vw, 42px);
    font-weight: 800;
    font-family: 'Bricolage Grotesque', 'Inter', system-ui, sans-serif;
  }
  .shhead h2 em {
    font-family: 'Bricolage Grotesque', 'Inter', system-ui, sans-serif;
    font-style: italic;
    font-weight: 500;
    color: #ff3b6b;
  }
  .shhead .sub {
    margin-top: 8px;
    color: #52525b;
    font-size: 15px;
  }

  .nav-pills {
    display: inline-flex;
    gap: 6px;
    margin-top: 16px;
    flex-wrap: wrap;
    justify-content: center;
  }
  .pill {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
    font-family:
      'Space Grotesk',
      -apple-system,
      system-ui,
      sans-serif;
    color: #52525b;
    background: var(--surface);
    border: 1px solid var(--line);
  }

  .macmini {
    max-width: 1100px;
    margin: 22px auto 0;
    filter: drop-shadow(0 16px 42px rgba(0, 0, 0, 0.16));
  }
  .lidmini {
    position: relative;
    background: #0c0e12;
    border-radius: 18px 18px 0 0;
    padding: 10px 10px 0;
    overflow: hidden;
  }
  .wallpaper {
    position: absolute;
    inset: 10px 10px 0;
    border-radius: 12px 12px 0 0;
    background: linear-gradient(
      112deg,
      #0b5cff 0%,
      #2ec5ff 28%,
      #3dd68c 52%,
      #c7d7ff 78%,
      #ff5a7a 100%
    );
  }
  .streak {
    position: absolute;
    inset: -20%;
    opacity: 0.3;
    background: linear-gradient(
      100deg,
      transparent 36%,
      rgba(255, 255, 255, 0.5) 50%,
      transparent 64%
    );
    transform: skewX(-14deg);
  }
  .streak.s2 {
    opacity: 0.18;
    transform: skewX(-18deg) translateX(40px);
  }
  .notchmini {
    position: absolute;
    top: 10px;
    left: 50%;
    transform: translateX(-50%);
    width: 120px;
    height: 22px;
    background: #000;
    border-radius: 0 0 10px 10px;
    display: grid;
    place-items: center;
    color: #ff5a7a;
    font-size: 10px;
  }
  .win {
    position: relative;
    margin: 36px 10px 0;
    background: rgba(255, 255, 255, 0.97);
    backdrop-filter: blur(8px);
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.7);
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
    height: 680px;
  }
  .winbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 8px 12px;
    background: var(--surface-2);
    border-bottom: 1px solid var(--line);
    font-size: 11px;
  }
  .dots {
    display: flex;
    gap: 6px;
  }
  .dots i {
    width: 9px;
    height: 9px;
    border-radius: 50%;
    background: #ddd;
  }
  .winbody {
    height: calc(100% - 35px);
    overflow: hidden;
  }

  .mono {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 11px;
    letter-spacing: 0.05em;
  }

  .basemini {
    height: 16px;
    margin: 0 -1.2%;
    background: linear-gradient(90deg, #9aa0ac, #f0f2f6 50%, #9aa0ac);
    border-radius: 0 0 10px 10px;
  }
  .hint {
    text-align: center;
    margin-top: 12px;
    opacity: 0.6;
  }

  @media (max-width: 860px) {
    .win {
      height: 500px;
    }
  }
  @media (max-width: 560px) {
    .win {
      height: 420px;
    }
  }
</style>

<style>
  /* dark — mock window chrome follows the theme */
  :global([data-theme='dark']) .dots {
    color: #9aa0a6;
  }
</style>
