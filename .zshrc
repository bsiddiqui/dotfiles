# Keep this file portable and secret-free. Put machine-local exports, tokens,
# and one-off PATH additions in ~/.zshrc.local, which is intentionally ignored.
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

[ -r "$DOTFILES_DIR/shell/path.zsh" ] && source "$DOTFILES_DIR/shell/path.zsh"

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="${ZSH_THEME:-robbyrussell}"
plugins=(git macos rails node)

if [ -r "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

for file in "$DOTFILES_DIR"/shell/functions.zsh "$DOTFILES_DIR"/shell/aliases.zsh; do
  [ -r "$file" ] && source "$file"
done
unset file

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
