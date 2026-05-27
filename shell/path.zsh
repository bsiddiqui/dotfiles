typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "$HOME/.fastlane/bin"
  "$HOME/.rbenv/bin"
  $path
)

for brew_prefix in /opt/homebrew /usr/local; do
  [ -d "$brew_prefix/opt/postgresql@16/bin" ] && path=("$brew_prefix/opt/postgresql@16/bin" $path)
  [ -d "$brew_prefix/opt/ruby/bin" ] && path=("$brew_prefix/opt/ruby/bin" $path)
done
unset brew_prefix

if command -v gem >/dev/null 2>&1; then
  gem_bin="$(gem environment gemdir 2>/dev/null)/bin"
  [ -d "$gem_bin" ] && path=("$gem_bin" $path)
  unset gem_bin
fi

export GOPATH="${GOPATH:-$HOME/go}"

if command -v zed >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-zed --wait}"
  export VISUAL="${VISUAL:-zed --wait}"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-vim}"
  export VISUAL="${VISUAL:-vim}"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
