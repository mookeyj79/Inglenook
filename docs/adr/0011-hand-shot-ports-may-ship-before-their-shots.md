# Hand-shot ports may ship before their shots

Some ports can't be shot by the Photographer: the app needs a login, a license, a running server or a cluster, or it only shows outside a desktop (GRUB at boot, the whole Windows desktop). Their recipes are manual, and the shots wait until the owner takes them by hand. Holding the port back until then kept finished themes off the ports page for no gain to the reader.

Such a port may ship with `"screenshots": "pending"` in its `port.json`. The checks let it through without `screenshots/day.png` and `night.png`, and its card on the ports page says "Screenshots coming".

## Consequences

- Only the owner decides to ship a port this way. An automated recipe never needs it: the Photographer takes those shots.
- Once either image is in `screenshots/`, `check.ps1` fails until the flag is removed, so a port can't stay marked pending after its shots are in.
- Every other rule still holds: the port builds from the palette, passes the checks, has its README and MAPPING.md, and has the owner's approval.
