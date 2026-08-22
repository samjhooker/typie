#!/bin/zsh
# Builds the release binary and assembles typie.app
set -e
cd "$(dirname "$0")/.."

swift build -c release

APP="build/typie.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/typie" "$APP/Contents/MacOS/typie"

# SPM resource bundle (fonts etc.)
if [ -d ".build/release/Typie_Typie.bundle" ]; then
  cp -R ".build/release/Typie_Typie.bundle" "$APP/Contents/Resources/"
fi

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
    <string>0.1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleExecutable</key>
    <string>typie</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
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

codesign --force --sign - "$APP"

echo "built $APP"
