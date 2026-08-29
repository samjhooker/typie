<script>
  import { ui, send, local } from '../bridge.svelte.js';
  import {
    Plus,
    Pin,
    PinOff,
    Copy,
    Trash2,
    AudioLines,
    Pencil,
    Search,
  } from 'lucide-svelte';
  import { markCopied } from '../bridge.svelte.js';
  import SortSeg from '../SortSeg.svelte';
  import { infinite } from '../infinite.js';
  import { trash, fmtDateSmart } from '../trash.svelte.js';

  // sticky tints + a whisper of rotation so the wall feels hand-pinned
  const tints = [
    { bg: 'var(--card-cream)', pin: 'var(--sun)' },
    { bg: 'var(--card-lavender)', pin: 'var(--purple)' },
    { bg: 'var(--card-mint)', pin: 'var(--mint-live)' },
    { bg: 'var(--pink-band)', pin: 'var(--hotpink)' },
    { bg: 'var(--card-blue)', pin: 'var(--periwinkle)' },
    {
      bg: 'color-mix(in srgb, var(--lime) 38%, var(--page))',
      pin: 'var(--gold-ink)',
    },
  ];
  const rots = ['-0.7deg', '0.5deg', '-0.4deg', '0.8deg', '-0.9deg', '0.3deg'];

  // ── search + sort + progressive paging ──
  const SORTS = [
    { id: 'newest', label: 'newest' },
    { id: 'oldest', label: 'oldest' },
  ];
  const PAGE = 60;
  let query = $state('');
  let sortBy = $state('newest');
  let shown = $state(PAGE);

  // staged deletions disappear instantly, native delete fires after the grace window
  const pending = $derived(trash.pendingIds('note'));
  const searched = $derived(
    ui.notes.filter(
      (n) =>
        !pending.has(n.id) &&
        (!query.trim() ||
          n.text.toLowerCase().includes(query.trim().toLowerCase()))
    )
  );
  // pinned notes always float to the top; the chosen order applies within
  const sorted = $derived.by(() => {
    const arr = [...searched];
    const pin = (n) => -n.pinned;
    switch (sortBy) {
      case 'oldest':
        return arr.sort(
          (a, b) => pin(a) - pin(b) || new Date(a.date) - new Date(b.date)
        );
      default:
        return arr.sort(
          (a, b) => pin(a) - pin(b) || new Date(b.date) - new Date(a.date)
        );
    }
  });
  const visible = $derived(sorted.slice(0, shown));
  $effect(() => {
    query;
    sortBy;
    shown = PAGE;
  });

  // tint + tilt belong to the NOTE (hashed off its id), not its position,
  // pinning or deleting must never reshuffle the wall's colors
  function look(note) {
    let h = 0;
    for (const c of note.id) h = (h * 31 + c.charCodeAt(0)) >>> 0;
    return { tint: tints[h % tints.length], rot: rots[h % rots.length] };
  }

  function fmtDur(s) {
    return s >= 60 ? `${Math.round(s / 60)}m` : `${Math.round(s)}s`;
  }

  function doNewNote() {
    send({ type: 'toggleNoteRecording' });
  }
  function doDelete(note) {
    const preview = (note.text || '').trim().slice(0, 48) || 'note';
    trash.add('note', [note.id], preview);
  }
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>Voice notes</h2>
      <p>
        hold <b>{ui.settings.hotkeyShort}</b>, speak, it lands here.
        <span class="hand hint-hand">your pocket for thoughts</span>
      </p>
    </div>
    <div class="tools">
      <SortSeg
        options={SORTS}
        bind:value={sortBy}
      />
      <label class="input search">
        <Search size={14} />
        <input
          bind:value={query}
          placeholder="search notes…"
          spellcheck="false"
        />
      </label>
      <button
        class="btn btn-pink"
        onclick={doNewNote}
      >
        <Pencil size={15} /> new note
      </button>
    </div>
  </header>

  {#if ui.notes.length === 0}
    <div class="empty">
      <span class="hand big">nothing pinned to the wall yet…</span>
      <p>hit <b>new note</b> or just dictate with your hotkey.</p>
    </div>
  {:else if sorted.length === 0}
    <div class="empty">
      <span class="hand big"
        >{query.trim()
          ? `no matches for “${query}”`
          : 'the wall is empty…'}</span
      >
      {#if query.trim()}<p>try a different search.</p>{/if}
    </div>
  {:else}
    <div class="wall">
      {#each visible as note (note.id)}
        {@const { tint, rot } = look(note)}
        <article
          class="sticky"
          style="background:{tint.bg}; rotate:{rot}"
          class:pinned={note.pinned}
        >
          <p class="txt">{note.text}</p>
          <footer>
            <span class="meta"
              >{fmtDateSmart(note.date)}{note.durationSeconds > 1
                ? ` · ${fmtDur(note.durationSeconds)}`
                : ''}</span
            >
            <span class="acts">
              <button
                class="icon-btn"
                title="copy"
                onclick={() => {
                  send({ type: 'copy', text: note.text });
                  markCopied(note.id);
                }}
              >
                {#if local.copiedId === note.id}<span class="copied">✓</span
                  >{:else}<Copy size={13} />{/if}
              </button>
              <button
                class="icon-btn"
                title={note.pinned ? 'unpin' : 'pin'}
                onclick={() => send({ type: 'notesTogglePin', id: note.id })}
              >
                {#if note.pinned}<PinOff size={13} />{:else}<Pin
                    size={13}
                  />{/if}
              </button>
              <button
                class="icon-btn"
                title="delete"
                onclick={() => doDelete(note)}
              >
                <Trash2 size={13} />
              </button>
            </span>
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

    {#if visible.length < sorted.length}
      <button
        class="more"
        use:infinite={() => (shown += PAGE)}
        onclick={() => (shown += PAGE)}
      >
        show more · {sorted.length - visible.length} left
      </button>
    {/if}
  {/if}
</div>

<style>
  .wrap {
    padding: 28px 32px 40px;
    max-width: 1200px;
    margin: 0 auto;
  }

  .head {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 22px;
    flex-wrap: wrap;
  }
  .head h2 {
    font-size: 26px;
  }
  .head p {
    font-size: 13px;
    color: var(--text-3);
    margin-top: 4px;
  }
  .head p b {
    color: var(--ink);
    font-weight: 700;
  }
  .hint-hand {
    font-size: 16px;
    color: var(--hotpink);
    margin-left: 8px;
  }
  .tools {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .search {
    max-width: 230px;
    padding: 8px 15px;
    background: var(--cream);
  }

  .empty {
    padding: 80px 20px;
    text-align: center;
    border: 2px dashed var(--line-strong);
    border-radius: 24px;
  }
  .big {
    font-size: 30px;
    color: var(--ink);
  }
  .empty p {
    margin-top: 10px;
    font-size: 13px;
    color: var(--text-3);
  }

  .wall {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 18px;
    align-items: start;
  }
  .sticky {
    position: relative;
    padding: 18px 18px 12px;
    border-radius: 4px 18px 6px 20px;
    box-shadow: 0 3px 12px rgba(19, 23, 34, 0.08);
    display: flex;
    flex-direction: column;
    gap: 14px;
    min-height: 150px;
    transition:
      transform 0.22s var(--spring),
      box-shadow 0.22s var(--ease-out);
  }
  .sticky:hover {
    transform: translateY(-3px) rotate(0deg) !important;
    box-shadow: 0 10px 22px rgba(19, 23, 34, 0.13);
  }
  .sticky.pinned {
    outline: 2px solid var(--line);
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
    color: var(--ink);
    font-size: 14px;
    line-height: 1.55;
  }

  footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .meta {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: var(--text-3);
  }
  .acts {
    display: flex;
    gap: 2px;
    opacity: 0;
    transition: opacity 0.18s var(--ease-out);
  }
  .sticky:hover .acts,
  .sticky:focus-within .acts {
    opacity: 1;
  }
  .icon-btn {
    width: 26px;
    height: 26px;
    border-radius: 8px;
  }
  .copied {
    font-size: 12px;
    color: var(--green);
    font-weight: 800;
  }

  .more {
    display: block;
    margin: 24px auto 4px;
    padding: 8px 18px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-3);
    border: 1px dashed var(--line-strong);
    transition:
      color 0.18s var(--ease-out),
      border-color 0.18s var(--ease-out),
      background 0.18s var(--ease-out);
  }
  .more:hover {
    color: var(--hotpink);
    border-color: var(--hotpink);
    background: rgba(252, 86, 129, 0.05);
  }
</style>
