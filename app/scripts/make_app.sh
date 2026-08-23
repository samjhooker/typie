#!/bin/zsh
# Builds the release binary and assembles typie.app
set -e
cd "$(dirname "$0")/.."

swift build -c release

APP="build/typie.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/typie" "$APP/Contents/MacOS/typie"

cp Sources/Typie/Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# SPM resource bundles (fonts, sounds) go in Contents/Resources ONLY.
# Never place them in the .app root: Swift's generated Bundle.module looks
# there, but codesign refuses to seal bundle-root contents ("unsealed
# contents present in the bundle root"), so the app could never be signed.
# Typie reads them via Bundle.typieResources instead (see ResourceBundle.swift).
for dir in .build/release .build/arm64-apple-macosx/release; do
  for b in "$dir"/*.bundle(N); do
    name="${b:t}"
    mkdir -p "$APP/Contents/Resources/$name"
    ditto "$b" "$APP/Contents/Resources/$name"
  done
done

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>typie</string>
    <key>CFBundleDisplayName</key>
    <string>typie</string>
    <key>CFBundleIdentifier</key>
    <string>app.typie.typie</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION:-1.0.0}</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION:-1.0.0}</string>
    <key>CFBundleExecutable</key>
    <string>typie</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>typie listens only while you hold the dictation key. Audio never leaves this Mac.</string>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
</dict>
</plist>
PLIST

# Prefer the stable "typie-dev" identity when available: TCC permissions
# (Accessibility, mic) survive rebuilds with a real cert, unlike ad-hoc.
# --deep so nested resource bundles get sealed into the signature too
if security find-identity -v -p codesigning | grep -q 'typie-dev'; then
    echo "→ signing with stable identity 'typie-dev' (permissions persist)"
    codesign --force --deep --sign "typie-dev" "$APP"
else
    echo "⚠ signing ad-hoc — permissions will reset on every rebuild!"
    echo "  run scripts/create_signing_cert.sh once to fix this"
    codesign --force --deep --sign - "$APP"
fi

echo "built $APP"
