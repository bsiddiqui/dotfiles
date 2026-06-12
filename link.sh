#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

link_file() {
  local source="$1"
  local target="$2"
  local target_dir
  target_dir="$(dirname "$target")"

  mkdir -p "$target_dir"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok: $target"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup_name="${target#"$HOME"/}"
    local backup_target="$BACKUP_DIR/$backup_name"
    mkdir -p "$(dirname "$backup_target")"
    echo "backup: $target -> $backup_target"
    mv "$target" "$backup_target"
  fi

  ln -s "$source" "$target"
  echo "link: $target -> $source"
}

install_if_missing() {
  local source="$1"
  local target="$2"
  local target_dir
  target_dir="$(dirname "$target")"

  mkdir -p "$target_dir"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "exists: $target"
    return
  fi

  cp "$source" "$target"
  echo "install: $target"
}

# shellcheck source=scripts/links.sh
source "$DOTFILES_DIR/scripts/links.sh"

for entry in "${DOTFILES_LINKS[@]}"; do
  link_file "$DOTFILES_DIR/${entry%%|*}" "${entry#*|}"
done

install_if_missing "$DOTFILES_DIR/agents/codex/config.template.toml" "$HOME/.codex/config.toml"

if [ ! -e "$HOME/.zshrc.local" ]; then
  echo "tip: copy templates/zshrc.local.example to ~/.zshrc.local for machine-local secrets and PATH additions."
fi
