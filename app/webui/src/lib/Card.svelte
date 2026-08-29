<script>
  /** cream section card with an icon chip and a chunky title */
  let { icon = '', tint = 'var(--pink)', title = '', children } = $props();
</script>

<section class="card">
  {#if title}
    <header>
      <span
        class="chip"
        style="background:{tint}">{icon}</span
      >
      <h2>{title}</h2>
    </header>
  {/if}
  {@render children?.()}
</section>

<style>
  .card {
    display: flex;
    flex-direction: column;
    gap: 13px;
    padding: 17px;
    text-align: left;
  }

  header {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .chip {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 29px;
    height: 29px;
    border-radius: 9px;
    font-size: 14px;
  }

  h2 {
    font-size: 16px;
  }
</style>
