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
echo "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
echo "Moving any existing dotfiles from ~ to $olddir"
for file in $files; do
  mv ~/$file ~/dotfiles_old/
  echo "Creating symlink to $file in home directory."
  ln -s $dir/$file ~/$file
done
echo "done"

# install homebrew
echo "installing homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "done"

# install some taps
echo "installing some taps"
brew install ag cmake ctags tmux vim node reattach-to-user-namespace caskroom/cask/brew-cask
echo "done"

# install some apps"
echo "installing some apps"
brew cask install google-chrome soundcleod iterm2 dropbox postman flux notion quip telegram spotify sublime-text stremio postico slack
echo "done"

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
cd ~/dotfiles/.vim/bundle/YouCompleteMe && ./install.sh
echo "done"

# setup tern server
echo "setting up tern server"
cd ~/.vim/bundle/tern_for_vim && npm install
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
