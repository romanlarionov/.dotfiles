" Here are some basic customizations, please refer to the ~/.SpaceVim.d/init.vim
" file for all possible options:
let g:spacevim_default_indent = 4
let g:spacevim_max_column     = 80

" Change the default directory where all miscellaneous persistent files go.
" By default it is ~/.cache/vimfiles.
"let g:spacevim_plugin_bundle_dir = '~/.cache/vimfiles'

" C++ specific
let g:neomake_cpp_enabled_makers=["clang"]
let g:neomake_cpp_clang_args = ["-std=c++11", "-Wextra", "-Wall", "-fsanitize=undefined","-g"]

set number

" set SpaceVim colorscheme
"let g:spacevim_colorscheme = 'jellybeans'

" Set plugin manager, you want to use, default is dein.vim
"let g:spacevim_plugin_manager = 'dein'  " neobundle or dein or vim-plug

" use space as `<Leader>`
let mapleader = "\<space>"

" By default, language specific plugins are not loaded. This can be changed
" with the following, then the plugins for go development will be loaded.
"call SpaceVim#layers#load('lang#go')

" loaded ui layer
call SpaceVim#layers#load('ui')

" If there is a particular plugin you don't like, you can define this
" variable to disable them entirely:
"let g:spacevim_disabled_plugins=[
"    \ ['junegunn/fzf.vim'],
"    \ ]

" If you want to add some custom plugins, use these options:
"let g:spacevim_custom_plugins = [
"    \ ['plasticboy/vim-markdown', {'on_ft' : 'markdown'}],
"    \ ['wsdjeg/GitHub.vim'],
"    \ ]