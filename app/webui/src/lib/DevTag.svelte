<script>
  import { ui } from './bridge.svelte.js'

  /** tiny pink DEV pill next to the logo on dev builds */
  const isDev = $derived(ui.variant === 'dev')
</script>

{#if isDev}
  <span class="devtag" title="typie dev — runs alongside your production typie">DEV</span>
{/if}

<style>
  .devtag {
    font-family: var(--mono);
    font-size: 9px;
    font-weight: 500;
    letter-spacing: 0.14em;
    color: #fff;
    background: var(--hotpink);
    padding: 2px 7px;
    border-radius: 999px;
    transform: translateY(-1px);
  }
</style>
