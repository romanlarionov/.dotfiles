"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Misc
set nocompatible
set number
set noswapfile
set mousehide

if exists(":mouse")
    set mouse=i
endif

if exists(":belloff")
    set belloff=all
endif

if exists(":termsize")
    set termsize=10x999
endif

" set the character for vertical separating column between windows
set fillchars+=vert:│

augroup misc_group
    autocmd!

    " use vertical split for help
    autocmd FileType help wincmd L

    " understand glsl files
    autocmd BufNewFile,BufRead *.vp,*.fp,*.gp,*.vs,*.fs,*.gs,*.tes,*.cs,*.vert,*.frag,*.geom,*.tess,*.shd,*.gls,*.glsl 
     \ set filetype=glsl

    " redraw with the cursorline in the middle of the screen
    autocmd BufWinEnter * norm zz

    " automatically makes split windows equal size after resizing app or font
    autocmd VimResized * if &equalalways | wincmd = | endif

augroup END

let s:on_windows = has('win32') || has('win64')

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Sessions
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

" remember the list of open buffers the last time vim was open (saved in ~/.viminfo)
set viminfo='50,%10,f0

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Search
set incsearch
set fileignorecase
set ignorecase

" fuzzy finding
set wildmenu
set wildignorecase
set wildmode=full,list:full
set wildignore+=*.o,*.jpg,*.obj,*.mtl,*.png,*.docx,*.exe
set wildignore+=*/node_modules/*,*/build/*,*/.git/*,*/deps/*

" Ctrl-F starts fuzzy finding files
nnoremap <C-F> :find *

" sets path vim searches with 'find' to the current dir + recursively downwards
set path=.,,**

" opens autocompete popup with the tab/shift-tab keys in smart way
inoremap <expr> <TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-N>" : "<TAB>"
inoremap <expr> <S-TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-P>" : "<TAB>"

" which buffers to search for autocomplete via TAB
set complete=w,.,b,u

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Movement

nnoremap <S-K> <C-U>
nnoremap <S-J> <C-D>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set smartindent

" allow backspace to go to previous line
set backspace=indent,eol,start

" tab in visual mode indents
vnoremap <TAB> >
vnoremap <S-TAB> <

nnoremap < <<
nnoremap > >>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Formatting
set formatoptions+=ro

" print matching braces
inoremap { {<CR>}<Esc>ko<TAB>
inoremap ( ()<Esc>i

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Folds
set foldopen=hor,search,undo

" fold matching brace
nnoremap <C-M> zf%<CR>

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Colors
syntax enable
syntax sync minlines=64

set synmaxcol=256
set hlsearch

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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Statusline
set laststatus=2
set lazyredraw

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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Windows/Buffers
" keeps window sizes equal after closing
set equalalways

" always place a vertical split to the right
set splitright

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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" { Clang Format
" all taken and adapated from here: https://github.com/rhysd/vim-clang-format

" todo: should be command to echo the chosen .clang-format file's path
" todo: make sure clang format is located on the system already, else print not found
" todo: surround this entire block by a check if the shell command 'clang-format'
"       exists plus make sure that a .clang-format file can be found

" if we don't find the .clang-format file
"if ! (findfile('.clang-format', fnameescape(expand('%:p:h')).';') != '')

function! s:error_message(result) abort
    echoerr 'clang-format has failed to format.'
    if a:result =~# '^YAML:\d\+:\d\+: error: unknown key '
        echohl ErrorMsg
        for l in split(a:result, "\n")[0:1]
            echomsg l
        endfor
        echohl None
    endif
endfunction

function! s:shellescape(str) abort
    if s:on_windows && (&shell =~? 'cmd\.exe')
        " shellescape() surrounds input with single quote when 'shellslash' is on. But cmd.exe
        " requires double quotes. Temporarily set it to 0.
        let shellslash = &shellslash
        set noshellslash
        try
            return shellescape(a:str)
        finally
            let &shellslash = shellslash
        endtry
    endif
    return shellescape(a:str)
endfunction

let g:command = get(g:, 'command', 'clang-format')

function! s:format(line1, line2) abort
    let args = printf(' -lines=%d:%d', a:line1, a:line2)

    " todo: this should error if .clang-format file not found
    let args .= ' -style=file '
    let filename = expand('%')
    if filename !=# ''
        let args .= printf('-assume-filename=%s ', s:shellescape(escape(filename, " \t")))
    endif
    let clang_format = printf('%s %s --', s:shellescape(g:command), args)
    let source = join(getline(1, '$'), "\n")

    return system(clang_format, source)
endfunction

function! s:replace(line1, line2, ...) abort
    " verify command

    let invalidity = 0
    if !exists('s:command_available')
        if !executable(g:command)
            let invalidity = 1
        endif
        let s:command_available = 1
    else
        let invalidity = 0
    endif

    if invalidity == 1
        echoerr "clang-format is not found. check g:command."
    elseif invalidity == 2
        echoerr 'clang-format 3.3 or earlier is not supported for the lack of aruguments'
    endif

    let pos_save = a:0 >= 1 ? a:1 : getpos('.')
    let formatted = s:format(a:line1, a:line2)
    let format_success = v:shell_error == 0 && formatted !~# '^YAML:\d\+:\d\+: error: unknown key '

    if ! (format_success)
        call s:error_message(formatted)
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

command! -range=% -nargs=0 ClangFormat call s:replace(<line1>, <line2>)
nnoremap <silent> <C-K> :ClangFormat<CR>

"}
