#!/bin/zsh
# Builds the Svelte web UI (app/webui) and bundles it into the Swift
# package resources so WebKit can load it offline. Also regenerates the
# rasterized lucide PNGs the native side uses for shelf icons.
set -e
cd "$(dirname "$0")"

echo "→ icons: regenerating lucide PNGs"
node ./icons_to_png.mjs

cd ../webui

[ -d node_modules ] || npm install
npm run build

DIST="../Sources/Typie/WebResources/webui"
rm -rf "$DIST"
mkdir -p "$DIST"
cp -R dist/. "$DIST/"
echo "→ web UI bundled into Sources/Typie/WebResources/webui"
