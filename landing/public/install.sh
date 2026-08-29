#!/bin/bash
# typie one-line installer
#
#   curl -fsSL https://typie.cc/install.sh | bash
#
# Downloads the latest release straight from GitHub, installs it into
# /Applications, clears the quarantine flag (typie is open source and
# not Apple notarized — terminal installs never get the prompt anyway),
# resets onboarding so the welcome flow always runs, and opens the app.
set -euo pipefail

REPO="samjhooker/typie"
DMG_URL="https://github.com/${REPO}/releases/latest/download/typie.dmg"
APP_DEST="/Applications/typie.app"
BUNDLE_ID="app.typie.typie"

command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
[ "$(uname -s)" = "Darwin" ] || { echo "this installer is macOS only"; exit 1; }
[ "$(uname -m)" = "arm64" ] || { echo "typie is Apple Silicon only right now (M1/M2/M3/M4)"; exit 1; }

# ── output helpers (colors only when stdout is a terminal) ──
if [ -t 1 ]; then
  PINK=$'\033[38;2;252;86;129m'
  WHITE=$'\033[1m\033[97m'
  DIM=$'\033[2m'
  BOLD=$'\033[1m'
  OFF=$'\033[0m'
else
  PINK=""; WHITE=""; DIM=""; BOLD=""; OFF=""
fi
say()  { printf '%s\n' "$1"; }
step() { printf '%s\n' "${DIM}→${OFF} $1"; }
die()  { printf '%s✗ %s%s\n' "${PINK}" "$1" "${OFF}" >&2; exit 1; }

# ── the robot, hand-tuned block art ──
art() {
  local P="$PINK" W="$WHITE"
  say ""
  printf '%s                 ███████\n' "$P"
  printf '%s                 ███████\n' "$P"
  printf '%s                       ████\n' "$P"
  printf '%s              ██████████████████████\n' "$P"
  printf '%s              ██████████████████████\n' "$P"
  printf '%s           █████                  █████\n' "$P"
  printf '%s           ████                    ████\n' "$P"
  printf '%s           ████    %s███%s      %s███%s    ████\n' "$P" "$W" "$P" "$W" "$P"
  printf '%s        ███████    %s███%s      %s███%s    ███████\n' "$P" "$W" "$P" "$W" "$P"
  printf '%s        ███████    %s███%s      %s███%s    ███████\n' "$P" "$W" "$P" "$W" "$P"
  printf '%s           ████    %s███%s      %s███%s    ████\n' "$P" "$W" "$P" "$W" "$P"
  printf '%s           ████                    ████\n' "$P"
  printf '%s           ████                    ████\n' "$P"
  printf '%s           ████                    ████\n' "$P"
  printf '%s              ██████████████████████\n' "$P"
  printf '%s              ██████████████████████\n' "$P"
}

say ""
art
say ""
say "${BOLD}typie installer${OFF}"
say "${DIM}local dictation for mac · no cloud · no account · MIT${OFF}"
say ""

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

step "downloading typie.dmg (latest release)"
curl -fL --progress-bar "$DMG_URL" -o "$TMP/typie.dmg" \
  || die "download failed, check your connection and try again"

step "mounting dmg"
MNT="$(hdiutil attach "$TMP/typie.dmg" -nobrowse -readonly \
  | awk -F'\t' '/Volumes\/typie/{print $NF}' | tail -1)"
[ -n "$MNT" ] || die "could not mount the dmg"

step "installing to /Applications"
rm -rf "$APP_DEST"
ditto "$MNT/typie.app" "$APP_DEST" || die "install failed"

hdiutil detach "$MNT" -quiet >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$APP_DEST" 2>/dev/null || true

# first open always starts at the welcome flow, even over an old install
defaults delete "$BUNDLE_ID" onboardingDone >/dev/null 2>&1 || true

say ""
say "${PINK}${BOLD}✓ typie installed${OFF}"
say ""

step "opening typie"
if ! open "$APP_DEST" 2>/dev/null; then
  # couldn't launch it directly, at least reveal it in Finder
  open -R "$APP_DEST" 2>/dev/null || true
  say "${DIM}  couldn't auto-launch, typie is waiting in Applications${OFF}"
fi

say ""
say "${DIM}  the welcome flow walks you through models + permissions.${OFF}"
say "${DIM}  issues? https://github.com/${REPO}/issues${OFF}"
say ""
