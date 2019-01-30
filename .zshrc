export PATH=/usr/local/bin:/usr/local/sbin:$PATH:$HOME/.rvm/bin


# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git osx rails node heroku)
source $ZSH/oh-my-zsh.sh

for file in ~/.{functions,aliases}; do
    [ -r "$file" ] && source "$file"
done
unset file

# disable marking untracked files under VCS as dirty DISABLE_UNTRACKED_FILES_DIRTY="true"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

export PATH="$HOME/.fastlane/bin:$PATH"
