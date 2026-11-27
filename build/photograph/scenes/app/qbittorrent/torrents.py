"""The qBittorrent scene's torrents: local files and .torrent files for them, with no trackers.

Fixed names, sizes, bytes and dates, so every take shows the same list. Nothing here
reaches the network: a torrent with no trackers, and DHT, LSD and PeX off, finds no peers.
Usage: python3 torrents.py <dir>. Writes <dir>/data (the save path) and <dir>/torrents.
"""
import hashlib
import os
import sys

PIECE = 256 * 1024
CREATED = 1780304400  # 2026-06-01 09:00 UTC

# name, files (path, size in KiB), how much of the data is on disk: all, half, or none
TORRENTS = [
    ("Fireside Reading List", [("reading-list.epub", 3072), ("covers.zip", 1536)], "all"),
    ("Cabin Field Recordings", [("01 Rain on the roof.flac", 4096), ("02 Kettle.flac", 2048), ("03 Wood stove.flac", 3072)], "half"),
    ("Pine Forest Photos", [("photos.tar", 6144)], "all"),
    ("Library Catalog Scans", [("catalog.pdf", 5120)], "none"),
]


def bencode(v):
    if isinstance(v, int):
        return b"i%de" % v
    if isinstance(v, str):
        v = v.encode()
    if isinstance(v, bytes):
        return b"%d:%s" % (len(v), v)
    if isinstance(v, list):
        return b"l" + b"".join(bencode(x) for x in v) + b"e"
    return b"d" + b"".join(bencode(k) + bencode(v[k]) for k in sorted(v)) + b"e"


def content(name, size):
    # Fixed bytes per file, from its name.
    seed = hashlib.sha256(name.encode()).digest()
    out = bytearray()
    block = 0
    while len(out) < size:
        out += hashlib.sha256(seed + block.to_bytes(8, "big")).digest()
        block += 1
    return bytes(out[:size])


def main(root):
    data = os.path.join(root, "data")
    tdir = os.path.join(root, "torrents")
    os.makedirs(tdir, exist_ok=True)
    for name, files, present in TORRENTS:
        blobs = [(path, content(name + "/" + path, kib * 1024)) for path, kib in files]
        stream = b"".join(b for _, b in blobs)
        pieces = b"".join(hashlib.sha1(stream[i:i + PIECE]).digest() for i in range(0, len(stream), PIECE))
        info = {"name": name, "piece length": PIECE, "pieces": pieces, "private": 1,
                "files": [{"length": len(b), "path": [p]} for p, b in blobs]}
        meta = {"info": info, "creation date": CREATED, "created by": "Inglenook Photographer"}
        with open(os.path.join(tdir, name + ".torrent"), "wb") as f:
            f.write(bencode(meta))
        keep = {"all": len(blobs), "half": (len(blobs) + 1) // 2, "none": 0}[present]
        for path, b in blobs[:keep]:
            d = os.path.join(data, name)
            os.makedirs(d, exist_ok=True)
            with open(os.path.join(d, path), "wb") as f:
                f.write(b)


if __name__ == "__main__":
    main(sys.argv[1])
