<script>
  import Robot from './Robot.svelte';

  let { size = 26, color = null } = $props();

  const LETTERS = ['t', 'y', 'p', 'i', 'e'];
</script>

<span
  class="logo"
  style="font-size:{size}px; {color ? `--tone:${color}` : ''}"
>
  <Robot
    size={Math.round(size * 1.15)}
    mood="idle"
  />
  <span class="word">
    {#each LETTERS as ch}<b>{ch}</b>{/each}<i>.</i>
  </span>
</span>

<style>
  .logo {
    display: inline-flex;
    align-items: center;
    gap: 0.32em;
    line-height: 1;
    color: var(--tone, var(--hotpink));
  }

  .logo :global(.robot) {
    color: var(--tone, var(--hotpink));
  }

  .word {
    font-family: var(--display);
    font-weight: 900;
    font-size: 1.12em;
    letter-spacing: -0.05em;
    color: var(--tone, var(--ink));
  }

  .word i {
    font-style: normal;
  }
</style>
