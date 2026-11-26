# ripgrep: color mapping

For maintainers. The install guide is [README.md](README.md).

## Color mapping

| App setting | Color | Why |
|---|---|---|
| `path:fg` | reference (pine) | File names are paths |
| `line:fg` | dim | Line numbers are supporting text, like a gutter |
| `column:fg` | dim | Same as line numbers |
| `match:fg`, `match:bg` | text on the steel wash | Every match in the output, per Search and matches in PHILOSOPHY.md |
| `match:style` | bold | ripgrep's own default; a second signal besides color |

Each type is cleared with `{type}:none` first, so ripgrep's defaults (magenta paths, green line numbers, red matches) never leak through.

## Gaps and trade-offs

- Tier 2: ripgrep has no background or plain-text setting. Both come from the terminal, so the port looks right only on an Inglenook terminal.
- The match is the one background the port sets. The wash is mixed into `base`, so it is exact only on an Inglenook terminal; elsewhere `text` on it still reads, as with the Git grep match. It is written as `{{steel|wash|comma}}`, since ripgrep takes `r,g,b`.
- The `highlight` type (whole matching lines) is newer than ripgrep 14, which Ubuntu 24.04 and Mint 22 ship. An unknown type is an error that stops every search, so the port leaves it out.
- Context lines and the separators between matches and file groups have no color setting.
- The screenshots show the stock terminal theme behind ripgrep (Adwaita light and dark), since no Inglenook terminal port exists yet.

## Research

- [Dracula for ripgrep](https://github.com/dracula/ripgrep) (MIT): a config file of `--colors` lines with 24-bit hex triples for path, line, column and match, installed through `RIPGREP_CONFIG_PATH`. Same method here; no files reused.
- ripgrep takes a 24-bit color as `r,g,b` with no spaces (decimal or `0x` hex). `r, g, b` is rejected, hence the `|comma` filter.
- Config file rules (GUIDE.md): one argument per line, verbatim, no escaping; `#` lines and blank lines are ignored; command-line flags override it.

## Screenshot recipe

- ripgrep needs no login or license (MIT or Unlicense, [LICENSE](https://github.com/BurntSushi/ripgrep/blob/master/LICENSE-MIT)).
- The scene runs the search in `bash -i` so it reads `RIPGREP_CONFIG_PATH` from `~/.bashrc`, as the reader's shell would. `--sort path` is added so every take prints the same order. Not tested by hand.
