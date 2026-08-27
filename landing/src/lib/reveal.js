export function reveal(node, { delay = 0 } = {}) {
  node.classList.add('reveal');
  if (delay) node.style.transitionDelay = `${delay}ms`;

  let done = false;
  const show = () => {
    if (done) return;
    done = true;
    node.classList.add('visible');
    try { io.disconnect(); } catch {}
  };

  const io = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) show();
    },
    { threshold: 0.14, rootMargin: '0px 0px -8% 0px' }
  );

  io.observe(node);
  // fallback: if observer never fires (screenshot, no scroll, offscreen), show after short delay
  const t = setTimeout(show, 900 + delay);

  return {
    destroy() {
      clearTimeout(t);
      try { io.disconnect(); } catch {}
    }
  };
}

export function spoken(node, { ramble = '', delay = 0 } = {}) {
  const clean = node.textContent.trim();
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (reduce || !ramble) {
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          node.classList.add('visible');
          io.disconnect();
        }
      },
      { threshold: 0.3 }
    );
    node.classList.add('reveal');
    io.observe(node);
    return { destroy() { io.disconnect(); } };
  }

  node.textContent = clean;
  const cleanH = node.offsetHeight;
  node.classList.add('spoken-pending');
  node.textContent = ramble;
  const rambleH = node.offsetHeight;
  node.style.minHeight = `${Math.max(rambleH, cleanH)}px`;

  let timer;
  const io = new IntersectionObserver(
    ([entry]) => {
      if (!entry.isIntersecting) return;
      io.disconnect();
      timer = setTimeout(() => {
        node.classList.remove('spoken-pending');
        node.classList.add('typing-caret');
        let i = 0;
        const step = () => {
          i++;
          node.textContent = clean.slice(0, i);
          if (i < clean.length) {
            timer = setTimeout(step, 26);
          } else {
            node.classList.remove('typing-caret');
          }
        };
        node.textContent = '';
        step();
      }, delay);
    },
    { threshold: 0.35 }
  );

  io.observe(node);

  return {
    destroy() {
      io.disconnect();
      clearTimeout(timer);
    }
  };
}

export function parallax(node, { speed = 0.12 } = {}) {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  let raf = null;

  function update() {
    raf = null;
    const r = node.getBoundingClientRect();
    const mid = r.top + r.height / 2 - window.innerHeight / 2;
    node.style.transform = `translate3d(0, ${(mid * -speed).toFixed(1)}px, 0)`;
  }

  function onScroll() {
    if (!raf) raf = requestAnimationFrame(update);
  }

  update();
  window.addEventListener('scroll', onScroll, { passive: true });

  return {
    destroy() {
      window.removeEventListener('scroll', onScroll);
      if (raf) cancelAnimationFrame(raf);
    }
  };
}
