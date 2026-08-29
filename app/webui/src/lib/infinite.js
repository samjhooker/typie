/**
 * IntersectionObserver Svelte action, calls `cb` whenever the node scrolls
 * near the viewport. Used as the sentinel for progressive lists, so the
 * library stays fast with hundreds of transcripts.
 *
 * Root is the viewport, which works even though scrolling happens inside
 * AppShell's `.content` pane.
 */
export function infinite(node, cb) {
  let fire = cb;
  const io = new IntersectionObserver(
    (entries) => {
      if (entries.some((e) => e.isIntersecting)) fire();
    },
    { rootMargin: '600px' } // start loading well before the bottom is reached
  );
  io.observe(node);
  return {
    update(next) {
      fire = next;
    },
    destroy() {
      io.disconnect();
    },
  };
}
