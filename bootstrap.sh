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

check_fetch_url() {
  local label="$1"
  local url="$2"

  if curl -fsSL --connect-timeout 10 --max-time 20 "$url" >/dev/null; then
    echo "ok: $label"
    return
  fi

  echo "error: could not reach $label ($url)" >&2
  return 1
}

check_http_status() {
  local label="$1"
  local url="$2"
  local expected_statuses="$3"
  local status

  status="$(curl -sS -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 20 "$url" || true)"

  case " $expected_statuses " in
  *" $status "*)
    echo "ok: $label"
    ;;
  *)
    echo "error: could not reach $label ($url returned HTTP $status)" >&2
    return 1
    ;;
  esac
}

check_homebrew_fetch_access() {
  local status=0

  echo "check: Homebrew fetch access"
  check_fetch_url "Homebrew formula API" "https://formulae.brew.sh/api/formula/bat.json" || status=1
  check_fetch_url "GitHub" "https://github.com/Homebrew/brew" || status=1
  check_http_status "GitHub Container Registry" "https://ghcr.io/v2/" "200 401" || status=1

  if [ "$status" -ne 0 ]; then
    cat >&2 <<'HELP'

Homebrew needs access to formulae.brew.sh, github.com, and ghcr.io before
brew bundle can fetch formula metadata and bottles. If this is a managed or
filtered network, try a VPN, phone hotspot, or proxy configuration, then rerun
./bootstrap.sh.
HELP
    exit 1
  fi
}

update_homebrew_metadata() {
  echo "update: Homebrew metadata"

  if brew update --force --quiet; then
    return
  fi

  cat >&2 <<'HELP'

Homebrew could not update its metadata. Try this manually for the full error:

  brew update --force
  brew doctor

Then rerun ./bootstrap.sh.
HELP
  exit 1
}

tap_brewfile_taps() {
  echo "tap: Brewfile taps"

  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file "$DOTFILES_DIR/Brewfile" --tap |
    while IFS= read -r tap_name; do
      [ -n "$tap_name" ] || continue
      brew tap "$tap_name"
    done
}

run_brew_bundle() {
  check_homebrew_fetch_access
  update_homebrew_metadata
  tap_brewfile_taps
  brew bundle --file "$DOTFILES_DIR/Brewfile"
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
  run_brew_bundle
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
