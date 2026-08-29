/**
 * Landing theme controller — mirrors the Mac app's system exactly:
 * 'system' (default, follows prefers-color-scheme live) | 'light' | 'dark'.
 * Persisted in localStorage under 'typie-appearance' (migrates the old
 * binary 'typie-theme' key). index.html applies data-theme pre-paint
 * to avoid a flash; this module re-applies + watches system changes.
 */

export const appearance = $state({ pref: 'system' });

const KEY = 'typie-appearance';

export function resolveDark(pref) {
  const p = pref ?? 'system';
  if (p === 'dark') return true;
  if (p === 'light') return false;
  return matchMedia('(prefers-color-scheme: dark)').matches;
}

export function applyTheme() {
  document.documentElement.dataset.theme = resolveDark(appearance.pref)
    ? 'dark'
    : 'light';
}

export function setAppearance(pref) {
  appearance.pref = pref;
  try {
    localStorage.setItem(KEY, pref);
  } catch {}
  applyTheme();
}

export function initTheme() {
  let pref = 'system';
  try {
    pref = localStorage.getItem(KEY) ?? 'system';
    // migrate the old binary toggle: an explicit choice stays explicit
    const legacy = localStorage.getItem('typie-theme');
    if (
      !localStorage.getItem(KEY) &&
      (legacy === 'dark' || legacy === 'light')
    ) {
      pref = legacy;
      localStorage.setItem(KEY, legacy);
    }
  } catch {}
  if (!['system', 'light', 'dark'].includes(pref)) pref = 'system';
  appearance.pref = pref;
  applyTheme();

  // live-follow the OS while in system mode
  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    if (appearance.pref === 'system') applyTheme();
  });
}
