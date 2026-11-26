# How well-regarded color themes structure their palettes

Research for designing a new, original theme. This document records how other themes are built: structure, method and numbers. It is not a source of values to reuse. Hex values appear only so the contrast numbers can be checked.

Gathered 2026-11-26 from each theme's official repo or site (see Sources). Contrast is the WCAG 2.x relative-luminance ratio, computed here from the hex values. OKLCH (L 0–100, C, h°) was also computed here, to show warm vs cool bases. When chroma (C) is below about 0.005 the color is effectively neutral and its hue angle means nothing.

## 1. Theme-by-theme structure

### Catppuccin (Latte / Frappé / Macchiato / Mocha)
- **Count:** 26 named colors per flavor, the same names in all four (`palette.json`).
- **Neutrals:** 12 steps, named by role in layers: `crust, mantle, base` (backgrounds), `surface0–2`, `overlay0–2`, `subtext0–1`, `text`. The names describe depth (what sits on what), not lightness.
- **Accents:** 14, named after things (rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender). There are several near-duplicate hues (two pinks, three blues) so ports have spares.
- **Semantic layer:** Yes. It is a separate written style guide (`docs/style-guide.md`) that maps functions to names, such as "Background Pane → Base", "Secondary panes → Crust, Mantle" and "Overlays". It is a document, not code.
- **Light variant:** Latte is designed separately under the same names. Its base is a near-neutral cool white.
- **Color space:** The palette ships hex, RGB and HSL. The official repo documents no perceptual-space rule.
- **Base temperature:** All flavors are cool (hue about 265–285°, blue-violet).

### Rosé Pine (main / moon / dawn)
- **Count:** The site advertises "3 variants & 15 colours". The Neovim palette adds `leaf` and an `_nc` (non-current window) background.
- **Neutrals:** 6 named by role: `base, surface, overlay` (backgrounds), then `muted, subtle, text` (foregrounds). There are also 3 `highlight_low/med/high` for selection and cursorline.
- **Accents:** 6, with evocative names that don't name a hue: `love, gold, rose, pine, foam, iris`. The site lists them under a "Role" column.
- **Semantic layer:** Thin. The names are already roles. Usage guidance lives on the site.
- **Light variant:** Dawn is designed separately. It has a **warm** base (hue about 72°, cream) with a cool violet ink (h about 290°). Accents are darkened by hand, not by formula.
- **Color space:** None documented.

