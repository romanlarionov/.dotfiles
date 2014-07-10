"""""""""""""""""""""""""""""""""
" Roman Larionov's vim settings
"""""""""""""""""""""""""""""""""

"Load Pathogen and all bundles
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""
 
set number
set tabstop=4
set shiftwidth=4
set hlsearch
set smartcase
set smarttab
set shiftround
set showmatch
set autoindent
set copyindent
set nobackup
set noswapfile
syntax enable
set term=xterm-256color
set scrolloff=8         		" Start scrolling when we're 8 lines away from margins. 
nnoremap ; :
nnoremap j gj
nnoremap k gk
set visualbell

""""""""""""""""""""""""""""
" Pathogen Plugins
""""""""""""""""""""""""""""

" VIM Solarized Theme
set background=dark
colorscheme solarized

" Airline
set laststatus=2					" Makes airline appear all the time.
let g:airline_powerline_fonts = 1	" Allow Powerline fonts.

" NERD Tree
autocmd vimenter * NERDTree			" Auto start NERD Tree.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
nnoremap <silent> <C-T> :NERDTreeToggle<CR>




