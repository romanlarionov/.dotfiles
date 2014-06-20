
" Starting NeoBundle
if has('vim_starting')
   set nocompatible 

   " Required:
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
call neobundle#end()

filetype plugin indent on

NeoBundleCheck


" Bundles 

NeoBundleLazy 'scrooloose/nerdtree'


" NERDTree code
autocmd vimenter * if !argc() | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>