### Gruvbox (dark / light, each in hard / medium / soft)
- **Count:** Each mode has 5 bg, 5 fg, 1 gray and 7 accents, plus 7 "neutral" accents for terminal normal colors. That is about 19 values.
- **Neutrals:** One ladder, `dark0_hard, dark0, dark0_soft, dark1…dark4`, then `gray`, then `light4…light1, light0_soft, light0, light0_hard`. Semantic aliases `bg0–bg4` and `fg0–fg4` point into it.
- **Accents:** 7 hues (red, green, yellow, blue, purple, aqua, orange) in 3 intensity tiers: `bright_*`, `neutral_*` and `faded_*`.
- **Semantic layer:** Yes, through the `bg0–4`, `fg0–4` and `s:red…` indirection in the Vim script.
- **Light variant:** A swap, not a redesign. Light mode maps `bg*` to the light ladder, `fg*` to the dark ladder, and accents from `bright` to `faded`.
- **Color space:** None. Values were chosen by eye ("retro groove").
- **Base temperature:** The dark bg is neutral gray (#282828, chroma 0) under warm cream text. The light bg is a strongly warm, yellowish cream (C 0.055, h about 96°).

### Everforest (dark / light, each in hard / medium / soft)
- **Count:** Split into `palette1` (backgrounds) and `palette2` (foregrounds). Per contrast level there are 7 bg steps, 6 **tinted** backgrounds, 1 fg, 7 accents, 3 greys and 3 statusline colors.
- **Neutrals:** `bg_dim, bg0…bg5`. Each step has a documented usage (`palette.md`): bg0 is the editor, bg1 the cursorline, bg2 popups, bg3 list chars, bg4 splits and whitespace.
- **Tinted backgrounds:** `bg_visual, bg_red, bg_yellow, bg_green, bg_blue, bg_purple` are dark, low-chroma washes of the accents. They are used for diff lines and diagnostic highlights.
- **Accents:** 7 plain hue names: red, orange, yellow, green, aqua, blue, purple.
- **Semantic layer:** Yes. It is a large table that maps identifiers to usages, and its semantics apply to every variant.
- **Light variant:** Designed separately, with its own hand-picked values. The light accents are much more saturated than the dark ones.
- **Base temperature:** The dark bg is a cool, slightly green-blue charcoal (h about 240°) under warm beige text (h about 86°). The light bg is a warm cream (h about 90°). Its contrast is deliberately low: 7.4:1 dark and 5.2:1 light.

### Kanagawa (wave / dragon / lotus)
- **Count:** One large shared named pool of about 100 colors, inspired by Hokusai. Each theme picks from the pool.
- **Neutrals:** Grouped families with numbered steps: `sumiInk0–6` (wave bg), `dragonBlack0–6` and `lotusWhite0–5`.
- **Accents:** Named for a thing plus a hue (`springGreen, crystalBlue, oniViolet, carpYellow, surimiOrange, sakuraPink`). These names give a strong identity without naming hex-like hues.
- **Semantic layer:** **Explicit and in code.** `themes.lua` builds a `ThemeColors` table with sub-tables: `ui` (`fg, fg_dim, bg_m3…bg_m1, bg, bg_p1, bg_p2, bg_gutter, bg_search, bg_visual, pmenu, float`), `syn` (string, keyword, fun, type, comment…), `diag`, `vcs`, `diff` and `term`. Users override either layer.
- **Background ladder:** Named relative to the main bg (`bg_m3…bg`, `bg_p1, bg_p2`), so the same code works in dark and light.
- **Light variant:** Lotus is designed separately. Its base is a strongly warm parchment (C 0.063, h about 102°). Dragon is a low-chroma, warm-black alternative dark.

### Nord
- **Count:** 16 colors, `nord0–nord15`, in 4 named groups. The groups are Polar Night (0–3, dark bgs), Snow Storm (4–6, light), Frost (7–10, the bluish main accents) and Aurora (11–15: red, orange, yellow, green, purple).
- **Semantic layer:** Every color's usage is written as prose in the style guide (`src/nord.css`). For example, nord3 is used for comments and invisibles, nord8 is "the accent color… primary UI elements and functions", nord11 for errors and deletions, nord14 for strings and additions.
- **Light variant:** No official separate light palette. Snow Storm "may be used as semi-light background depending on the theme shading design", so a light mode is an inversion of roles inside the same 16.
- **Color space:** None documented. It aims for "dimmed pastel colors for an eye-comfortable, but yet colorful ambiance".
- **Base temperature:** Cool blue-gray (h about 264°).

### Solarized (dark / light)
- **Count:** 16 colors shared by both modes: 8 monotones (`base03, base02, base01, base00, base0, base1, base2, base3`) and 8 accents (yellow, orange, red, magenta, violet, blue, cyan, green).
- **Neutrals:** Named symmetrically around a middle gray. The 03 and 3 ends are the backgrounds, and the 0 and 00 steps are body text.
- **Semantic layer:** By convention only. The `rebase` mixin in the README assigns bg, body text and emphasis to base steps.
- **Light variant:** Derived by **swapping** the monotones. This is the canonical example. The README says: "The monotones have symmetric CIELAB lightness differences, so switching from dark to light mode retains the same perceived contrast."
- **Color space:** **CIELAB.** Accent hues come from color-wheel relations and are then fixed in CIELAB for uniform lightness. Its "selective contrast" philosophy lowers *brightness* contrast while keeping *hue* contrast.
- **Base temperature:** Dark is teal-blue (h about 220°). Light is warm cream (h about 90°). It is one of the lowest-contrast popular themes (4.75 and 4.13:1).

### Tokyo Night (night / storm / moon / day)
- **Count:** About 30 named entries per style, plus `git.add/change/delete`.
- **Neutrals:** Named functionally: `bg_dark1, bg_dark, bg, bg_highlight, terminal_black, fg_gutter, dark3, dark5, comment, fg_dark, fg`.
- **Accents:** Numbered families (`blue, blue0, blue1, blue2, blue5, blue6, blue7`, plus `green1/2`, `red1`, `magenta2`). They grew organically, so the numbers don't form an ordered ramp.
- **Semantic layer:** Highlight groups are built from the palette in code. Night is literally storm with three bg values overridden.
- **Light variant:** **Algorithmic.** `day.lua` calls `Util.invert`, which converts each color to **HSLuv**, sets L to 100 − L, then lifts dark results by `day_brightness`. The result is a cool gray-lavender bg with saturated blue text, and only 4.52:1 contrast.
- **Base temperature:** All styles are cool (h about 275–280°).

### Flexoki (light / dark)
- **Count:** A base ramp of 14 neutrals (`paper`, `base-50…base-950`, `black`) and 8 accents (red, orange, yellow, green, cyan, blue, purple, magenta). Each accent has a standard 400/600 pair (16 values), and an extended ramp runs from 50 to 950.
- **Neutrals:** Numbered like Tailwind, with short role tokens on top: `bg, bg-2, ui, ui-2, ui-3, tx-3, tx-2, tx`. The same tokens point to different steps in each mode.
- **Rules:** "Light themes should use 600 for syntax highlighted text, dark themes should use 400." Accent tints "cannot be derived using opacity because this desaturates the pigment effect."
- **Light variant:** Light and dark are equal citizens built from the same ramps, with the role tokens remapped.
- **Color space:** **Oklab.** It keeps perceptual relationships at both ends and ramps chroma "exponentially to emulate the vibrancy that pigments exhibit even when diluted". The author notes that strict perceptual evenness "can end up with a palette that looks washed out", so it was tuned by eye afterwards.
- **Base temperature:** Warm paper (h about 95°) and a warm near-black ink. It is high contrast by design (18.6:1 light, 12:1 dark).

### Ayu (dark / mirage / light)
- **Count:** 11 base hues per variant (gray, red, pink, orange, peach, yellow, green, teal, indigo, blue, purple). Each one is **generated** into 5 steps (`l1…l5`) across an OKLCH lightness range, for example `range: 0.675:0.875, steps: 5` in dark.
- **Semantic layer:** **The deepest of the set.** YAML has layers for `syntax` (tag, func, entity, string, keyword… mapped to `$palette.orange.l3` and so on), `terminal`, `vcs`, `surface` (`sunk, base, lift, over`), `editor`, `ui` and `common.accent`. References carry modifiers like `-L0.07` (OKLCH lightness delta) and `A0.74` (alpha).
- **Notable:** Foreground text is set with **alpha over the bg** (dark fg `FCF8EC A0.74`), so text always takes on a little of the background's tint.
- **Light variant:** The light palette is designed separately, and the same semantic map is applied to it.
- **Color space:** **OKLCH**, with culori gamut mapping and chroma clamping (`src/color.ts`). The repo ships a designer app with OKLCH sliders and a contrast checker.
- **Base temperature:** Dark and mirage have cool blue-gray bgs under warm off-white text (h about 95°). Light is neutral white.

### Night Owl / Light Owl
- **Count:** No named palette. These are VS Code theme JSON files with about 104 (Night) and 54 (Light) distinct hexes assigned directly to UI keys and token scopes.
- **Semantic layer:** Only VS Code's own (`editor.background`, token scopes).
- **Stated goals:** It is "fine-tuned for those of us who like to code late into the night", and its colors take "into consideration what is accessible to people with colorblindness and in low-light circumstances". Light Owl was "color balanced from the Dark version for easy viewing in daylight", so it was rebalanced by hand rather than inverted.
- **Base temperature:** Night Owl is a deep saturated navy (C 0.045, h about 244°). Light Owl is neutral white with violet-gray ink.

## 2. Background / foreground contrast (computed)

The pairs are the default editor bg and fg. Ayu's fg is the alpha-composited result.

| Theme | bg | fg | WCAG ratio | bg OKLCH | fg OKLCH |
|---|---|---|---|---|---|
| Catppuccin Latte | `#eff1f5` | `#4c4f69` | 7.06:1 | L95.8 C0.006 h265 | L43.5 C0.043 h279 |
| Catppuccin Frappé | `#303446` | `#c6d0f5` | 8.06:1 | L32.9 C0.032 h275 | L86.2 C0.053 h273 |
| Catppuccin Macchiato | `#24273a` | `#cad3f5` | 9.92:1 | L27.9 C0.035 h277 | L87.1 C0.048 h274 |
| Catppuccin Mocha | `#1e1e2e` | `#cdd6f4` | 11.34:1 | L24.3 C0.030 h284 | L87.9 C0.043 h272 |
| Rosé Pine (main) | `#191724` | `#e0def4` | 13.39:1 | L21.3 C0.025 h291 | L90.9 C0.030 h290 |
| Rosé Pine Moon | `#232136` | `#e0def4` | 11.86:1 | L26.0 C0.039 h288 | L90.9 C0.030 h290 |
| Rosé Pine Dawn | `#faf4ed` | `#464261` | 8.69:1 | L97.0 C0.011 h72 | L39.6 C0.052 h290 |
| Gruvbox dark (medium) | `#282828` | `#ebdbb2` | 10.75:1 | L27.7 C0.000 h90 | L89.4 C0.057 h89 |
| Gruvbox light (medium) | `#fbf1c7` | `#3c3836` | 10.22:1 | L95.6 C0.055 h96 | L34.4 C0.007 h49 |
| Everforest dark (medium) | `#2D353B` | `#D3C6AA` | 7.38:1 | L32.4 C0.015 h240 | L83.0 C0.041 h86 |
| Everforest light (medium) | `#FDF6E3` | `#5C6A72` | 5.18:1 | L97.4 C0.026 h90 | L51.5 C0.021 h233 |
| Kanagawa Wave | `#1F1F28` | `#DCD7BA` | 11.26:1 | L24.3 C0.017 h285 | L87.6 C0.039 h99 |
| Kanagawa Dragon | `#181616` | `#c5c9c5` | 10.76:1 | L20.3 C0.003 h17 | L83.2 C0.007 h146 |
| Kanagawa Lotus | `#f2ecbc` | `#545464` | 6.19:1 | L93.6 C0.063 h102 | L45.2 C0.026 h285 |
| Nord | `#2e3440` | `#d8dee9` | 9.25:1 | L32.4 C0.023 h264 | L89.9 C0.016 h263 |
| Solarized dark | `#002b36` | `#839496` | 4.75:1 | L26.7 C0.049 h220 | L65.4 C0.020 h205 |
| Solarized light | `#fdf6e3` | `#657b83` | 4.13:1 | L97.4 C0.026 h90 | L56.8 C0.029 h222 |
| Tokyo Night Night | `#1a1b26` | `#c0caf5` | 10.59:1 | L22.6 C0.021 h280 | L84.6 C0.061 h275 |
| Tokyo Night Storm | `#24283b` | `#c0caf5` | 9.02:1 | L28.2 C0.036 h275 | L84.6 C0.061 h275 |
| Tokyo Night Moon | `#222436` | `#c8d3f5` | 10.26:1 | L26.7 C0.034 h279 | L86.9 C0.049 h271 |
| Tokyo Night Day | `#e1e2e7` | `#3760bf` | 4.52:1 | L91.3 C0.007 h277 | L51.2 C0.156 h264 |
| Flexoki dark | `#100F0F` | `#CECDC3` | 11.98:1 | L17.0 C0.002 h17 | L84.6 C0.014 h102 |
| Flexoki light | `#FFFCF0` | `#100F0F` | 18.62:1 | L99.0 C0.016 h95 | L17.0 C0.002 h17 |
| Ayu Dark | `#10141C` | `#bfbdb6` | 9.81:1 | L19.1 C0.017 h264 | L79.8 C0.010 h94 |
| Ayu Mirage | `#242936` | `#cccac2` | 8.85:1 | L28.2 C0.025 h268 | L83.8 C0.011 h95 |
| Ayu Light | `#FCFCFC` | `#5c6166` | 6.10:1 | L99.1 C0.000 h90 | L49.0 C0.010 h248 |
| Night Owl | `#011627` | `#d6deeb` | 13.54:1 | L19.3 C0.045 h244 | L89.8 C0.020 h260 |
| Light Owl | `#FBFBFB` | `#403f53` | 9.88:1 | L98.8 C0.000 h90 | L37.7 C0.034 h287 |
| (ref) pure black/white | `#000000` | `#ffffff` | 21.00:1 | L0.0 C0.000 h0 | L100.0 C0.000 h90 |

Observations:
- Almost every dark theme lands between **9:1 and 13.5:1**. Dark themes avoid pure black: the darkest bg is Flexoki's #100F0F (L 17), and most sit at L 19–33.
- Light themes vary more, from **4.1:1** (Solarized) to **18.6:1** (Flexoki). Light themes avoid pure white too: most use cream or off-white at L 93–99.
- WCAG AA for body text is 4.5:1 and AAA is 7:1. Solarized light (4.13) fails AA for body text. Tokyo Night Day sits right at the AA line, and Everforest light is between AA and AAA.
- Warm light bases (Rosé Pine Dawn, Gruvbox, Everforest, Kanagawa Lotus, Solarized, Flexoki) are common. Warm *dark* bases are rare: only Gruvbox (neutral), Kanagawa Dragon and Flexoki. Most dark themes are blue-violet.
- A pattern recurs: a **cool bg with warm text**, or the reverse (Everforest dark, Kanagawa Wave, Ayu, Solarized light, Rosé Pine Dawn).

## 3. Cross-theme patterns in structure

| Axis | Approaches seen |
|---|---|
| Neutral naming | Depth layers (Catppuccin crust/mantle/base/surface/overlay); role names (Rosé Pine base/surface/overlay/muted/subtle/text); a numbered ramp plus role tokens (Flexoki 50–950 with bg/ui/tx); relative-to-bg steps (Kanagawa bg_m3…bg_p2); symmetric numbering (Solarized base03…base3) |
| Neutral count | 6 (Rosé Pine) up to 14 (Flexoki); 7–12 is typical |
| Accent count | 6 (Rosé Pine) and 7–8 (Gruvbox, Everforest, Solarized, Flexoki) up to 11–14 (Ayu, Catppuccin) |
| Accent naming | Plain hues (Gruvbox, Everforest, Solarized, Flexoki); evocative non-hue names (Rosé Pine); thing plus hue (Kanagawa, Catppuccin); numbered groups (Nord) |
| Intensity tiers | Gruvbox bright/neutral/faded; Flexoki 400 vs 600 per mode; Ayu l1–l5 generated |
| Semantic layer | Code-level (Kanagawa, Ayu, Tokyo Night); documented table (Everforest, Nord, Catppuccin style guide); implicit (Solarized, Rosé Pine) |
| Light derivation | Neutral swap (Solarized, Gruvbox, Nord); algorithmic inversion in HSLuv (Tokyo Night Day); separate design under the same names (Catppuccin, Rosé Pine, Everforest, Kanagawa, Ayu, Light Owl); shared ramps with roles remapped (Flexoki) |
| Perceptual space | CIELAB (Solarized), Oklab (Flexoki), OKLCH (Ayu), HSLuv (Tokyo Night inversion); none documented (Catppuccin, Rosé Pine, Gruvbox, Everforest, Kanagawa, Nord, Night Owl) |
| Tinted bg washes | Everforest bg_red/green/blue…; Kanagawa winterGreen/Red/Yellow/Blue for diffs |

## 4. What the evidence says about eye strain in long sessions

This section draws on peer-reviewed human-factors, optometry and chronobiology work, plus standards. Strength-of-evidence notes are included.

**The biggest factors aren't the theme.** Reviews of digital eye strain (Sheppard & Wolffsohn 2018; Rosenfield 2011) put most symptoms down to reduced and incomplete blinking (dry eye), uncorrected refractive error or presbyopia, near-focus effort, viewing distance and angle, glare, and session length without breaks. Prevalence is around 50% or more of users. A theme can help at the margins, through contrast, brightness and glare, but it can't fix the dominant causes.

**Polarity (dark vs light).**
- Controlled lab studies consistently find a **positive-polarity (dark text on light) advantage** for legibility and proofreading. Buchner & Baumgartner (2007) found it held regardless of ambient light and color contrast. Piepenbrock et al. (2013) found it held for younger and older adults. Piepenbrock et al. (2014) tie it to smaller pupils on bright screens, which give a sharper image through greater depth of field. Dobres et al. (2017) found that polarity interacts with ambient light and letter size in glance-like reading.
- Measured **fatigue** differences between modes are small and mixed. In a 2025 RCT (Sengsoon et al., n=30 tablet users), the modes did not differ significantly in visual fatigue. Critical flicker frequency and dry-eye symptoms did differ, and the authors lean toward dark mode for fatigue. Both modes raised fatigue over time.
- Reasonable reading: light mode for performance-critical reading in a lit room; dark mode is acceptable, and often more comfortable, in dim surroundings. Neither one prevents strain.

**Contrast level.**
- WCAG 2.x sets 4.5:1 (AA) and 7:1 (AAA) for body text. The ergonomic display standards (ISO 9241-303, ANSI/HFES 100) set a minimum luminance contrast around 3:1 and favor more. There is no strong evidence that *maximal* contrast (21:1) is harmful as such.
- The "too much contrast tires the eye" claim (Solarized's selective contrast) is a design argument, not a measured result. What does have support is **luminance mismatch** between a bright screen and a dim room. Benedetto et al. (2014) examined screen luminance against room illuminance for fatigue and arousal during reading. Fan et al. (2024) found that raising ambient light reduced fatigue with dark-mode text.
- WCAG 2's formula is known to misjudge contrast for dark backgrounds and thin text, which is the motivation for APCA in the WCAG 3 drafts. Check dark themes by eye as well as by ratio.

**Pure black and white.** No study reviewed here directly tests pure #000/#FFF against off-black and off-white for strain. Themes near-universally avoid both, and the rationale is mainly practical: less glare and halation, OLED smearing, and a softer look. Mark this as convention, not evidence. Because of the luminance-mismatch findings, a slightly lifted dark bg (L about 15–25) in a dim room is defensible.

**Saturation and hue of text.**
- With dark backgrounds, text color affected fatigue in Fan et al. (2024). Red text produced the most fatigue and yellow the least, and yellow and white text gave better cognitive performance than red.
- The eye's longitudinal chromatic aberration (textbook optics) focuses saturated blue and red at different depths than mid-spectrum colors. Highly saturated blue or red thin text is therefore harder to hold sharp and can show chromostereopsis (colors appearing to float at different depths) on dark backgrounds. This supports desaturated or mid-lightness accents for text, and keeping saturated color for small areas.

**Color temperature (day vs night).**
- Evening exposure to bright, blue-rich self-luminous screens suppresses melatonin and shifts circadian timing (Cajochen et al. 2011, LED computer screen; Chang et al. 2015, PNAS, e-readers).
- But **warming the screen without dimming it is not enough**. In Nagare et al. (2018), iPad Night Shift at low and high color temperatures did not differ in melatonin suppression, and the authors conclude that brightness must also drop. The 2023 Cochrane review of blue-light-filtering lenses found they **probably make little or no difference to eye strain** in the short term.
- The idea that warm light is preferred at low light levels (the Kruithof curve) has weak replication. Davis & Ginthner (1990) found illuminance mattered more than color temperature.
- Net: a warm, dim night theme is defensible for **comfort, mood and possibly sleep**, but only because it is also darker and lower in luminance. Hue alone does little. A cool daytime theme has no measured eye-strain benefit, but it matches daylight ambience. That is an aesthetic argument, not a physiological one.

## 5. Patterns worth borrowing (as ideas, not values)

1. **Two layers, kept separate.** Have a named palette, then a semantic role map (bg, surface, text-dim, keyword, error, diff-add…), as Kanagawa and Ayu do. Variants change the palette while the roles stay put, and ports only ever reference roles.
2. **Name neutrals by depth or role, not lightness.** Ideas include Catppuccin's crust/mantle/base/surface/overlay, Kanagawa's steps relative to bg (bg-2…bg+2), and Flexoki's bg/ui/tx tokens over a numbered ramp. Relative names let one map serve both light and dark.
3. **Build ramps in a perceptual space (OKLCH or Oklab), then tune by eye.** Flexoki's lesson is that perfect evenness looks washed out, so allow deliberate deviations and write them down.
4. **Per-mode intensity tiers instead of opacity tints.** Use a darker or more saturated accent tier on light and a lighter one on dark (Gruvbox bright vs faded, Flexoki 400 vs 600). Flexoki also warns that opacity desaturates.
5. **Tinted background washes** for diff lines, diagnostics and selection (Everforest bg_red/green/blue). They carry meaning without colored text.
6. **Cool/warm counterpoint.** A slightly cool bg with warm ink, or the reverse, appears again and again, and it reads as calm. A day/night pair can flip which side carries the warmth.
7. **Design the light variant on its own; don't invert it.** Swaps and algorithmic inversions (Solarized, Tokyo Night Day) give the lowest contrast in this set. The hand-designed light variants hold up better.
8. **Contrast targets as rules.** Keep body text at 7:1 or more in both modes, as most dark themes here already do (9–13:1). Put comments and dim text at 4.5:1 or more. Avoid pure #000 and #FFF.
9. **Calm accents for text.** Lean on mid-lightness, moderate-chroma ambers, golds, sages and teals. Keep saturated red and blue for small signals such as errors and the cursor (see the Fan 2024 and chromatic aberration notes).
10. **A night variant that is also dimmer**, with a lower bg and lower text luminance, not only warmer hue. Brightness is what the circadian evidence points to.
11. **Use-mapped documentation**, as in Nord's and Everforest's per-color usage notes. This keeps ports consistent.

## Sources

Theme primary sources:
- Catppuccin palette: https://github.com/catppuccin/palette (palette.json). Style guide: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
- Rosé Pine: https://rosepinetheme.com/palette/ ; https://github.com/rose-pine/neovim/blob/main/lua/rose-pine/palette.lua
- Gruvbox: https://github.com/morhetz/gruvbox/blob/master/colors/gruvbox.vim
- Everforest: https://github.com/sainnhe/everforest/blob/master/palette.md
- Kanagawa: https://github.com/rebelot/kanagawa.nvim (lua/kanagawa/colors.lua, lua/kanagawa/themes.lua)
- Nord: https://github.com/nordtheme/nord/blob/develop/src/nord.css
- Solarized: https://github.com/altercation/solarized (README)
- Tokyo Night: https://github.com/folke/tokyonight.nvim (lua/tokyonight/colors/*.lua, lua/tokyonight/util.lua, extras/kitty/tokyonight_day.conf)
- Flexoki: https://stephango.com/flexoki ; https://github.com/kepano/flexoki
- Ayu: https://github.com/ayu-theme/ayu-colors (themes/*.yaml, src/color.ts)
- Night Owl / Light Owl: https://github.com/sdras/night-owl-vscode-theme (README, themes/*.json)

Human-factors and physiology sources:
- Buchner, A., & Baumgartner, N. (2007). Text–background polarity affects performance irrespective of ambient illumination and colour contrast. *Ergonomics* 50(7). doi:10.1080/00140130701306413
- Piepenbrock, C., Mayr, S., Mund, I., & Buchner, A. (2013). Positive display polarity is advantageous for both younger and older adults. *Ergonomics*. doi:10.1080/00140139.2013.790485
- Piepenbrock, C., Mayr, S., & Buchner, A. (2014). Smaller pupil size and better proofreading performance with positive than with negative polarity displays. *Ergonomics*. doi:10.1080/00140139.2014.948496
- Dobres, J., Chahine, N., & Reimer, B. (2017). Effects of ambient illumination, contrast polarity, and letter size on text legibility under glance-like reading. *Applied Ergonomics*. doi:10.1016/j.apergo.2016.11.001
- Benedetto, S., et al. (2014). Effects of luminance and illuminance on visual fatigue and arousal during digital reading. *Computers in Human Behavior* 41. doi:10.1016/j.chb.2014.09.023
- Fan, et al. (2024). The Effect of Ambient Illumination and Text Color on Visual Fatigue under Negative Polarity. *Sensors* 24(11):3516. doi:10.3390/s24113516
- Sengsoon, et al. (2025). Immediate Effects of Light Mode and Dark Mode Features on Visual Fatigue in Tablet Users. *IJERPH* 22(4):609. doi:10.3390/ijerph22040609
- Sheppard, A. L., & Wolffsohn, J. S. (2018). Digital eye strain: prevalence, measurement and amelioration. *BMJ Open Ophthalmology*. doi:10.1136/bmjophth-2018-000146
- Rosenfield, M. (2011). Computer vision syndrome: a review of ocular causes and potential treatments. *Ophthalmic & Physiological Optics*. doi:10.1111/j.1475-1313.2011.00834.x
- Cajochen, C., et al. (2011). Evening exposure to a LED-backlit computer screen affects circadian physiology and cognitive performance. *J Appl Physiol*. doi:10.1152/japplphysiol.00165.2011
- Chang, A.-M., Aeschbach, D., Duffy, J. F., & Czeisler, C. A. (2015). Evening use of light-emitting eReaders negatively affects sleep, circadian timing, and next-morning alertness. *PNAS*. doi:10.1073/pnas.1418490112
- Nagare, R., Plitnick, B., & Figueiro, M. G. (2018). Does the iPad Night Shift mode reduce melatonin suppression? *Lighting Research & Technology*. doi:10.1177/1477153517748189
- Singh, S., et al. (2023). Blue-light filtering spectacle lenses for visual performance, sleep, and macular health in adults. *Cochrane Database of Systematic Reviews*. doi:10.1002/14651858.CD013244.pub2
- Davis, R. G., & Ginthner, D. N. (1990). Correlated Color Temperature, Illuminance Level, and the Kruithof Curve. *J. Illuminating Engineering Society*. doi:10.1080/00994480.1990.10747937
- W3C, WCAG 2.2, Success Criteria 1.4.3 and 1.4.6 (contrast minimum and enhanced): https://www.w3.org/TR/WCAG22/
- ISO 9241-303 and ANSI/HFES 100-2007 (display ergonomics). Cited from secondary knowledge, not re-read for this note.

Verification notes: the theme facts come from the fetched source files. All DOIs were confirmed through Crossref. Crossref returned abstracts for Nagare 2018, Fan 2024 and Sengsoon 2025, and those summaries follow the abstracts. The other studies are summarized from prior knowledge of their findings, without re-reading them.
