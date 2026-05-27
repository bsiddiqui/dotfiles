#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0

required_commands=(
  brew
  git
  gh
  rg
  fd
  fzf
  jq
  direnv
  codex
  claude
  zed
)

check_command() {
  local command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    echo "ok: $command_name"
  else
    echo "missing: $command_name"
    status=1
  fi
}

check_link() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok: $target linked"
  else
    echo "missing: $target should link to $source"
    status=1
  fi
}

for command_name in "${required_commands[@]}"; do
  check_command "$command_name"
done

if command -v brew >/dev/null 2>&1; then
  if brew bundle check --file "$DOTFILES_DIR/Brewfile" >/dev/null 2>&1; then
    echo "ok: Brewfile satisfied"
  else
    echo "missing: Brewfile has missing or outdated packages"
    status=1
  fi
fi

if "$DOTFILES_DIR/scripts/secret-scan.sh"; then
  echo "ok: no obvious secrets in tracked files"
else
  status=1
fi

if [ -f "$HOME/.zshrc" ] && grep -Eq 'sk-(ant|proj)-|OPENAI_API_KEY=|ANTHROPIC_API_KEY=' "$HOME/.zshrc"; then
  echo "warning: ~/.zshrc appears to contain an API key. Move secrets to ~/.zshrc.local or a secret manager."
fi

check_link "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
check_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
check_link "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
check_link "$DOTFILES_DIR/.functions" "$HOME/.functions"
check_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
check_link "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
check_link "$DOTFILES_DIR/.gemrc" "$HOME/.gemrc"
check_link "$DOTFILES_DIR/.ackrc" "$HOME/.ackrc"
check_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
check_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
check_link "$DOTFILES_DIR/apps/zed/settings.json" "$HOME/.config/zed/settings.json"
check_link "$DOTFILES_DIR/apps/gh/config.yml" "$HOME/.config/gh/config.yml"
check_link "$DOTFILES_DIR/apps/ghostty/config" "$HOME/.config/ghostty/config"
check_link "$DOTFILES_DIR/agents/claude/settings.json" "$HOME/.claude/settings.json"

exit "$status"
