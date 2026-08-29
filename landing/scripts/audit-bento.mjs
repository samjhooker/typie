// Playwright audit: screenshot the bento section (light + dark), measure
// card balance, and detect horizontal overflow. Run from landing/.
import { chromium } from 'playwright-core';
import { existsSync } from 'node:fs';

const exe =
  process.env.CHROME_PATH ||
  `${process.env.HOME}/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`;
if (!existsSync(exe)) {
  console.error('chrome not found at', exe);
  process.exit(1);
}

const base = process.env.BASE_URL || 'http://localhost:5173';
const browser = await chromium.launch({ executablePath: exe });
const report = { light: null, dark: null };

async function audit(theme) {
  const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
  await page.goto(base, { waitUntil: 'networkidle' });
  if (theme === 'dark') {
    await page.evaluate(() => {
      localStorage.setItem('typie-theme', 'dark');
      document.documentElement.dataset.theme = 'dark';
    });
    await page.waitForTimeout(300);
  }
  // hide fixed-position chrome (sticky nav) so section shots aren't polluted
  await page.evaluate(() => {
    for (const el of document.querySelectorAll('body *')) {
      if (getComputedStyle(el).position === 'fixed') el.style.visibility = 'hidden';
    }
  });
  // freeze animations for deterministic shots
  await page.addStyleTag({
    content: `*, *::before, *::after { animation-play-state: paused !important; }`,
  });
  const section = page.locator('#features');
  await section.scrollIntoViewIfNeeded();
  await page.waitForTimeout(900); // reveal transitions
  await section.screenshot({
    path: `audit-bento-${theme}.png`,
    animations: 'disabled',
  });

  const data = await page.evaluate(() => {
    const cards = [...document.querySelectorAll('#features .card')];
    const rows = new Map();
    for (const c of cards) {
      const r = c.getBoundingClientRect();
      // group by rounded top position (row bands)
      const key = Math.round(r.top / 40) * 40;
      if (!rows.has(key)) rows.set(key, []);
      rows.get(key).push({
        cls: c.className.replace('card ', ''),
        w: Math.round(r.width),
        h: Math.round(r.height),
        bottom: Math.round(r.bottom),
      });
    }
    const rowsArr = [...rows.entries()].sort((a, b) => a[0] - b[0]);
    return {
      docOverflow:
        document.documentElement.scrollWidth > window.innerWidth
          ? `${document.documentElement.scrollWidth} > ${window.innerWidth}`
          : null,
      rows: rowsArr.map(([k, cards]) => ({
        top: k,
        cards,
        aligned:
          new Set(cards.map((c) => c.bottom)).size === 1 &&
          new Set(cards.map((c) => c.h)).size === 1,
      })),
    };
  });
  report[theme] = data;
  await page.close();
}

await audit('light');
await audit('dark');
await browser.close();

for (const theme of ['light', 'dark']) {
  const r = report[theme];
  console.log(`\n══ ${theme.toUpperCase()} ══`);
  console.log('doc horizontal overflow:', r.docOverflow || 'none ✓');
  for (const row of r.rows) {
    const sizes = row.cards.map((c) => `${c.cls} ${c.w}×${c.h}`).join(' | ');
    console.log(`row@${row.top}  aligned=${row.aligned ? '✓' : '✗'}  ${sizes}`);
  }
}
