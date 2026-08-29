<script>
  const notes = [
    {
      id: '1',
      text: 'podcast idea — the voice is the interface, not the keyboard',
      pinned: true,
      date: 'today',
      dur: '12s',
    },
    {
      id: '2',
      text: 'standup — we ship friday, two things left: pricing and video',
      pinned: false,
      date: 'yesterday',
      dur: '8s',
    },
    {
      id: '3',
      text: "grandma's recipe — add miso, trust me, white pepper too",
      pinned: false,
      date: '2 days ago',
      dur: '21s',
    },
    {
      id: '4',
      text: 'follow up with Maya on pricing page before the demo',
      pinned: true,
      date: '3 days ago',
      dur: '14s',
    },
    {
      id: '5',
      text: "don't forget: hold option, don't click the mic icon",
      pinned: false,
      date: 'today',
      dur: '5s',
    },
    {
      id: '6',
      text: 'idea — offline is a feature, not a fallback',
      pinned: false,
      date: 'today',
      dur: '9s',
    },
  ];

  const tints = [
    { bg: '#fdf3dc', pin: '#ffd230' },
    { bg: '#efecfb', pin: '#c88cfd' },
    { bg: '#dff0e4', pin: '#6ee89a' },
    { bg: '#fbdae4', pin: '#fc5681' },
    { bg: '#dde9fa', pin: '#6f8ffb' },
  ];
  const rots = ['-0.7deg', '0.5deg', '-0.4deg', '0.8deg', '-0.9deg', '0.3deg'];

  function look(id) {
    let h = 0;
    for (const c of id) h = (h * 31 + c.charCodeAt(0)) >>> 0;
    return { tint: tints[h % tints.length], rot: rots[h % rots.length] };
  }

  // optional note that flies in (used by landing demos)
  let { extra = null } = $props();
</script>

<div class="wall">
  {#if extra}
    <article
      class="sticky fresh"
      style="background:{extra.tint.bg}; rotate:{extra.rot}"
      class:pinned={extra.pinned}
    >
      <p class="txt">{extra.text}</p>
      <footer><span class="meta">{extra.meta}</span></footer>
      {#if extra.pinned}<span
          class="pin"
          style="background:{extra.tint.pin}"
        ></span>{/if}
    </article>
  {/if}

  {#each notes as note (note.id)}
    {@const { tint, rot } = look(note.id)}
    <article
      class="sticky"
      style="background:{tint.bg}; rotate:{rot}"
      class:pinned={note.pinned}
    >
      <p class="txt">{note.text}</p>
      <footer>
        <span class="meta">{note.date} · {note.dur}</span>
      </footer>
      {#if note.pinned}
        <span
          class="pin"
          style="background:{tint.pin}"
        ></span>
      {/if}
    </article>
  {/each}
</div>

<style>
  .wall {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 14px;
    align-items: start;
  }
  .sticky {
    position: relative;
    padding: 16px 16px 12px;
    border-radius: 4px 18px 6px 20px;
    box-shadow: 0 3px 12px rgba(19, 23, 34, 0.08);
    display: flex;
    flex-direction: column;
    gap: 12px;
    min-height: 130px;
    transition:
      transform 0.22s var(--spring, ease),
      box-shadow 0.22s ease;
    cursor: pointer;
  }
  .sticky:hover {
    transform: translateY(-3px) rotate(0deg) !important;
    box-shadow: 0 10px 22px rgba(19, 23, 34, 0.13);
  }
  .sticky.pinned {
    outline: 2px solid rgba(19, 23, 34, 0.08);
  }

  .pin {
    position: absolute;
    top: -7px;
    left: 50%;
    transform: translateX(-50%);
    width: 14px;
    height: 14px;
    border-radius: 99px;
    box-shadow:
      0 2px 4px rgba(19, 23, 34, 0.25),
      inset 0 -2px 3px rgba(255, 255, 255, 0.4);
  }

  .txt {
    flex: 1;
    white-space: pre-wrap;
    word-break: break-word;
    color: #131722;
    font-size: 14px;
    line-height: 1.55;
  }

  footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .meta {
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
    font-size: 10px;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: rgba(19, 23, 34, 0.45);
  }

  .fresh {
    animation: landIn 0.55s var(--spring, cubic-bezier(0.22, 1.2, 0.36, 1)) both;
  }
  @keyframes landIn {
    0% {
      opacity: 0;
      transform: translateY(26px) scale(0.85) rotate(-6deg);
    }
    60% {
      opacity: 1;
      transform: translateY(-4px) scale(1.03) rotate(2deg);
    }
    100% {
      opacity: 1;
      transform: none;
    }
  }
</style>
