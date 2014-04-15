export PATH=/usr/local/bin:/Users/Basil/.rvm/bin:/usr/local/Library/Formula/nvm.rb:$PATH

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git osx rails node)
source $ZSH/oh-my-zsh.sh

for file in ~/.{functions,aliases}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

source $HOME/.nvm/nvm.sh
