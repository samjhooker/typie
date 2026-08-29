import { chromium } from 'playwright-core';
const exe = `${process.env.HOME}/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`;
const browser = await chromium.launch({ executablePath: exe });
const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
await page.goto('http://localhost:5173', { waitUntil: 'networkidle' });
const r = await page.evaluate(() => {
  window.scrollTo({ left: 300 });
  return { scrollX: window.scrollX, canScroll: window.scrollX > 0 };
});
console.log(JSON.stringify(r));
await browser.close();
