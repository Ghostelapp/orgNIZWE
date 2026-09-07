#!/bin/bash
# Skrypt pomaga przygotować certyfikat .p12 do uploadu jako sekret GitHub.
# Użycie: ./scripts/prepare_p12.sh Sciezka/Do/Certyfikatu.p12

set -e

P12_PATH="$1"

if [ -z "$P12_PATH" ]; then
    echo "❌ Podaj ścieżkę do pliku .p12"
    echo "Użycie: $0 /ścieżka/do/certyfikatu.p12"
    exit 1
fi

if [ ! -f "$P12_PATH" ]; then
    echo "❌ Plik nie istnieje: $P12_PATH"
    exit 1
fi

OUTPUT="${P12_PATH}.base64.txt"
base64 -i "$P12_PATH" -o "$OUTPUT"

echo "✅ Certyfikat zakodowany w base64:"
echo "   $OUTPUT"
echo ""
echo "Skopiuj całą zawartość tego pliku do sekretu GitHub: APPLE_P12_BASE64"
echo "(Settings → Secrets and variables → Actions → New repository secret)"
