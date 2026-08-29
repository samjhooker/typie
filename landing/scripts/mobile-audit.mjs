import { chromium } from 'playwright-core';
const exe = `${process.env.HOME}/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`;
const browser = await chromium.launch({ executablePath: exe });
const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
await page.goto('http://localhost:5173', { waitUntil: 'networkidle' });
await page.waitForTimeout(1500);
const r = await page.evaluate(() => {
  const overflow = document.documentElement.scrollWidth - window.innerWidth;
  // find worst offenders causing overflow
  const wide = [];
  document.querySelectorAll('body *').forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.right > window.innerWidth + 2 && rect.width > 40) {
      const cls = (el.className?.baseVal ?? el.className ?? '').toString().slice(0,40);
      wide.push(`${el.tagName.toLowerCase()}.${cls} w=${Math.round(rect.width)} right=${Math.round(rect.right)}`);
    }
  });
  // touch targets: visible interactive elements smaller than 44x44 in first viewport
  const small = [];
  document.querySelectorAll('a, button, [role="button"], input').forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.width > 0 && rect.height > 0 && rect.bottom < window.innerHeight) {
      if (rect.width < 44 || rect.height < 44) {
        small.push(`${el.tagName.toLowerCase()} ${(el.textContent||el.getAttribute('aria-label')||'').trim().slice(0,24)} ${Math.round(rect.width)}x${Math.round(rect.height)}`);
      }
    }
  });
  return { overflow, wide: wide.slice(0, 8), small: small.slice(0, 14) };
});
console.log(JSON.stringify(r, null, 1));
await browser.close();
