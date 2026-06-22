#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0
CHECK_PERSONAL=0

usage() {
  cat <<'USAGE'
Usage: ./doctor.sh [--personal]

Options:
  --personal  Also check promoted personal/package and macOS candidate rows.
  -h, --help  Show this help.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --personal)
    CHECK_PERSONAL=1
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

# shellcheck source=scripts/links.sh
source "$DOTFILES_DIR/scripts/links.sh"

for entry in "${DOTFILES_LINKS[@]}"; do
  check_link "$DOTFILES_DIR/${entry%%|*}" "${entry#*|}"
done

if [ "$(uname)" = "Darwin" ]; then
  if "$DOTFILES_DIR/scripts/macos-settings.sh" --check; then
    :
  else
    status=1
  fi
fi

if [ "$CHECK_PERSONAL" -eq 1 ]; then
  if "$DOTFILES_DIR/scripts/macos-defaults.sh" --check; then
    echo "ok: promoted macOS candidates"
  else
    status=1
  fi

  if "$DOTFILES_DIR/scripts/personal-check.sh"; then
    echo "ok: promoted personal candidates"
  else
    status=1
  fi
fi

exit "$status"
