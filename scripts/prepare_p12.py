#!/usr/bin/env python3
"""
Pomocnik do zakodowania certyfikatu .p12 w base64.
Użycie: python scripts/prepare_p12.py sciezka/do/certyfikatu.p12
"""
import base64
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) < 2:
        print("❌ Podaj ścieżkę do pliku .p12")
        print(f"Użycie: python {sys.argv[0]} /ścieżka/do/certyfikatu.p12")
        sys.exit(1)

    p12_path = Path(sys.argv[1])
    if not p12_path.is_file():
        print(f"❌ Plik nie istnieje: {p12_path}")
        sys.exit(1)

    output_path = p12_path.with_suffix(p12_path.suffix + ".base64.txt")
    encoded = base64.b64encode(p12_path.read_bytes()).decode("ascii")
    output_path.write_text(encoded, encoding="ascii")

    print(f"✅ Certyfikat zakodowany w base64:")
    print(f"   {output_path}")
    print("")
    print("Skopiuj całą zawartość tego pliku do sekretu GitHub: APPLE_P12_BASE64")
    print("(Settings → Secrets and variables → Actions → New repository secret)")


if __name__ == "__main__":
    main()
