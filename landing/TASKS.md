# Typie Landing — "Fun Pass" Tasks

Critique of current build vs. goal: **sparse, corporate, empty** → want **fun,
interactive, robot-everywhere, pops of color, clean**.

## Fault list (section by section)

| # | Section | Fault | Fix |
|---|---------|-------|-----|
| F1 | Global | Robots are static decoration; eyes never move; page feels dead between interactions | **Eye tracking**: all robots' pupils follow the cursor site-wide (reduced-motion aware) |
| F2 | Hero | No mascot in the copy column — the only robot hides inside the laptop; hero reads corporate | **Robot buddy** next to headline: big robot whose mood is bound to *live* dictation state (`listening` wiggle / `done` pop with ms), speech bubble narrating ("psst… hold ⌥" → "listening…" → "typed ✓ 62 ms"), clickable to start dictation |
| F3 | Global | Cream emptiness between sections — no color pops anywhere | **Pastel background blobs** behind hero/features/testimonials/CTA (soft radial gradients) + re-add handwritten kicker notes that were dropped in redesign |
| F4 | Feature cards | Art is small, floats awkwardly; cards don't respond; feel like a slide deck | **Micro-interactions per card**: waveform dances + robot boogies on hover; padlock shackle opens on hover; app icons orbit the robot; keycap depresses on hover; cards tilt/lift |
| F5 | Apps row | Flat white tiles, nothing alive | Staggered float animation, colored hover lift, **robot peeking over the row** |
| F6 | Testimonials | Corner cameos clipped half off-screen; cards static | Fully-visible bobbing robots at edges (holding a tiny "hi!" bubble), pastel avatar rings |
| F7 | FAQ | Starburst only; heading lonely; answers appear instantly (corporate) | Thinking-robot beside the heading; answers type out with blinking caret |
| F8 | CTA banner | Landscape is nice but uninhabited | **Robot sitting on the front hill**, waving; twinkling stars |
| F9 | Notch band | Inactive pills too washed out; fine otherwise | Keep cycle, richer contrast (done), pills clickable to set state manually |

## Order
F1 → F2 → F3 → F4 → F5 → F6 → F7 → F8 → screenshot sweep after each group.
