# OKLCH is the source of truth

Every color in `palette/palette.json` is written as OKLCH: lightness, chroma, and hue. OKLCH is perceptual, so two colors with the same lightness look equally light and two with the same chroma look equally colorful. That is what "muted and evenly matched" needs: the named colors share a lightness band per variant, and tuning one means moving one number, not guessing at hex.

The build converts OKLCH to sRGB hex with Björn Ottosson's OKLab matrices and the standard sRGB transfer function. Hex is generated, never written by hand in a template.

## Consequences

- A value outside the sRGB gamut is clamped to the nearest channel values. When a channel clips by more than 0.003, `check.ps1` prints a warning, not a failure, so the clip is seen and can be judged by eye.
- Contrast is measured on the generated hex with the WCAG 2.x formula, so the numbers match what apps draw.
- Ports and checks read the palette only through `build/lib/Palette.psm1`, the one place the conversion lives.
