import { chromium } from 'playwright-core';
const exe = `${process.env.HOME}/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`;
const browser = await chromium.launch({ executablePath: exe });
const page = await browser.newPage({ viewport: { width: 1440, height: 960 } });
await page.goto('http://localhost:5173', { waitUntil: 'networkidle' });
await page.evaluate(() => { for (const el of document.querySelectorAll('body *')) { if (getComputedStyle(el).position === 'fixed') el.style.visibility = 'hidden'; } });
// catch the pressed frame: pause animations mid-press
await page.addStyleTag({ content: `*,*::before,*::after{animation-play-state:paused !important;} .optcap{animation-delay:1s !important;}` });
const deck = page.locator('.mac-deck');
await deck.scrollIntoViewIfNeeded();
await page.waitForTimeout(1200);
await deck.screenshot({ path: '/tmp/hero-key.png' });
// bento key pressed frame
const card = page.locator('#features .c2 .demoStack');
await card.scrollIntoViewIfNeeded();
await page.waitForTimeout(600);
await card.screenshot({ path: '/tmp/bento-key.png' });
await browser.close();
