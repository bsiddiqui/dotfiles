# Dotfiles

Portable macOS setup for agent-heavy coding, terminal work, and daily apps.

## Setup

```sh
git clone https://github.com/bsiddiqui/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew when needed, runs `brew bundle`, links managed dotfiles, installs Oh My Zsh if missing, and enables this repo's pre-commit hook.

For repeat runs that should skip the full Brewfile pass:

```sh
./bootstrap.sh --skip-bundle
```

For link-only changes:

```sh
./link.sh
```

For a quick health check:

```sh
./doctor.sh
```

## Secrets

Do not commit private keys, API keys, auth files, histories, SQLite state, or machine IDs.

Use ignored local overlays instead:

- `~/.zshrc.local` for machine-local exports and PATH changes.
- `~/.gitconfig.local` for private identity or tool-specific machine IDs.
- Per-project `.env.local` files for app secrets.
- 1Password CLI, macOS Keychain, or another secret manager for real credentials.

Templates live in `templates/`.

```sh
cp templates/zshrc.local.example ~/.zshrc.local
cp templates/gitconfig.local.example ~/.gitconfig.local
```

The repo includes `scripts/secret-scan.sh` and a pre-commit hook to catch common secret patterns before they reach GitHub.

## Layout

```text
Brewfile                 Homebrew formulae and apps
bootstrap.sh             New-machine setup
link.sh                  Idempotent symlink manager
doctor.sh                Local setup checks
shell/                   Zsh path, aliases, and functions
agents/                  Codex and Claude portable templates
apps/                    App config for Zed, gh, Ghostty
templates/               Ignored local overlay examples
legacy/                  Old Vim, tmux powerline, and iTerm configs
```

## Agent Config

Tracked:

- `agents/codex/config.template.toml`
- `agents/claude/settings.json`
- `agents/AGENTS.md`

Permission defaults:

- Codex template sets `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`.
- Claude settings allow common tools, set `permissions.defaultMode = "bypassPermissions"`, and set `skipDangerousModePermissionPrompt = true`.
- Both Codex and Claude play `/System/Library/Sounds/Blow.aiff` when an agent finishes.
- Zed settings set `agent.tool_permissions.default = "allow"` and `agent.play_sound_when_agent_done = "always"`.

`link.sh` links Claude settings directly. Codex config is copied from the template only if `~/.codex/config.toml` does not already exist, because Codex stores machine-local app state in that file.

Not tracked:

- `~/.codex/auth.json`
- `~/.codex/history.jsonl`
- `~/.codex/*.sqlite*`
- `~/.codex/logs*`
- `~/.claude/history.jsonl`
- `~/.claude/sessions/`
- Any generated cache, telemetry, or auth state

## Legacy Vim And Tmux

The old plugin-heavy Vim and tmux powerline configs are preserved under `legacy/`. The active root `.vimrc` and `.tmux.conf` are intentionally small fallback configs.
