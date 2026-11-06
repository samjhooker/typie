<script>
  import { ui, send, markCopied, local } from '../bridge.svelte.js';
  import { Search, Copy, Check, Zap, Trash2, Sparkles } from 'lucide-svelte';
  import { infinite } from '../infinite.js';
  import { trash } from '../trash.svelte.js';

  let query = $state('');
  // which rows have their pre-cleanup transcript revealed
  let openRaw = $state(new Set());

  function toggleRaw(id) {
    const next = new Set(openRaw);
    next.has(id) ? next.delete(id) : next.add(id);
    openRaw = next;
  }

  function matches(h) {
    const q = query.trim().toLowerCase();
    if (!q) return true;
    return (
      h.text.toLowerCase().includes(q) ||
      (h.rawText || '').toLowerCase().includes(q)
    );
  }

  // progressive paging, history grows forever, the DOM shouldn't
  const PAGE = 80;
  let shown = $state(PAGE);
  $effect(() => {
    query;
    shown = PAGE;
  });

  // staged deletions vanish instantly; native delete fires after the grace window
  const pending = $derived(trash.pendingIds('history'));

  const totalMatched = $derived(ui.history.filter(matches).length);

  const grouped = $derived.by(() => {
    let items = [...ui.history].sort(
      (a, b) => new Date(b.date) - new Date(a.date)
    );
    if (query.trim()) items = items.filter(matches);
    items = items.filter((h) => !pending.has(h.id)).slice(0, shown);
    const day = (d) =>
      new Date(
        new Date(d).getFullYear(),
        new Date(d).getMonth(),
        new Date(d).getDate()
      ).getTime();
    const today = day(new Date());
    const yest = today - 86400000;
    const thisYear = new Date().getFullYear();
    const groups = [];
    for (const h of items) {
      const d = day(new Date(h.date));
      const dt = new Date(h.date);
      const label =
        d === today
          ? 'today'
          : d === yest
            ? 'yesterday'
            : dt.toLocaleDateString(
                undefined,
                dt.getFullYear() === thisYear
                  ? { weekday: 'long', month: 'long', day: 'numeric' }
                  : {
                      weekday: 'long',
                      month: 'long',
                      day: 'numeric',
                      year: 'numeric',
                    }
              );
      let g = groups.find((x) => x.label === label);
      if (!g) {
        g = { label, items: [] };
        groups.push(g);
      }
      g.items.push(h);
    }
    return groups;
  });

  function fmtTime(iso) {
    return new Date(iso).toLocaleTimeString(undefined, {
      hour: '2-digit',
      minute: '2-digit',
    });
  }
  function fmtLat(ms) {
    return ms >= 1000 ? `${(ms / 1000).toFixed(1)}s` : `${Math.round(ms)}ms`;
  }

  function doDelete(e, h) {
    e.stopPropagation();
    trash.add(
      'history',
      [h.id],
      (h.text || '').trim().slice(0, 48) || 'dictation'
    );
  }
  function doClearAll() {
    if (ui.history.length === 0) return;
    trash.add(
      'history',
      ui.history.map((h) => h.id),
      'your entire history',
      { bulk: true }
    );
  }

  // how much of the (filtered) history is currently on screen
  const visibleCount = $derived(Math.min(shown, totalMatched));
</script>

