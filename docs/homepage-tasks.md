# Homepage Redesign — Task Series

*Companion to homepage-audit.md. Work these in order. Each task is independently shippable — do one, look at it, then decide. Don't batch: the point of "minimal and powerful" is that each cut has to visibly earn its keep.*

---

## Task 1 — Hero diet ✅

Strip the first screen down to interfere's skeleton:

- Kill the eyebrow pill, the 4 guarantee badges, the stage-head hint, the under-Mac hint text
- Kill the 4 banner cards → replace with **4 minimal text tabs** (Dictate · Capture · Transcribe · Notes) above or beside the Mac — same click wiring, ~1/10th the pixels
- One CTA only: **Download for Mac — free**. GitHub becomes a quiet text link next to it
- Sub-copy cut to ≤20 words
- The Mac becomes the full-width focal point under the headline
- Demo engine (timeline, tour, notch, cursor, dock) untouched

**Definition of done:** at 1440×900 you see headline, one button, four small words, and the Mac. Nothing else.

## Task 2 — Delete the strip ✅

Remove the "whole deal — no asterisks" 4-pill section entirely. The guarantees already live in the security section and FAQ where they can be *substantiated* instead of chanted.

**DoD:** guarantees appear exactly twice on the page (security, FAQ). Count them.

## Task 3 — Testimonials → one quote ✅

Replace the 3-card grid with a single centered quote band (interfere-style, pastel wash, one attribution). Pick the strongest quote. If attribution feels fabricated, drop first-name-only or cut the section entirely.

**DoD:** one quote, one attribution, zero avatar photos.

## Task 4 — Security section simplification ✅

*(Revised per the impeccable craft floor: no `01/02/03` section numbers, no unicode glyph icons — the current ⊘ ⌁ ◇ mono chips are exactly the “unicode standing in for an icon system” crime.)*

Rebuild as three quiet rows: drawn SVG icon (same stroke language as the notch menu icons) + short heading + one ≤14-word line. Keep the “show me the proof” terminal commands collapsed for skeptics — that part is genuinely good. Kill repeated guarantee phrasing inside the cards.

**DoD:** 3 rows, no numbers, no unicode glyphs, proof still one click away.

## Task 5 — FAQ trim ✅

8 items → 6. Single column, tighter type, less boxy (fewer borders, more list). Merge the two dictation-vs-builtin + internet questions if possible.

**DoD:** 6 questions, one column, scan in 20 seconds.

## Task 6 — Final CTA de-decoration + footer ghost wordmark ✅

- Final CTA: headline + one sub + one black button. Kill gradient italic, kill the sparkle pseudo-elements
- Footer: interfere-style giant ghost wordmark ("typie" at ~15vw, 4% opacity) behind the links

**DoD:** the last screen looks like a signature, not a confetti cannon.

## Task 7 — Global color diet ✅

*(Per the impeccable craft floor, also bans: kickers/eyebrows above headings — AppsRow's rotated pink “works wherever you type” script kicker and Testimonials' mono label both go — and gradient text, which covers the final CTA's gradient italic already covered in Task 6.)*

- One accent: hotpink. Audit every section for lavender/butter/mint/lime multi-color noise; those live in the app demo only, not in the page chrome
- Kill every kicker above section headings; headings carry their own weight
- Unify pill/badge radius + padding across nav, tabs, buttons
- AppsRow marquee: keep one row of icons (it earns its place), cut to one track

**DoD:** screenshot the full page at 25% zoom — you should see white, near-black, and one pink. Anything else has to justify itself. Then run the impeccable detector and clear it.
