/**
 * Bridge between the Swift host and this UI.
 *
 * Swift pushes full state snapshots via window.__typie.push(json);
 * we send actions back through webkit.messageHandlers.typie.
 */

export const ui = $state({
  ready: false,
  route: 'app', // 'onboarding' | 'app'
  variant: 'prod', // 'prod' | 'dev'
  settings: {
    hotkey: 'Right ⌥ Option',
    hotkeyShort: '⌥',
    triggerMode: 'both',
    historyEnabled: true,
    launchAtLogin: true,
    notesKeepAudio: true,
    meetingMixMic: false,
    transcriptsKeepAudio: true,
    aiEnabled: true,
    appearance: 'system', // 'system' | 'light' | 'dark'
  },
  permissions: { mic: false, ax: false, screen: false },
  model: { status: 'notDownloaded', fraction: 0, error: '' },
  modelsExist: false,
  eta: '',
  transcribe: {
    model: { state: 'unknown', fraction: 0, error: '' },
    downloadMB: 22,
    busy: false,
    stage: '',
    progress: null,
    eta: '',
    queued: 0,
    queue: [],
    error: '',
    result: null,
  },
  stats: {
    totalWords: 0,
    totalDictations: 0,
    totalAudioSeconds: 0,
    avgLatencyMs: 0,
  },
  storage: { usedBytes: 0, freeBytes: 0, totalBytes: 0 },
  history: [],
  notes: [],
  transcripts: [],
  dictation: { phase: 'idle', lastMs: -1 },
  capturingHotkey: false,
  meeting: { isCapturing: false, processing: false, startedAt: '' },
  aiAvailable: false,
  aiSettingSupported: false,
});

/** purely local UI state the native side doesn't care about */
export const local = $state({
  pane: 'home',
  selectedTranscriptId: null,
  // transcripts opened at least once — the "new" chip retires forever.
  // persisted: the library shouldn't tease "new" on every relaunch.
  openedIds: (() => {
    try {
      return JSON.parse(localStorage.getItem('typie:openedIds') || '{}');
    } catch {
      return {};
    }
  })(),
  step: 0,
  practice: '',
  flash: false,
  copiedId: null,
  recheck: false, // true when we re-show only the permissions step after setup
  // remember that screen permission was granted (or requested) so we don't
  // re-ask on every navigation, macOS needs a restart for CGPreflight to
  // flip, so we optimistically cache the grant
  askedScreenPermission: (() => {
    try {
      return localStorage.getItem('typie:askedScreen') === '1';
    } catch {
      return false;
    }
  })(),
  // Apple Intelligence banner dismissed, SESSION-ONLY. Never persisted:
  // a one-time ✕ click must not hide the hint forever.
  aiNudgeDismissed: false,
});

let seenTranscript = '';
let flashTimer = 0;

/** full transcripts (turns + words) fetched on demand by the detail pane */
export const transcriptCache = $state({});

function setTranscript(data) {
  if (data?.id) transcriptCache[data.id] = data;
}

let copyTimer = 0;
export function markOpened(id) {
  if (!id || local.openedIds[id]) return;
  local.openedIds[id] = true;
  try {
    localStorage.setItem('typie:openedIds', JSON.stringify(local.openedIds));
  } catch {}
}

export function markCopied(id) {
  local.copiedId = id;
  clearTimeout(copyTimer);
  copyTimer = setTimeout(() => (local.copiedId = null), 1200);
}

export function send(msg) {
  // remember screen permission request so Library/Home don't keep re-asking
  if (msg?.type === 'requestScreenPermission') {
    local.askedScreenPermission = true;
    try {
      localStorage.setItem('typie:askedScreen', '1');
    } catch {}
  }
  window.webkit?.messageHandlers.typie.postMessage(msg);
}

/** hide the Apple Intelligence banner until the app relaunches */
export function dismissAiNudge() {
  local.aiNudgeDismissed = true;
}

