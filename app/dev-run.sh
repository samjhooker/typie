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

# TYPIE_VARIANT=dev ./dev-run.sh  → side-by-side dev instance:
# signs as app.typie.typie-dev, does NOT pkill the running production app
VARIANT="${TYPIE_VARIANT:-}"
SIGNED_ID="app.typie.typie${VARIANT:+-$VARIANT}"

swift build

codesign --force --sign "$IDENTITY" --identifier "$SIGNED_ID" \
    .build/debug/typie 2>/dev/null || {
    echo "⚠︎  codesign failed (no '$IDENTITY' identity?) — accessibility grants may reset each build"
}

if [ -n "$VARIANT" ]; then
    # kill only stale DEBUG instances of this build — never production,
    # which lives at /Applications and is also named "typie"
    pkill -f "\.build/debug/typie" 2>/dev/null && sleep 1
    TYPIE_VARIANT="$VARIANT" nohup .build/debug/typie > /tmp/typie-${VARIANT}-run.log 2>&1 &
    echo "typie ($VARIANT) running (pid $!) — logs: tail -f /tmp/typie-${VARIANT}-run.log"
else
    pkill -x typie 2>/dev/null && sleep 1
    nohup .build/debug/typie > /tmp/typie-run.log 2>&1 &
    echo "typie running (pid $!) — logs: tail -f /tmp/typie-run.log"
fi
