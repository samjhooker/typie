# [typie.cc](https://typie.cc/)

> hold a key. say the thing. it's typed.
> a native macos dictation engine that answers in under 100 ms and never touches the internet.

<img width="1646" height="1024" alt="Screenshot 2026-08-30 at 5 13 24 PM" src="https://github.com/user-attachments/assets/dc51050e-2dab-48a1-aacc-f865adab58f1" />

yes, it's just another transcription app. Powered locally by [Nvidia Parakeet](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3)

https://typie.cc/

<img width="1641" height="508" alt="Screenshot 2026-08-30 at 5 14 10 PM" src="https://github.com/user-attachments/assets/4e418fb1-4628-4bb9-aa41-e2d89ca9b1cc" />


most existing transcription apps share a common design decision: your voice goes to their cloud, and you pay rent on your own voice. typie makes the opposite bet - **all inference local, zero backend, sub-100 ms end-to-end** - and turns that constraint into the product.

<img width="1635" height="939" alt="Screenshot 2026-08-30 at 5 13 45 PM" src="https://github.com/user-attachments/assets/642ffce6-7a46-4ba7-92a0-1a0a9c6b0f4d" />



## what it actually is

a native macos menu bar app. hold your hotkey, talk, let go. text lands wherever your cursor is.

```
you ──hold ⌥──> mic ──> on-device ASR model ──> CGEvent keystrokes ──> whatever app you're in

                        (~500 mb, local)          <100 ms later
```


<img width="1632" height="774" alt="Screenshot 2026-08-30 at 5 15 46 PM" src="https://github.com/user-attachments/assets/1604ba28-6595-4e98-af3b-c80eab1f7cf9" />


## the whole suite

it's a dictation engine that kept adding jobs. one app, four tricks, zero cloud:

- **talk to your mac.** hold the hotkey, speak, text lands at the cursor in under 100 ms. every app with a cursor, no per-app integrations.
- **notes that file themselves.** quick thoughts become searchable voice notes. pin the good ones, export as markdown, find anything later.
- **capture any call.** zoom, meet, phone calls, recorded straight off your mac's audio, then transcribed and split by speaker. no bot crashes the party.
- **summaries written on your mac.** when a call (or any transcript) ends, the app writes the title, executive summary, key points and verbatim quotes — on-device via apple intelligence (macOS 26+), with a local heuristic fallback on older macOS.

beyond the four:

- **transcript library.** every recording, searchable and sortable, with click-a-word-to-seek playback and editable, persisted speaker labels. rename, export (md / txt / srt / vtt / json), delete.
- **drop in a file.** drag any audio or video — mp3, m4a, wav, mp4 — and it's transcribed and diarized on-device straight into the library. several at once is fine.
- **history.** the last 200 dictations, grouped by day, searchable, cleanly staged for deletion.
- **stats.** lifetime words, dictations, audio seconds and time saved (counted at 35 wpm), plus a per-hour heatmap. all on this mac only.

everything stays on-device: the dictation brain (~470 mb), the speaker-label "ears" (~22 mb, downloaded from transcripts), then the app never touches the internet again. no accounts, no bot in your calendar, no cloud round-trip.

## design decisions

**one dependency: [FluidAudio](https://github.com/FluidInference/FluidAudio).**
the ASR engine runs entirely on-device on apple silicon. i evaluated the alternatives:

| option                                    | verdict                                                                              |
| ----------------------------------------- | ------------------------------------------------------------------------------------ |
| cloud APIs (whisper api, assemblyai, ...) | adds 200-800 ms round trip, per-minute billing, a privacy policy, and an outage mode |
| self-hosted whisper.cpp server            | same latency problem, now i'm ops                                                    |
| on-device via FluidAudio                  | no network after model download, no per-use cost, latency = inference time           |

the ~500 mb model -[ Nvidia Parakeet](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3) - downloads once on first install. after that the app has no reason to ever see the internet again.

**CGEvent synthetic keystrokes for output.**
transcription becomes real keyboard events into whatever app has focus. mail, slack, notes, electron abominations - if it accepts typing, typie works there. no clipboard pollution, no per-app integrations to maintain.

**AppKit for the parts that touch your system, a bundled Svelte web UI (WKWebView) for the windows.**
the dictation engine, hotkeys, notch island and menu bar are native; the settings/stats/onboarding windows are a Svelte 5 app (same design system as this site) served from local files inside a WKWebView, pretty and flexible without shipping a server or a network call.

**carbon-era global hotkeys, fully remappable.**
hold-to-talk on any modifier, rebound in-app. small feature, but it's the difference between a tool and a toy.

**SwiftUI notch panel.**
the robot lives in your macbook notch and pops out while listening. this serves no business purpose. it is simply correct.

## latency

sub-100 ms from releasing the key to text on screen. doing inference locally removes the round trip entirely - the network hop most competitors pay is slower than the actual transcription.

## privacy

not a policy, an architecture:

- audio goes mic -> model -> garbage collector. nothing else
- no analytics, no telemetry, no update pings
- zero network calls after the initial model download
- delete the app and nothing remains

## build it

macos 14+, apple silicon, swift 5.9+.

```bash
cd app
./scripts/build_webui.sh   # rebuild the Svelte web UI into the app resources
./scripts/make_app.sh      # release binary -> build/typie.app
./scripts/make_dmg.sh      # same, plus distributable dmg
```

side-by-side dev build (runs while production typie stays open, own settings,
shares the model, skips the notch):

```bash
cd app
./scripts/make_dev_app.sh && open build/typie-dev.app
```

grant mic + accessibility permissions when asked. it cannot do its job without them, which is more than most apps can say honestly.

## repo layout

```
app/       the mac app (swift, ~20 files, one dependency)
landing/   the website (svelte 5 + vite), featuring a support chatbot whose
           entire knowledge base is "it's free and works fully offline"
```

## pricing

| plan       | price   |
| ---------- | ------- |
| free       | $0      |
| pro        | $0      |
| enterprise | $0/seat |

payment infrastructure is expensive and i could not be bothered.
