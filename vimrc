"""""""""""""""""""""""""""""""""
" Roman Larionov's vim settings
"""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""
set nocompatible
filetype off

" Whitespace
set tabstop=4
set shiftwidth=4
set autoindent
set smarttab
set copyindent
set smartindent
set shiftround

" Searching
set ignorecase
set smartcase
set nohlsearch					" Disable highlighting after seach.
set incsearch					" Search as you type

" Standard
syntax on
set number
set showmatch					" Shows matching brace/bracket.
set nobackup
set noswapfile
set term=xterm-256color
set scrolloff=999         		" Current line always stays in the middle of the screen. 
set colorcolumn=105				" Color in code stop marker on start.
set cursorline					" Highlights current line.
set visualbell					" Set bell to flash screen.
set t_vb=						" Visual bell now does nothing.

" Useful remaps
nnoremap ; :					
nnoremap j gj	
nnoremap k gk	
nnoremap <silent> t :tabnext<CR>	

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
Plugin 'scrooloose/nerdtree'
Plugin 'altercation/vim-colors-solarized' 
Plugin 'bling/vim-airline'
Plugin 'vim-scripts/Conque-Shell'
Plugin 'vim-scripts/Auto-Pairs'
Plugin 'scrooloose/syntastic'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'walm/jshint.vim'

if !has("win32") || !has("win16")
	Plugin 'Valloric/YouCompleteMe'
endif

call vundle#end()
filetype plugin indent on

""""""""""""""""""""""""""""
" Plugin Options
""""""""""""""""""""""""""""

" VIM Solarized Theme
set background=dark
colorscheme solarized

" Airline
set laststatus=2					" Makes airline appear all the time.
let g:airline_powerline_fonts  = 1	" Allow Powerline fonts.
let g:airline_enable_branch    = 1
let g:airline_enable_syntastic = 1

" NERDTree			
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeShowHidden=1	" Show hidden files
nnoremap <silent> <C-X> :NERDTreeToggle<CR>

" Conque Shell
nnoremap <C-Z> :ConqueTermSplit zsh <CR>
let g:ConqueTerm_StartMessages = 0 

" Indent Guides
"hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1

" Syntastic
let g:syntastic_cpp_check_header = 1

" YouCompleteMe
let g:ycm_enable_diagnostic_highlighting = 1			" YCM will highlight the part of the line where there's an issue.
let g:ycm_seed_identifiers_with_syntax = 1				" YCM will show keywords for various languages in complete box.
let g:ycm_add_preview_to_completeopt = 1				" Shows more info about the proposed autocomplete.
let g:ycm_autoclose_preview_window_after_completion = 1 " Closes preview after tab complete.
let g:ycm_autoclose_preview_window_after_insertion = 1  " Closes preview if user leaves insert mode.



