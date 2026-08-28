# Homepage v3 — The Vibe Pass

*Replaces the earlier v3 (offline flex / name-the-enemy / receipts — shelved: no dunking, no star-counting). Goal, in Sam's words: "beautifully laid out and airy, yet you can understand the full vibe of the product."*

**The diagnosis.** WisprFlow and Superwhisper feel like stories because of four mechanics — one idea per viewport, product owning the screen, extreme type-scale contrast, second-person present tense. Typie has the assets (a live Mac replay, real sounds, a good H1) but presents them as well-organized rooms instead of a paced narrative. This pass is about *pace and presence*, not new content.

---

## Task C — The page dictates itself (signature moment) 🏆

Between the hero and the marquee: a full-viewport typographic beat. As it scrolls into view, the line **"hold a key. say the thing. it's typed."** types itself letter-by-letter — with the real `keypress.wav` / `keyrelease.wav` sounds, triggered on scroll progress, respecting `prefers-reduced-motion` (silent + pre-typed there).

Huge Fraunces italic on "it's typed." Mono caret blinking. Nothing else on screen. The page performs the product's core verb instead of describing it.

**DoD:** scrolling through the beat feels like watching typie work. One line, one sound design, zero UI chrome.

## Task A — Scene pace: one idea per viewport

Each major beat gets breathing room to read as a page-turn, not a stacked document:

- Hero + Mac: one screen, complete.
- Marquee section: its own screen.
- Quote band: full viewport height, dead-center. (Interfere's quote band energy.)
- Security rows, FAQ, final CTA: paced, centered, unhurried.

Concretely: `min-height: 90–100svh` + centered flex on the beats that deserve a full page-turn. Remove the `.field` uniform padding that currently makes everything the same height.

**DoD:** the scroll has rhythm — fast through light sections, resting on the important ones.

## Task B — Let the Mac own the screen

The demo is the best asset and currently sits as a 1020px prop. Scale its presence: full container width, tighter crop on the stage, drop the centered-and-shrunk feeling. The Mac should feel like the page's protagonist, not a screenshot in an article.

**DoD:** at 1440px the Mac is unmissable and the scene inside it is comfortably readable.

## Task D — Type scale + metadata language

Commit to the contrast that makes their pages feel expensive:

- Chapter display type up to 72–96px where a beat earns it (quote, final CTA, the Task C moment).
- Tiny JetBrains Mono metadata as the factual voice: `80ms · 25 languages · MIT · no account` — one consistent micro-label style used everywhere facts appear (replacing remaining mixed pill/mono styles).
- One spacing scale; more space above headings than below (already house rule).

**DoD:** at 25% zoom the page reads as three sizes — BIG, body, tiny — and nothing in between.

## Task E — Slower, costlier motion

Fewer animated things, each feeling expensive: longer reveals (700–900ms), scroll-linked arrival (elements animate *as you arrive*, not a fixed fade-up everywhere), one eased curve family. The current single fade-up pattern repeats on every section — vary it or calm it.

**DoD:** motion feels like one hand placed everything, slowly.

---

## Shelved (from the earlier draft)

- Offline toggle in the demo menubar — a quiet, honest version may return later as a delight detail, not a flex.
- Vs-built-in-dictation comparison — the FAQ answer covers it; a whole section is argumentative.
- GitHub receipts / logos — not earned yet, and doesn't need to be.
- Persona pages, video tutorials, mic-test utility — real ideas, separate surfaces, later.
