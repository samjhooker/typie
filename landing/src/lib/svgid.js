/**
 * Inline SVGs often declare gradients/filters with short generic ids ("a", "e").
 * Injecting several via {@html} causes id collisions - the browser resolves
 * url(#a) to the FIRST match in the document, breaking colors everywhere else.
 * nsSvg() namespaces all ids (and their references) so every instance is unique.
 */
export function nsSvg(svg, ns) {
  if (!svg) return '';
  if (typeof svg !== 'string') svg = svg.svg ?? String(svg);
  if (!svg.includes(' id=')) return svg;
  const safe = String(ns).replace(/\W+/g, '');
  let out = svg;
  const seen = new Set();
  for (const m of svg.matchAll(/\sid="([^"]+)"/g)) {
    const id = m[1];
    if (seen.has(id)) continue;
    seen.add(id);
    out = out.split(` id="${id}"`).join(` id="${safe}-${id}"`);
    out = out.split(`url(#${id})`).join(`url(#${safe}-${id})`);
    out = out.split(`url('#${id}')`).join(`url('#${safe}-${id}')`);
    out = out.split(`href="#${id}"`).join(`href="#${safe}-${id}"`);
    out = out.split(`xlink:href="#${id}"`).join(`xlink:href="#${safe}-${id}"`);
  }
  return out;
}
