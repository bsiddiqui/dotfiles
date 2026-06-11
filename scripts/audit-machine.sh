#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANDIDATES_FILE="$DOTFILES_DIR/docs/machine-candidates.md"

usage() {
  cat <<'USAGE'
Usage: ./scripts/audit-machine.sh [--output PATH]

Writes an editable machine setup inventory. Existing candidate statuses and
notes are preserved by stable row ID when the file is regenerated.

Statuses:
  candidate  observed, but not approved for bootstrap
  promote    approved to incorporate into setup later
  skip       intentionally ignored
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --output)
    CANDIDATES_FILE="${2:-}"
    if [ -z "$CANDIDATES_FILE" ]; then
      echo "error: --output requires a path" >&2
      exit 1
    fi
    shift
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

escape_cell() {
  local value="${1:-}"
  value="${value//$'\n'/ }"
  value="${value//$'\r'/ }"
  value="${value//|//}"
  printf '%s' "$value" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

preserved_field() {
  local id="$1"
  local field="$2"

  if [ ! -f "$CANDIDATES_FILE" ]; then
    return
  fi

  awk -F'|' -v wanted="$id" -v wanted_field="$field" '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/^`|`$/, "", value)
      return value
    }
    {
      row_id = trim($3)
      if (row_id == wanted) {
        if (wanted_field == "status") {
          print trim($2)
        } else if (wanted_field == "notes") {
          print trim($6)
        }
        exit
      }
    }
  ' "$CANDIDATES_FILE"
}

row_status() {
  local id="$1"
  local status
  status="$(preserved_field "$id" status || true)"

  case "$status" in
  candidate | promote | skip)
    printf '%s' "$status"
    ;;
  *)
    printf 'candidate'
    ;;
  esac
}

row_notes() {
  local id="$1"
  local notes
  notes="$(preserved_field "$id" notes || true)"

  if [ -n "$notes" ]; then
    printf '%s' "$notes"
  else
    printf 'Review before promoting.'
  fi
}

add_row() {
  local id="$1"
  local observed="$2"
  local recommendation="$3"
  local status notes

  status="$(row_status "$id")"
  notes="$(row_notes "$id")"

  printf "| %s | \`%s\` | %s | %s | %s |\n" \
    "$status" \
    "$(escape_cell "$id")" \
    "$(escape_cell "$observed")" \
    "$(escape_cell "$recommendation")" \
    "$(escape_cell "$notes")"
}

