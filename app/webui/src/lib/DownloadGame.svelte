<script>
  import { onMount } from 'svelte';
  import Robot from './Robot.svelte';

  const W = 540;
  const H = 132;

  let score = $state(0);
  let items = $state([]);
  let robotX = $state(W / 2);
  let targetX = $state(W / 2);

  onMount(() => {
    let raf;
    let last = performance.now();
    let spawnAcc = 400;
    let id = 0;
    const colors = ['var(--mint)', 'var(--butter)', 'var(--pink)', 'var(--lavender)'];

    const tick = (now) => {
      const dt = Math.min(40, now - last);
      last = now;

      spawnAcc += dt;
      if (spawnAcc > 620) {
        spawnAcc = 0;
        items.push({
          id: id++,
          x: 26 + Math.random() * (W - 52),
          y: -14,
          vy: 0.09 + Math.random() * 0.07,
          c: colors[id % colors.length],
          r: (Math.random() - 0.5) * 40,
        });
      }

      robotX += (targetX - robotX) * Math.min(1, 0.012 * dt);

      const keep = [];
      for (const it of items) {
        it.y += it.vy * dt;
        if (it.y > H - 36 && it.y < H - 4 && Math.abs(it.x - robotX) < 38) {
          score += 1;
          continue;
        }
        if (it.y < H + 16) keep.push(it);
      }
      items = keep;

      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);

    const key = (e) => {
      if (e.key === 'ArrowLeft') targetX = Math.max(24, targetX - 42);
      if (e.key === 'ArrowRight') targetX = Math.min(W - 24, targetX + 42);
    };
    window.addEventListener('keydown', key);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener('keydown', key);
    };
  });

  function move(e) {
    const r = e.currentTarget.getBoundingClientRect();
    targetX = Math.min(W - 24, Math.max(24, e.clientX - r.left));
  }
</script>

<div class="game card">
  <header class="ghead">
    <strong>feed the robot while you wait</strong>
    <span class="chip score-chip">caught · {score}</span>
  </header>

  <div class="arena" onpointermove={move} ontouchstart={move} style="width:{W}px">
    {#each items as it (it.id)}
      <span
        class="snack"
        style="left:{it.x}px; top:{it.y}px; background:{it.c}; transform:translate(-50%,-50%) rotate({it.r}deg)"
      ></span>
    {/each}
    <div class="bot" style="transform:translateX({robotX}px) translateX(-50%)">
      <Robot size={34} mood="listening" />
    </div>
    <div class="floor"></div>
  </div>

  <span class="hand ghint">mouse or ← → to move</span>
</div>

<style>
  .game {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    padding: 12px 14px 8px;
    width: fit-content;
  }

  .ghead {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    padding: 0;
    border: none;
  }

  .ghead strong {
    font-size: 12.5px;
    font-weight: 800;
    color: var(--ink);
  }

  .score-chip {
    background: var(--card-mint);
    color: var(--green-deep);
  }

  .arena {
    position: relative;
    height: 132px;
    overflow: hidden;
    cursor: none;
    touch-action: none;
  }

  .snack {
    position: absolute;
    width: 13px;
    height: 13px;
    border-radius: 4.5px;
    box-shadow: 0 1px 3px rgba(19, 23, 34, 0.12);
  }

  .bot {
    position: absolute;
    bottom: 4px;
    left: 0;
    will-change: transform;
  }

  .floor {
    position: absolute;
    left: 8px;
    right: 8px;
    bottom: 0;
    height: 2px;
    border-radius: 999px;
    background: var(--line-strong);
  }

  .ghint {
    font-size: 14px;
    color: var(--green-deep);
    opacity: 0.55;
  }
</style>
