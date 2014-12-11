"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Be sure to read the README!
"   shortcuts:
"   ; maps to :
"   ,a: ack from the current directory
"   ,b: browse tags
"   ,c: toggle comments
"   ,C: toggle block comments
"   ,nt: open file in new tab
"   ,l: toggle NERDTree
"   ,h: open a shell in a new tab
"   ,k: syntax-check the current file
"   ,m: toggle mouse support
"   ,p: toggle paste mode
"   ,o: open file
"   ,s: split window
"   ,hs: horizontal split
"   ,t: new tab
"   ,w: close tab
"   ,ed: edit vimrc
"   ,src: source vimrc
"   ,tgt: display target of cursor position
"   kj: enter normal mode and save
"   Ctrl+{h,j,k,l}: move among windows
"   ii: operate on all text at current indent level
"   ai: operate on all text plus one line up at current indent level
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" long live vim
set encoding=utf-8
set nocompatible

" vundle
filetype off
set rtp+=~/dotfiles/.vim/bundle/Vundle.vim
call vundle#begin()
Bundle 'gmarik/Vundle.vim'

" color schemes
Bundle 'nanotech/jellybeans.vim'
Bundle 'tomasr/molokai'
Bundle 'vim-scripts/Skittles-Dark'
Bundle 'sickill/vim-monokai'
Bundle 'hukl/Smyck-Color-Scheme'
Bundle 'vim-scripts/wombat256.vim'

" plugins
Bundle 'mileszs/ack.vim'
Bundle 'tomtom/checksyntax_vim'
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'tpope/vim-fugitive'
Bundle 'jistr/vim-nerdtree-tabs'
Bundle 'bling/vim-airline'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'tomtom/tcomment_vim'
Bundle 'vim-scripts/trailing-whitespace'
Bundle 'vim-scripts/taglist.vim'
Bundle 'terryma/vim-multiple-cursors'
" Bundle 'kshenoy/vim-signature'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'raimondi/delimitMate'
Bundle 'gregsexton/gitv'
Bundle 'godlygeek/tabular'
" Bundle 'Valloric/YouCompleteMe'
Bundle 'marijnh/tern_for_vim'
Bundle 'ervandew/supertab'
" Bundle 'SirVer/ultisnips'

" syntax files
Bundle 'jelera/vim-javascript-syntax'
Bundle 'tpope/vim-markdown'
Bundle 'voithos/vim-python-syntax'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-haml'
Bundle 'digitaltoad/vim-jade'
Bundle 'wavded/vim-stylus'
Bundle 'mustache/vim-mustache-handlebars'
Bundle 'groenewege/vim-less'

" checksyntax config
let g:checksyntax#auto_mode = 0

" taglist config
let g:Tlist_Use_Right_Window = 1

" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" syntax highlighting and auto-indentation
syntax on
filetype indent on
filetype plugin on
inoremap # X<C-H>#
set ai
set si
set nu

" omg folding is the worst
set nofoldenable

" omg automatic comment insertion is the worst
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" expand tabs to 2 spaces
set shiftwidth=2
set tabstop=2
set smarttab
set expandtab

" auto save buffers whenever you lose focus
au FocusLost * silent! wa

" auto save buffers when you switch context
set autowriteall

" buffer navigation
nnoremap <silent> <tab> <C-i>
nnoremap <silent> <S-tab> <C-o>

" leave showtabline as default (for now)
set showtabline=1

" searching options
set incsearch
set showcmd
set ignorecase
set smartcase
set hlsearch

" escape search highliting by hitting return
nnoremap <CR> :noh<CR><CR>

" disable backups
set nobackup
set nowritebackup
set noswapfile

" disable annoying beep on errors
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set vb t_vb=
endif

" font options
set background=dark
set t_Co=256
colorscheme smyck

" keep at least 5 lines below the cursor
set scrolloff=5

" window options
set showmode
set showcmd
set ruler
set ttyfast
set backspace=indent,eol,start
set laststatus=2

" enable mouse support
set mouse=a

" cursor
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" word wrapping
set wrap
set linebreak
set nolist

" better tab completion on commands
set wildmenu
set wildmode=list:longest

" close buffer when tab is closed
set nohidden

" better moving between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" shortcuts to common commands
let mapleader = ","
nnoremap <leader>a :Ack
nnoremap <leader>b :TlistToggle<CR>
nnoremap <leader>c :TComment<CR>
nnoremap <leader>C :TCommentBlock<CR>
vnoremap <leader>c :TComment<CR>
vnoremap <leader>C :TCommentBlock<CR>
nnoremap <leader>nt :tabnew<CR>:CtrlP<CR>
nnoremap <leader>l :NERDTreeTabsToggle<CR>
nnoremap <leader>k :CheckSyntax<CR>
nnoremap <leader>o :CtrlP<CR>
nnoremap <leader>p :set invpaste<CR>
nnoremap <leader>t :tabnew<CR>
nnoremap <leader>s :vsplit<CR>
nnoremap <leader>hs :split<CR>
nnoremap <leader>w :tabclose<CR>
nnoremap <leader>ed :tabnew ~/.vimrc<cr>
nnoremap <leader>src :source ~/.vimrc<cr>
nnoremap <leader>tgt :set cursorcolumn! cursorline!<CR>

" ; is better than :, and kj is better than ctrl-c
nnoremap ; :
nnoremap : ;

"swap areas of text
vnoremap <C-X> <Esc>`.``gvP``P

" remove any trailing whitespace that is in the file
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" also autosave when going to insert mode
inoremap kj <Esc>:w<CR>
inoremap jk <Esc>:w<CR>

" more logical vertical navigation
nnoremap <silent> k gk
nnoremap <silent> j gj

" compile coffee into js
function! BrewCoffee()
  silent! !coffee -p % &> /tmp/coffeetmp.js
  sview /tmp/coffeetmp.js
endfunc

" make copy/pasting nice
function! ToggleMouse()
    if &mouse == 'a'
        set mouse=r
        set nonu
    else
        set mouse=a
        set nu
    endif
endfunction
nnoremap <leader>m :call ToggleMouse()<CR>

" statusline
set laststatus=2

" ctrl p settings
" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.yardoc\|node_modules\|dist\|log\|tmp$',
  \ 'file': '\.so$\|\.dat$|\.DS_Store$'
  \ }

call vundle#config#require(g:bundles)
