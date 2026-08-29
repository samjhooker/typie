/* Ripple click — signature micro-animation for the download CTAs.
   Spawns a radial dot exactly at the pointer position and scales it
   out while fading. Pointerdown only; navigation is untouched. */
export function ripple(node) {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (!matchMedia('(hover: hover) and (pointer: fine)').matches) return;

  const style = getComputedStyle(node);
  if (style.position === 'static') node.style.position = 'relative';
  node.style.overflow = 'hidden';

  function spawn(e) {
    const r = node.getBoundingClientRect();
    const d = Math.max(r.width, r.height) * 2.2;
    const light = node.classList.contains('btn-butter') || node.classList.contains('btn-ghost');
    const el = document.createElement('span');
    el.className = 'ripple-dot';
    el.style.width = el.style.height = `${d}px`;
    el.style.left = `${e.clientX - r.left - d / 2}px`;
    el.style.top = `${e.clientY - r.top - d / 2}px`;
    el.style.backgroundColor = light ? 'rgba(19, 23, 34, 0.14)' : 'rgba(255, 255, 255, 0.35)';
    node.appendChild(el);
    el.addEventListener('animationend', () => el.remove());
  }

  node.addEventListener('pointerdown', spawn);

  return {
    destroy() {
      node.removeEventListener('pointerdown', spawn);
    },
  };
}
