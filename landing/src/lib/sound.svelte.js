/* tiny synth for UI blips - no audio files, generated on the fly.
   off until the visitor asks for it (autoplay policies demand a
   gesture anyway) */
export const sound = $state({ on: false });

let ctx;

/* real key-clack samples (public/sounds/), loaded lazily on first
   use after the visitor opts in — never on page load */
let buffers = {};

async function sample(name) {
  try {
    ctx ??= new (window.AudioContext || window.webkitAudioContext)();
    if (ctx.state === 'suspended') ctx.resume();
    buffers[name] ??= await ctx.decodeAudioData(
      await (await fetch(`sounds/${name}.wav`)).arrayBuffer()
    );
    const src = ctx.createBufferSource();
    src.buffer = buffers[name];
    const g = ctx.createGain();
    g.gain.value = 0.35;
    src.connect(g);
    g.connect(ctx.destination);
    src.start();
  } catch {
    blip(); /* sample failed → synth fallback, still charming */
  }
}

export const keyDown = () => sound.on && sample('keypress');
export const keyUp = () => sound.on && sample('keyrelease');

export function blip(freq = 520, dur = 0.08, type = 'triangle', gain = 0.05) {
  if (!sound.on) return;
  try {
    ctx ??= new (window.AudioContext || window.webkitAudioContext)();
    if (ctx.state === 'suspended') ctx.resume();
    const o = ctx.createOscillator();
    const g = ctx.createGain();
    o.type = type;
    o.frequency.value = freq;
    g.gain.setValueAtTime(gain, ctx.currentTime);
    g.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + dur);
    o.connect(g);
    g.connect(ctx.destination);
    o.start();
    o.stop(ctx.currentTime + dur);
  } catch {
    /* no audio, no problem */
  }
}
