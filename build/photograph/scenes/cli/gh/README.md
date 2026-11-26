# Inglenook

A cozy color theme: **Day** is a cabin in natural light, *Night* a library by the fire. ~~Hyaline~~ came first.

1. Pick a port on the [ports page](https://example.invalid/Ports/).
2. Save its file to `~/.config/inglenook/`.
- [x] Day and Night shots
- [ ] Palette 1.0

> Colors come only from `palette/palette.json`.

```python
@cache
def wash(color: str, strength=0.16):
    """Mix a color into base."""
    return mix(BASE, color, strength)  # solid, never alpha
```

| Variant | Room |
|---|---|
| Night | A library by the fire |
