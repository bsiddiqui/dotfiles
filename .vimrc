" long live vim
set encoding=utf-8
set nocompatible

" vundle
filetype off
set rtp+=~/dotfiles/.vim/bundle/Vundle.vim
call vundle#begin()

" let vundle manage vundle
Bundle 'gmarik/Vundle.vim'

" color schemes
Bundle 'brendonrapp/smyck-vim'

" plugins
Bundle 'rking/ag.vim'
" Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'tpope/tpope-vim-abolish'
Bundle 'tpope/vim-fugitive'
Bundle 'jistr/vim-nerdtree-tabs'
Bundle 'bling/vim-airline'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'tomtom/tcomment_vim'
" Bundle 'vim-scripts/trailing-whitespace'
Bundle 'vim-scripts/taglist.vim'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'raimondi/delimitMate'
Bundle 'gregsexton/gitv'
Bundle 'godlygeek/tabular'
Bundle 'Valloric/YouCompleteMe'
Bundle 'marijnh/tern_for_vim'
Bundle 'ervandew/supertab'
" Bundle 'SirVer/ultisnips'
Bundle 'honza/vim-snippets'
Bundle 'tpope/vim-eunuch'
Bundle 'wincent/Command-T'
Bundle 'skywind3000/asyncrun.vim'
Bundle 'github/copilot.vim'

" syntax files
Bundle 'w0rp/ale'
Bundle 'vim-scripts/JavaScript-Indent'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-markdown'
Bundle 'voithos/vim-python-syntax'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-haml'
Bundle 'digitaltoad/vim-jade'
Bundle 'wavded/vim-stylus'
Bundle 'mustache/vim-mustache-handlebars'
Bundle 'groenewege/vim-less'
Bundle 'pantharshit00/vim-prisma'
call vundle#end()

" shortcuts to common commands
let mapleader = ","
nnoremap <leader>a :Ag
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
nnoremap <leader>RC :.-1read ~/code/snippets/container.js<CR>G<ESC>dd
nnoremap <leader>Rc :.-1read ~/code/snippets/component.js<CR>G<ESC>dd

" checksyntax config
let g:checksyntax#auto_mode = 0

" use standard javascript syntax checking
let g:ale_fixers = {'javascript': ['prettier_standard']}
let g:ale_linters = {'javascript': ['standard']}
let g:ale_sign_error = '●'
let g:ale_sign_error = '.'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
nmap <silent> <C-b> <Plug>(ale_previous_wrap)
nmap <silent> <C-n> <Plug>(ale_next_wrap)

" taglist config
let g:Tlist_Use_Right_Window = 1

" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ale#enabled = 1

" snippet config
let g:UltiSnipsExpandTrigger="<C-j>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"

" ctrlp config
" let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\.git$\|\.yardoc\|node_modules\|dist\|log\|tmp$',
"   \ 'file': '\.so$\|\.dat$|\.DS_Store$'
"   \ }
" ag is fast enough that ctrlp doesn't need to cache
" let g:ctrlp_use_caching = 0

set wildignore+=dist,ios

" command-t config
let g:CommandTTraverseSCM = 'pwd'
let g:CommandTCancelMap=['<ESC>', '<C-c>']
let g:CommandTHighlightColor= 'CursorLine'
let g:CommandTCursorColor= 'Constant'
let g:CommandTCharMatchedColor= 'Constant'
set wildignore+=*.DS_Store,.git,node_modules,Pods,android
nnoremap <C-p> <Esc>:CommandT<CR>

" use ag over grep
set grepprg=ag\ --nogroup\ --nocolor

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

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

" ; is better than :
nnoremap ; :
nnoremap : ;

" kj/jk is better than ctrl-c or esc - also autosave when leaving insert mode
inoremap kj <Esc>:w<CR>
inoremap jk <Esc>:w<CR>
inoremap jj <Esc>

" remove any trailing whitespace that is in the file
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" more logical vertical navigation
nnoremap <silent> k gk
nnoremap <silent> j gj

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

" call vundle#config#require(g:bundles)
