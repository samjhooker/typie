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
  stats: { totalWords: 0, totalDictations: 0, totalAudioSeconds: 0, avgLatencyMs: 0 },
  storage: { usedBytes: 0, freeBytes: 0, totalBytes: 0 },
  history: [],
  notes: [],
  transcripts: [],
  dictation: { phase: 'idle', lastMs: -1 },
  capturingHotkey: false,
  meeting: { isCapturing: false, processing: false, startedAt: '' },
})

/** purely local UI state the native side doesn't care about */
export const local = $state({
  pane: 'home',
  selectedTranscriptId: null,
  openedIds: {}, // transcripts opened at least once — the "new" chip retires
  step: 0,
  practice: '',
  flash: false,
  copiedId: null,
})

let seenTranscript = ''
let flashTimer = 0

/** full transcripts (turns + words) fetched on demand by the detail pane */
export const transcriptCache = $state({})

function setTranscript(data){
  if (data?.id) transcriptCache[data.id] = data
}

let copyTimer = 0
export function markCopied(id) {
  local.copiedId = id
  clearTimeout(copyTimer)
  copyTimer = setTimeout(() => (local.copiedId = null), 1200)
}

export function send(msg) {
  window.webkit?.messageHandlers.typie.postMessage(msg)
}

/** called by Swift with a fresh state snapshot */
export function applyPush(s) {
  if (!s || typeof s !== 'object') return
  const wasRoute = ui.route
  ui.variant = s.variant ?? 'prod'
  Object.assign(ui.settings, s.settings)
  Object.assign(ui.permissions, s.permissions)
  Object.assign(ui.model, s.model)
  ui.modelsExist = s.modelsExist
  ui.eta = s.eta ?? ''
  Object.assign(ui.transcribe, s.transcribe)
  Object.assign(ui.stats, s.stats)
  ui.history = s.history
  ui.notes = s.notes ?? []
  ui.transcripts = s.transcripts ?? []
  if (s.storage) Object.assign(ui.storage, s.storage)
  Object.assign(ui.dictation, s.dictation)
  ui.capturingHotkey = s.capturingHotkey
  if (s.meeting) Object.assign(ui.meeting, s.meeting)
  if (!ui.ready || wasRoute !== s.route) {
    // first snapshot or route change: adopt it wholesale
    ui.route = s.route
  }
  if (!ui.ready) ui.ready = true

  // onboarding practice box: append transcripts as they land
  const t = s.dictation?.transcript
  if (t && t !== seenTranscript && s.route === 'onboarding') {
    seenTranscript = t
    local.practice = local.practice ? `${local.practice} ${t}` : t
    local.flash = true
    clearTimeout(flashTimer)
    flashTimer = setTimeout(() => (local.flash = false), 700)
  }
}

window.__typie = { push: applyPush, setTranscript }

// tell the Swift host the page is live so it starts pushing state
if (typeof window !== 'undefined') {
  send({ type: 'ready' })
}

/* ── formatting helpers shared by panes ───────────────────── */

const STANDARD_WPM = 35

export function timeSavedSeconds(stats) {
  return (stats.totalWords / STANDARD_WPM) * 60
}

export function formatDuration(seconds) {
  const total = Math.round(seconds)
  const hours = Math.floor(total / 3600)
  const minutes = Math.floor((total % 3600) / 60)
  if (hours >= 1) return minutes > 0 ? `${hours}h ${minutes}m` : `${hours}h`
  if (minutes >= 1) return `${minutes}m`
  return total > 0 ? 'under a minute' : '0m'
}

export function formatAudio(seconds) {
  if (seconds < 1) return '<1s'
  if (seconds < 60) return `${Math.round(seconds)}s`
  return formatDuration(seconds)
}

export function formatLatency(ms) {
  return ms >= 1000 ? `${(ms / 1000).toFixed(1)}s` : `${Math.round(ms)}ms`
}
