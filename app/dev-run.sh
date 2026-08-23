#!/bin/bash
# Build, sign, and run typie locally.
#
# The signing step matters: SwiftPM debug binaries get an ad-hoc signature
# with a random UUID identifier on every rebuild, so macOS TCC treats each
# build as a brand-new app and Accessibility grants silently break.
# Signing with the real identity + stable bundle id keeps the grant sticky.
set -euo pipefail
cd "$(dirname "$0")"

IDENTITY="${TYPIE_SIGN_IDENTITY:-typie-dev}"

swift build

codesign --force --sign "$IDENTITY" --identifier app.typie.typie \
    .build/debug/typie 2>/dev/null || {
    echo "⚠︎  codesign failed (no '$IDENTITY' identity?) — accessibility grants may reset each build"
}

pkill -x typie 2>/dev/null && sleep 1
nohup .build/debug/typie > /tmp/typie-run.log 2>&1 &
echo "typie running (pid $!) — logs: tail -f /tmp/typie-run.log"
