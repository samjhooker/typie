// Canonical notch geometry, single source of truth for landing.
// Mirrors app/Sources/Typie/NotchPanel.swift + NotchView.swift so the
// marketing site cannot drift from the shipped island.
// • idleW, measured hardware notch on 14" MBP (~174-186). 176 is the
//              design compromise that reads correct at landing scale.
// • expandedW, app: max(320, notchWidth+140) ≈ 320-340. 344 matches the
//               Hero's 340 hover wings with 4px breathing room.
// • h, menu bar / notch height. Real mac is 32-33pt; landing lid
//              mocks it at 24px (Hero) vs 28-34px (Notch band). We expose
//              both so each surface can pick its scale while sharing radii.
// • rIdle/rExpanded, UnevenRoundedRectangle bottom corners: 10 → 18-20
//                     (app: 10 idle, 20 expanded). Continuous curve.
// Update here and both Hero + Notch band reflow together.

export const NOTCH = {
  // hero lid mock (inside the Mac window, 24px menubar), mirrors NotchPanel: idle 10 → expanded 20 continuous
  hero: {
    idleW: 148,
    idleH: 24,
    expandedW: 340,
    expandedH: 24,
    menuExpandedW: 340,
    menuH: 108, // 24 pill + 84 dropdown
    rIdle: 10,
    rExpanded: 20,
  },
  // feature band (standalone large notch, 28/34 scale), same radii, scaled
  band: {
    idleW: 96,
    idleH: 28,
    expandedW: 280,
    expandedH: 34,
    rIdle: 10,
    rExpanded: 18,
  },
  // app truth (for reference, not directly rendered in landing)
  app: {
    idleW: 186,
    idleH: 32,
    expandedW: 344,
    rIdle: 10,
    rExpanded: 20,
  },
  // shared visual tokens
  tokens: {
    bg: '#000',
    shadowIdle: '0 3px 10px rgba(0,0,0,.16)',
    shadowExpanded: '0 8px 24px rgba(0,0,0,.38)',
    shadowApp: '0 4px 14px rgba(0,0,0,.28)',
    camGradient:
      'radial-gradient(circle at 35% 32%, #4a5568 0 18%, #151a22 42%, #07080c 100%)',
    camRing: 'inset 0 0 0 1px rgba(120,130,150,.35), 0 0 0 2px #000',
  },
};
