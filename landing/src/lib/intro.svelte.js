/**
 * Intro veil state: page loads desaturated with a single pink glow
 * marking the option key, then color fades back in.
 */
export const intro = $state({
  active: true,
  glow: null // { x, y } viewport coords
});
