export PATH=/usr/local/bin:/usr/local/sbin:$PATH:$HOME/.rvm/bin


# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git macos rails node heroku)
source $ZSH/oh-my-zsh.sh

for file in ~/.{functions,aliases}; do
    [ -r "$file" ] && source "$file"
done
unset file

# disable marking untracked files under VCS as dirty DISABLE_UNTRACKED_FILES_DIRTY="true"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.fastlane/bin:$PATH"
