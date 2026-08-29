/**
 * Pending-deletion buffer with undo grace period.
 *
 * Deleted items vanish from the UI instantly; the real native delete only
 * fires after the grace window expires without an undo. Purely web-side —
 * no native changes needed, and quitting within the window simply means
 * nothing was deleted.
 */
import { send } from './bridge.svelte.js';

export const TRASH_GRACE_MS = 5000;

let seq = 0;
let entries = $state([]); // { uid, kind: 'note'|'transcript', ids[], preview, expiresAt }

function flush(entry) {
  if (!entries.some((e) => e.uid === entry.uid)) return; // undone already
  entries = entries.filter((e) => e.uid !== entry.uid);
  if (entry.bulk) {
    // one-shot clears go out as a single native command
    send({ type: entry.kind === 'history' ? 'historyClear' : 'notesClear' });
    return;
  }
  const types = {
    note: 'notesDelete',
    transcript: 'transcriptsDelete',
    history: 'historyDelete',
  };
  const type = types[entry.kind];
  for (const id of entry.ids) send({ type, id });
}

export const trash = {
  get entries() {
    return entries;
  },

  /** stage one item (or several ids sharing one preview label).
      bulk: true sends a single clear-everything command on flush. */
  add(kind, ids, preview, { bulk = false } = {}) {
    const entry = {
      uid: ++seq,
      kind,
      ids,
      preview,
      bulk,
      expiresAt: Date.now() + TRASH_GRACE_MS,
    };
    entries.push(entry);
    setTimeout(() => flush(entry), TRASH_GRACE_MS + 50);
    return entry;
  },

  undo(uid) {
    entries = entries.filter((e) => e.uid !== uid);
  },

  /** ids staged for deletion of a kind — panes filter their lists by this */
  pendingIds(kind) {
    return new Set(
      entries.filter((e) => e.kind === kind).flatMap((e) => e.ids)
    );
  },
};

/** shared date formatter — adds the year once it isn't the current one */
export function fmtDateSmart(iso) {
  const d = new Date(iso);
  const sameYear = d.getFullYear() === new Date().getFullYear();
  return d.toLocaleDateString(
    undefined,
    sameYear
      ? { month: 'short', day: 'numeric' }
      : { month: 'short', day: 'numeric', year: 'numeric' }
  );
}
