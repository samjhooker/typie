# typie

> hold a key. say the thing. it's typed.
> a native macos dictation engine that answers in under 100 ms and never touches the internet.

yes, it's just another transcription app. there are roughly forty of them now. three launched while you were reading this sentence.

most of them share one design decision: your voice goes to their cloud, and you pay rent on your own voice. typie makes the opposite bet - **all inference local, zero backend, sub-100 ms end-to-end** - and turns that constraint into the product.

## what it actually is

a native macos menu bar app. hold your hotkey, talk, let go. text lands wherever your cursor is.

```
you ──hold ⌥──> mic ──> on-device ASR model ──> CGEvent keystrokes ──> whatever app you're in
                         (~500 mb, local)          <100 ms later
```

## design decisions

**one dependency: [FluidAudio](https://github.com/FluidInference/FluidAudio).**
the ASR engine runs entirely on-device on apple silicon. i evaluated the alternatives:

| option | verdict |
|---|---|
| cloud APIs (whisper api, assemblyai, ...) | adds 200-800 ms round trip, per-minute billing, a privacy policy, and an outage mode |
| self-hosted whisper.cpp server | same latency problem, now i'm ops |
| on-device via FluidAudio | no network after model download, no per-use cost, latency = inference time |

the ~500 mb model downloads once on first install. after that the app has no reason to ever see the internet again.

**CGEvent synthetic keystrokes for output.**
transcription becomes real keyboard events into whatever app has focus. mail, slack, notes, electron abominations - if it accepts typing, typie works there. no clipboard pollution, no per-app integrations to maintain.

**AppKit/SwiftUI, zero UI framework tax.**
a menu bar utility should not ship a browser runtime. the whole app is ~20 swift files with one package dependency.

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
./scripts/make_app.sh     # release binary -> build/typie.app
./scripts/make_dmg.sh     # same, plus distributable dmg
```

grant mic + accessibility permissions when asked. it cannot do its job without them, which is more than most apps can say honestly.

## repo layout

```
app/       the mac app (swift, ~20 files, one dependency)
landing/   the website (svelte 5 + vite), featuring a support chatbot whose
           entire knowledge base is "it's free and works fully offline"
```

## pricing

| plan | price |
|------|-------|
| free | $0 |
| pro | $0 |
| enterprise | $0/seat |

payment infrastructure is expensive and i could not be bothered.

## license

mit. do whatever.
