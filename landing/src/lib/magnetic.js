/* Magnetic pull, signature micro-animation for the hero option key.
   The key lerps toward the cursor inside a proximity zone and springs
   home when it leaves. Purely presentational: applied to the .keywrap
   wrapper so the .key press transform is untouched. */
export function magnetic(node, { strength = 0.32, radius = 56 } = {}) {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (!matchMedia('(hover: hover) and (pointer: fine)').matches) return;

  let raf = null;
  let tx = 0,
    ty = 0; // target offset
  let cx = 0,
    cy = 0; // current offset
  let engaged = false;

  function loop() {
    /* critically-damped-ish lerp: fast approach, soft settle */
    cx += (tx - cx) * 0.16;
    cy += (ty - cy) * 0.16;
    node.style.transform = `translate(${cx.toFixed(2)}px, ${cy.toFixed(2)}px)`;
    if (engaged || Math.abs(tx - cx) > 0.15 || Math.abs(ty - cy) > 0.15) {
      raf = requestAnimationFrame(loop);
    } else {
      node.style.transform = '';
      raf = null;
    }
  }

  function kick() {
    if (!raf) raf = requestAnimationFrame(loop);
  }

  function onMove(e) {
    const r = node.getBoundingClientRect();
    const mx = e.clientX - (r.left + r.width / 2);
    const my = e.clientY - (r.top + r.height / 2);
    const zone = Math.max(r.width, r.height) / 2 + radius;
    if (Math.hypot(mx, my) < zone) {
      engaged = true;
      tx = mx * strength;
      ty = my * strength;
    } else {
      engaged = false;
      tx = 0;
      ty = 0;
    }
    kick();
  }

  window.addEventListener('pointermove', onMove, { passive: true });

  return {
    destroy() {
      window.removeEventListener('pointermove', onMove);
      if (raf) cancelAnimationFrame(raf);
      node.style.transform = '';
    },
  };
}
