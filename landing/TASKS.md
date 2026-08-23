# Typie Landing — Redesign (mockup-matched) ✅

Design reference: `~/Downloads/ChatGPT Image Aug 23, 2026, 01_46_56 PM.png`
The robot stays the main symbol throughout. All illustration/photo slots are
wired via `AssetSlot.svelte` — drop files into `public/assets/`, zero code changes.

## Status: build passing, all sections restructured

| # | Task | Status |
|---|------|--------|
| 1 | Tokens remapped in `app.css` (pastel card fills, pink band, footer green, flat buttons, Inter display face, 24px card radius) | ✅ |
| 2 | Fonts: Inter 400–900 + Caveat + IBM Plex Mono (`index.html`) | ✅ |
| 3 | `AssetSlot.svelte` scaffold (probes `public/assets/{id}.{png,webp,svg}`) | ✅ |
| 4 | `Nav.svelte` — flat bar, center links, black pill CTA, blur-on-scroll | ✅ |
| 5 | `Hero.svelte` — script kicker, stacked Press/Talk/Typed (ink/periwinkle/butter), "Hold ⌥ option" line + arrow doodle + squiggle, HoldStage framed in a MacBook lid; intro glow + auto-demo preserved | ✅ |
| 6 | `AppsRow.svelte` — "Works wherever you type" + 7 white cards incl. dashed "Any app"; periwinkle squiggle underline | ✅ |
| 7 | `FeatureCards.svelte` — 2×2 pastel cards (lavender/blue/cream/mint): Talk naturally / Keep your words private / Use it everywhere / Never break your flow; robot appears in cards as fallback art | ✅ |
| 8 | `Notch.svelte` — pink band, three black state pills (Idle / Listening / Typed), auto-cycles every 2.6s, animated waveform, robot glyph in idle pill | ✅ |
| 9 | `Testimonials.svelte` — centered heading w/ hotpink underline, 3 quote cards, robot cameos peeking from edges | ✅ |
| 10 | `CtaBanner.svelte` — butter banner "Your voice. Anywhere.", black download CTA, macOS specs line, illustrated hills/trees/house SVG scene at bottom edge (`id="pricing"` anchor for nav) | ✅ |
| 11 | `Faq.svelte` — two-column layout, hairline rows, pink +/− toggles, starburst doodle | ✅ |
| 12 | `Footer.svelte` — dark green wave, robot peeking over the crest, Product/Resources/Company columns, X + GitHub icons | ✅ |
| 13 | `App.svelte` recomposed; old Features/Languages/Manifesto/Pricing/Finale removed (in git history if ever needed) | ✅ |
| 14 | `Logo.svelte` accepts `color` prop (footer uses cream); `PageShell` fixed for removed classes; ChatBot verified palette-coherent | ✅ |

## Asset drop-ins (when final art arrives)

Drop files into `public/assets/` with these names:

| File | Slot | Notes |
|------|------|-------|
| `hero-doodle.png` | Hero squiggle under hold line | ~220px wide |
| `apps-row.png` | Entire app-card row (replaces inline icon cards) | full-width strip |
| `feature-talk.png` | "Talk naturally" art | waveform + mascot |
| `feature-privacy.png` | "Keep your words private" art | padlock scene |
| `feature-everywhere.png` | "Use it everywhere" art | mascot + orbiting apps |
| `feature-flow.png` | "Never break your flow" art | keycap render |
| `avatar-0.png` `avatar-1.png` `avatar-2.png` | Testimonial headshots | 52px circles |
| `cta-scene.png` | CTA banner bottom landscape | full-width, transparent top |

`.webp` and `.svg` variants also work. Until then each slot renders its inline
fallback (SVG illustrations + the robot glyph).

## Remaining polish ideas (non-blocking)

- [ ] Real testimonial avatars/photos (blocked on assets)
- [ ] Mobile nav menu (links hidden < 860px currently — fine while only 4 links)
- [ ] Lighthouse pass after assets land
