# Bright ANSI colors are the same hue, slightly stronger

Terminals have 16 ANSI slots. The six hue slots map to named colors: red to ember, green to moss, yellow to brass, blue to steel, magenta to heather, cyan to pine. Each bright slot is the same hue as its normal slot, slightly stronger: in Night its lightness rises by 0.05 (to at most 0.92), in Day it falls by 0.05, and in both its chroma is 1.1 times the normal one.

Reusing the normal colors for bright would make emphasis invisible in tools that use bright colors for it. New hues would break the one-color-one-meaning rule. A small step in the direction of more contrast keeps the meaning and still shows the difference.

Black and white slots map to neutrals by brightness: in Day, black is `text`, bright black `faint`, white `line`, bright white `raised`; in Night, black is `raised`, bright black `faint`, white `dim`, bright white `text`.

## Consequences

- The bright colors are computed by the build and are not in `palette/palette.json`. Ports reach all sixteen through `{{ansi.<slot>}}`.
- A bright color can fall outside sRGB. It is clamped, and `check.ps1` warns about it like any other color.
