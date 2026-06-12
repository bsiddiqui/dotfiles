#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANDIDATES_FILE="$DOTFILES_DIR/docs/machine-candidates.md"
status=0

usage() {
  cat <<'USAGE'
Usage: ./scripts/macos-defaults.sh --check

Checks macOS rows marked "promote" in docs/machine-candidates.md against the
current machine. This script does not apply settings.
USAGE
}

if [ "${1:-}" != "--check" ]; then
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
      if (status == "promote" && (id ~ /^macos\./ || id ~ /^keyboard\./)) {
        print id "\t" observed
      }
    }
  ' "$CANDIDATES_FILE"
}

defaults_value() {
  local domain="$1"
  local key="$2"

  if [ "$domain" = "NSGlobalDomain" ]; then
    defaults read -g "$key" 2>/dev/null || printf '__UNSET__'
  else
    defaults read "$domain" "$key" 2>/dev/null || printf '__UNSET__'
  fi
}

normalize_value() {
  local value="${1:-}"
  value="${value//$'\n'/ }"
  value="${value//$'\r'/ }"
  printf '%s' "$value" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

check_defaults_row() {
  local id="$1"
  local observed="$2"
  local domain key expected current

  domain="${observed%% *}"
  key="${observed#* }"
  key="${key%%=*}"
  expected="${observed#*=}"

  if [ -z "$domain" ] || [ -z "$key" ] || [ "$expected" = "$observed" ]; then
    echo "warning: cannot parse promoted row $id"
    status=1
    return
  fi

  current="$(defaults_value "$domain" "$key")"
  if [ "$(normalize_value "$current")" = "$(normalize_value "$expected")" ]; then
    echo "ok: $id"
  else
    echo "drift: $id expected '$(normalize_value "$expected")' but found '$(normalize_value "$current")'"
    status=1
  fi
}

check_keyboard_row() {
  local id="$1"
  local observed="$2"
  local key expected current

  case "$id" in
  keyboard.hidutil.UserKeyMapping)
    expected="${observed#*=}"
    current="$(hidutil property --get UserKeyMapping 2>/dev/null || true)"
    ;;
  keyboard.currentHost.*)
    key="${observed%%=*}"
    expected="${observed#*=}"
    current="$(defaults -currentHost read -g "$key" 2>/dev/null || true)"
    ;;
  *)
    echo "warning: unsupported promoted keyboard row $id"
    status=1
    return
    ;;
  esac

  if [ "$(normalize_value "$current")" = "$(normalize_value "$expected")" ]; then
    echo "ok: $id"
  else
    echo "drift: $id expected '$(normalize_value "$expected")' but found '$(normalize_value "$current")'"
    status=1
  fi
}

promoted_count=0
while IFS=$'\t' read -r id observed; do
  [ -n "${id:-}" ] || continue
  promoted_count=$((promoted_count + 1))
  case "$id" in
  macos.*)
    check_defaults_row "$id" "$observed"
    ;;
  keyboard.*)
    check_keyboard_row "$id" "$observed"
    ;;
  esac
done <<EOF
$(promoted_rows)
EOF

if [ "$promoted_count" -eq 0 ]; then
  echo "ok: no promoted macOS or keyboard rows to check"
fi

exit "$status"
