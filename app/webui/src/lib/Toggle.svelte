<script>
  /** iOS-style switch bound to a bridge setting */
  import { ui, send } from './bridge.svelte.js';

  let { setting } = $props();

  const checked = $derived(ui.settings[setting]);
</script>

<button
  class="switch"
  class:on={checked}
  role="switch"
  aria-checked={checked}
  aria-label={setting}
  onclick={() => send({ type: 'setSetting', key: setting, value: !checked })}
>
  <span class="knob"></span>
</button>

<style>
  .switch {
    position: relative;
    width: 42px;
    height: 26px;
    border-radius: 999px;
    background: var(--wash-strong);
    transition: background 0.22s var(--ease-out);
    flex-shrink: 0;
  }

  .on {
    background: var(--mint-live);
  }

  .knob {
    position: absolute;
    top: 3px;
    left: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--surface);
    box-shadow: 0 1px 4px var(--shadow-knob);
    transition: transform 0.22s var(--spring);
  }

  .on .knob {
    transform: translateX(16px);
  }
</style>
