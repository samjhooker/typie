<script>
  /** iOS-style switch bound to a bridge setting.
      bits-ui Switch provides the behavior + a11y; our classes carry the look. */
  import { Switch } from 'bits-ui';
  import { ui, send } from './bridge.svelte.js';

  let { setting } = $props();

  const checked = $derived(ui.settings[setting]);
</script>

<Switch.Root
  checked={checked}
  onCheckedChange={(v) => send({ type: 'setSetting', key: setting, value: v })}
  class="switch"
  aria-label={setting}
>
  <span class="knob"></span>
</Switch.Root>

<style>
  /* bits-ui renders the root button itself, so these selectors must be
     :global — scoped selectors never reach another component's elements */
  :global(.switch) {
    position: relative;
    width: 42px;
    height: 26px;
    border-radius: 999px;
    background: var(--wash-strong);
    transition: background 0.22s var(--ease-out);
    flex-shrink: 0;
  }

  :global(.switch[data-state='checked']) {
    background: var(--mint-live);
  }

  :global(.switch .knob) {
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

  .switch[data-state='checked'] :global(.switch .knob) {
    transform: translateX(16px);
  }
</style>
