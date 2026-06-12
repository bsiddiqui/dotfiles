#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANDIDATES_FILE="$DOTFILES_DIR/docs/machine-candidates.md"
status=0

usage() {
  cat <<'USAGE'
Usage: ./scripts/personal-check.sh

Checks personal/package rows marked "promote" in docs/machine-candidates.md.
This script reports missing items only; it does not install anything.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$#" -gt 0 ]; then
  usage >&2
  exit 1
fi

if [ ! -f "$CANDIDATES_FILE" ]; then
  echo "missing: $CANDIDATES_FILE"
  echo "run: ./scripts/audit-machine.sh"
  exit 1
fi

promoted_rows() {
  awk -F'|' '
    function trim_value(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/^`|`$/, "", value)
      return value
    }
    {
      status = trim_value($2)
      id = trim_value($3)
      observed = trim_value($4)
      if (status == "promote" && id !~ /^macos\./ && id !~ /^keyboard\./) {
        print id "\t" observed
      }
    }
  ' "$CANDIDATES_FILE"
}

check_command_available() {
  local command_name="$1"
  local required_for="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  echo "missing: $command_name is required to check $required_for"
  status=1
  return 1
}

check_brew_formula() {
  local name="$1"

  check_command_available brew "$name" || return
  if brew list --formula "$name" >/dev/null 2>&1; then
    echo "ok: brew formula $name"
  else
    echo "missing: brew formula $name"
    status=1
  fi
}

check_brew_cask() {
  local name="$1"

  check_command_available brew "$name" || return
  if brew list --cask "$name" >/dev/null 2>&1; then
    echo "ok: brew cask $name"
  else
    echo "missing: brew cask $name"
    status=1
  fi
}

check_app() {
  local name="$1"

  if [ -d "/Applications/$name.app" ] || [ -d "$HOME/Applications/$name.app" ]; then
    echo "ok: app $name"
  else
    echo "missing: app $name"
    status=1
  fi
}

check_npm_global() {
  local name="$1"

  check_command_available npm "$name" || return
  if npm -g list --depth=0 "$name" >/dev/null 2>&1; then
    echo "ok: npm global $name"
  else
    echo "missing: npm global $name"
    status=1
  fi
}

check_go_bin() {
  local name="$1"

  check_command_available go "$name" || return
  local gopath
  gopath="$(go env GOPATH 2>/dev/null || true)"
  if [ -n "$gopath" ] && [ -x "$gopath/bin/$name" ]; then
    echo "ok: Go binary $name"
  else
    echo "missing: Go binary $name"
    status=1
  fi
}

check_local_bin() {
  local path="$1"
  path="${path/#\~/$HOME}"

  if [ -x "$path" ]; then
    echo "ok: local executable $path"
  else
    echo "missing: local executable $path"
    status=1
  fi
}

check_named_tool() {
  local command_name="$1"
  local label="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    echo "ok: $label $command_name"
  else
    echo "missing: $label $command_name"
    status=1
  fi
}

promoted_count=0
while IFS=$'\t' read -r id observed; do
  [ -n "${id:-}" ] || continue
  promoted_count=$((promoted_count + 1))

  case "$id" in
  brew.extra-formula.*)
    check_brew_formula "${id#brew.extra-formula.}"
    ;;
  brew.missing-formula.*)
    check_brew_formula "${id#brew.missing-formula.}"
    ;;
  brew.extra-cask.*)
    check_brew_cask "${id#brew.extra-cask.}"
    ;;
  brew.missing-cask.*)
    check_brew_cask "${id#brew.missing-cask.}"
    ;;
  app.*)
    check_app "${id#app.}"
    ;;
  npm.global.*)
    check_npm_global "${id#npm.global.}"
    ;;
  go.bin.*)
    check_go_bin "${id#go.bin.}"
    ;;
  local.bin.*)
    check_local_bin "${observed%% is an executable*}"
    ;;
  uv.tool.*)
    check_named_tool "${id#uv.tool.}" "uv tool"
    ;;
  pipx.tool.*)
    check_named_tool "${id#pipx.tool.}" "pipx tool"
    ;;
  cargo.tool.*)
    check_named_tool "${id#cargo.tool.}" "cargo tool"
    ;;
  mise.tool.*)
    echo "info: mise promoted row '$id' should be checked against repo-local mise config"
    ;;
  *)
    echo "warning: unsupported promoted row $id"
    status=1
    ;;
  esac
done <<EOF
$(promoted_rows)
EOF

if [ "$promoted_count" -eq 0 ]; then
  echo "ok: no promoted personal/package rows to check"
fi

exit "$status"
