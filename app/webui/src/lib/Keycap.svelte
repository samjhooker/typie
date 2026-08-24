<script>
  import { ui, send } from './bridge.svelte.js'

  /** click-to-record keybinding chooser, like the native KeyCap */
  const name = $derived(ui.capturingHotkey ? '?' : ui.settings.hotkeyShort)
</script>

<div class="wrap">
  <button
    class="cap"
    class:recording={ui.capturingHotkey}
    title="click to remap"
    onclick={() => send({ type: 'startHotkeyCapture' })}
  >
    {name}
  </button>

  <div class="labels">
    <strong class:recording={ui.capturingHotkey}>
      {ui.capturingHotkey ? 'press a modifier…' : ui.settings.hotkey}
    </strong>
    <span>{ui.capturingHotkey ? 'esc to cancel' : 'click the key to remap it'}</span>
  </div>
</div>

<style>
  .wrap {
    display: flex;
    align-items: center;
    gap: 14px;
  }

  .cap {
    font-family: var(--display);
    font-weight: 800;
    font-size: 26px;
    color: var(--cream);
    padding: 12px 22px;
    border-radius: 12px;
    background: var(--ink);
    box-shadow: 0 6px 0 #0b1f1b;
    transition:
      transform 0.18s var(--spring),
      box-shadow 0.18s var(--ease-out),
      outline-color 0.15s var(--ease-out);
    outline: 3px solid transparent;
    outline-offset: -3px;
  }

  .cap:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 0 #0b1f1b;
  }

  .cap:active {
    transform: translateY(2px);
    box-shadow: 0 3px 0 #0b1f1b;
  }

  .cap.recording {
    outline-color: var(--hotpink);
    transform: scale(1.06);
  }

  .labels {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  strong {
    color: var(--green);
    font-size: 14px;
    font-weight: 600;
  }

  strong.recording {
    color: var(--hotpink);
  }

  span {
    font-size: 11.5px;
    color: rgba(3, 89, 77, 0.6);
  }
</style>
