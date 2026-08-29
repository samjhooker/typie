/**
 * Theme: system default (prefers-color-scheme), overridable to
 * light/dark in Settings. Writes data-theme on <html> so the CSS
 * token blocks swap, and tells the Swift window so the native
 * title bar + under-page color follow along.
 */
import { ui } from './bridge.svelte.js';

export function resolveDark(pref) {
  const p = pref ?? 'system';
  if (p === 'dark') return true;
  if (p === 'light') return false;
  return matchMedia('(prefers-color-scheme: dark)').matches;
}

export function applyTheme() {
  const dark = resolveDark(ui.settings.appearance);
  document.documentElement.dataset.theme = dark ? 'dark' : 'light';
  // native chrome follows: window bg + title bar + WKWebView under-page
  window.webkit?.messageHandlers.typie?.postMessage({
    type: 'windowTheme',
    dark,
  });
}
