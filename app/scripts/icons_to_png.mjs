// Renders the Lucide SVGs in Sources/Typie/Resources/Icons/*.svg to
// black @4x PNGs (96×96 px). The Swift side loads them with template
// rendering so the shelf can tint them any color. Lucide's stroke icons
// are stroke="currentColor" (black by default), so we rasterize black and
// tint at draw time.
//
// macOS's public SDK has no SVG renderer (NSSVGImageRep is not exposed,
// ImageIO ignores SVG), so a raster at 4x is the crisp-at-13px tradeoff, // the SVGs stay bundled alongside for reference/future use.
import { readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

// resolve relative to this script so the build works from any CWD
const appRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const dir = join(appRoot, 'Sources/Typie/Resources/Icons');
const files = readdirSync(dir).filter((f) => f.endsWith('.svg'));

for (const f of files) {
  const src = join(dir, f);
  const out = join(dir, f.replace(/\.svg$/, '.png'));
  await sharp(src, { density: 96 }) // render the 24×24 viewBox at 24px
    .resize(96, 96) // then scale up cleanly to 4x
    .png()
    .toFile(out);
  console.log(`→ ${f.replace(/\.svg$/, '.png')}`);
}
console.log(`${files.length} icons → PNG @4x`);
