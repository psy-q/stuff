" Parts stolen from: https://github.com/skwp/dotfiles

set nocompatible


set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-cucumber'
Bundle 'vim-ruby/vim-ruby'
Bundle 'kien/ctrlp.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-fugitive'
Bundle 'hughbien/md-vim'
Bundle 'maciakl/vim-neatstatus'

syntax on
set hidden
filetype plugin indent on

" == Indentation ==
set autoindent
set smartindent
set smarttab
"set shiftwidth=2
"set softtabstop=2
"set tabstop=2
set expandtab

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

" == Extra matchers for % ==
runtime macros/matchit.vim

" == Folds ==

set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

" == Scrolling

set scrolloff=4         "Start scrolling when we're 4 lines away from margins


" == Backup files
set nobackup
set nowb

" == Search settings ==
set incsearch
set hlsearch


" == Line numbering ==
set number

" == Colors ==
colorscheme xoria256

" == Mousymouse
set mouse=a
set ttymouse=xterm2

" == Open NERDTree on entering? ==
"autocmd vimenter * NERDTree


" == Easily navigate split windows ==
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" == Easily jump between buffers
nmap <silent> <C-J> :bprevious<CR>
nmap <silent> <C-K> :bnext<CR>

" == Easily jump between tabs
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>


" == Fonts, encoding, Powerline ==

set guifont=Monospace\ 12
set encoding=utf-8
let g:Powerline_symbols = 'unicode'

" Markdown extension
au BufNewFile,BufRead *.md set ft=md
