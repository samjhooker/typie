# [typie.cc](https://typie.cc/)

> hold a key. say the thing. it's typed.
> a native macos dictation engine that answers in under 100 ms and never touches the internet.

<img width="1643" height="1013" alt="Screenshot 2026-08-23 at 10 08 57 PM" src="https://github.com/user-attachments/assets/c2586213-7952-40d0-953a-7d73fe30c7dc" />

yes, it's just another transcription app. Powered locally by [Nvidia Parakeet](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3)

https://typie.cc/

most existing transcription apps share a common design decision: your voice goes to their cloud, and you pay rent on your own voice. typie makes the opposite bet - **all inference local, zero backend, sub-100 ms end-to-end** - and turns that constraint into the product.

<img width="1642" height="573" alt="Screenshot 2026-08-23 at 10 09 27 PM" src="https://github.com/user-attachments/assets/2d804240-1d7f-478e-b297-6fad40e1aeb2" />

<img width="1623" height="581" alt="Screenshot 2026-08-23 at 10 09 15 PM" src="https://github.com/user-attachments/assets/2f4dcdc7-fd6e-4cdf-844d-df825420fc34" />

## what it actually is

a native macos menu bar app. hold your hotkey, talk, let go. text lands wherever your cursor is.

```
you ──hold ⌥──> mic ──> on-device ASR model ──> CGEvent keystrokes ──> whatever app you're in

                        (~500 mb, local)          <100 ms later
```

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
