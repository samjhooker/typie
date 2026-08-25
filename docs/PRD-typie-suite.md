# PRD: typie — from dictation tool to offline AI workspace

**Status:** draft · **Owner:** sam · **Last updated:** after the web-UI migration (`ef04a15`)

---

## 1. Summary

typie started as a hold-a-hotkey-talk-at-your-cursor dictation tool. Since migrating
all windows to a bundled Svelte web UI inside WKWebView, we can iterate on product
surface as fast as any web app — while keeping every byte of audio and text on-device.

This PRD proposes evolving typie into a **multi-tool offline voice workspace**, all
anchored to one piece of contested macOS real estate: **the notch**. Hover the top of
your screen, a toolbar slides out, and you pick a tool:

| # | Tool | One-liner | Status |
|---|------|-----------|--------|
| F1 | **Dictation** | Hold a key, speak, text lands at your cursor | ✅ shipped |
| F2 | **Voice Notes** | Tap record, ramble, tap stop — get a tidy written note | 🆕 |
| F3 | **Transcribe File** | Drop any audio/video file → full speaker-labeled transcript | 🔶 exists in settings pane; promote to first-class |
| F4 | **Meeting Capture** | Record system audio of any call/meeting → diarized transcript | 🆕 |

Alongside the notch work, the main window gets a **traditional multi-tool layout**:
title top-left, sidebar tabs down the left, one page per feature, with
just-in-time permission prompts instead of an up-front permission wall.

---

## 2. Goals & non-goals

### Goals
1. Four tools, one entry point (the notch), zero cloud. Everything works on a plane.
2. Hover-to-reveal notch toolbar — discoverable without stealing screen space.
3. Main window restructured so each tool has a real home (history, search, export).
4. Just-in-time permissions: mic asked when you first dictate; screen-recording
   asked only when you first start a capture.
5. Reuse what exists: `AudioCapture`, `DictationController`, `DiarizeStore`,
   `HistoryStore`, the `window.__typie` state bridge.

### Non-goals (for now)
- Live/streaming transcription during capture (post-processing only in v1).
- Speaker *identification* (naming a face/voice automatically) — speakers are
  named by hand, labels are remembered per-note only.
- Windows/Linux. Menu bar / notch is a Mac play.
- Cloud sync, accounts, telemetry.

---

## 3. The notch toolbar ("the shelf")

### Current behaviour
The notch island appears while dictating (robot + waveform) and otherwise hugs the
notch invisibly. It's dictation-only.

### Proposed interaction model

```
                    idle                hover (top-centre)         active tool
   ┌─────────┐      ┌─────────┐         ┌──────────────────┐      ┌──────────────────┐
   │  notch  │  →   │  notch  │  hover  │ ▣ 🎙️ ✎ ⧉ 🖥️ ●    │  →   │ waveform / timer │
   └─────────┘      └─────────┘  ─────→  └──────────────────┘      └──────────────────┘
                         invisible       icons slide out            expands per tool
```

- **Hover zone:** pointer within ~120 px of top-centre of the display → panel
  expands (~380 px wide) revealing four icons plus a live-status slot.
- **Icons:** 🎙️ dictation status (also reflects hotkey state passively),
  ✎ voice note, ⧉ transcribe file, 🖥️ meeting capture.
- **Click-through rules stay:** panel remains `.nonactivatingPanel`,
  `ignoresMouseEvents = false` *only* while expanded; collapses on mouse-leave
  unless a tool is active.
- **Drag-and-drop target:** dropping an audio/video file anywhere onto the
  expanded shelf launches **F3** immediately (the Otter move).
- **Two robots, two shelves:** dev and prod variants each own their island
  (already true); variant tag shows in the expanded state.
- **Notch-less Macs:** shelf floats as a capsule below the menu bar
  (`NotchPanel.position()` already handles this).

### Active-state visuals (per tool)
- Dictation: existing robot dance + waveform.
- Voice note: pulsing red dot + elapsed timer.
- Meeting capture: red dot + timer + app/source hint; click again to stop & process.

---

## 4. Feature specs

### F1 — Dictation *(shipped, keep as-is)*
Hold (or toggle, per settings) the bound modifier → speak → release → text pasted
at cursor via CGEvents. Latency stats, history, robot waveform all unchanged.
Only change: dictation status surfaces on the shelf's passive icon.

### F2 — Voice Notes
**Job story:** *"When I think of something on a call, I want to hit one button,
mumble a reminder, and trust I'll find it written down later."*

- Click ✎ on the shelf → starts recording instantly (<300 ms to red dot).
- Click again (or Esc / hotkey) → stops, transcribes, files the note.
- Each note: timestamped card with the transcript, duration, and (later) detected
  language. Optional auto-cleanup pass: strip filler words into a "clean" rendering
  while keeping raw text one toggle away.
- Lives in a **Notes** page in the main window: reverse-chronological list, search,
  pin, delete, copy as markdown, export (.md/.txt).
- Storage: SQLite or JSON-per-note under `Application Support/<variant>/notes/`.
  Audio retained optionally (setting, default off) for replay.
- New `NoteStore: ObservableObject` mirroring `HistoryStore` patterns; pushed to
  the web UI through the existing coalesced snapshot bridge.

### F3 — Transcribe File (promote to first class)
Already functional in the settings window's Transcribe pane (Parakeet ASR + FluidAudio
offline VBx diarization, token-level merge). Changes:

- Move from a settings sub-pane to its own **Transcripts** page.
- Entry points: shelf icon (file picker), **drag file onto shelf**, share-sheet/
  open-with later.
- Post-run editor: speaker labels are editable ("Speaker 1" → "Sam") and persisted;
  turns mergeable/splitable by clicking boundaries (v1.1).
