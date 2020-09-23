"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Misc
"{

let skip_defaults_vim = 1

set nocompatible
set number
set nospell
set noswapfile
set novisualbell
set belloff=all

" copies all yank commands to clipboard
set clipboard=unnamed

if exists(":termsize")
    set termsize=10x999
endif

" set the character for vertical separating column between windows
set fillchars+=vert:│

" detect if a build script is detected and map it to Ctrl-B
function! BuildProject()
    let g:build_script = ".build.sh"
    if !exists('s:build_script_available')
        if g:build_script == "" || !filereadable(g:build_script)
            echoerr 'Could not find ./.build.sh'
            return
        endif
        let s:build_script_available = 1
    endif

    execute '!./' . g:build_script
endfunction

augroup misc_group
    autocmd!

    " use vertical split for help
    autocmd FileType help wincmd L

    " understand glsl files
    autocmd BufNewFile,BufRead *.vp,*.fp,*.gp,*.vs,*.fs,*.gs,*.tes,*.cs,*.vert,*.frag,*.geom,*.tess,*.shd,*.gls,*.glsl \ 
        set filetype=glsl

    " redraw with the cursorline in the middle of the screen
    autocmd BufEnter,WinEnter,WinNew,VimResized *,*.* norm zz

    " automatically makes split windows equal size after resizing app or font
    autocmd VimResized * if &equalalways | wincmd = | endif

augroup END

" TODO: find way to detect if in visual studio
let s:on_windows = has('win32') || has('win64')

" TODO: find out if there's a way to add empty 'padding' lines before the first line of code if you press 'zz' towards the top of the file.
" This works for the bottom of the file. meaning if you type 'shft-g' followed by 'zz', it will still bring the last line to the middle of the screen.

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Sessions
"{

let g:session_file = ""
let g:session_dir = ""
function! SaveSession()
    if g:session_dir != "" && g:session_file != ""
        if !isdirectory(g:session_dir)
            execute 'silent !mkdir -p ' g:session_dir
        endif
        execute "mksession! " . g:session_file
    endif
endfunction

" TODO: should automatically create tags and put them into the session directory...
" whether that's somethign that happens all the time is a good question'

function! LoadSession()
    " if starting vim without referencing a file (no arguments)
    if argc() == 0
        let g:session_dir = $HOME . "/.vim/sessions" . getcwd()
        let g:session_file = g:session_dir . "/Session.vim"
        if (filereadable(g:session_file))
            execute 'source ' g:session_file
        endif
    endif
endfunction

augroup session_group
    autocmd!
    autocmd VimEnter * nested :call LoadSession()
    autocmd VimLeavePre * :call SaveSession()
augroup END

" what to save into session file
set sessionoptions=buffers,curdir,folds,winpos,winsize

" disable writing to ~/.viminfo on exit in favor of sessions
set viminfo=""

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Search
"{

set incsearch
set fileignorecase
set ignorecase

