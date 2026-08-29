<script>
  const turns = [
    {
      speaker: 0,
      name: 'Maya',
      time: '02:14',
      text: 'and the launch checklist is basically done?',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '02:18',
      text: 'two items left. pricing page and the demo video.',
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '02:24',
      text: 'perfect. i can take the video this afternoon.',
    },
    {
      speaker: 1,
      name: 'Sam',
      time: '02:31',
      text: "awesome. i'll handle the pricing page then.",
    },
    {
      speaker: 0,
      name: 'Maya',
      time: '02:38',
      text: "let's sync at 4 to make sure everything's aligned.",
    },
  ];

  const SP_COLORS = [
    '#fc5681',
    '#6f8ffb',
    '#c88cfd',
    '#ff9124',
    '#03594d',
    '#e59e12',
  ];
  function spColor(i) {
    return SP_COLORS[i % SP_COLORS.length];
  }
</script>

<div class="turns">
  {#each turns as turn, i (i)}
    <div class="oturn">
      <div class="ohead">
        <span
          class="avatar"
          style="background:{spColor(turn.speaker)}">{turn.name[0]}</span
        >
        <span class="oname">{turn.name}</span>
        <span class="ts">{turn.time}</span>
      </div>
      <p class="otext">{turn.text}</p>
    </div>
  {/each}
</div>

<style>
  .turns {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .oturn {
    padding: 10px 14px 11px;
    border-radius: 14px;
    border: 1px solid transparent;
    transition: background 0.2s ease;
  }
  .oturn:hover {
    background: var(--hover-row);
  }
  .ohead {
    display: flex;
    align-items: center;
    gap: 9px;
    margin-bottom: 5px;
  }
  .avatar {
    display: grid;
    place-items: center;
    width: 24px;
    height: 24px;
    border-radius: 99px;
    flex-shrink: 0;
    color: #fff;
    font-size: 11px;
    font-weight: 800;
  }
  .oname {
    font-size: 13px;
    font-weight: 700;
    color: var(--ink-app);
  }
  .ts {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 11px;
    letter-spacing: 0.05em;
    opacity: 0.55;
  }
  .otext {
    font-size: 14px;
    line-height: 1.7;
    color: var(--text-2);
  }
</style>
