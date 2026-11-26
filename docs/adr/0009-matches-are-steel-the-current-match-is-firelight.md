# Search matches are steel; the match at the cursor is firelight

Search and find matches need a color of their own in every app that highlights them: editors, pickers, pagers, grep tools, and history search. No role means "match", and the first ports each picked their own (firelight in ripgrep and Git grep, steel in fzf and Neovim, yellow in less and nano), so the same search looked different from app to app.

Every match is marked with a steel wash and `text` on it, or with steel text, bold where possible, in an app that colors only the text. The one match at the cursor, or on the selected line, is a firelight fill with `on_accent` text: it is "you are here", the accent's one meaning (ADR 0004). An app that keeps syntax colors on a match, such as VS Code, gives the current match the steel wash and a firelight border instead. A 16-color tool has no washes and no firelight slot, and its yellow slot is brass, the warning color, so it uses the blue slot, which is steel, in reverse video for every match.

Steel was picked because it is calm, reads as information, and is not the selection's color. Most established themes keep matches apart from the selection, and Tokyo Night uses the same split: a cool wash for every match and a warm accent for the current one.

## Consequences

- The selection stays a firelight wash. Steel never marks a selection, and firelight never marks a match away from the cursor.
- Tools with one match, shown at the cursor (zsh's history search, zsh-history-substring-search), use the firelight fill.
- PSReadLine has one match color for history search and every row of its suggestion list, so it uses the steel wash everywhere.
- A wash written as `r,g,b` or `r;g;b` chains a format filter after `|wash`, such as `{{steel|wash|comma}}` for ripgrep.
- Washes are mixed into `base`, so a terminal tool's match wash is exact only on an Inglenook terminal.
