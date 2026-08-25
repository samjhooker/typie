# PRD execution tasks

Derived from [`PRD-typie-suite.md`](PRD-typie-suite.md). One checkbox per
work unit; each milestone ships standalone. Progress tracked in place —
tick as we go.

---

## M1 — Shelf foundations *(unblocks everything else)* — **implementation done, in smoke test**

- [x] **1.1 Hover-expand state machine** — `NotchPanel` gains an expanded/
      collapsed state driven by pointer proximity (~120 px of top-centre);
      panel accepts mouse events only while expanded; collapses on
      mouse-leave unless a tool is active. Notch-less Macs: capsule below
      menu bar behaves the same.
      *→ `ShelfController` + hover zone monitors in `NotchPanel`;
        `ignoresMouseEvents` flips via `refreshInteraction()`.*
- [x] **1.2 Icon row UI** — `NotchView` expanded state shows the four tool
      icons (🎙️ dictation status · ✎ voice note · ⧉ transcribe file ·
      🖥️ meeting capture) plus a live-status slot; per-tool active visuals
      (dictation keeps robot+waveform; record tools get red dot + timer).
      *→ `ToolButton` row + `TranscribeStatus` slot; ✎/🖥️ dimmed "soon".
        Red-dot+timer visuals deferred to M2/M4 when capture exists.*
- [x] **1.3 Drag-and-drop routing** — dropping an audio/video file onto the
      expanded shelf launches F3 (`DiarizeStore.process`) immediately.
      *→ `ShelfHostingView` drag target; drag-enter pops the shelf open;
        drop kicks off the job + opens the transcribe pane.*
- [x] **1.4 Click wiring (existing tools only)** — ⧉ opens the file picker +
      Transcribe pane; ✎ and 🖥️ render disabled ("coming in a later drop")
      until M2/M4 land; 🎙️ is passive status only.
      *→ `ShelfController.onTranscribeChosen/Dropped` wired in `AppDelegate`.*
- [ ] **1.5 Build + smoke test** — `swift build` clean ✓; dev app launches ✓
      (`build/typie-dev.app`, pid running).
      **Needs eyes:** complete typie-dev onboarding once, then verify:
      hover top-centre → shelf expands · leave → collapses · ⧉ click →
      transcribe pane opens · drop an mp3 onto shelf → job starts.

## M2 — Voice Notes — **implementation done, in smoke test**

- [x] **2.1 `NoteStore`** — ObservableObject mirroring `HistoryStore`
      patterns; JSON-per-note under `Application Support/<variant>/notes/`;
      optional audio retention (setting, default off).
      *→ 16 kHz mono WAV (PCM16) via AVAudioFile when keep-audio is on.*
- [x] **2.2 Record flow** — shelf ✎ click starts capture instantly (<300 ms
      to red dot); stop → Parakeet transcript → filed note; Esc stops.
      *→ shelf shows pulsing red dot + elapsed timer while recording,
        "writing it down…" dots while transcribing; click/esc stops.*
- [x] **2.3 Notes page** — reverse-chron list, search, pin, delete, copy as
      markdown, export .md/.txt; wired through the snapshot bridge.
      *→ new NotesPane + notes tab in the pill switcher; ⌘K focuses search;
        pinned notes float to the top.*
- [x] **2.4 Settings** — "keep audio" toggle plumbed end to end.
      *→ Settings → Preferences → "Keep voice note audio".*
- [ ] **2.5 Build + smoke test** — webui rebuilt ✓, `swift build` clean ✓,
      dev app relaunched ✓.
      **Needs eyes:** record a mumble from the shelf ✎ → note appears in
      the notes tab; pin/delete/copy/export work; keep-audio toggle stores
      a .wav under Application Support/typie-dev/notes/audio/.

## M3 — Transcripts promotion — **implementation done, in smoke test**

- [x] **3.1 Transcripts page** — moved out of the dev-only settings sub-pane;
      searchable library of past jobs (name, duration, speaker count, date).
      *→ pane renamed `transcripts`, visible in prod too; full-text filter
        over file names + turn text.*
- [x] **3.2 Transcript metadata index** — persisted job list on disk.
      *→ `TranscriptStore`: JSON-per-transcript under
        `Application Support/<variant>/transcripts/`; auto-files every job
        via a new `DiarizeStore.onJobCompleted` hook (armed at launch).*
- [x] **3.3 Editable speaker labels** — rename persists per transcript.
      *→ inline speaker editors above the turns; stored in
        `speakerNames[index]`; merge/split turns deferred to v1.1.*
