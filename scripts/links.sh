# shellcheck shell=bash
# Single source of truth for managed symlinks, sourced by link.sh and
# doctor.sh. Each entry is "repo-relative-source|absolute-target".
# shellcheck disable=SC2034
DOTFILES_LINKS=(
  ".zprofile|$HOME/.zprofile"
  ".zshrc|$HOME/.zshrc"
  ".gitconfig|$HOME/.gitconfig"
  ".gitignore_global|$HOME/.gitignore_global"
  ".gemrc|$HOME/.gemrc"
  ".ackrc|$HOME/.ackrc"
  ".vimrc|$HOME/.vimrc"
  ".tmux.conf|$HOME/.tmux.conf"
  "apps/zed/settings.json|$HOME/.config/zed/settings.json"
  "apps/gh/config.yml|$HOME/.config/gh/config.yml"
  "apps/ghostty/config|$HOME/.config/ghostty/config"
  "macos/com.basils.dotfiles.key-remap.plist|$HOME/Library/LaunchAgents/com.basils.dotfiles.key-remap.plist"
  "agents/AGENTS.md|$HOME/.codex/AGENTS.md"
  "agents/AGENTS.md|$HOME/.claude/AGENTS.md"
  "agents/CLAUDE.md|$HOME/.claude/CLAUDE.md"
  "agents/claude/settings.json|$HOME/.claude/settings.json"
)
