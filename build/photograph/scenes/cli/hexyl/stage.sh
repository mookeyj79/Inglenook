#!/usr/bin/env bash
# hexyl's part of the CLI/TUI scene, run from its recipe's stage steps. Writes a small
# PNG file, the same bytes every take, with every kind of byte hexyl colors: null
# bytes, printable text, whitespace, other ASCII and bytes above 0x7F. The scene then
# shows it with hexyl and waits.
set -euo pipefail
python3 - "$HOME/inglenook-hexyl/swatch.png" <<'PY'
import os, struct, sys, zlib
path = sys.argv[1]
os.makedirs(os.path.dirname(path), exist_ok=True)
def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
rows = b"".join(b"\x00" + bytes([x * 60, 140, 200 - x * 40, 255]) * 4 for x in range(4))
png = (b"\x89PNG\r\n\x1a\n"
       + chunk(b"IHDR", struct.pack(">IIBBBBB", 4, 4, 8, 6, 0, 0, 0))
       + chunk(b"tEXt", b"Title\x00Inglenook swatch")
       + chunk(b"tEXt", b"Comment\x00A cabin room in natural light,\twith plants on the sill.")
       + chunk(b"IDAT", zlib.compress(rows, 9))
       + chunk(b"IEND", b""))
with open(path, "wb") as f:
    f.write(png)
PY
printf 'hexyl ~/inglenook-hexyl/swatch.png\nexec sleep infinity\n' > ~/.inglenook-cli
