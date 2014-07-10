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
syntax enable
set term=xterm-256color

" VIM Solarized Theme
set background=dark
colorscheme solarized

" Wildmenu
set wildmode=list:longest
"set wildmenuset

" Scrolling 
set scrolloff=8         			" Start scrolling when we're 8 lines away from margins. 

""""""""""""""""""""""""""""
" Pathogen Plugins
""""""""""""""""""""""""""""

" Airline
set laststatus=2					" Makes airline appear all the time.
let g:airline_powerline_fonts = 1	" Allow Powerline fonts.




