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

link_file "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/.functions" "$HOME/.functions"
link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES_DIR/.gemrc" "$HOME/.gemrc"
link_file "$DOTFILES_DIR/.ackrc" "$HOME/.ackrc"
link_file "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

link_file "$DOTFILES_DIR/apps/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$DOTFILES_DIR/apps/gh/config.yml" "$HOME/.config/gh/config.yml"
link_file "$DOTFILES_DIR/apps/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES_DIR/agents/claude/settings.json" "$HOME/.claude/settings.json"
install_if_missing "$DOTFILES_DIR/agents/codex/config.template.toml" "$HOME/.codex/config.toml"

if [ ! -e "$HOME/.zshrc.local" ]; then
  echo "tip: copy templates/zshrc.local.example to ~/.zshrc.local for machine-local secrets and PATH additions."
fi