/** called by Swift with a fresh state snapshot */
export function applyPush(s) {
  if (!s || typeof s !== 'object') return;
  const wasRoute = ui.route;
  ui.variant = s.variant ?? 'prod';
  if (s.settings) {
    Object.assign(ui.settings, s.settings);
    // the AI toggle only makes sense when the OS can actually deliver
    ui.aiSettingSupported = !!s.aiAvailable;
  }
  Object.assign(ui.permissions, s.permissions);
  // if the OS finally reports granted, persist it so first render is correct
  if (s.permissions?.screen) {
    local.askedScreenPermission = true;
    try {
      localStorage.setItem('typie:askedScreen', '1');
    } catch {}
  }
  Object.assign(ui.model, s.model);
  ui.modelsExist = s.modelsExist;
  ui.eta = s.eta ?? '';
  Object.assign(ui.transcribe, s.transcribe);
  Object.assign(ui.stats, s.stats);
  ui.history = s.history;
  ui.notes = s.notes ?? [];
  ui.transcripts = s.transcripts ?? [];
  if (s.storage) Object.assign(ui.storage, s.storage);
  Object.assign(ui.dictation, s.dictation);
  ui.capturingHotkey = s.capturingHotkey;
  if (s.meeting) Object.assign(ui.meeting, s.meeting);
  if ('aiAvailable' in s) ui.aiAvailable = !!s.aiAvailable;
  if (!ui.ready || wasRoute !== s.route) {
    // first snapshot or route change: adopt it wholesale
    ui.route = s.route;
  }
  if (!ui.ready) ui.ready = true;

  // onboarding practice box: append transcripts as they land
  const t = s.dictation?.transcript;
  if (t && t !== seenTranscript && s.route === 'onboarding') {
    seenTranscript = t;
    local.practice = local.practice ? `${local.practice} ${t}` : t;
    local.flash = true;
    clearTimeout(flashTimer);
    flashTimer = setTimeout(() => (local.flash = false), 700);
  }
}

export function setStep(n) {
  const v = Math.max(0, Math.min(3, Number(n) | 0));
  local.step = v;
}
export function setRecheck(v) {
  local.recheck = !!v;
}

/** native → pane switching (legacy ids incl.). Lives at module level, NOT
 * in a component: Swift delivers queued panes the moment the page says
 * "ready", which fires at module load — before any component mounts —
 * so setPane must already exist or the switch is silently dropped
 * (this exact race made "stop a call → open library" land on home). */
export function setPane(p) {
  if (p?.startsWith('transcript:')) {
    local.pane = 'library';
    local.selectedTranscriptId = p.split(':')[1];
    return;
  }
  const map = {
    dictation: 'notes',
    app: 'notes',
    past_dictations: 'history',
    history: 'history',
    transcripts: 'library',
    recordings: 'library',
  };
  const nid = map[p] ?? p;
  if (['home', 'notes', 'library', 'history', 'settings', 'stats'].includes(nid))
    local.pane = nid;
}
window.__typie = { push: applyPush, setTranscript, setPane, setStep, setRecheck };

// tell the Swift host the page is live so it starts pushing state
if (typeof window !== 'undefined') {
  send({ type: 'ready' });
}

/* ── formatting helpers shared by panes ───────────────────── */

const STANDARD_WPM = 35;

export function timeSavedSeconds(stats) {
  return (stats.totalWords / STANDARD_WPM) * 60;
}

export function formatDuration(seconds) {
  const total = Math.round(seconds);
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  if (hours >= 1) return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`;
  if (minutes >= 1) return `${minutes}m`;
  return total > 0 ? 'under a minute' : '0m';
}

export function formatAudio(seconds) {
  if (seconds < 1) return '<1s';
  if (seconds < 60) return `${Math.round(seconds)}s`;
  return formatDuration(seconds);
}

export function formatLatency(ms) {
  return ms >= 1000 ? `${(ms / 1000).toFixed(1)}s` : `${Math.round(ms)}ms`;
}
