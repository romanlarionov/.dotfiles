"""""""""""""""""""""""""""""""""
" Roman Larionov's vim settings
"""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""

set nocompatible
filetype off

syntax on
set number

" Whitespace
set tabstop=4
set shiftwidth=4
set autoindent
set smarttab
set copyindent
set smartindent
set shiftround

" Standard
set hlsearch
set smartcase
set showmatch
set nobackup
set noswapfile
set term=xterm-256color
set scrolloff=8         		" Start scrolling when we're 8 lines away from margins. 
set visualbell					" No more dings.

" Useful remaps
nnoremap ; :					
nnoremap j gj	
nnoremap k gk				
nnoremap <silent> <C-T> :tabnext<CR>

""""""""""""""""""""""""""""
" Vundle Plugins
""""""""""""""""""""""""""""
" Vundle Help

" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()	" Place all vundle plugins here:

" Plugins
Plugin 'gmarik/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized' 
Plugin 'bling/vim-airline'


call vundle#end()
filetype plugin indent on

""""""""""""""""""""""""""""
" Vundle Options
""""""""""""""""""""""""""""

" VIM Solarized Theme
set background=dark
colorscheme solarized

" Airline
set laststatus=2					" Makes airline appear all the time.
let g:airline_powerline_fonts = 1	" Allow Powerline fonts.
let g:airline_theme="solarized"

" NERDTree			
autocmd vimenter * NERDTree 				" Auto start NERD Tree.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
nnoremap <silent> <C-X> :NERDTreeToggle<CR>
nnoremap <silent> <C-C> :NERDTree<CR>
let NERDTreeShowHidden=1


