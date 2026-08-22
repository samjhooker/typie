# typie

> hold a key. say the thing. it's typed.
> 100% on your mac. 100% free. 0% subscription.

**typie** is a tiny robot that lives in your mac menu bar and types whatever you say, in under 100 milliseconds, without your voice ever leaving your machine.

## why this exists

so there's this dictation app. it's genuinely good. it's also $12/month.

$12/month. for dictation. forever. to rent the ability to talk at your own computer.

i did the math: one year of that subscription costs more than the mac mini i'd rather spend money on. so instead of subscribing, i spent a weekend building the thing myself, and now you can have it for exactly $0.

this is not a business. there is no pricing page trickery (okay, there's a *joke* pricing page). there's just an app that runs on your computer and does its job.

## what it does

- hold ⌥ (or any key, if you're freaky like that), speak, release
- your words appear wherever your cursor is - mail, slack, notes, your cursed crm
- **under 100 ms** from lips to letters. by the time your sentence ends, it's on screen
- ~25 languages, zero settings
- works offline. on a plane. in a subway. in a cabin in the woods
- lives in the notch. literally pops out of it like a little robot butler

## privacy

your voice is processed entirely on-device and thrown away the moment it becomes text.

- no cloud. there is no server to hack, subpoena, or "temporarily discontinue"
- no analytics, telemetry, cookies, or accounts
- we can't hear you. we don't want to. we have no ears

the ~500 mb model downloads once on first install. after that, typie never touches the internet again.

## pricing

| plan | price |
|---|---|
| free | $0 |
| pro | $0 |
| enterprise | $0 per seat |

yes, really. payment infrastructure is expensive and i couldn't be bothered.

## building it

macos 14+, apple silicon, [swift](https://www.swift.org/install/) 5.9+.

```bash
# build typie.app
cd app
./scripts/make_app.sh

# or a distributable dmg
./scripts/make_dmg.sh
```

the app lands in `app/build/typie.app`. drag it to applications, grant mic + accessibility permissions when asked (it needs them to listen and type, that's the whole job), go.

### repo layout

```
app/       the mac app (swift, no dependencies worth mentioning)
landing/   the website (svelte + vite), including the support robot
           who will answer every question with "it's free and works
           fully offline"
```

## faq

**is it really free?**
payment infrastructure is expensive and i couldn't be bothered. $0 means $0.

**where does my voice go?**
nowhere. on-device processing, audio tossed instantly. we can't hear you.

**can i remap the key?**
yes. if you're freaky like that.

## license

mit. do whatever. if you make money with it, i'm honestly impressed, tell me how.
