set nocompatible

call pathogen#infect()
call pathogen#helptags()

syntax on
filetype plugin indent on

":set number
"autocmd vimenter * NERDTree
"colorscheme lucius
"LuciusDark
colorscheme xoria256

nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

set guifont=Monospace\ 12

set nobackup
set incsearch
set hlsearch
set encoding=utf-8
let g:Powerline_symbols = 'unicode'

" Markdown extension
au BufNewFile,BufRead *.md set ft=md

"autocmd FileType ruby setlocal expandtab shiftwidth=2 softtabstop=2
