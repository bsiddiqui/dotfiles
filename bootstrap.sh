#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_BUNDLE=0

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh [--skip-bundle|-s]

Options:
  -s, --skip-bundle  Skip brew bundle and run the rest of bootstrap.
  -h, --help         Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  -s | --skip-bundle)
    SKIP_BUNDLE=1
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [ "$(uname)" != "Darwin" ]; then
    echo "Homebrew is not installed. Install it first, then rerun this script." >&2
    exit 1
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_homebrew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    return
  fi

  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
}

set_default_shell() {
  local zsh_path
  if ! command -v brew >/dev/null 2>&1; then
    return
  fi

  zsh_path="$(brew --prefix)/bin/zsh"

  if [ ! -x "$zsh_path" ]; then
    echo "warning: brewed zsh is not installed at $zsh_path"
    return
  fi

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    echo "register: $zsh_path in /etc/shells"
    printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null || {
      echo "warning: could not register $zsh_path in /etc/shells"
    }
  fi

  if [ "${SHELL:-}" != "$zsh_path" ]; then
    chsh -s "$zsh_path" || echo "warning: could not change default shell automatically"
  fi
}

install_homebrew
load_homebrew

if [ "$SKIP_BUNDLE" -eq 1 ]; then
  echo "skip: brew bundle"
else
  brew bundle --file "$DOTFILES_DIR/Brewfile"
fi

install_oh_my_zsh
"$DOTFILES_DIR/link.sh"

if command -v git >/dev/null 2>&1; then
  git -C "$DOTFILES_DIR" config core.hooksPath .githooks
fi

set_default_shell

cat <<'NEXT_STEPS'

Bootstrap complete.

Recommended next steps:
  1. Rotate any API keys that were previously stored directly in shell config.
  2. Put local secrets in ~/.zshrc.local, 1Password, or per-project ignored .env.local files.
  3. Run: gh auth login
  4. Run: codex login
  5. Run: claude login
  6. Run: ./doctor.sh

NEXT_STEPS
