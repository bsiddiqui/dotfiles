My preferred vim setup
---

## Installation:

    yum install ack ctags
    mkdir ~/.vim
    git clone git://github.com/bsiddiqui/vimrc.git ~/.vim
    ln -s ~/.vim/.vimrc ~/.vimrc
    vim +BundleInstall +qall

## Color Schemes

The default color scheme is [Smyck](https://github.com/hukl/Smyck-Color-Scheme/), which looks best with the corresponding terminal theme installed as well.

Other available (awesome) colorschemes:

* jellybeans
* skittles_dark
* molokai
* wombat256mod

## Font

Using one of the following fonts is recommended: https://github.com/Lokaltog/powerline-fonts. Right now, I use Inconsolata. On iTerm2, you may have to make the size of "Non-ASCII Font" smaller/bigger than the size of "Regular Font" in order to ensure everything lines up.

## Shortcuts

* ; maps to :
* ,a: ack from the current directory
* ,b: browse tags
* ,c: toggle comments
* ,C: toggle block comments
* ,nt: open file in new tab
* ,l: toggle NERDTree
* ,h: open a shell in a new tab
* ,k: syntax-check the current file
* ,m: toggle mouse support
* ,p: toggle paste mode
* ,o: open file
* ,s: vertical split window
* ,hs: horizontal split window
* ,t: new tab
* ,w: close tab
* ,ed: edit vimrc
* ,src: source vimrc
* kj: enter normal mode and save
* Ctrl+{h,j,k,l}: move among windows