- Export: markdown with timestamps, plain text, SRT/VTT subtitles, JSON.
- Transcript library: searchable list of past jobs with file name, duration,
  speaker count, date.
- Long-file UX: chunked progress already exists — keep stage labels
  ("reading audio" → "transcribing" → "identifying speakers").
- Target: comfortable with 2-hour files; keep memory bounded (stream chunks to disk
  if needed).

### F4 — Meeting Capture
**Job story:** *"I had a 2-hour Zoom/Meet/whatever call — give me everything that was
said, who said what, without sending a byte anywhere."*

- Click 🖥️ on the shelf → permission check → records **system audio**
  (every app: Zoom, Meet in browser, Slack huddles, local playback).
- Implementation: ScreenCaptureKit (macOS 13+) audio stream — captures system
  output without a virtual loopback driver (no BlackHole dependency). Requires
  Screen Recording permission → requested just-in-time with a friendly explainer.
- Mic option (toggle): mix in the user's own mic so both sides of a call land in
  one track (system audio alone usually contains remote parties only).
- While capturing: shelf shows timer; a subtle screen-edge indicator optional.
- On stop: file runs through the exact F3 pipeline (resample → Parakeet → VBx →
  merged turns) and lands in the same Transcripts library, tagged `meeting`.
- Handles 15-second clips and 2-hour meetings alike; show honest ETA + allow
  "keep working, notify me when done".
- Explicitly out of scope in v1: video frame capture/analysis — audio only.

---

## 5. Main window redesign

Reference design: [`docs/design/home-mockup.png`](design/home-mockup.png).
Traditional multi-tool layout — three columns:

- **Sidebar:** `typie.` brand (robot mood reflects dictation state), nav
  (Home / Notes / Transcripts / Recordings), Settings at the bottom, and a
  **"Local — everything stays on this Mac"** footer with a storage meter
  (models + kept audio + transcripts vs. disk). The privacy stance, made ambient.
- **Library column (Home):** one unified, date-grouped list (Today / Yesterday /
  dates) of everything typie has made — voice notes, transcripts, meeting
  recordings — each with a pastel type chip (butter = note, lavender =
  transcript, pink = recording), title, and metadata line (type · duration ·
  speaker count). Search field up top with ⌘K focus; filters as you type.
- **Detail column:** master–detail. Selecting a transcript shows its full
  speaker-labeled turns — per-speaker colored dots and names, timestamps — plus
  an audio player bar (playhead, speaker-colored waveform, speed control) when
  audio is kept. Selecting a note shows its clean text with the raw one toggle
  away.

Full-window panes (Settings, Stats, the Transcripts upload/drop flow) replace the
library+detail pair when activated from the sidebar.
- **Sidebar tabs** map 1:1 to tools; deep-linkable via the existing
  `setPane()` bridge (`__typie.setPane('transcripts')`).
- **Just-in-time permissions:** each pane shows a small inline banner only when its
  capability is missing (mic / accessibility / screen recording), with a button
  that triggers the OS prompt. No permission wall at onboarding; onboarding slims
  down accordingly.
- **Settings** keeps hotkey picker, trigger mode, history toggle, launch-at-login,
  and gains per-tool preferences (keep audio, default exports, etc.).

---

## 6. Architecture notes (all reuse, mostly)

| Piece | Today | Needed for this PRD |
|---|---|---|
| Web UI bridge (`WebUIController`) | snapshots for 6 stores | add `NoteStore`; transcripts already wired via `DiarizeStore` |
| `DiarizeStore.process(url:)` | batch pipeline | shared engine behind F3 + F4; add export writers |
| `AudioCapture` | mic tap | unchanged; add ScreenCaptureKit system-audio source beside it |
| `NotchPanel`/`NotchView` | dictation visuals | hover tracking, icon row, per-tool active states, drop target |
| Persistence | history/stats JSON | add notes store; transcript metadata index |
| Models | Parakeet (~470 MB) + diarizer (~22 MB), cached once, shared dev/prod | unchanged |

New Swift surface is deliberately small: `NoteStore`, `SystemAudioRecorder`
(ScreenCaptureKit wrapper), notch hover/drag handling, export utilities.

---

## 7. Privacy stance (marketing-ready, and true)

- No network calls after model download. Ever. (Already asserted in the landing copy.)
- Audio never leaves the machine: no upload in any of the four tools.
- Screen/audio capture is opt-in per session, visibly indicated, trivially stopped.
- Delete a note/transcript → the audio and text are gone, not "deactivated".

---

## 8. Milestones

1. **M1 — Shelf foundations:** hover-expand notch toolbar, icon row, drag-drop
   routing to F3. Ship with existing tools only.
2. **M2 — Voice Notes:** `NoteStore`, shelf record flow, Notes page, search/export.
3. **M3 — Transcripts promotion:** dedicated page, library, editable speaker
   names, md/txt/SRT export.
4. **M4 — Meeting Capture:** ScreenCaptureKit recorder, mic-mix option, long-file
   hardening, notification-on-complete.
5. **M5 — Window revamp:** sidebar layout, Home pane, JIT permissions everywhere,
   slimmed onboarding.

Each milestone ships standalone; M1 unblocks everything else.

---

## 9. Open questions

- Voice notes: keep raw audio by default on or off?
- Meeting capture: auto-start detection of calls (e.g. notice Zoom audio) or
  strictly manual start/stop? (v1: manual.)
- Should transcripts and notes share one search index?
- Shelf behaviour on multi-monitor: primary display only (v1) or per-display islands?
- Naming: does "typie" still fit a four-tool suite, or do we brand the shelf?
