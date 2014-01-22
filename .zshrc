# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

alias learnyounode="/Users/Basil/.node/bin/learnyounode"

# General aliases
alias zshconfig='vim ~/.zshrc'
alias vimconfig='vim ~/.vim/.vimrc'
alias pgstart='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
alias pgstop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'
alias code='~/Desktop/Code'
alias ocarina='~/Desktop/Code/ocarina'
alias nest='~/Desktop/Code/Branch/Nest'
alias fs='foreman start'

# Git Aliases
get_git_branch() {
  echo `git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
}
alias gcam='git commit -am'
alias gps='git push origin `get_git_branch`'
alias gpl='git pull origin `get_git_branch`'
alias gs='git status'
alias gap='git add -p'
alias tests='bundle exec guard -g backend'
alias queue='bundle exec rake jobs:clear;VERBOSE=1 bundle exec rake resque:work'

# Rails Aliases
alias rs='rs'
alias rc='rc'

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

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git rails)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/usr/local/heroku/bin:$PATH:/usr/local/bin:/usr/local/sbin:~/bing:/Users/Basil/.rvm/gems/ruby-1.9.3-p327@rails329/bin:/Users/Basil/.rvm/gems/ruby-1.9.3-p327@global/bin:/Users/Basil/.rvm/rubies/ruby-1.9.3-p327/bin:/Users/Basil/.rvm/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

alias subl='open -a "Sublime Text 2"'
alias vi="/usr/local/bin/vim"