" fuzzy finding
set wildmenu
set wildignorecase
set wildmode=full,list:full
set wildignore+=*.o,*.jpg,*.obj,*.mtl,*.png,*.docx,*.exe
set wildignore+=*/node_modules/*,*/build/*,*/.git/*,*/deps/*,*Debug/*,*Release/*

" add ~/.tags directory when searching for a tag
set tags+=~/.tags/*
set tags+=$ROMANS_TAGS_PATH

" treat tag paths as global
set notagrelative

" TODO: look into 'popup'

" TODO: need some way of specifying (for tags) that I want to follow the tag in a separate window.
" basically, I want it to show up to the right of the screen so I can keeyp looking at where I was just at.
" ^^ can look up 'window-tag'

" TODO: look into 'preview-popup' and more specifically ':ptag'

" Ctrl-F starts fuzzy finding files
nnoremap <C-F> :find *

" TODO: when I use :find, I would like it to search through my loaded buffers. Need to write a function I think:
" https://vi.stackexchange.com/questions/2904/how-to-show-search-results-for-all-open-buffers

" sets path vim searches with 'find' to the current dir + recursively downwards
set path=.,,**

" opens autocompete popup with the tab/shift-tab keys in smart way
" TODO: this screws up the visual studio plugin for some reason
"inoremap <expr> <TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-N>" : "<TAB>"
"inoremap <expr> <S-TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-P>" : "<TAB>"

" which buffers to search for autocomplete via TAB
set complete=w,.,b,u,t

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Movement
"{

set nomousefocus
set mousehide
set scrolloff=5

if has("mouse")
    set mouse=n
endif

" keep cursor location the same when using the scroll wheel
nnoremap <ScrollWheelUp> 3<C-U>
nnoremap <ScrollWheelDown> 3<C-D>

nnoremap <S-K> <C-U>
nnoremap <S-J> <C-D>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Indentation
"{

set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set smartindent
set shiftround

" allow backspace to go to previous line
set backspace=indent,eol,start

" TODO: can I make this not exit virtual mode?
" tab in visual mode indents
vnoremap <TAB> >
vnoremap <S-TAB> <

nnoremap < <<
nnoremap > >>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Formatting
"{

set formatoptions+=ro

" TODO: these should be smarter and context dependent
" print matching braces
inoremap { {}<Esc>i
"inoremap ( ()<Esc>i
"inoremap [ []<Esc>i
"inoremap " ""<Esc>i
"inoremap ' ''<Esc>i

set foldopen=hor,search,undo

" fold matching brace
nnoremap <C-M> zf%<CR>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Colors
"{

" mintty identifies itself as xterm-compatible
if &term =~ 'xterm-256color'
    if &t_Co =~ 8
        " Use at least 256 colors
        set t_Co = 256
    endif

endif

syntax enable
syntax sync minlines=16 maxlines=64

set synmaxcol=256
set hlsearch

" highlight matching braces
set showmatch

highlight Comment      cterm=none                   ctermfg=darkgreen
highlight ErrorMsg     cterm=none ctermbg=darkred   ctermfg=black

highlight IncSearch    cterm=none ctermbg=darkgray  ctermfg=yellow
highlight Search       cterm=none ctermbg=yellow    ctermfg=black
highlight Visual       cterm=none ctermbg=yellow    ctermfg=black
highlight Folded       cterm=bold ctermbg=none      ctermfg=yellow

highlight LineNr       cterm=none                   ctermfg=blue
highlight CursorLineNr cterm=none                   ctermfg=yellow
highlight TabLine      cterm=none ctermbg=darkgray  ctermfg=white
highlight VertSplit    cterm=none ctermbg=black     ctermfg=darkgray

highlight StatusLine   cterm=none ctermbg=darkblue  ctermfg=black
highlight StatusLineNC cterm=none ctermbg=darkblue ctermfg=black

highlight Pmenu        cterm=none ctermbg=darkgreen ctermfg=black
highlight PmenuSel     cterm=none ctermbg=blue      ctermfg=black

highlight DiffAdd      cterm=none ctermbg=darkgray  ctermfg=darkgreen
highlight DiffChange   cterm=none ctermbg=darkgray  ctermfg=darkgreen
highlight DiffDelete   cterm=none ctermbg=darkgray  ctermfg=darkred  
highlight DiffText     cterm=none ctermbg=darkgray  ctermfg=darkred

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Statusline
"{

set laststatus=2
set lazyredraw

" don't print mode under statusline
set noshowmode

augroup statusline_group
    autocmd!
    autocmd VimEnter * redrawstatus!
    autocmd InsertEnter * redrawstatus!
    autocmd InsertLeave * redrawstatus!
augroup END

function! MyStatusBar()
    redrawstatus!

    let curr_mode=mode()
    if (curr_mode =~# '\v(n|no)')
        exe 'hi StatusLine ctermbg=darkblue'
        let mode_text="  NORMAL "
    elseif (curr_mode =~# '\v(v|V)')
        exe 'hi StatusLine ctermbg=yellow'
        let mode_text="  VISUAL "
    elseif (curr_mode =~# '')
        exe 'hi StatusLine ctermbg=yellow'
        let mode_text="  VBLOCK "
    elseif (curr_mode ==# 'i')
        exe 'hi StatusLine ctermbg=darkgreen'
        let mode_text="  INSERT "
    else
        exe 'hi StatusLine ctermbg=lightyellow'
        let mode_text="  SEARCH "
    endif

    " changes the statusline color based on vim mode
    let sl_mode="%" . mode_text
    " prints truncated global file path
    let sl_path="%#TabLine#\ %{expand('%:~:.')}%m%= "
    " prints file type
    let sl_type="%##\ \ \ %y"

    return sl_mode . sl_path . sl_type
endfunction

set statusline=%!MyStatusBar()

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Windows/Buffers
"{

" keeps window sizes equal after closing
set equalalways

" reloads a buffer when it's modified from outside of vim automatically
set autoread

" don't unload the buffer from memory when hidden
set bufhidden=hide

" always place a vertical split to the right
set splitright
set splitbelow
set previewheight=14

" tab switches windows
nnoremap <Tab> <C-W>w
nnoremap <S-Tab> <C-W><S-w>

" creates new vertical split
" TODO: if there exists loaded buffers, this should load the previous one, not the file browser
nnoremap gv :vsp .<CR>

" close active window (if not last one)
nnoremap q :close<CR>

" switching between buffers
nnoremap gn :bnext<CR>
nnoremap gp :bprev<CR>
nnoremap gb :e .<CR>

" netrw file browser settings
let g:netrw_banner=0
let g:netrw_dirhistmax=25
let g:netrw_liststyle=3

" complicated way of deleting a buffer via command
function! s:Bclose(bang, buffer)
    if empty(a:buffer)
        let btarget = bufnr('%')
    elseif a:buffer =~ '^\d\+$'
        let btarget = bufnr(str2nr(a:buffer))
    else
        let btarget = bufnr(a:buffer)
    endif

    if btarget < 0
        return
    endif

    if empty(a:bang) && getbufvar(btarget, '&modified')
        echohl ErrorMsg
        echomsg 'No write since last change for buffer '.btarget.' (use :Bclose!)'
        echohl NONE
        return
    endif

    " Numbers of windows that view target buffer which we will delete.
    let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
    if len(wnums) > 1
        execute 'close'
        return
    endif

    let wcurrent = winnr()

    for w in wnums
        execute w.'wincmd w'
        let prevbuf = bufnr('#')

        if prevbuf > 0 && buflisted(prevbuf) && prevbuf != btarget
            buffer #
        else
            bprevious
        endif

        if btarget == bufnr('%')
            " Numbers of listed buffers which are not the target to be deleted.
            let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
            " Listed, not target, and not displayed.
            let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
            " Take the first buffer, if any (could be more intelligent).
            let bjump = (bhidden + blisted + [-1])[0]
            if bjump > 0
                execute 'buffer '.bjump
            else
                execute 'enew'.a:bang
            endif
        endif
    endfor

    execute 'bdelete'.a:bang.' '.btarget
    execute wcurrent.'wincmd w'
endfunction

command! -bang -complete=buffer -nargs=? Bclose call <SID>Bclose(<q-bang>, <q-args>)
nnoremap <silent> gd :Bclose<CR>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Clang Format
"{

function! s:config_path() abort
    return findfile('.clang-format', fnameescape(expand('%:p:h')).';')
endfunction

function! s:replace(line1, line2, ...) abort
    if !exists('s:command_available')
        let g:command = get(g:, 'command', 'clang-format')

        if !executable(g:command)
            echoerr "The clang-format executable could not be found"
            return
        endif

        let s:command_available = 1
    endif

    let clang_format_config_path = printf("%s", s:config_path())
    if (clang_format_config_path == '')
        echoerr "Could not find a .clang-format config file in any parent directories."
        return
    endif

    if !(&ft == 'c' || &ft == 'cpp')
        echoerr "clang-format only works for C/C++."
        return
    endif

    " save our position in the file
    let pos_save = a:0 >= 1 ? a:1 : getpos('.')

    " construct the shell command w/ args
    let args = printf(' -lines=%d:%d', a:line1, a:line2)
    let args .= ' -style=file '

    let filename = expand('%')
    if filename !=# ''
        let args .= printf('-assume-filename=%s ', shellescape(escape(filename, " \t")))
    endif

    let clang_format = printf('%s %s --', shellescape(g:command), args)
    let source = join(getline(1, '$'), "\n")

    " actually execute the shell command
    let formatted = system(clang_format, source)

    let format_success = v:shell_error == 0 && formatted !~# '^YAML:\d\+:\d\+: error: unknown key '
    if !(format_success)
        echoerr 'clang-format has failed to format.'
        if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
            echohl ErrorMsg
            for l in split(a:formatted, "\n")[0:1]
                echomsg l
            endfor
            echohl None
        endif

        return
    endif

    let winview = winsaveview()
    let splitted = split(formatted, '\n', 1)

    silent! undojoin
    if line('$') > len(splitted)
        execute len(splitted) .',$delete' '_'
    endif

    call setline(1, splitted)
    call winrestview(winview)
    call setpos('.', pos_save)
endfunction

command! -range=% -nargs=0 ClangFormatConfigPath echo s:config_path()
command! -range=% -nargs=0 ClangFormat call s:replace(<line1>, <line2>)
nnoremap <silent> <C-K> :ClangFormat<CR>

"}