- [x] **3.4 Export writers** — markdown w/ timestamps, plain text, SRT/VTT,
      JSON from `DiarizeStore` results.
      *→ save-panel export from the detail card (↓md ↓txt ↓srt ↓vtt ↓json).*
- [x] **3.5 Entry points** — shelf icon picker + drag-drop both land in the
      library with stage labels intact.
      *→ shelf ⧉ opens the transcripts pane; drop starts the job and shows
        progress; finished jobs auto-filed.*
- [ ] **3.6 Build + smoke test** — webui ✓, `swift build` ✓, dev bundle
      rebuilt + relaunched ✓.
      **Needs eyes:** run one transcribe job → appears in library; rename a
      speaker; export srt; delete an entry.

## M4 — Meeting Capture — **implementation done, in smoke test**

- [x] **4.1 `SystemAudioRecorder`** — ScreenCaptureKit audio stream wrapper
      beside `AudioCapture`; no virtual driver dependency.
      *→ audio-only SCStream (no video frames requested); excludes own
        process audio; 16 kHz mono PCM16 appended straight to a temp WAV —
        flat memory for any length.*
- [x] **4.2 JIT permission** — screen-recording prompt with friendly
      explainer on first 🖥️ use.
      *→ NSAlert explainer → deep link into System Settings.*
- [x] **4.3 Mic-mix option** — toggle mixes user mic into the capture track.
      *→ Settings → "Mix my mic into meetings"; mic recorded as side-track,
        additively mixed at stop; system track streams to disk.*
- [x] **4.4 Capture UX** — shelf red dot + timer + source hint; click again
      (or Esc) to stop & process.
      *→ "recording this mac · click or esc to stop" in the shelf.*
- [x] **4.5 Pipeline hand-off** — stopped capture runs the F3 pipeline and
      lands in the Transcripts library tagged `meeting`.
      *→ `DiarizeStore.nextJobIsMeeting` flag consumed by TranscriptStore;
        library chip shows 🖥 for meeting entries.*
- [x] **4.6 Long-file hardening** — bounded memory via disk streaming of the
      system-audio path (mic side-track is in-memory in v1).
- [ ] **4.7 Build + smoke test** — `swift build` ✓, dev bundle rebuilt +
      relaunched ✓.
      **Needs eyes:** grant Screen Recording permission on first 🖥️ use,
      play a YouTube video while capturing, confirm a `meeting`-tagged
      transcript lands in the library.

## M5 — Window revamp — **implemented, in smoke test**

- [x] **5.1 Sidebar layout** — brand + nav
      (`docs/design/home-mockup.png` style, minus the 3-col split: Home /
      Notes / Transcripts / Recordings), Settings/Stats/Dictations at the
      bottom, and the *"Local — everything stays on this Mac"* footer with
      a live storage meter (models + notes + transcripts vs. disk).
      *→ window enlarged to 1080×700.*
- [x] **5.2 Home library column** — unified date-grouped list (Today /
      Yesterday / date) of everything typie has made, pastel chips
      (note ✎ butter · transcript ☰ lavender · meeting 🎥 pink), search
      field with ⌘K focus, filters as you type.
- [x] **5.3 Detail column** — master–detail: selecting a note shows full
      text + copy; a transcript shows speaker-labeled turns with colored
      speaker dots + names + timestamps; audio player bar (static,
      "replay soon") when audio kept. (Note raw/clean toggle deferred:
      no clean-pass exists yet.)
- [x] **5.4 JIT permission banners** — inline banners on Home when mic /
      accessibility / screen-recording is missing, each deep-linking to
      the right OS prompt. Onboarding slim-down deferred (untested).
- [x] **5.5 Per-tool settings** — keep-note-audio (M2) + mix-my-mic-meetings
      (M4) toggles; export prefs untouched (defaults fine for v1).
- [ ] **5.6 Build + smoke test** — `swift build` ✓, webui bundle ✓, dev
      bundle rebuilt + relaunched ✓.
      **Needs eyes:** sidebar nav, date-grouped library, ⌘K search,
      master–detail with colored speaker dots, permission banners, storage
      meter, 1080×700 window.

---

## Open questions carried from the PRD (don't block work)

- Voice notes default keep-audio: **off** (PRD default) unless sam says otherwise.
- Meeting capture v1: manual start/stop only.
- Search index shared between notes/transcripts: decide at M3.
- Multi-monitor shelf: primary display only in v1.
- Naming of the four-tool suite: unchanged for now.
