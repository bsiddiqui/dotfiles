export PATH=/usr/local/heroku/bin:$PATH:/usr/local/bin:/usr/local/sbin:~/bing:/Users/Basil/.rvm/gems/ruby-1.9.3-p327@rails329/bin:/Users/Basil/.rvm/gems/ruby-1.9.3-p327@global/bin:/Users/Basil/.rvm/rubies/ruby-1.9.3-p327/bin:/Users/Basil/.rvm/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git osx rails node)
source $ZSH/oh-my-zsh.sh

for file in ~/.{functions,aliases}; do
    [ -r "$file" ] && source "$file"
done
unset file

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"
