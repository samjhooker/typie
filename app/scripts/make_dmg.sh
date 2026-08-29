#!/bin/zsh
# Builds typie.app then packages it into a distributable DMG.
#
# Layout (icon positions, window size, background image) comes from the
# committed scripts/dmg-template/.DS_Store, captured once via Finder, so
# CI gets the identical polished layout with no GUI automation.
# Regenerate the template: edit scripts/gen_dmg_background.swift, rerun it,
# then re-run the Finder layout dance on a UDRW image (see git history).
set -e
cd "$(dirname "$0")/.."

export APP_VERSION="${APP_VERSION:-1.0.0}"
./scripts/make_app.sh

VERSION="${DMG_VERSION:-1.0.0}"
STAGING="build/dmg-staging"
TEMPLATE="scripts/dmg-template"
DMG="build/typie-$VERSION.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING/.background"
cp -R "build/typie.app" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cp "$TEMPLATE/.background/background.png" "$STAGING/.background/background.png"
cp "$TEMPLATE/.DS_Store" "$STAGING/.DS_Store"

hdiutil create \
  -volname "typie" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG"

echo ""
echo "DMG ready: $DMG ($(du -h "$DMG" | cut -f1))"
