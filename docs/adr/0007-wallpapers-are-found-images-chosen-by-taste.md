# Wallpapers are found images, chosen by taste

The repo may ship desktop wallpapers that go with the theme. They are found images, not made for the repo: each has a license that allows redistribution (CC0, public domain, CC BY, or CC BY-SA) and a recorded credit. They are the one exception to the palette rule, since they are images, not colors.

Because every surface is solid (ADR 0002), a wallpaper never affects readability. So wallpapers are chosen by taste, not measured against a rule. `build/wallpaper.ps1` grades lightness, saturation, and detail to rank candidates and suggest a variant, and refuses only a bad license or format.

The briefs: for Day, sunlit cabin interiors, window light on plants, a forest through a window. For Night, firelit or lamplit libraries and reading rooms, fireplaces. Wallpapers come in Day and Night pairs where possible.

## Consequences

- The theme must look complete without any wallpaper.
- Each image is marked `day`, `night`, or `both` in `wallpapers/README.md`, and a port may show one only in a variant it is marked for.
- `check.ps1` confirms every image has a thumbnail, a credit, and a mark, and every pair has one Day and one Night image.
