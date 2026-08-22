#!/bin/zsh
# Creates a stable self-signed code-signing certificate ("typie-dev") in the
# login keychain. With a stable identity, macOS TCC permissions (Accessibility,
# Input Monitoring, Microphone) survive rebuilds — no ad-hoc hash churn.
set -e

CERT_NAME="typie-dev"

if security find-identity -v -p codesigning | grep -q "$CERT_NAME"; then
    echo "✓ '$CERT_NAME' already exists — nothing to do"
    exit 0
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "→ generating $CERT_NAME (valid 10 years)…"
openssl req -newkey rsa:2048 -nodes -keyout "$WORKDIR/key.pem" \
    -x509 -days 3650 -out "$WORKDIR/cert.pem" \
    -subj "/CN=$CERT_NAME" \
    -addext "keyUsage=digitalSignature" \
    -addext "extendedKeyUsage=codeSigning"

openssl pkcs12 -export -out "$WORKDIR/cert.p12" \
    -inkey "$WORKDIR/key.pem" -in "$WORKDIR/cert.pem" \
    -password pass:typie-local-cert \
    -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1

security import "$WORKDIR/cert.p12" \
    -k "$HOME/Library/Keychains/login.keychain-db" \
    -P typie-local-cert \
    -T /usr/bin/codesign

# trust the cert for code signing (user domain — may show a password prompt)
security add-trusted-cert -r trustRoot -p codeSign \
    -k "$HOME/Library/Keychains/login.keychain-db" "$WORKDIR/cert.pem"

echo "✓ '$CERT_NAME' created. Rebuilds will now keep their permissions."
