#!/bin/bash
# typie one-line installer
#
#   curl -fsSL https://typie.cc/install.sh | bash
#
# Downloads the latest release straight from GitHub, installs it into
# /Applications, and clears the quarantine flag so Gatekeeper never
# prompts (typie is built as open source and is not Apple notarized).
# Terminal installs don't get the quarantine stamp in the first place,
# but we strip it anyway as belt and braces.
set -euo pipefail

REPO="samjhooker/typie"
DMG_URL="https://github.com/${REPO}/releases/latest/download/typie.dmg"
APP_DEST="/Applications/typie.app"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
dim() { printf '\033[2m%s\033[0m\n' "$1"; }
die() { printf '\033[31m✗ %s\033[0m\n' "$1" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required"
[ "$(uname -s)" = "Darwin" ] || die "this installer is macOS only"
[ "$(uname -m)" = "arm64" ] || die "typie is Apple Silicon only right now (M1/M2/M3/M4)"

echo ""
bold "typie installer"
dim "local dictation for mac · no cloud · no account · MIT"
echo ""

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ downloading typie.dmg (latest release)"
curl -fL --progress-bar "$DMG_URL" -o "$TMP/typie.dmg" \
  || die "download failed, check your connection and try again"

echo "→ mounting dmg"
MNT="$(hdiutil attach "$TMP/typie.dmg" -nobrowse -readonly \
  | awk -F'\t' '/Volumes\/typie/{print $NF}' | tail -1)"
[ -n "$MNT" ] || die "could not mount the dmg"

echo "→ installing to /Applications"
rm -rf "$APP_DEST"
ditto "$MNT/typie.app" "$APP_DEST" || die "install failed"

hdiutil detach "$MNT" -quiet >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$APP_DEST" 2>/dev/null || true

echo ""
bold "✓ typie installed"
echo ""
echo "  next steps:"
echo "    1. open typie from Applications (it lives in the menu bar / notch)"
echo "    2. grant Microphone + Accessibility when macOS asks, that's it"
echo ""
dim "  issues? https://github.com/${REPO}/issues"
echo ""
