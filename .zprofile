# Homebrew lives in different prefixes on Apple Silicon and Intel Macs.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
[ -r "$DOTFILES_DIR/shell/path.zsh" ] && source "$DOTFILES_DIR/shell/path.zsh"
