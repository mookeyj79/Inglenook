#!/usr/bin/env bash
# Halloy's part of the chat scene, run from its recipe's stage steps after apply.
# Puts the update check first (a TOML root key comes before any section), keeps
# what apply wrote, then adds the font and the scene's server. No colors here.
set -euo pipefail
cfg=~/.config/halloy/config.toml
{
  printf 'check_for_update_on_launch = false\n'
  cat "$cfg"
  printf '\n[font]\nfamily = "IBM Plex Mono"\nsize = 14\n'
  printf '\n[servers.inglenook]\nnickname = "reader"\nserver = "127.0.0.1"\nport = 6667\nuse_tls = false\nchannels = ["#inglenook", "#garden", "#tea"]\n'
} > "$cfg.new"
mv "$cfg.new" "$cfg"
