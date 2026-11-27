---
name: wallpaper
description: Find, check, and add a wallpaper (an optional found image) from Wikimedia Commons, marked with the variant it suits. Use when asked to "find a wallpaper", "find a night wallpaper", "find the other half of a pair", or "check this image".
argument-hint: [search words]
---

# Wallpaper

Wallpapers are optional found images that go with the theme (ADR 0007). The theme looks complete without them, and every surface is solid, so a wallpaper never affects readability and is chosen by taste. `build/wallpaper.ps1` applies the hard rules and grades the rest; this skill is the order to run it in.

## The rules

Gates (the script refuses an image that fails one):

- **License** allows redistribution: CC0, public domain, CC BY, or CC BY-SA.
- **Format**: a landscape JPEG at least 1920 px wide.

Grades (they rank results and never refuse):

- **Lightness** suggests a variant: `day` at L* 60 or above, `night` at 40 or below, `both` in between.
- **Saturation** over 25 is `colorful`, **detail** over 1.5 is `busy`. Otherwise `calm`.

Taste: calm and cozy, not busy; warm, earthy color that sits well with the palette; suits the variant it is marked for. No faces, text, or logos.

What to look for:

- **Day**: sunlit cabin interiors, window light on plants, a forest seen through a window.
- **Night**: firelit or lamplit libraries and reading rooms, fireplaces.

Make day and night pairs where possible: the same kind of room, once in daylight and once by the fire.

## 1. Search

```
pwsh build/wallpaper.ps1 -Search "$ARGUMENTS"
pwsh build/wallpaper.ps1 -Search "$ARGUMENTS" -Variant night
```

Grades up to 50 Commons results from previews (about a minute), calmest first. `-Variant day|night|both` keeps images suggested for that variant, exact suggestions first, then those suggested for `both`. `-All` shows why candidates failed a gate. Try several words if nothing suits.

To find the other half of a pair, search for the same kind of subject with the other variant, for example `-Search "library fireplace" -Variant night` for a sunlit reading room.

## 2. Check the originals, all in one run

```
pwsh build/wallpaper.ps1 -Check "File:<one>.jpg|File:<two>.jpg|File:<three>.jpg"
```

Put every candidate in one `-Check`, separated by `|`; never one run per file. Previews can be off by a little. `-Check` grades each original, and those grades count. It prints each file's credit (author, date, source, license, with links), so do not query the Commons API or download the files yourself: the script has it all. It exits 1 if any file fails a gate.

Each original and its Commons details are cached outside the repo, so a later `-Add` of the same file downloads nothing.

The script paces its requests to Commons, even across parallel runs. If Commons says it is busy, the script prints how long to wait and exits 3. Wait that long, then run the same command once; retrying sooner extends the block. Do not loop it.

## 3. Read the Commons page yourself

Open the candidate's Commons page (the Source link `-Check` printed). The script reads the license field, but confirm:

- The license on the page matches, and there is no extra restriction (personality rights, trademarks, a "do not use" note).
- The author is the real author. For "Public domain", the reason it is public domain applies worldwide, not just in one country.

If anything is unclear, stop and ask the user. Do not add it.

## 4. Show the user before adding

List the candidates with their Commons links, grades, and suggested variant, and let the user pick the image and its mark. Taste is theirs, not the script's.

## 5. Add

```
pwsh build/wallpaper.ps1 -Add "File:<title>.jpg" -Name <short-name> -Variant <day|night|both>
pwsh build/wallpaper.ps1 -Add "File:<one>.jpg|File:<two>.jpg" -Name <one-name>,<two-name> -Variant day,night
```

Add every picked image in one run: titles separated by `|`, one name each, and one mark for all or one each, separated by commas. `-Variant` is required; the script shows the suggestion beside it. For each image it saves the original byte for byte to `wallpapers/<short-name>.jpg` (from the cache `-Check` filled), writes the 640 px thumbnail, and prints a credit section with the mark.

Paste it into `wallpapers/README.md`:

- Add each image as a single. Make a pair only when the user asks for one.
- A single image gets its own `##` section, after the last one.
- A pair is one `##` section, listed before single images, with both thumbnails and a `###` subsection per image: one `day`, one `night`.

Rewrite **Subject** as one plain line. Keep the README to what a reader needs: image, mark, credit, license. No measurements or notes.

Then run `pwsh build/check.ps1`. It confirms every wallpaper has a thumbnail, a credit, and a mark, and every pair has one day and one night image.

## Report back

One or two lines: which image, its license and author, its mark, and the suggested variant if it differs.
