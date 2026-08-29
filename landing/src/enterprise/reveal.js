// Surgical scroll reveals. IntersectionObserver, threshold 0.15,
// unobserve after fire. Transform/opacity/filter only.
export function reveal(node, opts = {}) {
  const delay = opts.delay ?? 0;
  node.style.setProperty('--d', `${delay}s`);
  node.classList.add('ent-reveal');

  const io = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) {
        node.classList.add('ent-in');
        node.classList.remove('ent-reveal');
        io.disconnect();
      }
    },
    { threshold: 0.15, rootMargin: '-40px' }
  );

  io.observe(node);
  return { destroy: () => io.disconnect() };
}

const REDUCED =
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// Count-up for stat numerals. Opacity-free, transform-free, rAF driven.
export function countup(node, opts = {}) {
  const target = Number(node.dataset.count ?? opts.target ?? 0);
  const duration = 900;

  if (REDUCED || !Number.isFinite(target)) {
    node.textContent = String(target);
    return {};
  }

  node.textContent = '0';

  const io = new IntersectionObserver(
    ([entry]) => {
      if (!entry.isIntersecting) return;
      io.disconnect();

      const start = performance.now();
      const tick = (now) => {
        const t = Math.min((now - start) / duration, 1);
        // ease-out cubic: fast start, decelerating settle
        const eased = 1 - Math.pow(1 - t, 3);
        node.textContent = String(Math.round(eased * target));
        if (t < 1) requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    },
    { threshold: 0.4 }
  );

  io.observe(node);
  return { destroy: () => io.disconnect() };
}
