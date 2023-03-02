#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables
# dotfiles directory
dir=~/dotfiles
# old dotfiles backup directory
olddir=~/dotfiles_old
# list of files/folders to symlink in homedir
files=".tmux.conf .zshrc .vimrc .aliases .functions .gitconfig .gitignore .gemrc .ackrc"

##########

# create dotfiles_old in homedir
echo "creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir

# change to the dotfiles directory
echo "changing to the $dir directory ..."
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
echo "moving any existing dotfiles from ~ to $olddir"
for file in $files; do
  mv ~/$file ~/dotfiles_old/
  echo "creating symlink to $file in home directory."
  ln -s $dir/$file ~/$file
done

# install homebrew
echo "installing homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install some taps
echo "installing some taps"
brew tap dbt-labs/dbt
brew install dbt postgres firebase-cli heroku/brew/heroku python3 ag cmake ctags tmux vim node reattach-to-user-namespace dockutil ruby
brew services start postgresql

# install some apps"
echo "installing some apps"
brew cask install alfred google-cloud-sdk zoom superhuman google-chrome soundcleod iterm2 dropbox postman flux notion telegram spotify stremio postico slack figma notion

# remove pinned apps from the dock
echo "removing pinned apps from dock"
dockutil --remove all

echo "rebooting terminal"
source ~/.zshrc

# install vundle
echo "install vundle"
mkdir -p ~/dotfiles/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git ~/dotfiles/.vim/bundle/Vundle.vim
ln -s ~/dotfiles/.vim ~/.vim
echo "done"

# install vim bundles
echo "installing vim bundles"
vim +BundleInstall +qall
echo "done"

# compile YCM
echo "compiling youcompleteme"
cd ~/dotfiles/.vim/bundle/YouCompleteMe && python3 install.py --clangd-completer --ts-completer
echo "done"

# setup tern server
echo "setting up tern server"
cd ~/.vim/bundle/tern_for_vim && npm install
echo "done"

# setup command-t
echo "setting up command-t"
cd ~/.vim/bundle/Command-T/ruby/command-t/ext/command-t
ruby extconf.rb
make
echo "done"

echo "setting up terminal profile"
git clone https://github.com/hukl/Smyck-Color-Scheme.git ~/Downloads/Smyck-Terminal-Theme
git clone https://github.com/powerline/fonts.git ~/Downloads/Powerline-Fonts
cd ~/Downloads/Powerline-Fonts && ./install.sh Inconsolata
rm -rf ~/Downloads/Powerline-Fonts
echo "done"

install_zsh () {
  # Test to see if zshell is installed.  If it is:
  if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone the oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -d ~/.oh-my-zsh/ ]]; then
      echo "installing oh-my-zsh"
      git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
      echo "done"
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
      chsh -s $(which zsh)
    fi
  else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
      sudo apt-get install zsh
      install_zsh
      # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
      echo "Please install zsh, then re-run this script!"
      exit
    fi
  fi
}

install_zsh