section_header() {
  local title="$1"
  printf '\n## %s\n\n' "$title"
  printf '| Status | ID | Observed | Recommendation | Notes |\n'
  printf '| --- | --- | --- | --- | --- |\n'
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

add_defaults_row() {
  local id="$1"
  local domain="$2"
  local key="$3"
  local value
  value="$(defaults_value "$domain" "$key")"
  add_row "$id" "$domain $key=$value" "Promote only if this preference should be recreated on new Macs."
}

brewfile_items() {
  local kind="$1"
  local file="$2"

  if [ ! -f "$file" ]; then
    return
  fi

  awk -v kind="$kind" '
    $1 == kind {
      item = $2
      gsub(/"/, "", item)
      print item
    }
  ' "$file" | sort -u
}

installed_apps() {
  find /Applications "$HOME/Applications" -maxdepth 1 -name '*.app' -print 2>/dev/null |
    sed 's#.*/##; s#\.app$##' |
    sort -u
}

npm_globals() {
  if ! command -v npm >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    return
  fi

  npm -g list --depth=0 --json 2>/dev/null |
    jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value.version // "unknown")"' 2>/dev/null |
    sort -u
}

go_binaries() {
  if ! command -v go >/dev/null 2>&1; then
    return
  fi

  local gopath
  gopath="$(go env GOPATH 2>/dev/null || true)"
  if [ -z "$gopath" ] || [ ! -d "$gopath/bin" ]; then
    return
  fi

  find "$gopath/bin" -maxdepth 1 -type f -perm -111 -print 2>/dev/null |
    sed 's#.*/##' |
    sort -u
}

local_bins() {
  find "$HOME/.local/bin" "$HOME/bin" -maxdepth 1 -type f -perm -111 -print 2>/dev/null |
    sed "s#$HOME#~#" |
    sort -u
}

write_macos_settings() {
  section_header "macOS Settings"

  add_defaults_row "macos.NSGlobalDomain.InitialKeyRepeat" "NSGlobalDomain" "InitialKeyRepeat"
  add_defaults_row "macos.NSGlobalDomain.KeyRepeat" "NSGlobalDomain" "KeyRepeat"
  add_defaults_row "macos.NSGlobalDomain.ApplePressAndHoldEnabled" "NSGlobalDomain" "ApplePressAndHoldEnabled"
  add_defaults_row "macos.NSGlobalDomain.com.apple.swipescrolldirection" "NSGlobalDomain" "com.apple.swipescrolldirection"
  add_defaults_row "macos.NSGlobalDomain.com.apple.trackpad.scaling" "NSGlobalDomain" "com.apple.trackpad.scaling"
  add_defaults_row "macos.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls" "NSGlobalDomain" "AppleEnableSwipeNavigateWithScrolls"
  add_defaults_row "macos.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically" "NSGlobalDomain" "AppleInterfaceStyleSwitchesAutomatically"
  add_defaults_row "macos.com.apple.dock.autohide" "com.apple.dock" "autohide"
  add_defaults_row "macos.com.apple.dock.tilesize" "com.apple.dock" "tilesize"
  add_defaults_row "macos.com.apple.dock.wvous-br-corner" "com.apple.dock" "wvous-br-corner"
  add_defaults_row "macos.com.apple.finder.FXPreferredViewStyle" "com.apple.finder" "FXPreferredViewStyle"
  add_defaults_row "macos.com.apple.WindowManager.AppWindowGroupingBehavior" "com.apple.WindowManager" "AppWindowGroupingBehavior"
  add_defaults_row "macos.com.apple.WindowManager.HideDesktop" "com.apple.WindowManager" "HideDesktop"
}

write_keyboard_mappings() {
  local keys key value

  section_header "Keyboard Mappings"

  if command -v hidutil >/dev/null 2>&1; then
    value="$(hidutil property --get UserKeyMapping 2>/dev/null || true)"
    add_row "keyboard.hidutil.UserKeyMapping" "hidutil UserKeyMapping=$value" "Inventory only; promote key remaps deliberately."
  fi

  keys="$(defaults -currentHost read -g 2>/dev/null |
    awk -F'"' '/com\.apple\.keyboard\.modifiermapping/ {print $2}' |
    sort -u || true)"

  if [ -z "$keys" ]; then
    add_row "keyboard.currentHost.none" "No CurrentHost modifier mappings found." "Leave skipped unless you expected a mapping."
    return
  fi

  while IFS= read -r key; do
    [ -n "$key" ] || continue
    value="$(defaults -currentHost read -g "$key" 2>/dev/null || true)"
    add_row "keyboard.currentHost.$key" "$key=$value" "Likely device-specific; promote only after confirming the keyboard mapping is intentional."
  done <<EOF
$keys
EOF
}

write_homebrew_drift() {
  local brewfile="$DOTFILES_DIR/Brewfile"
  local item

  section_header "Homebrew Drift"

  if ! command -v brew >/dev/null 2>&1; then
    add_row "brew.unavailable" "brew not found" "Install Homebrew before auditing package drift."
    return
  fi

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "brew.extra-formula.$item" "$item is installed as a direct formula but is not in Brewfile." "Promote to Brewfile only if still wanted globally."
  done <<EOF
$(comm -23 <(brew leaves 2>/dev/null | sort -u) <(brewfile_items brew "$brewfile"))
EOF

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "brew.extra-cask.$item" "$item is installed as a cask but is not in Brewfile." "Promote to Brewfile or future Brewfile.personal only if intentional."
  done <<EOF
$(comm -23 <(brew list --cask 2>/dev/null | sort -u) <(brewfile_items cask "$brewfile"))
EOF

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "brew.missing-formula.$item" "$item is listed in Brewfile but not currently installed." "Usually investigate naming, stale formulae, or whether brew bundle needs to run."
  done <<EOF
$(comm -13 <(brew list --formula 2>/dev/null | sort -u) <(brewfile_items brew "$brewfile"))
EOF

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "brew.missing-cask.$item" "$item is listed in Brewfile but not currently installed." "Usually investigate cask renames or whether brew bundle needs to run."
  done <<EOF
$(comm -13 <(brew list --cask 2>/dev/null | sort -u) <(brewfile_items cask "$brewfile"))
EOF
}

write_apps_inventory() {
  local app

  section_header "Installed App Inventory"

  while IFS= read -r app; do
    [ -n "$app" ] || continue
    add_row "app.$app" "$app is present in /Applications or ~/Applications." "Inventory only; promote to Brewfile.personal only if it should be installed on new Macs."
  done <<EOF
$(installed_apps)
EOF
}

write_language_tools() {
  local item

  section_header "Language And User Tool Inventory"

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "npm.global.${item%@*}" "$item is installed as a global npm package." "Prefer project-local packages; promote only if this should be global."
  done <<EOF
$(npm_globals)
EOF

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "go.bin.$item" "$item is executable in GOPATH/bin." "Promote only after confirming the module path and version."
  done <<EOF
$(go_binaries)
EOF

  if command -v uv >/dev/null 2>&1; then
    while IFS= read -r item; do
      [ -n "$item" ] || continue
      add_row "uv.tool.$item" "$item" "Inventory only; promote only if this uv tool is still needed globally."
    done <<EOF
$(uv tool list 2>/dev/null || true)
EOF
  fi

  if command -v pipx >/dev/null 2>&1; then
    while IFS= read -r item; do
      [ -n "$item" ] || continue
      add_row "pipx.tool.$item" "$item" "Inventory only; promote only if this pipx tool is still needed globally."
    done <<EOF
$(pipx list 2>/dev/null || true)
EOF
  fi

  if command -v cargo >/dev/null 2>&1; then
    while IFS= read -r item; do
      [ -n "$item" ] || continue
      add_row "cargo.tool.${item%% *}" "$item" "Inventory only; promote only if this cargo tool is still needed globally."
    done <<EOF
$(cargo install --list 2>/dev/null | awk '/^[^[:space:]].*:$/ {gsub(/:$/, "", $1); print $1}' || true)
EOF
  fi

  if command -v mise >/dev/null 2>&1; then
    while IFS= read -r item; do
      [ -n "$item" ] || continue
      add_row "mise.tool.${item%% *}" "$item" "Inventory only; prefer repo-local mise config where possible."
    done <<EOF
$(mise ls 2>/dev/null || true)
EOF
  fi

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    add_row "local.bin.$item" "$item is an executable in ~/.local/bin or ~/bin." "Inventory only; promote only if there is a stable install source."
  done <<EOF
$(local_bins)
EOF
}

mkdir -p "$(dirname "$CANDIDATES_FILE")"
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

{
  cat <<EOF
# Machine Candidates

Generated by \`scripts/audit-machine.sh\`.

This file is a review queue, not desired state. Change \`Status\` from
\`candidate\` to \`promote\` only for items you want incorporated into setup
later. Use \`skip\` for known bloat or machine-specific state.

EOF

  write_macos_settings
  write_keyboard_mappings
  write_homebrew_drift
  write_apps_inventory
  write_language_tools
} >"$tmp_file"

mv "$tmp_file" "$CANDIDATES_FILE"
trap - EXIT

echo "wrote: $CANDIDATES_FILE"
