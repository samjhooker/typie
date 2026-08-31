<script>
  import {
    ui,
    send,
    transcriptCache,
    local,
    dismissAiNudge,
    markOpened,
    markCopied,
  } from '../bridge.svelte.js';
  import ClaudeIcon from '../ClaudeIcon.svelte';
  import GptIcon from '../GptIcon.svelte';
  import { Tabs } from 'bits-ui';
  import InlineEdit from '../InlineEdit.svelte';
  import { Avatar, Style } from '@dicebear/core';
  import blobsJson from '../dicebear/blobs.json';
  import {
    ArrowLeft,
    Search,
    Download,
    Play,
    Pause,
    Pencil,
    Check,
    Sparkles,
    Clock,
    Loader2,
    Wand2,
    X,
    PanelRightClose,
    PanelRight,
    Copy,
    MessageSquarePlus,
  } from 'lucide-svelte';
  import { infinite } from '../infinite.js';
  import { fly } from 'svelte/transition';
  import { cubicOut } from 'svelte/easing';

  let { id, onBack } = $props();

  let query = $state('');
  let playing = $state(false);
  let currentTime = $state(0);
  let duration = $state(0);
  let rate = $state(1);
  let renaming = $state(null);
  let renameVal = $state('');
  let audioEl;
  let contentColEl;

  // progressive rendering, long meetings are thousands of word spans;
  // mount them a page at a time as the reader (or playback) advances
  const TURN_PAGE = 50;
  let shown = $state(TURN_PAGE);

  const meta = $derived(ui.transcripts.find((x) => x.id === id));
  // once a transcript has been opened it's no longer "new" (persisted —
  // the chip must not resurrect on every relaunch)
  $effect(() => {
    markOpened(id);
  });
  const cached = $derived(transcriptCache[id]);
  // metadata arrives via the global push; turns/words arrive on demand,
  // request (or refresh) whenever the stored turnCount moves ahead of cache
  $effect(() => {
    if (!id || !meta) return;
    const needsAI =
      !cached ||
      cached.aiStatus !== meta.aiStatus ||
      cached.aiSummary !== meta.aiSummary ||
      cached.aiTitle !== meta.aiTitle;
    if (
      !cached ||
      cached.turns.length !== meta.turnCount ||
      cached.fileName !== meta.fileName ||
      needsAI
    ) {
      send({ type: 'transcriptGet', id });
    }
  });
  const t = $derived(
    meta
      ? {
          ...meta,
          ...(cached ?? {}),
          // annotations live in the push metadata (always fresh) — cached
          // full-transcript fetches would otherwise shadow them
          annotations: meta.annotations ?? cached?.annotations ?? [],
          // same for audio: the cache may have been fetched while the file
          // was still processing (audioFile not adopted yet) — the fresh
          // push metadata must win, or the player never appears
          audioUrl: meta.audioUrl || cached?.audioUrl || '',
          hasAudio: !!(meta.hasAudio ?? cached?.hasAudio),
          speakerNames: {
            ...(meta.speakerNames ?? {}),
            ...(cached?.speakerNames ?? {}),
          },
          // AI fields: prefer cached when it has real content, but fall through to meta when cached is empty/stale
          aiTitle:
            cached?.aiTitle && cached.aiTitle !== ''
              ? cached.aiTitle
              : (meta.aiTitle ?? ''),
          aiSummary:
            cached?.aiSummary && cached.aiSummary !== ''
              ? cached.aiSummary
              : (meta.aiSummary ?? ''),
          aiStatus:
            cached?.aiStatus && cached.aiStatus !== ''
              ? cached.aiStatus
              : (meta.aiStatus ?? ''),
          aiEngine: cached?.aiEngine ?? meta.aiEngine ?? '',
          aiTopics:
            cached?.aiTopics && cached.aiTopics.length
              ? cached.aiTopics
              : (meta.aiTopics ?? []),
        }
      : null
  );
  // turns arrive via the on-demand fetch; metadata alone has none yet
  const turns = $derived(t ? (t.turns ?? []) : []);
  // user highlights & comments — merged from BOTH sources (push metadata
  // and the full-transcript fetch) so a stale cache can never drop them
  const annotations = $derived.by(() => {
    const byId = new Map();
    for (const a of meta?.annotations ?? []) byId.set(a.id, a);
    for (const a of cached?.annotations ?? []) if (!byId.has(a.id)) byId.set(a.id, a);
    return [...byId.values()];
  });
  const sortedAnnotations = $derived(
    [...annotations].sort((a, b) => a.start - b.start)
  );
  const railVisible = $derived(
    // close must always win — with annotations in the library the old
    // condition forced the rail back open, so the close button did nothing
    railOpen && (aiAvailable || annotations.length > 0)
  );
  // the rail shows one section at a time — AI or the user's own marks —
  // so the panel doesn't stack summary + highlights into a wall
  let railTab = $state('ai');
  let seenAnnotationCount = 0;
  $effect(() => {
    // a fresh highlight/comment flips the rail to the yours tab
    const n = annotations.length;
    if (n > seenAnnotationCount && n > 0) railTab = 'yours';
    seenAnnotationCount = n;
  });
  const filtered = $derived(
    !t || query.trim() === ''
      ? turns
      : turns.filter((x) =>
          x.text.toLowerCase().includes(query.trim().toLowerCase())
        )
  );
  const visibleTurns = $derived(filtered.slice(0, shown));
  $effect(() => {
    query;
    shown = TURN_PAGE;
  });
  const speakers = $derived(
    t ? [...new Set(turns.map((x) => x.speaker))].sort((a, b) => a - b) : []
  );

  const SP_COLORS = [
    'var(--sp1)',
    'var(--sp2)',
    'var(--sp3)',
    'var(--sp4)',
    'var(--sp5)',
    'var(--sp6)',
  ];
  function spColor(i) {
    return SP_COLORS[i % SP_COLORS.length];
  }
  function spName(i) {
    return t?.speakerNames?.[String(i)] ?? `Speaker ${i + 1}`;
  }
  function spInitial(i) {
    return (spName(i).trim()[0] ?? '?').toUpperCase();
  }

  // ── default avatars: deterministic DiceBear pixel-art, generated on-device
  // (no network calls — the privacy promise holds). Seeded by the speaker's
  // display name, so a rename gives that speaker a fresh bot.
  // dicebear needs literal hexes (css vars won't work) — pastel mirrors of --sp1..6
  const SP_HEX = ['#ffb1c9', '#9ec5ff', '#d4bfff', '#ffd6a5', '#b5ead7', '#fff1b8'];

  const avatarCache = new Map();
  const blobsStyle = new Style(blobsJson);
  function avatarUri(i) {
    const name = spName(i);
    if (!avatarCache.has(name)) {
      avatarCache.set(
        name,
        new Avatar(blobsStyle, {
          seed: name,
          size: 48,
          // speaker's brand colour as the backdrop — radical per-speaker
          // variety (the blobs style's own palette is blue-dominant)
          backgroundColor: [SP_HEX[i % SP_HEX.length]],
        }).toDataUri()
      );
    }
    return avatarCache.get(name);
  }

  function startRename(i) {
    renaming = i;
    renameVal = spName(i);
  }
  function saveRename() {
    if (renaming != null && renameVal.trim() && t) {
      send({
        type: 'transcriptsRenameSpeaker',
        id: t.id,
        index: renaming,
        name: renameVal.trim(),
      });
    }
    renaming = null;
  }

  function fmtDur(s) {
    const n = Math.max(0, Math.floor(s));
    return `${String(Math.floor(n / 60)).padStart(2, '0')}:${String(n % 60).padStart(2, '0')}`;
  }
  function fmtDate(iso) {
    return new Date(iso).toLocaleDateString(undefined, {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    });
  }
  function fmtClock(s) {
    // h:mm:ss for the dock
    const n = Math.max(0, Math.floor(s));
    const h = Math.floor(n / 3600);
    return h > 0
      ? `${h}:${String(Math.floor(n / 60) % 60).padStart(2, '0')}:${String(n % 60).padStart(2, '0')}`
      : fmtDur(s);
  }

  // ── audio playback ──────────────────────────────────────────

  function togglePlay() {
    if (!audioEl) return;
    if (playing) audioEl.pause();
    else audioEl.play().catch(() => {});
  }
  function seekTo(s, andPlay = false) {
    if (!audioEl) return;
    audioEl.currentTime = Math.max(
      0,
      Math.min(s, duration || t?.durationSeconds || 0)
    );
    if (andPlay && !playing) audioEl.play().catch(() => {});
  }

  // smooth word highlighting, rAF while playing, timeupdate as fallback
  let raf = 0;
  function tick() {
    currentTime = audioEl.currentTime;
    raf = requestAnimationFrame(tick);
  }
  function onPlay() {
    playing = true;
    tick();
  }
  function onStop() {
    playing = false;
    cancelAnimationFrame(raf);
    if (audioEl) currentTime = audioEl.currentTime;
  }
  $effect(() => () => cancelAnimationFrame(raf));

  function setRate(r) {
    rate = r;
    if (audioEl) audioEl.playbackRate = r;
  }

  // ── words ───────────────────────────────────────────────────

  // real word timings when present; legacy transcripts get estimates
  function wordsOf(turn) {
    if (turn.words?.length) {
      return turn.words.map((w) => ({
        text: w.text,
        start: w.start,
        end: w.end,
      }));
    }
    const parts = (turn.text || '').split(/\s+/).filter(Boolean);
    const totalLen = parts.reduce((a, p) => a + p.length + 1, 0) || 1;
    const span = Math.max(0.4, turn.end - turn.start);
    let at = turn.start;
    return parts.map((p) => {
      const d = ((p.length + 1) / totalLen) * span;
      const w = { text: p, start: at, end: at + d };
      at += d;
      return w;
    });
  }

  const activeTurnIdx = $derived(
    turns.findIndex(
      (turn) => currentTime >= turn.start && currentTime < turn.end + 0.3
    )
  );
  const activeTurn = $derived(activeTurnIdx >= 0 ? turns[activeTurnIdx] : null);

  // follow playback: keep the spoken block in view (paging in more if needed)
  let turnEls = {};

  // ── continuous selection highlight ─────────────────────────────
  // The native ::selection paints each inline word span as a separate
  // chip with gaps at the whitespace between them. Instead we draw ONE
  // rounded band per line behind the text, driven by the real selection
  // (which stays intact for copy/paste — its own paint is disabled).
  // CSS transitions on the band rects make selection growth glide.
  let turnsEl = $state(null);

  // word indexes matching the current search query, per turn (cached)
  // — used to paint yellow search hits inside the filtered turns
  let hitCache = new WeakMap();
  let hitCacheQuery = '';
  function hitSet(turn) {
    const q = query.trim().toLowerCase();
    if (!q) return null;
    if (hitCacheQuery !== q) {
      hitCache = new WeakMap();
      hitCacheQuery = q;
    }
    if (hitCache.has(turn)) return hitCache.get(turn);
    const words = wordsOf(turn);
    const hits = new Set();
    const text = words.map((w) => w.text).join(' ').toLowerCase();
    let idx = text.indexOf(q);
    while (idx !== -1) {
      let at = 0;
      for (let wi = 0; wi < words.length; wi++) {
        const s = at;
        const e = at + words[wi].text.length;
        if (s < idx + q.length && e > idx) hits.add(wi);
        at = e + 1;
      }
      idx = text.indexOf(q, idx + q.length);
    }
    hitCache.set(turn, hits);
    return hits;
  }
  let selBands = $state([]);

  function updateSelBands() {
    const sel = document.getSelection();
    if (!turnsEl || !sel || sel.isCollapsed || sel.rangeCount === 0) {
      selBands = [];
      selMenu = null;
      return;
    }
    const range = sel.getRangeAt(0);
    const node = range.commonAncestorContainer;
    const host = node.nodeType === 1 ? node : node.parentElement;
    if (!host || !turnsEl.contains(host)) {
      selBands = [];
      return;
    }
    const base = turnsEl.getBoundingClientRect();
    // getClientRects yields one box per inline element; merge fragments
    // that share a line into a single band. Grouping is by VERTICAL
    // OVERLAP, not exact top: trailing fragments at a line end come back
    // with the full line-box height (different top than glyph rects) and
    // used to stack a second band on top of the first ("double highlight").
    const lines = [];
    const sorted = [...range.getClientRects()].sort((a, b) => a.top - b.top);
    for (const r of sorted) {
      if (r.width < 1 || r.height < 1) continue;
      const last = lines[lines.length - 1];
      if (
        last &&
        r.top < last.top + last.height &&
        r.top + r.height > last.top
      ) {
        const right = Math.max(last.left + last.width, r.left + r.width);
        last.left = Math.min(last.left, r.left);
        last.width = right - last.left;
        const top = Math.min(last.top, r.top);
        const bottom = Math.max(last.top + last.height, r.top + r.height);
        last.top = top;
        last.height = bottom - top;
      } else {
        lines.push({ top: r.top, left: r.left, width: r.width, height: r.height });
      }
    }
    selBands = lines.map((b) => ({
      top: b.top - base.top - 1,
      left: b.left - base.left - 4,
      width: b.width + 8,
      height: b.height + 2,
    }));
  }

  $effect(() => {
    document.addEventListener('selectionchange', updateSelBands);
    return () => {
      document.removeEventListener('selectionchange', updateSelBands);
      selBands = [];
    };
  });

  // ── selection actions: highlight colours / comment / copy ──────
  const HL_COLORS = ['#ffd43b', '#69db7c', '#4dabf7', '#ff8787', '#b197fc'];

  let selMenu = $state(null); // {x,y,text,start,end}
  let commentDraft = $state(null); // {x,y,text,start,end,note}

  /** first/last selected word spans give the audio-time anchor */
  function selectionAnchor() {
    const sel = document.getSelection();
    if (!sel || sel.isCollapsed || sel.rangeCount === 0 || !turnsEl)
      return null;
    const range = sel.getRangeAt(0);
    if (!turnsEl.contains(range.commonAncestorContainer)) return null;
    const spans = [...turnsEl.querySelectorAll('.w')].filter((el) =>
      range.intersectsNode(el)
    );
    if (!spans.length) return null;
    // build the quote from the words themselves — range.toString() leaks
    // speaker headers ("Speaker 1 00:42") and newlines when the drag
    // crosses turn boundaries
    const text = spans
      .map((el) => el.textContent.trim())
      .filter(Boolean)
      .join(' ');
    if (!text) return null;
    return {
      text,
      start: parseFloat(spans[0].dataset.s) || 0,
      end: parseFloat(spans[spans.length - 1].dataset.e) || 0,
    };
  }

  function onTurnsMouseUp() {
    if (commentDraft) return;
    const sel = document.getSelection();
    if (!sel || sel.isCollapsed) {
      selMenu = null;
      return;
    }
    const range = sel.rangeCount ? sel.getRangeAt(0) : null;
    if (!range || !turnsEl || !turnsEl.contains(range.commonAncestorContainer)) {
      selMenu = null;
      return;
    }
    // smart highlight: snap partial-word edges to whole words so saved
    // highlights always start and end cleanly
    const spans = [...turnsEl.querySelectorAll('.w')].filter((el) =>
      range.intersectsNode(el)
    );
    if (spans.length > 1) {
      const snapped = document.createRange();
      snapped.setStart(spans[0], 0);
      const lastNode = spans[spans.length - 1];
      snapped.setEnd(lastNode, lastNode.childNodes.length);
      sel.removeAllRanges();
      sel.addRange(snapped);
    }
    const anchor = selectionAnchor();
    if (!anchor) {
      selMenu = null;
      return;
    }
    const b = selBands[selBands.length - 1];
    selMenu = {
      x: Math.max(
        4,
        Math.min((b?.left ?? 0) + (b?.width ?? 0) - 44, (turnsEl?.clientWidth ?? 640) - 218)
      ),
      y: (b ? b.top + b.height : 0) + 8,
      ...anchor,
    };
  }

  function menuCopy() {
    if (selMenu) send({ type: 'copy', text: selMenu.text });
    selMenu = null;
  }

  function doHighlight(color) {
    if (!selMenu || !id) return;
    send({
      type: 'transcriptAnnotate',
      id,
      kind: 'highlight',
      text: selMenu.text,
      note: '',
      color,
      start: selMenu.start,
      end: selMenu.end,
    });
    selMenu = null;
    document.getSelection()?.removeAllRanges();
  }

  function startComment() {
    if (!selMenu) return;
    commentDraft = { ...selMenu, note: '' };
    selMenu = null;
  }

  function cancelComment() {
    commentDraft = null;
    document.getSelection()?.removeAllRanges();
  }

  function saveComment() {
    if (!commentDraft || !id) return;
    send({
      type: 'transcriptAnnotate',
      id,
      kind: 'comment',
      text: commentDraft.text,
      note: commentDraft.note,
      start: commentDraft.start,
      end: commentDraft.end,
    });
    commentDraft = null;
    document.getSelection()?.removeAllRanges();
  }

  function unannotate(annotationId) {
    if (id) send({ type: 'transcriptUnannotate', id, annotationId });
  }

  /** comment border-box click → jump to the note AND play from there */
  function openComment(a) {
    if (!a) return;
    if (t?.audioUrl) seekTo(a.start, true);
    jumpToComment(a);
  }

  /** comment margin marker → open the yours tab and reveal the note */
  let flashComment = $state(null);
  function jumpToComment(a) {
    if (!railOpen) setRailOpen(true);
    railTab = 'yours';
    flashComment = a.id;
    setTimeout(() => {
      document
        .getElementById('mine-' + a.id)
        ?.scrollIntoView({ block: 'center', behavior: 'smooth' });
    }, 480); // after the rail's fly-in transition
    setTimeout(() => {
      if (flashComment === a.id) flashComment = null;
    }, 2200);
  }


  /** the annotation overlapping a word, for painting highlights.
      comments paint as a NEUTRAL GREY highlight (not colourful) —
      highlights keep their saved colour. */
  function markFor(w) {
    const a = annotations.find((x) => w.start < x.end && w.end > x.start);
    if (a) return a.kind === 'comment' ? { ...a, color: '#9aa0a6' } : a;
    // live preview: the selected area greys out the moment the comment
    // draft opens, and reverts if the draft is cancelled
    if (commentDraft && w.start < commentDraft.end && w.end > commentDraft.start)
      return { color: '#9aa0a6' };
    return null;
  }

  function focusOnMount(node) {
    node.focus();
  }

  // ── copy for LLM: inline-tag annotated transcript ──────────────
  // per Claude's format advice: plain-text turns with speaker+timestamp
  // prefix, annotations as inline <highlight>/<comment> tags wrapped
  // around the EXACT spans (nested when overlapping), <>& escaped.
  const HL_COLOR_NAMES = {
    '#ffd43b': 'yellow',
    '#69db7c': 'green',
    '#4dabf7': 'blue',
    '#ff8787': 'coral',
    '#b197fc': 'purple',
  };

  function escapeXml(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  /** insert open/close tags around the marked char ranges, nesting
      overlapping marks instead of colliding */
  function applyMarks(text, marks) {
    if (!marks.length) return escapeXml(text);
    const sorted = [...marks].sort((a, b) => a.from - b.from || b.to - a.to);
    let out = '';
    let pos = 0;
    const open = [];
    const closeUpTo = (upto) => {
      while (open.length && open[open.length - 1].to <= upto) {
        const m = open.pop();
        out += escapeXml(text.slice(pos, m.to)) + m.close;
        pos = m.to;
      }
    };
    for (const m of sorted) {
      closeUpTo(m.from);
      if (m.from > pos) {
        out += escapeXml(text.slice(pos, m.from));
        pos = m.from;
      }
      out += m.open;
      open.push(m);
    }
    closeUpTo(Infinity);
    out += escapeXml(text.slice(pos));
    return out;
  }

  function turnToLLM(turn) {
    const words = wordsOf(turn);
    let text = '';
    const spans = [];
    for (const w of words) {
      const s = text.length;
      text += w.text + ' ';
      spans.push({ ws: w.start, we: w.end, s, e: s + w.text.length });
    }
    text = text.trimEnd();
    const marks = [];
    for (const a of annotations) {
      // NB: annotation payloads carry .start/.end (seconds), NOT .startSeconds
      if (a.end <= turn.start || a.start >= turn.end) continue;
      const inside = spans.filter(
        (sp) => sp.ws < a.end && sp.we > a.start
      );
      if (!inside.length) continue;
      const from = inside[0].s;
      const to = Math.min(inside[inside.length - 1].e, text.length);
      if (a.kind === 'comment') {
        const note = escapeXml(a.note || '').replace(/"/g, '&quot;');
        marks.push({
          from,
          to,
          open: `<comment${note ? ` note="${note}"` : ''}>`,
          close: '</comment>',
        });
      } else {
        const color = HL_COLOR_NAMES[(a.color || '').toLowerCase()] || 'yellow';
        marks.push({ from, to, open: `<highlight color="${color}">`, close: '</highlight>' });
      }
    }
    return `[${fmtDur(turn.start)}] ${spName(turn.speaker)}: ${applyMarks(text, marks)}`;
  }

  function copyForLLM() {
    if (!t || !turns.length) return;
    const name = (t.fileName || 'transcript').replace(/"/g, '&quot;');
    const text =
      `<transcript name="${name}" speakers="${speakers.length}">\n\n` +
      turns.map(turnToLLM).join('\n\n') +
      `\n</transcript>`;
    send({ type: 'copy', text });
    markCopied(t.id);
  }
  $effect(() => {
    if (!playing || activeTurnIdx < 0) return;
    // never yank the view mid-selection: smooth-scrolling back to the
    // active turn while the user drags a highlight elsewhere destroys
    // their selection ("only the playing clip can be highlighted")
    if (document.getSelection()?.type === 'Range') return;
    if (activeTurnIdx >= shown)
      shown = Math.min(filtered.length, activeTurnIdx + 25);
    const el = turnEls[activeTurnIdx];
    if (!el) return;
    // and don't scroll at all when the active turn is already on screen
    const col = contentColEl?.getBoundingClientRect();
    const rect = el.getBoundingClientRect();
    if (col && rect.top >= col.top && rect.bottom <= col.bottom) return;
    el.scrollIntoView({
      block: 'center',
      behavior: 'smooth',
    });
  });

  // reset when switching transcripts
  $effect(() => {
    id;
    playing = false;
    currentTime = 0;
    duration = 0;
    rate = 1;
    shown = TURN_PAGE;
    if (contentColEl) contentColEl.scrollTop = 0;
    const rail = document.querySelector('.ai-rail');
    if (rail) rail.scrollTop = 0;
  });

  // ── AI helpers ───────────────────────────────────────────────
  const aiTopics = $derived(t?.aiTopics ?? []);
  const _aiSections = $derived(t?.aiSections ?? []);
  const _aiQuotes = $derived(t?.aiQuotes ?? []);
  // normalize existing transcripts that were saved with hallucinated timestamps (e.g. all 00:00 or 07h+)
  //, new generations already clamp & redistribute via MeetingAIService, but this fixes display for old rows
  const aiSections = $derived.by(() => {
    const secs = _aiSections;
    if (secs.length <= 1) return secs;
    const dur =
      t?.durationSeconds || Math.max(...turns.map((x) => x.end), 0) || 0;
    const outOfBounds = secs.filter((s) => s.start > dur + 30).length;
    const dup = secs.filter(
      (s, i) => i > 0 && Math.abs(s.start - secs[i - 1].start) < 15
    ).length;
    if (outOfBounds === 0 && dup < secs.length / 2) return secs;
    // redistribute clustered / OOB entries proportionally
    const sorted = [...secs].sort((a, b) => a.start - b.start);
    return sorted
      .map((s, i) => {
        const needFix =
          s.start > dur + 30 ||
          (i > 0 && Math.abs(s.start - sorted[i - 1].start) < 15);
        if (!needFix) return s;
        const frac = i / Math.max(1, sorted.length - 1);
        const target = Math.round(frac * dur);
        const newPoints = (s.points ?? []).map((p) =>
          Math.abs(p.start - s.start) < 15 ? { ...p, start: target } : p
        );
        return {
          ...s,
          start: target,
          ts: `${String(Math.floor(target / 60)).padStart(2, '0')}:${String(target % 60).padStart(2, '0')}`,
          timestampLabel: `${String(Math.floor(target / 60)).padStart(2, '0')}:${String(target % 60).padStart(2, '0')}`,
          points: newPoints,
        };
      })
      .sort((a, b) => a.start - b.start);
  });
  const aiQuotes = $derived.by(() => {
    const dur =
      t?.durationSeconds || Math.max(...turns.map((x) => x.end), 0) || 0;
    return _aiQuotes.map((q) => {
      if (q.start <= dur + 30) return q;
      // clamp hallucinated 7h timestamps to end of meeting minus spread
      const idx = _aiQuotes.indexOf(q);
      const frac = idx / Math.max(1, _aiQuotes.length - 1);
      const target = Math.round(frac * dur * 0.9 + dur * 0.05);
      return {
        ...q,
        start: target,
        ts: `${String(Math.floor(target / 60)).padStart(2, '0')}:${String(target % 60).padStart(2, '0')}`,
      };
    });
  });
  // rail visibility, remembered across sessions, reopenable from the edge tab
  let railOpen = $state(
    (() => {
      try {
        return localStorage.getItem('typie:aiRailOpen') !== '0';
      } catch {
        return true;
      }
    })()
  );
  function setRailOpen(v) {
    railOpen = v;
    try {
      localStorage.setItem('typie:aiRailOpen', v ? '1' : '0');
    } catch {}
  }

  // ── resizable rail, grab the divider to widen/narrow the AI panel ──
  let railWidth = $state(
    (() => {
      try {
        const v = parseInt(localStorage.getItem('typie:aiRailWidth') || '', 10);
        if (Number.isFinite(v)) return Math.min(720, Math.max(300, v));
      } catch {}
      return 340;
    })()
  );
  let resizing = $state(false);
  const RAIL_MIN = 300,
    RAIL_MAX = 720;
  function clampRail(w) {
    return Math.min(RAIL_MAX, Math.max(RAIL_MIN, w));
  }
  function onResizeStart(e) {
    resizing = true;
    e.preventDefault();
    e.currentTarget.setPointerCapture?.(e.pointerId);
  }
  function onResizeMove(e) {
    if (!resizing) return;
    // rail hugs the right edge → width = distance from cursor to right side
    railWidth = clampRail(window.innerWidth - e.clientX);
  }
  function onResizeEnd() {
    if (!resizing) return;
    resizing = false;
    try {
      localStorage.setItem('typie:aiRailWidth', String(railWidth));
    } catch {}
  }
  function onResizeKey(e) {
    if (e.key === 'ArrowLeft') {
      railWidth = clampRail(railWidth + 24);
      onResizeEnd();
    } else if (e.key === 'ArrowRight') {
      railWidth = clampRail(railWidth - 24);
      onResizeEnd();
    } else if (e.key === 'Home') {
      railWidth = 340;
      onResizeEnd();
    } else return;
    e.preventDefault();
  }

  // the skeleton deserves an audience, present the rail when generation kicks off
  $effect(() => {
    if (aiAvailable && aiStatus === 'pending') setRailOpen(true);
  });

  const aiSummary = $derived(t?.aiSummary ?? '');
  const aiTitle = $derived(t?.aiTitle ?? '');
  const aiStatus = $derived(t?.aiStatus ?? '');
  const aiEngine = $derived(t?.aiEngine ?? '');
  const aiAvailable = $derived(ui.aiAvailable ?? false);
  // subtle in-context hint: only inside a conversation, only while the real
  // model is unavailable, quietly retireable
  const showAiBanner = $derived(
    !aiAvailable && (t?.turns?.length ?? 0) > 0 && !local.aiNudgeDismissed
  );
  function generateAI() {
    if (t) send({ type: 'transcriptGenerateAI', id: t.id });
  }
  function clearAI() {
    if (t) send({ type: 'transcriptClearAI', id: t.id });
  }

  // esc returns to the library (unless a speaker rename is in progress)
  function onKeydown(e) {
    if (e.key === 'Escape' && renaming == null) onBack();
  }
</script>

<svelte:window onkeydown={onKeydown} />

{#if !t}
  <div class="missing">
    <p>transcript not found.</p>
    <button
      class="btn btn-ghost small"
      onclick={onBack}>← back</button
    >
  </div>
{:else}
  <div
    class="wrap"
    class:split={aiAvailable}
    class:rail-open={railVisible}
    class:resizing
  >
    <div class="cols">
      <div
        class="content-col"
        bind:this={contentColEl}
      >
        <!-- sticky header: arrow + title + exports on one line -->
        <header>
          <div class="titlerow">
            <button
              class="back-arrow"
              onclick={onBack}
              aria-label="back"><ArrowLeft size={18} /></button
            >
            <div class="titleblock">
              <h2>
                <InlineEdit
                  value={t.fileName}
                  size="lg"
                  onSave={(v) =>
                    send({ type: 'transcriptsRename', id: t.id, name: v })}
                />
              </h2>
              <p class="meta mono-kicker">
                {fmtDate(t.date)} · {fmtDur(duration || t.durationSeconds)} · {speakers.length}
                speaker{speakers.length === 1 ? '' : 's'}{t.isMeeting
                  ? ' · call'
                  : ''}
              </p>
            </div>
            <div class="exports">
              <button
                class="btn btn-ghost small"
                onclick={() =>
                  send({ type: 'transcriptExport', id: t.id, format: 'md' })}
                ><Download size={13} /> .md</button
              >
              <button
                class="btn btn-ghost small"
                onclick={() =>
                  send({ type: 'transcriptExport', id: t.id, format: 'txt' })}
                ><Download size={13} /> .txt</button
              >
              <button
                class="btn btn-ghost small"
                onclick={copyForLLM}
                title="copy for LLM — transcript with your highlights & comments inline"
                aria-label="copy for LLM"
                ><ClaudeIcon size={14} /><GptIcon size={13} /> copy for LLM</button
              >
              {#if aiAvailable || annotations.length > 0}
                <button
                  class="rail-toggle"
                  onclick={() => setRailOpen(!railOpen)}
                  title={railOpen
                    ? 'hide panel'
                    : 'show panel · AI summary, highlights & comments'}
                  aria-label="toggle panel"
                  ><PanelRight size={14} /></button
                >
              {/if}
            </div>
          </div>
        </header>

        <div class="filters">
          <label class="input search">
            <Search size={14} />
            <input
              bind:value={query}
              placeholder="search this transcript…"
              spellcheck="false"
            />
          </label>

          <!-- Apple Intelligence hint, sits between search and speakers, only
         while the model is unavailable; ✕ hides it for this session only -->
          {#if showAiBanner}
            <div class="ai-banner card">
              <Sparkles size={13} />
              <span
                ><b>want summaries & topics?</b> enable Apple Intelligence in System
                Settings.</span
              >
              <button
                class="banner-x"
                onclick={dismissAiNudge}
                aria-label="dismiss"><X size={12} /></button
              >
            </div>
          {/if}

          <!-- speaker legend -->
          {#if speakers.length > 0}
            <div class="legend">
              {#each speakers as i (i)}
                {#if renaming === i}
                  <span
                    class="speaker pill editing"
                    style="--c:{spColor(i)}"
                  >
                    <input
                      bind:value={renameVal}
                      onkeydown={(e) => {
                        if (e.key === 'Enter') saveRename();
                        if (e.key === 'Escape') renaming = null;
                      }}
                      spellcheck="false"
                    />
                    <button
                      class="ok"
                      onclick={saveRename}><Check size={12} /></button
                    >
                  </span>
                {:else}
                  <button
                    class="speaker pill"
                    style="--c:{spColor(i)}"
                    title="click to rename"
                    onclick={() => startRename(i)}
                  >
                    <i></i>{spName(i)}
                    <Pencil size={10} />
                  </button>
                {/if}
              {/each}
            </div>
          {/if}
        </div>

        <!-- transcript, otter-style blocks -->
        {#if turns.length === 0}
          <div class="pending">
            <span class="hand big"
              >recording saved, the words are on their way…</span
            >
            <p class="mono-kicker">
              transcription + speaker labels land here automatically
            </p>
          </div>
        {:else}
          <div
            class="turns"
            bind:this={turnsEl}
            onmouseup={onTurnsMouseUp}
          >
            {#if !commentDraft}<div class="selband-wrap" aria-hidden="true">
              {#each selBands as b, i (i)}
                <div
                  class="selband"
                  style="top:{b.top}px;left:{b.left}px;width:{b.width}px;height:{b.height}px"
                ></div>
              {/each}
            </div>{/if}
            {#if selMenu}
              <!-- mousedown prevented so picking a colour doesn't collapse
                   the selection before the click lands -->
              <div
                class="selmenu"
                style="left:{selMenu.x}px;top:{selMenu.y}px"
                onmousedown={(e) => e.preventDefault()}
                role="toolbar"
                aria-label="selection actions"
              >
                <button
                  class="sm-act"
                  onclick={menuCopy}
                  title="copy"
                  ><Copy size={13} /></button
                >
                {#each HL_COLORS as c (c)}
                  <button
                    class="sm-swatch"
                    style="background:{c}"
                    title="highlight"
                    onclick={() => doHighlight(c)}
                  ></button>
                {/each}
                <button
                  class="sm-act"
                  onclick={startComment}
                  title="comment"
                  ><MessageSquarePlus size={13} /></button
                >
              </div>
            {:else if commentDraft}
              <div
                class="selmenu draft"
                style="left:{commentDraft.x}px;top:{commentDraft.y}px"
              >
                <textarea
                  rows="3"
                  placeholder="add a note…"
                  bind:value={commentDraft.note}
                  use:focusOnMount
                  onkeydown={(e) => {
                    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) saveComment();
                    if (e.key === 'Escape') cancelComment();
                  }}
                ></textarea>
                <div class="draft-row">
                  <span class="draft-hint mono-kicker">⌘↵ save</span>
                  <button class="btn btn-ghost small" onclick={cancelComment}
                    >cancel</button
                  >
                  <button class="btn small" onclick={saveComment}>save</button>
                </div>
              </div>
            {/if}
            {#each visibleTurns as turn, idx (idx)}
              {@const turnHits = hitSet(turn)}
              {@const turnComments = annotations.filter(
                (a) => a.kind === 'comment' && a.start < turn.end && a.end > turn.start
              )}
              {@const isNow = t.audioUrl && turn === activeTurn}
              <div
                class="oturn"
                class:now={isNow}
                bind:this={turnEls[idx]}
              >
                <div class="ohead">
                  <img
                    class="avatar"
                    src={avatarUri(turn.speaker)}
                    alt={spName(turn.speaker)}
                  />
                  <!-- renameable right here, not just from the top legend -->
                  <InlineEdit
                    value={spName(turn.speaker)}
                    onSave={(name) =>
                      t &&
                      send({
                        type: 'transcriptsRenameSpeaker',
                        id: t.id,
                        index: turn.speaker,
                        name,
                      })}
                  />
                  <button
                    class="ts mono-kicker"
                    title={t.audioUrl ? 'play from here' : undefined}
                    onclick={() => t.audioUrl && seekTo(turn.start, true)}
                  >
                    {fmtDur(turn.start)}
                  </button>
                  {#if turnComments.length}
                    <button
                      class="cmark"
                      onclick={() => openComment(turnComments[0])}
                      title={turnComments[0].note || 'comment — see yours tab'}
                      aria-label="jump to comment"
                    >
                      <MessageSquarePlus size={11} />
                      {#if turnComments.length > 1}
                        <span class="cmark-n mono-kicker">{turnComments.length}</span>
                      {/if}
                    </button>
                  {/if}
                  {#if isNow}<span class="eq"><i></i><i></i><i></i></span>{/if}
                </div>
                <p class="otext">
                  {#each wordsOf(turn) as w, wi (wi)}{@const mk = markFor(w)}<span class="w" class:hit={!mk && turnHits?.has(wi)} class:marked={!!mk} style={mk ? `--mk:${mk.color || '#ffd43b'}` : undefined} class:on={t.audioUrl && currentTime >= w.start && currentTime < w.end} data-s={w.start} data-e={w.end} onclick={() => t.audioUrl && seekTo(w.start, true)}>{w.text}{' '}</span>{/each}
                </p>
              </div>
            {/each}
            {#if filtered.length === 0}
              <p class="nomatch hand">no matches for “{query}”…</p>
            {/if}

            {#if visibleTurns.length < filtered.length}
              <button
                class="more"
                use:infinite={() => (shown += TURN_PAGE)}
                onclick={() => (shown += TURN_PAGE)}
              >
                show more · {filtered.length - visibleTurns.length} blocks left
              </button>
            {/if}
          </div>
        {/if}
      </div>
      <!-- /.content-col -->

      {#if railVisible}
        <!-- drag divider, grab to resize the AI panel -->
        <div
          class="rail-resize"
          class:active={resizing}
          role="separator"
          aria-orientation="vertical"
          aria-label="resize AI panel"
          tabindex="0"
          title="drag to resize · double-click to reset"
          onpointerdown={onResizeStart}
          onpointermove={onResizeMove}
          onpointerup={onResizeEnd}
          onpointercancel={onResizeEnd}
          onkeydown={onResizeKey}
          ondblclick={() => {
            railWidth = 340;
            onResizeEnd();
          }}
        ></div>
        <aside
          class="ai-rail"
          class:yours-tab={railTab === 'yours' || !aiAvailable}
          style="width:{railWidth}px"
          transition:fly={{ x: 380, duration: 420, easing: cubicOut }}
        >
          <!-- one section at a time: AI or the user's own marks.
               bits-ui Tabs primitive — accessible, keyboard-navigable,
               styles carried by our own classes (headless pattern) -->
          <Tabs.Root value={railTab} onValueChange={(v) => { if (v) railTab = v; }}>
            <Tabs.List class="rail-tabs">
              {#if aiAvailable}
                <Tabs.Trigger
                  value="ai"
                  class="rail-tab {railTab === 'ai' ? 'active' : ''}"
                >
                  <Sparkles size={12} /> AI
                </Tabs.Trigger>
              {/if}
              <Tabs.Trigger
                value="yours"
                class="rail-tab {railTab === 'yours' || !aiAvailable ? 'active' : ''}"
              >
                yours
                {#if sortedAnnotations.length > 0}
                  <span class="tab-count mono-kicker"
                    >{sortedAnnotations.length}</span
                  >
                {/if}
              </Tabs.Trigger>
            </Tabs.List>
          </Tabs.Root>

          {#if railTab === 'yours' || !aiAvailable}
          <div class="mine card">
            <div class="mine-head">
              <h4 class="rail-kicker">yours</h4>
            </div>
            {#if sortedAnnotations.length === 0}
              <p class="mine-empty">
                select text in the transcript to highlight it in one of five
                colours or leave a comment
              </p>
            {:else}
              <div class="mine-list">
                {#each sortedAnnotations as a (a.id)}
                  <div
                    id="mine-{a.id}"
                    class="mine-item"
                    class:comment={a.kind === 'comment'}
                    class:flash={flashComment === a.id}
                  >
                    {#if a.kind === 'comment'}
                      <span class="mine-tag mono-kicker" title="your comment"
                        >comment</span
                      >
                    {:else}
                      <span
                        class="mine-dot"
                        style="background:{a.color || '#ffd43b'}"
                      ></span>
                    {/if}
                    <div class="mine-body">
                      <button
                        class="mine-ts mono-kicker"
                        onclick={() => seekTo(a.start, true)}
                        title="play from here"
                      >
                        {fmtDur(a.start)}
                      </button>
                      {#if a.text && a.kind !== 'comment'}
                        <p class="mine-quote">“{a.text}”</p>
                      {/if}
                      {#if a.note}
                        <p class="mine-note">{a.note}</p>
                      {/if}
                    </div>
                    <button
                      class="mine-del"
                      onclick={() => unannotate(a.id)}
                      title="remove"
                      ><X size={11} /></button
                    >
                  </div>
                {/each}
              </div>
            {/if}
          </div>
          {/if}

          {#if aiAvailable && railTab === 'ai'}
          <div class="ai card">
            <div class="ai-head">
              {#if aiEngine === 'heuristic'}
                <span
                  class="ai-badge"
                  title="generated locally without the language model, enable Apple Intelligence for real summaries"
                  ><Sparkles size={13} /> local heuristic</span
                >
              {:else}
                <span class="ai-badge"><Sparkles size={13} /> on-device AI</span
                >
              {/if}
              <span class="rail-actions">
                {#if aiStatus === 'pending'}
                  <span class="mono-kicker ai-pending"
                    ><Loader2 size={12} /> generating…</span
                  >
                {:else if aiSummary}
                  <button
                    class="btn btn-ghost small ai-regen"
                    onclick={generateAI}
                    title="regenerate"><Wand2 size={12} /></button
                  >
                {:else if aiStatus === 'failed'}
                  <span
                    class="mono-kicker"
                    style="color:var(--red-ink)">failed</span
                  >
                {/if}
              </span>
            </div>

            {#if aiStatus === 'pending'}
              <!-- skeleton, the shape of what's coming, shimmering -->
              <div
                class="skel"
                aria-hidden="true"
              >
                <div class="skel-line w60 title"></div>
                <div class="skel-line"></div>
                <div class="skel-line w80"></div>
                <div class="skel-line w70"></div>
                {#each [0, 1, 2] as i}
                  <div class="skel-sec">
                    <div class="skel-line w50"></div>
                    <div class="skel-point">
                      <i></i>
                      <div class="skel-line w90"></div>
                    </div>
                    <div class="skel-point">
                      <i></i>
                      <div class="skel-line w75"></div>
                    </div>
                    <div class="skel-point">
                      <i></i>
                      <div class="skel-line w85"></div>
                    </div>
                  </div>
                {/each}
                <div class="skel-line w40"></div>
                <div class="skel-quote"></div>
                <div class="skel-quote"></div>
              </div>
            {:else if aiSummary || aiSections.length > 0}
              {#if aiTitle}<h3 class="ai-title">{aiTitle}</h3>{/if}
              {#if aiSummary}<p class="ai-summary">{aiSummary}</p>{/if}

              {#if aiSections.length > 0}
                <div class="ai-breakdown">
                  <h4 class="rail-kicker">breakdown</h4>
                  {#each aiSections as section, si (si + ':' + section.title + section.start)}
                    <div class="ai-section">
                      <button
                        class="sec-head"
                        onclick={() => seekTo(section.start, true)}
                        title="play from {section.timestampLabel}"
                      >
                        <Clock size={11} />
                        <span class="sec-ts mono-kicker"
                          >{section.timestampLabel}</span
                        >
                        <span class="sec-title">{section.title}</span>
                      </button>
                      {#if section.points?.length > 0}
                        <ul class="sec-points">
                          {#each section.points as point, pi (pi + ':' + point.text + point.start)}
                            <li>
                              <button
                                onclick={() => seekTo(point.start, true)}
                                title="play from here"
                              >
                                <span class="pt-ts mono-kicker"
                                  >{fmtDur(point.start)}</span
                                >
                                <span class="pt-text">{point.text}</span>
                              </button>
                            </li>
                          {/each}
                        </ul>
                      {/if}
                    </div>
                  {/each}
                </div>
              {:else if aiTopics.length > 0}
                <div class="ai-topics">
                  {#each aiTopics as topic, ti (ti + ':' + topic.title + topic.start)}
                    <button
                      class="topic pill"
                      onclick={() => seekTo(topic.start, true)}
                      title={topic.summary}
                    >
                      <Clock size={11} />
                      {fmtDur(topic.start)} · {topic.title}
                    </button>
                  {/each}
                </div>
              {/if}

              {#if aiQuotes.length > 0}
                <div class="ai-quotes">
                  <h4 class="rail-kicker">key quotes</h4>
                  {#each aiQuotes as quote, qi (qi + ':' + quote.text + quote.start)}
                    <button
                      class="quote"
                      onclick={() => seekTo(quote.start, true)}
                      title="play from {quote.ts}"
                    >
                      <span class="q-text">“{quote.text}”</span>
                      <span class="q-meta mono-kicker"
                        >{quote.speaker || '–'} · {quote.ts}</span
                      >
                    </button>
                  {/each}
                </div>
              {/if}
            {:else}
              <p class="ai-empty">no summary yet</p>
              <button
                class="btn btn-pink small"
                onclick={generateAI}
                ><Sparkles size={13} /> summarize with Apple Intelligence</button
              >
            {/if}
          </div>
          {/if}
        </aside>
      {/if}
    </div>
    <!-- /.cols -->

    <!-- bottom bar: static, stuck to viewport bottom like header -->
    {#if t.audioUrl}
      <div class="dock">
        <button
          class="play"
          onclick={togglePlay}
        >
          {#if playing}<Pause size={16} />{:else}<Play size={16} />{/if}
        </button>
        <span class="time mono-kicker now">{fmtClock(currentTime)}</span>

        <div
          class="seek-track"
          role="slider"
          tabindex="0"
          aria-label="seek"
          onkeydown={(e) => {
            if (e.key === 'ArrowRight') seekTo(currentTime + 5);
            if (e.key === 'ArrowLeft') seekTo(currentTime - 5);
          }}
          onclick={(e) =>
            seekTo(
              ((e.clientX - e.currentTarget.getBoundingClientRect().left) /
                e.currentTarget.getBoundingClientRect().width) *
                (duration || t.durationSeconds)
            )}
        >
          {#each filtered as seg}
            {@const left =
              (seg.start / Math.max(1, duration || t.durationSeconds)) * 100}
            {@const width = Math.max(
              0.4,
              ((seg.end - seg.start) /
                Math.max(1, duration || t.durationSeconds)) *
                100
            )}
            <div
              class="seek-seg"
              style="left:{left}%; width:{width}%; background:{spColor(
                seg.speaker
              )}"
            ></div>
          {/each}
          <div
            class="seek-head"
            style="left:{(duration ? currentTime / duration : 0) * 100}%"
          >
            <i></i>
          </div>
        </div>

        <span class="time mono-kicker dim"
          >{fmtClock(duration || t.durationSeconds)}</span
        >
        <div class="rates">
          {#each [0.75, 1, 1.5, 2] as r (r)}
            <button
              class="rate"
              class:on={rate === r}
              onclick={() => setRate(r)}>{r}×</button
            >
          {/each}
        </div>

        <audio
          bind:this={audioEl}
          src={t.audioUrl}
          onplay={onPlay}
          onpause={onStop}
          onended={onStop}
          ontimeupdate={() => {
            if (!playing && audioEl) currentTime = audioEl.currentTime;
          }}
          onloadedmetadata={() => {
            duration = audioEl.duration || t.durationSeconds;
          }}
          preload="metadata"
        ></audio>
      </div>
    {:else}
      <p class="noaudio hand">this one was saved without audio, text only.</p>
    {/if}
  </div>
{/if}

<style>
  .wrap {
    max-width: 880px;
    margin: 0 auto;
    /* fixed app frame: header pinned to the top, audio dock pinned to the
       bottom, only the conversation scrolls — even when the transcript is
       short. The outer .content container never scrolls here. */
    height: 100vh;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  /* with the rail open the conversation splits into two independent scroll panes */
  .wrap.split {
    max-width: none;
    transition: none;
  }

  /* ── availability hint, reuses the shared .card component ── */
  .ai-banner {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 10px 14px;
    background: rgba(252, 86, 129, 0.06);
    border: 1px dashed rgba(252, 86, 129, 0.3);
    font-size: 12px;
    color: var(--text-2);
    animation: nudge-in 0.4s var(--ease-out) both;
  }
  .ai-banner :global(svg) {
    color: var(--hotpink);
    flex-shrink: 0;
  }
  .ai-banner b {
    color: var(--hotpink);
    font-weight: 700;
  }
  .banner-x {
    margin-left: auto;
    display: inline-grid;
    place-items: center;
    width: 20px;
    height: 20px;
    border-radius: 7px;
    color: var(--text-3);
    flex-shrink: 0;
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .banner-x:hover {
    background: var(--wash);
    color: var(--ink);
  }
  @keyframes nudge-in {
    from {
      opacity: 0;
      transform: translateY(-6px);
    }
    to {
      opacity: 1;
      transform: none;
    }
  }

  /* ── two-column layout: conversation + AI rail ── */
  .cols {
    display: flex;
    flex-direction: column;
    flex: 1;
    min-height: 0;
  }
  .wrap.split .cols {
    flex-direction: row;
    gap: 0;
    align-items: stretch;
    flex: 1;
    min-height: 0;
    overflow: hidden;
  }
  .content-col {
    min-width: 0;
    flex: 1;
    overflow-y: auto;
    overscroll-behavior: contain;
    /* NO top padding: the sticky header must be the first pixel of the
       scroll container. WebKit constrains sticky to the padding box, so a
       padding-top here left a gap above the pinned header. The header's own
       padding provides the spacing; 32px bottom = breathing room above the
       dock (the dock sits below .cols, not over the text) */
    padding: 0 32px 32px;
  }
  .ai-rail {
    position: relative;
    top: auto;
    right: auto;
    bottom: auto;
    z-index: 5;
    flex-shrink: 0;
    align-self: stretch;
    max-height: 100%;
    background: var(--paper);
    border-left: 1px solid var(--line);
    padding: 24px 20px 100px;
    overflow-y: auto;
    overscroll-behavior: contain;
  }
  /* yours tab: the card stretches rail-top to the very bottom and the
     list scrolls inside it, instead of floating mid-panel */
  .ai-rail.yours-tab {
    display: flex;
    flex-direction: column;
    padding-bottom: 24px;
  }
  :global(.ai-rail.yours-tab .rail-tabs) {
    flex-shrink: 0;
  }
  .ai-rail.yours-tab .mine {
    flex: 1 1 0;
    min-height: 0;
    display: flex;
    flex-direction: column;
    margin-bottom: 0;
  }
  .ai-rail.yours-tab .mine-list {
    flex: 1;
    min-height: 0;
    max-height: none;
    overflow-y: auto;
  }
  .rail-resize {
    position: relative;
    z-index: 6;
    width: 9px;
    margin-left: -4px;
    flex-shrink: 0;
    cursor: col-resize;
    touch-action: none;
  }
  .rail-resize::after {
    content: '';
    position: absolute;
    top: 0;
    bottom: 0;
    left: 3px;
    width: 3px;
    border-radius: 99px;
    background: var(--line);
    transition:
      background 0.18s var(--ease-out),
      opacity 0.18s var(--ease-out);
    opacity: 0.6;
  }
  .rail-resize:hover::after {
    background: var(--hotpink);
    opacity: 0.55;
  }
  .rail-resize.active::after {
    background: var(--hotpink);
    opacity: 0.85;
  }
  .wrap.resizing {
    cursor: col-resize;
    user-select: none;
  }
  .wrap.resizing .content-col,
  .wrap.resizing .ai-rail {
    pointer-events: none;
  }
  /* the panel is the surface, the card inside goes completely flat.
     no cream, no mint gradient, no card chrome. */
  .ai-rail .card,
  .ai-rail .ai {
    background: transparent;
    border: none;
    box-shadow: none;
    padding: 0;
    margin: 0;
  }
  .rail-actions {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .rail-close {
    display: inline-grid;
    place-items: center;
    width: 24px;
    height: 24px;
    border-radius: 8px;
    color: var(--text-3);
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .rail-close:hover {
    background: var(--wash);
    color: var(--ink);
  }

  /* ── skeleton, shimmering placeholder while the model thinks ── */
  .skel {
    display: flex;
    flex-direction: column;
    gap: 9px;
    margin-top: 4px;
  }
  .skel-line {
    height: 11px;
    border-radius: 6px;
    background: linear-gradient(
      90deg,
      var(--wash) 25%,
      var(--wash-strong) 45%,
      var(--wash) 65%
    );
    background-size: 220% 100%;
    animation: shimmer 1.5s linear infinite;
  }
  .skel-line.title {
    height: 16px;
  }
  .skel-line.w40 {
    width: 40%;
  }
  .skel-line.w50 {
    width: 50%;
  }
  .skel-line.w60 {
    width: 60%;
  }
  .skel-line.w70 {
    width: 70%;
  }
  .skel-line.w75 {
    width: 75%;
  }
  .skel-line.w80 {
    width: 80%;
  }
  .skel-line.w85 {
    width: 85%;
  }
  .skel-line.w90 {
    width: 90%;
  }
  .skel-sec {
    margin-top: 8px;
    padding: 10px 12px;
    border: 1px dashed var(--line);
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .skel-point {
    display: flex;
    align-items: center;
    gap: 7px;
  }
  .skel-point i {
    width: 5px;
    height: 5px;
    border-radius: 99px;
    background: var(--line-strong);
    flex-shrink: 0;
  }
  .skel-point .skel-line {
    flex: 1;
    max-width: none;
    width: auto;
  }
  .skel-quote {
    margin-top: 4px;
    padding: 11px 12px;
    border-left: 3px solid var(--pink);
    border-radius: 0 10px 10px 0;
    background: rgba(252, 86, 129, 0.05);
    height: 44px;
  }
  @keyframes shimmer {
    from {
      background-position: 120% 0;
    }
    to {
      background-position: -100% 0;
    }
  }

  /* ── breakdown tree ── */
  .rail-kicker {
    font-family: var(--mono);
    font-size: 9.5px;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    color: var(--text-3);
    margin: 14px 0 8px;
  }
  .ai-breakdown {
    display: flex;
    flex-direction: column;
  }
  .ai-section {
    margin-bottom: 10px;
  }
  .sec-head {
    display: flex;
    align-items: center;
    gap: 7px;
    width: 100%;
    text-align: left;
    padding: 6px 9px;
    border-radius: 9px;
    color: var(--hotpink);
    transition: background 0.15s var(--ease-out);
  }
  .sec-head:hover {
    background: rgba(252, 86, 129, 0.08);
  }
  .sec-ts {
    color: var(--text-3);
  }
  .sec-title {
    font-size: 13px;
    font-weight: 800;
    color: var(--ink);
  }
  .sec-points {
    list-style: none;
    margin: 2px 0 0;
    padding: 0 0 0 10px;
    border-left: 2px solid var(--line);
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .sec-points button {
    display: flex;
    gap: 7px;
    width: 100%;
    text-align: left;
    padding: 4px 8px;
    border-radius: 8px;
    transition: background 0.15s var(--ease-out);
  }
  .sec-points button:hover {
    background: var(--wash);
  }
  .pt-ts {
    color: var(--text-3);
    flex-shrink: 0;
    padding-top: 2px;
  }
  .pt-text {
    font-size: 12px;
    line-height: 1.5;
    color: var(--text-2);
  }

  /* ── key quotes ── */
  .ai-quotes {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .quote {
    display: flex;
    flex-direction: column;
    gap: 5px;
    text-align: left;
    padding: 10px 12px;
    border-left: 3px solid var(--pink);
    border-radius: 0 10px 10px 0;
    background: rgba(252, 86, 129, 0.05);
    transition:
      background 0.15s var(--ease-out),
      transform 0.15s var(--spring, ease);
  }
  .quote:hover {
    background: rgba(252, 86, 129, 0.1);
    transform: translateX(2px);
  }
  .q-text {
    font-size: 12px;
    line-height: 1.5;
    color: var(--ink);
    font-weight: 500;
  }
  .q-meta {
    color: var(--text-3);
  }
  /* ── sticky header, pinned to top of viewport ──
     first child of .content-col (which has no top padding), so top: 0 pins
     it truly flush — no negative-margin trick to fight the scroll container */
  header {
    position: sticky;
    top: 0;
    z-index: 30;
    margin: 0 -32px 14px;
    padding: 16px 32px 12px;
    background: var(--surface);
    backdrop-filter: blur(12px);
    border-bottom: 1px solid var(--line);
  }
  .missing {
    padding: 60px;
    text-align: center;
    display: flex;
    flex-direction: column;
    gap: 14px;
    align-items: center;
  }

  .back-arrow {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 32px;
    height: 32px;
    border-radius: 999px;
    color: var(--text-2);
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .back-arrow:hover {
    background: var(--wash);
    color: var(--ink);
  }
  .back-arrow:active {
    transform: scale(0.96);
  }

  .titlerow {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .titleblock {
    flex: 1;
    min-width: 0;
  }
  h2 :global(.ie .txt) {
    white-space: normal;
  }
  h2 :global(.ie input) {
    font-size: 22px;
    font-weight: 800;
    letter-spacing: -0.02em;
  }
  .meta {
    margin-top: 4px;
  }

  .exports {
    display: flex;
    gap: 8px;
    flex-shrink: 0;
  }
  .filters {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
    margin-top: 2px;
  }
  .search {
    max-width: 420px;
  }

  .legend {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 14px;
  }
  .pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 999px;
    background: var(--paper);
    border: 1px solid var(--line);
    font-size: 12px;
    font-weight: 600;
    color: var(--ink);
    transition:
      border-color 0.18s var(--ease-out),
      transform 0.18s var(--spring);
  }
  button.pill:hover {
    border-color: var(--c);
    transform: translateY(-1px);
  }
  .pill i {
    width: 9px;
    height: 9px;
    border-radius: 99px;
    background: var(--c);
    flex-shrink: 0;
  }
  .pill svg {
    opacity: 0.4;
  }
  .pill.editing {
    gap: 4px;
    padding-right: 6px;
  }
  .pill.editing input {
    width: 110px;
    background: none;
    border: none;
    outline: none;
    font-size: 12px;
    font-weight: 600;
    color: var(--ink);
    user-select: text;
  }
  .pill .ok {
    display: grid;
    place-items: center;
    width: 22px;
    height: 22px;
    border-radius: 99px;
    color: var(--green-deep);
  }
  .pill .ok:hover {
    background: var(--card-mint);
  }

  /* ── otter-style blocks ── */
  .turns {
    position: relative;
    margin-top: 26px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding-bottom: 8px;
  }

  .oturn {
    position: relative;
    padding: 10px 14px 11px;
    border-radius: 14px;
    border: 1px solid transparent;
    transition:
      background 0.2s var(--ease-out),
      border-color 0.2s var(--ease-out);
  }
  .oturn:hover {
    background: var(--paper);
  }
  /* active turn: background tint only — no border, no weight changes,
     nothing that makes the text reflow while it's speaking */
  .oturn.now {
    background: color-mix(in srgb, var(--hotpink) 5%, transparent);
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
    width: 26px;
    height: 26px;
    border-radius: 8px;
    flex-shrink: 0;
    color: #fff;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 0;
  }
  .oname {
    font-size: 13px;
    font-weight: 700;
    color: var(--ink);
  }
  .ts {
    cursor: pointer;
    opacity: 0.55;
    letter-spacing: 0.05em;
    transition:
      opacity 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .ts:hover {
    opacity: 1;
    color: var(--hotpink);
    text-decoration: underline;
  }
  .eq {
    display: inline-flex;
    gap: 2px;
    height: 9px;
    align-items: flex-end;
  }
  .eq i {
    width: 3px;
    background: var(--hotpink);
    border-radius: 2px;
    animation: eq 0.7s ease-in-out infinite;
  }
  .eq i:nth-child(1) {
    animation-delay: 0s;
  }
  .eq i:nth-child(2) {
    animation-delay: 0.18s;
  }
  .eq i:nth-child(3) {
    animation-delay: 0.36s;
  }
  @keyframes eq {
    50% {
      height: 3px;
    }
    0%,
    100% {
      height: 9px;
    }
  }

  .otext {
    font-size: 15px;
    line-height: 1.85;
    color: var(--text-1);
    user-select: text;
    overflow-wrap: anywhere;
    /* native selection paint is replaced by the continuous selband
       overlay; keep the selection itself functional for copy/paste */
  }
  .otext ::selection {
    background: transparent;
    color: inherit;
  }
  .selband-wrap {
    position: absolute;
    inset: 0;
    pointer-events: none;
    /* turn cards are position:relative and would otherwise paint over the
       bands — and .oturn:hover's opaque background made highlights
       invisible everywhere except the playing turn */
    z-index: 25;
  }
  .selband {
    position: absolute;
    background: var(--hotpink);
    opacity: 0.24;
    border-radius: 7px;
    transition:
      left 0.13s var(--ease-out),
      width 0.13s var(--ease-out),
      top 0.1s var(--ease-out),
      height 0.1s var(--ease-out),
      opacity 0.16s var(--ease-out);
  }

  /* floating selection toolbar — same tokens as .card */
  .selmenu {
    position: absolute;
    z-index: 30;
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 6px 8px;
    background: var(--cream);
    border: 1px solid var(--line);
    border-radius: var(--radius-card, 12px);
    box-shadow: 0 2px 10px var(--shadow-card);
  }
  .sm-act {
    display: grid;
    place-items: center;
    width: 26px;
    height: 26px;
    border-radius: 8px;
    color: var(--text-2);
    transition:
      background 0.12s var(--ease-out),
      color 0.12s var(--ease-out);
  }
  .sm-act:hover {
    background: var(--hotpink);
    color: #fff;
  }
  .sm-swatch {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    border: 2px solid rgba(0, 0, 0, 0.08);
    transition:
      transform 0.12s var(--ease-out),
      box-shadow 0.12s var(--ease-out);
  }
  .sm-swatch:hover {
    transform: scale(1.25);
    box-shadow: 0 0 0 2px var(--line);
  }
  .selmenu.draft {
    flex-direction: column;
    align-items: stretch;
    gap: 6px;
    width: 250px;
    border-radius: 18px;
    border-bottom-left-radius: 5px;
    padding: 10px 10px 8px;
  }
  /* comic speech-bubble tail pointing back at the selection */
  .selmenu.draft::before {
    content: '';
    position: absolute;
    top: -6px;
    left: 16px;
    width: 12px;
    height: 12px;
    background: var(--cream);
    border-top: 1px solid var(--line);
    border-left: 1px solid var(--line);
    transform: rotate(45deg);
    border-top-left-radius: 3px;
  }
  .selmenu.draft textarea {
    font: inherit;
    font-size: 13px;
    color: var(--text-1);
    background: var(--page);
    border: 1px solid var(--line-strong);
    border-radius: 8px;
    padding: 7px 9px;
    resize: vertical;
  }
  .selmenu.draft textarea:focus {
    outline: none;
    border-color: var(--hotpink);
  }
  .draft-row {
    display: flex;
    align-items: center;
    gap: 8px;
    justify-content: flex-end;
  }
  .draft-hint {
    margin-right: auto;
    color: var(--text-3);
  }

  /* panel toggle: quiet ghost icon, no border, no box */
  .rail-toggle {
    display: grid;
    place-items: center;
    width: 28px;
    height: 28px;
    border: none;
    border-radius: 8px;
    color: var(--text-3);
    transition:
      color 0.15s var(--ease-out),
      background 0.15s var(--ease-out);
  }
  .rail-toggle:hover {
    color: var(--text-1);
    background: var(--paper);
  }
  /* rail section tabs: AI | yours — one thing at a time */
  :global(.rail-tabs) {
    display: flex;
    gap: 6px;
    margin-bottom: 12px;
  }
  :global(.rail-tab) {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 12.5px;
    font-weight: 600;
    color: var(--text-3);
    background: transparent;
    border: 1px solid var(--line);
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out),
      border-color 0.15s var(--ease-out);
  }
  :global(.rail-tab:hover) {
    color: var(--text-1);
  }
  :global(.rail-tab.active) {
    background: var(--hotpink);
    border-color: var(--hotpink);
    color: var(--on-accent, #fff);
  }
  :global(.tab-count) {
    background: rgba(0, 0, 0, 0.14);
    border-radius: 999px;
    padding: 1px 7px;
    font-size: 10px;
  }
  :global(.rail-tab:not(.active) .tab-count) {
    background: var(--paper, var(--page));
    color: var(--text-3);
  }

  /* the "yours" rail card: highlights + comments */
  .mine {
    margin-bottom: 14px;
  }
  .mine-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
  }
  .mine-empty {
    font-size: 12.5px;
    line-height: 1.5;
    color: var(--text-3);
  }
  .mine-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    max-height: 300px;
    overflow-y: auto;
  }
  .mine-item {
    display: flex;
    gap: 8px;
    align-items: flex-start;
    padding: 8px 9px;
    border-radius: 10px;
    background: var(--page);
    transition: background 0.12s var(--ease-out);
  }
  /* comments read as speech bubbles, clearly distinct from highlights */
  .mine-item.comment {
    background: color-mix(in srgb, var(--hotpink) 5%, var(--page));
    border: 1px solid color-mix(in srgb, var(--hotpink) 25%, transparent);
    border-radius: 14px;
    border-bottom-left-radius: 4px;
  }
  .mine-tag {
    flex: none;
    font-size: 9px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--hotpink);
    background: color-mix(in srgb, var(--hotpink) 12%, transparent);
    padding: 2px 7px;
    border-radius: 999px;
    margin-top: 3px;
  }
  .mine-item:hover {
    background: var(--page-deep, var(--page));
  }
  .mine-dot {
    flex: none;
    width: 9px;
    height: 9px;
    border-radius: 50%;
    margin-top: 4px;
  }
  .mine-body {
    flex: 1;
    min-width: 0;
  }
  .mine-ts {
    color: var(--text-3);
    transition: color 0.12s var(--ease-out);
  }
  .mine-ts:hover {
    color: var(--hotpink);
  }
  .mine-quote {
    font-size: 13px;
    line-height: 1.45;
    color: var(--text-1);
    margin: 2px 0 0;
  }
  .mine-note {
    font-size: 12.5px;
    line-height: 1.45;
    color: var(--text-2);
    margin: 4px 0 0;
    padding-left: 8px;
    border-left: 2px solid var(--line-strong);
  }
  .mine-item.comment .mine-note {
    border-left-color: var(--hotpink);
  }
  /* comment margin marker in the turn header */
  .cmark {
    margin-left: auto;
    display: inline-flex;
    align-items: center;
    gap: 3px;
    padding: 3px 7px;
    border-radius: 999px;
    color: var(--hotpink);
    background: color-mix(in srgb, var(--hotpink) 10%, transparent);
    transition:
      background 0.15s var(--ease-out),
      transform 0.15s var(--ease-out);
  }
  .cmark:hover {
    background: color-mix(in srgb, var(--hotpink) 22%, transparent);
    transform: scale(1.06);
  }
  .cmark-n {
    font-size: 9px;
  }
  @keyframes mine-flash {
    0%, 60% {
      background: color-mix(in srgb, var(--hotpink) 26%, var(--page));
    }
    100% {
      background: color-mix(in srgb, var(--hotpink) 5%, var(--page));
    }
  }
  .mine-item.flash {
    animation: mine-flash 2s var(--ease-out);
  }
  .mine-del {
    flex: none;
    display: grid;
    place-items: center;
    width: 20px;
    height: 20px;
    border-radius: 6px;
    color: var(--text-3);
    opacity: 0;
    transition:
      opacity 0.12s var(--ease-out),
      color 0.12s var(--ease-out);
  }
  .mine-item:hover .mine-del {
    opacity: 1;
  }
  .mine-del:hover {
    color: var(--red-ink, var(--hotpink));
  }
  .w {
    border-radius: 5px;
    padding: 1px 2px;
    margin: 0 -1px;
    cursor: pointer;
    transition: background 0.12s var(--ease-out);
  }
  .w:hover {
    background: rgba(252, 86, 129, 0.14);
  }
  .w.hit {
    /* search match: yellow marker, dark text, works on both themes */
    background: #ffd43b;
    color: #131722;
  }
  .w.hit:hover {
    background: #ffcd1f;
  }
  .w.on {
    background: var(--hotpink);
    color: #fff;
  }
  /* saved highlights painted on the words themselves — must come after
     .hit and .on so the user's chosen colour wins over search yellow,
     and the playing word still wins over everything.
     The word's trailing space lives INSIDE the span, so marked spans tile
     edge-to-edge: margin 0 (no negative-margin overlap) + translucent tint
     paints exactly once → continuous band, no dark seams. */
  .w.marked {
    background: color-mix(in srgb, var(--mk) 30%, transparent);
    margin: 0;
    border-radius: 0;
  }
  /* the word being spoken right now always reads as playback pink */
  .w.marked.on {
    background: var(--hotpink);
    color: #fff;
  }
  .nomatch {
    text-align: center;
    padding: 40px 0;
    font-size: 26px;
    color: var(--ink);
  }

  .more {
    display: block;
    margin: 16px auto;
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

  /* ── bottom dock ── */
  .noaudio {
    margin-top: 20px;
    font-size: 19px;
    color: var(--text-3);
  }

  .pending {
    padding: 60px 20px;
    text-align: center;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .pending .big {
    font-size: 26px;
    color: var(--ink);
  }

  .dock {
    /* in-flow at the bottom of the fixed-height wrap: .cols (flex: 1) fills
       the space above, so the dock sits pinned at the bottom edge even when
       the transcript is shorter than the viewport */
    flex-shrink: 0;
    padding: 11px 32px;
    display: flex;
    align-items: center;
    gap: 13px;
    background: var(--surface);
    border-top: 1px solid var(--line);
  }
  .play {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 42px;
    height: 42px;
    border-radius: 99px;
    background: var(--hotpink);
    color: #fff;
    box-shadow: 0 4px 12px rgba(252, 86, 129, 0.35);
    transition: transform 0.18s var(--spring);
  }
  .play:hover {
    transform: scale(1.07);
  }
  .play:active {
    transform: scale(0.96);
  }
  .time {
    white-space: nowrap;
  }
  /* current-time emphasis (dock only — never on turn text) */
  .time.now {
    color: var(--ink);
    font-weight: 500;
  }
  /* (no .now text styling — weight/colour changes made the whole turn reflow)
  .dim {
    color: var(--text-3);
  }

  /* scrubber — :global + namespaced. The scoped .tl rule was being pruned
     by the svelte compiler (no warning!) which unanchored the absolutely
     positioned segments and stretched them across the whole window, and
     SortSeg's :global .seg was leaking onto these segments too. */
  :global(.seek-track) {
    position: relative;
    flex: 1;
    height: 14px;
    border-radius: 99px;
    background: var(--wash);
    cursor: pointer;
    overflow: hidden;
  }
  :global(.seek-track::before) {
    content: '';
    position: absolute;
    inset: 0;
  } /* hit area */
  :global(.seek-seg) {
    position: absolute;
    top: 3px;
    bottom: 3px;
    border-radius: 99px;
    opacity: 0.75;
  }
  :global(.seek-head) {
    position: absolute;
    top: -2px;
    bottom: -2px;
    width: 2.5px;
    background: var(--ink);
    border-radius: 2px;
    pointer-events: none;
  }
  :global(.seek-head .seek-head-dot) {
    position: absolute;
    top: -1px;
    left: 50%;
    transform: translateX(-50%);
    width: 9px;
    height: 9px;
    border-radius: 99px;
    background: var(--ink);
  }
  .rates {
    display: flex;
    gap: 2px;
    flex-shrink: 0;
  }
  .rate {
    padding: 3px 8px;
    border-radius: 99px;
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-3);
    transition:
      background 0.15s var(--ease-out),
      color 0.15s var(--ease-out);
  }
  .ai {
    padding: 18px 20px;
    margin: 14px 0 6px;
    background: linear-gradient(135deg, var(--cream) 40%, var(--card-mint));
    border-color: var(--line);
  }
  .ai-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 8px;
  }
  .ai-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    border-radius: 999px;
    background: var(--ink);
    color: var(--cream-50);
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }
  .ai-badge :global(svg) {
    color: var(--mint);
  }
  .ai-pending {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--text-3);
  }
  .ai-pending :global(svg) {
    animation: spin 1s linear infinite;
  }
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
  .ai-pending-text {
    font-size: 16px;
    color: var(--text-2);
  }
  .ai-title {
    font-size: 18px;
    margin: 6px 0 6px;
  }
  .ai-summary {
    font-size: 13.5px;
    line-height: 1.6;
    color: var(--text-1);
    user-select: text;
  }
  .ai-topics {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 12px;
  }
  .topic {
    background: var(--paper);
    border: 1px solid var(--line);
    color: var(--ink);
    cursor: pointer;
  }
  .topic:hover {
    border-color: var(--hotpink);
    color: var(--hotpink);
  }
  .ai-empty {
    font-size: 13px;
    color: var(--text-3);
    margin-bottom: 10px;
  }
  .ai-hint {
    font-size: 10px;
    margin: 8px 0 10px;
    line-height: 1.4;
  }
  .ai-regen {
    padding: 5px 10px;
    font-size: 11px;
  }
  .progress .indet {
    animation: pulsebar 1.4s ease-in-out infinite alternate;
  }
  @keyframes pulsebar {
    from {
      opacity: 0.4;
    }
    to {
      opacity: 1;
    }
  }

  .rate:hover {
    background: var(--wash);
    color: var(--ink);
  }
  .rate.on {
    background: var(--ink);
    color: #fff;
  }
</style>
