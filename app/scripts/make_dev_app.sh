#!/bin/zsh
# Builds "typie dev" — a side-by-side testing build that can run at the
# same time as your installed production typie:
#
#   - bundle id app.typie.typie-dev  → the single-instance guard only
#     matches its own variant, so both robots sit in the menu bar
#   - own defaults + ~/Library/Application Support/typie-dev for
#     settings/history/stats (fresh onboarding, no risk to prod data)
#   - SHARES the production model dir → no ~470 mb re-download
#   - skips the notch island (prod owns that real estate)
#
# First launch will ask for mic + accessibility again (new app identity);
# signing with the stable 'typie-dev' cert keeps those grants sticky.
set -e
cd "$(dirname "$0")"

APP_NAME=typie-dev BUNDLE_ID=app.typie.typie-dev ./make_app.sh

echo ""
echo "→ run it:  open build/typie-dev.app"
echo "  prod typie can stay running — they coexist by design"
echo "  tip: pick a DIFFERENT hotkey in dev, or both apps will react to it"