<div class="wrap">
  <header class="head">
    <div>
      <h2>History</h2>
      <p>
        everything you've dictated, newest first. <span class="hand hint-hand"
          >your words, archived locally</span
        >
      </p>
    </div>
    <div class="tools">
      <label class="input search">
        <Search size={14} />
        <input
          bind:value={query}
          placeholder="search dictations…"
          spellcheck="false"
          data-search
        />
      </label>
      {#if ui.history.length > 0}
        <button
          class="clearall"
          title="delete every dictation"
          onclick={doClearAll}
        >
          <Trash2 size={12} /> clear all
        </button>
      {/if}
    </div>
  </header>

  {#if grouped.length === 0}
    <div class="empty">
      <span class="hand big"
        >{ui.history.length === 0
          ? 'nothing said yet, hold your hotkey and talk!'
          : `no matches for “${query}”`}</span
      >
    </div>
  {:else}
    {#each grouped as group (group.label)}
      <section>
        <div class="dayline">
          <span class="mono-kicker">{group.label}</span>
          <i></i>
          <span class="count">{group.items.length}</span>
        </div>
        <div class="rows">
          {#each group.items as h (h.id)}
            <div class="row card">
              <span class="time mono-kicker">{fmtTime(h.date)}</span>
              <div class="body">
                <p class="txt">{h.text}</p>
                {#if h.rawText && openRaw.has(h.id)}
                  <div class="raw">
                    <span class="mono-kicker">before cleanup</span>
                    <p class="rawtxt">{h.rawText}</p>
                    <button
                      class="icon-btn"
                      title="copy original"
                      onclick={() => {
                        send({ type: 'copy', text: h.rawText });
                        markCopied(h.id + ':raw');
                      }}
                    >
                      {#if local.copiedId === h.id + ':raw'}<Check
                          size={13}
                        />{:else}<Copy size={13} />{/if}
                    </button>
                  </div>
                {/if}
              </div>
              <span class="tail">
                {#if h.rawText}
                  <button
                    class="chip cleaned {openRaw.has(h.id) ? 'on' : ''}"
                    title="typie cleaned this up, click to compare"
                    onclick={() => toggleRaw(h.id)}
                  >
                    <Sparkles size={10} /> cleaned
                  </button>
                {/if}
                <span
                  class="chip lat"
                  title="transcription latency"
                  ><Zap size={10} />{fmtLat(h.latencyMs)}</span
                >
                <button
                  class="icon-btn"
                  title="copy cleaned"
                  onclick={() => {
                    send({ type: 'copy', text: h.text });
                    markCopied(h.id);
                  }}
                >
                  {#if local.copiedId === h.id}<Check size={13} />{:else}<Copy
                      size={13}
                    />{/if}
                </button>
                <button
                  class="icon-btn del"
                  title="delete"
                  onclick={(e) => doDelete(e, h)}
                >
                  <Trash2 size={13} />
                </button>
              </span>
            </div>
          {/each}
        </div>
      </section>
    {/each}

    {#if shown < totalMatched}
      <div class="expand">
        <div
          class="meter"
          aria-hidden="true"
        >
          <div
            style="width:{Math.max(4, (visibleCount / totalMatched) * 100)}%"
          ></div>
        </div>
        <button
          class="more"
          use:infinite={() => (shown += PAGE)}
          onclick={() => (shown += PAGE)}
        >
          expand more · showing {visibleCount} of {totalMatched}
        </button>
      </div>
    {/if}
  {/if}
</div>

<style>
  .wrap {
    padding: 28px 32px 48px;
    max-width: 900px;
    margin: 0 auto;
  }

  .head {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 18px;
    margin-bottom: 26px;
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
  .hint-hand {
    font-size: 16px;
    color: var(--periwinkle);
    margin-left: 8px;
  }
  .tools {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .search {
    max-width: 260px;
    padding: 8px 15px;
  }

  .clearall {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 10.5px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-3);
    transition:
      color 0.18s var(--ease-out),
      background 0.18s var(--ease-out);
  }
  .clearall:hover {
    color: var(--red-ink);
    background: rgba(252, 86, 129, 0.09);
  }

  .empty {
    padding: 80px 20px;
    text-align: center;
  }
  .big {
    font-size: 28px;
    color: var(--ink);
  }

  section {
    margin-bottom: 30px;
  }
  .dayline {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
  }
  .dayline i {
    flex: 1;
    height: 1px;
    background: var(--line);
  }
  .count {
    font-family: var(--mono);
    font-size: 11px;
    color: var(--text-3);
  }

  .rows {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .row {
    display: flex;
    align-items: flex-start;
    gap: 16px;
    padding: 13px 18px;
    transition:
      border-color 0.18s var(--ease-out),
      box-shadow 0.18s var(--ease-out);
    animation: enter-up 0.45s var(--spring-snappy, ease) both;
  }
  .row:hover {
    border-color: var(--line-strong);
    box-shadow: 0 4px 14px rgba(19, 23, 34, 0.06);
  }
  .time {
    width: 60px;
    flex-shrink: 0;
    padding-top: 1px;
  }
  .body {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .txt {
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-1);
    white-space: pre-wrap;
    word-break: break-word;
    user-select: text;
  }
  .raw {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 8px 12px;
    border-radius: 10px;
    background: var(--wash);
  }
  .raw > .mono-kicker {
    flex-shrink: 0;
    padding-top: 3px;
    opacity: 0.7;
  }
  .rawtxt {
    flex: 1;
    min-width: 0;
    font-size: 13px;
    line-height: 1.55;
    color: var(--text-2);
    white-space: pre-wrap;
    word-break: break-word;
    user-select: text;
  }
  .cleaned {
    background: var(--card-lavender, var(--wash));
    color: #6d28d9;
    border: 1px solid transparent;
    transition:
      border-color 0.18s var(--ease-out),
      background 0.18s var(--ease-out);
  }
  .cleaned:hover,
  .cleaned.on {
    border-color: #6d28d9;
  }
  .tail {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-shrink: 0;
    padding-top: 1px;
  }
  .lat {
    background: var(--card-cream);
    color: var(--gold-ink);
  }
  .icon-btn {
    width: 26px;
    height: 26px;
    border-radius: 8px;
  }
  .del:hover {
    color: var(--red-ink);
    background: rgba(252, 86, 129, 0.1);
  }

  /* ── expansion footer ── */
  .expand {
    margin: 26px auto 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    max-width: 340px;
  }
  .meter {
    width: 100%;
    height: 5px;
    border-radius: 99px;
    background: var(--wash);
    overflow: hidden;
  }
  .meter > div {
    height: 100%;
    border-radius: 99px;
    background: linear-gradient(90deg, var(--mint), var(--mint-live));
    transition: width 0.45s var(--spring-snappy, ease);
  }
  .more {
    padding: 9px 20px;
    border-radius: 999px;
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-2);
    border: 1px solid var(--line-strong);
    background: var(--cream);
    box-shadow: 0 2px 8px rgba(19, 23, 34, 0.05);
    transition:
      transform 0.25s var(--snap),
      color 0.18s var(--ease-out),
      border-color 0.18s var(--ease-out),
      box-shadow 0.25s var(--snap),
      background 0.18s var(--ease-out);
  }
  .more:hover {
    color: var(--hotpink);
    border-color: var(--hotpink);
    background: var(--cream-50);
    transform: translateY(-2px);
    box-shadow: 0 7px 18px rgba(252, 86, 129, 0.18);
  }
  .more:active {
    transform: translateY(0) scale(0.98);
  }
</style>
