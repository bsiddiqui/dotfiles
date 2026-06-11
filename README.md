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

## Machine Candidates

The default bootstrap is intentionally lean: it does not copy every global
package, installed app, or macOS preference from the current machine.

To create an editable review queue of things that might be worth promoting
later:

```sh
just audit-machine
```

This writes `docs/machine-candidates.md`. Rows start as `candidate`; change a
row to `promote` only when you want it folded into setup later, or `skip` when
it is known bloat or machine-specific state.

The file is generated, machine-specific, and gitignored: it inventories
installed apps, global packages, and macOS preferences, which should not be
published in this repo.

Read-only checks for promoted rows:

```sh
just macos-check
just personal-check
just doctor-personal
```

These commands report drift only. They do not install packages or apply macOS
settings.

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
docs/machine-candidates.md Generated review queue for optional machine state (gitignored)
shell/                   Zsh path, aliases, and functions
agents/                  Codex and Claude portable templates
apps/                    App config for Zed, gh, Ghostty
templates/               Ignored local overlay examples
```

## Agent Config

Tracked:

- `agents/codex/config.template.toml`
- `agents/claude/settings.json`
- `agents/AGENTS.md`
- `agents/CLAUDE.md`

Permission defaults:

- Codex template sets `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`.
- Claude settings allow common tools, set `permissions.defaultMode = "bypassPermissions"`, and set `skipDangerousModePermissionPrompt = true`.
- Both Codex and Claude play `/System/Library/Sounds/Blow.aiff` when an agent finishes.
- Zed settings set `agent.tool_permissions.default = "allow"` and `agent.play_sound_when_agent_done = "always"`.

`agents/AGENTS.md` is the shared instruction source. `link.sh` links it to `~/.codex/AGENTS.md` for Codex and `~/.claude/AGENTS.md` for Claude imports. `agents/CLAUDE.md` is a small Claude wrapper that imports `@AGENTS.md` and leaves room for Claude-specific notes without duplicating shared guidance.

`link.sh` links Claude settings directly. Codex config is copied from the template only if `~/.codex/config.toml` does not already exist, because Codex stores machine-local app state in that file.

Not tracked:

- `~/.codex/auth.json`
- `~/.codex/history.jsonl`
- `~/.codex/*.sqlite*`
- `~/.codex/logs*`
- `~/.claude/history.jsonl`
- `~/.claude/sessions/`
- Any generated cache, telemetry, or auth state
