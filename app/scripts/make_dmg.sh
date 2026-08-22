#!/bin/zsh
# Builds typie.app then packages it into a distributable DMG
# (typie.app + drag-to-Applications symlink).
set -e
cd "$(dirname "$0")/.."

./scripts/make_app.sh

VERSION="0.1.0"
STAGING="build/dmg-staging"
DMG="build/typie-$VERSION.dmg"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "build/typie.app" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create \
  -volname "typie" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG"

echo ""
echo "DMG ready: $DMG ($(du -h "$DMG" | cut -f1))"
