" Minimal fallback Vim config.
set nocompatible
set encoding=utf-8
syntax on
filetype plugin indent on

let mapleader = ","
set number
set scrolloff=5
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab
set shiftwidth=2
set tabstop=2
set nofoldenable
set mouse=a
set nobackup
set nowritebackup
set noswapfile

if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case
elseif executable("ag")
  set grepprg=ag\ --nogroup\ --nocolor
endif

nnoremap ; :
nnoremap : ;
nnoremap <CR> :noh<CR><CR>
nnoremap <leader>s :vsplit<CR>
nnoremap <leader>hs :split<CR>
inoremap jk <Esc>
inoremap kj <Esc>

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
autocmd BufWritePre * if ! &bin | silent! %s/\s\+$//e | endif
