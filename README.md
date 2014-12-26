# Dotfiles

## Setup

clone this repository
```
git clone https://github.com/bsiddiqui/dotfiles.git ~/dotfiles
```
navigate into dotfiles directory
```
cd ~/dotfiles
```
make the devsetup.sh script executable
```
chmod +x devsetup.sh
```
run the script
```
./devsetup.sh
```

## Vim

### Color Schemes

The default color scheme is [Smyck](https://github.com/hukl/Smyck-Color-Scheme/), which looks best with the [corresponding terminal theme](https://github.com/hukl/Smyck-Color-Scheme/) installed as well.

### Font

Using one of the following fonts is recommended: https://github.com/Lokaltog/powerline-fonts. Right now, I use Inconsolata. On iTerm2, you may have to make the size of "Non-ASCII Font" smaller than the size of "Regular Font" in order to ensure everything lines up in your powerline. I typically use 12pt for "Regular" and 10pt for "Non-ASCII".

### Shortcuts

* ; maps to :
* ,a: ack from the current directory
* ,b: browse tags
* ,c: toggle comments
* ,C: toggle block comments
* ,nt: open file in new tab
* ,l: toggle NERDTree
* ,k: syntax-check the current file
* ,o: open file
* ,p: toggle paste mode
* ,t: new tab
* ,s: vertical split window
* ,hs: horizontal split window
* ,w: close tab
* kj: enter normal mode and save
* Ctrl+{h, j, k, l}: move among windows

## Credits

Inspiration drawn from [@ranman](https://github.com/ranman/), [@tmacwill](https://github.com/tmacwill/), [@MattNguyen](https://github.com/MattNguyen/)
