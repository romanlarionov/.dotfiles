
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Misc
set nocompatible
set number
set noswapfile
set mousehide

" allow backspace to go to previous line
set backspace=2

if exists(":mouse")
    set mouse=i
endif

if exists(":belloff")
    set belloff=all
endif

if exists(":termsize")
    set termsize=10x999
endif

" use vertical split for help
autocmd FileType help wincmd L

" understand glsl files
autocmd BufNewFile,BufRead *.vp,*.fp,*.gp,*.vs,*.fs,*.gs,*.tes,*.cs,*.vert,*.frag,*.geom,*.tess,*.shd,*.gls,*.glsl 
 \ set filetype=glsl

" todo: CTRL-Backspace (and CTRL-Delete) should delete a tabs worth of spaces

let s:on_windows = has('win32') || has('win64')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Search
set incsearch
set fileignorecase
set ignorecase

" opens autocompete popup with the tab/shift-tab keys in smart way
inoremap <expr> <TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-N>" : "<TAB>"
inoremap <expr> <S-TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-P>" : "<TAB>"

" which buffers to search for autocomplete via TAB
set complete=w,.,b

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set smartindent

" tab in visual mode indents
vnoremap <TAB> >
vnoremap <S-TAB> <

nnoremap < <<
nnoremap > >>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Formatting
" todo: checkout what else I can do with :h fo-table
set formatoptions+=ro

" print matching curly brace
inoremap {<CR> {<CR>}<Esc>ko

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Folds
set foldmethod=manual

" fold matching brace
nnoremap <C-M> zf%<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Colors
syntax enable
color torte

set cursorline
highlight clear CursorLine
highlight Cursor cterm=none ctermbg=lightgray
highlight CursorLine cterm=none ctermbg=darkgray
highlight comment cterm=none ctermfg=darkgreen

set hlsearch
highlight IncSearch cterm=none ctermbg=yellow
highlight Search cterm=none ctermbg=yellow
highlight Visual cterm=none ctermfg=yellow
highlight Folded cterm=bold ctermfg=yellow

highlight LineNr cterm=none ctermfg=blue

highlight StatusLine cterm=none ctermfg=black ctermbg=darkblue
highlight StatusLineNC cterm=none ctermfg=black ctermbg=darkblue

highlight Pmenu cterm=none ctermbg=darkblue ctermfg=black
highlight PmenuSel cterm=none ctermbg=blue ctermfg=black

" todo: need to fix vimdiff colors. current colors are unusable

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Statusline
set laststatus=2

" changes the statusbar git branch color depending on if there are any unstaged changes detected
let g:has_unstanged_git_changes = (strlen(system("git status 2>/dev/null | grep 'Changes not staged for commit'")) > 0) ? 1 : 0
function! ChangeStatuslineGitColor()
    if (g:has_unstanged_git_changes)
        exe 'hi! StatusLineNC ctermbg=yellow'
    else
        exe 'hi! StatusLineNC ctermbg=green'
    endif
endfunction
autocmd VimEnter * :call ChangeStatuslineGitColor()

" changes statusline color depending on vim mode
function! ChangeStatuslineColor()
    let curr_mode=mode()
    if (curr_mode =~# '\v(n|no)')
        exe 'hi! StatusLine ctermbg=darkblue'
        return '  NORMAL '
    elseif (curr_mode =~# '\v(v|V)')
        exe 'hi! StatusLine ctermbg=yellow'
        return '  VISUAL '
    elseif (curr_mode =~# '\v(v|V)')
        exe 'hi! StatusLine ctermbg=yellow'
        return '  VISUAL BLOCK '
    elseif (curr_mode ==# 'i')
        exe 'hi! StatusLine ctermbg=darkgreen'
        return '  INSERT '
    else
        exe 'hi! StatusLine ctermbg=lightred'
        return ''
    endif
endfunction

" todo: this should be recalculated per buffer
let g:branchname = system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")

set statusline=
" changes the statusline color based on vim mode
set statusline+=%#StatusLine#%{ChangeStatuslineColor()}

" prints git branch name
if (strlen(g:branchname) > 0)
    set statusline+=%#StatusLineNC#%{'\ \ '.g:branchname.'\ '}
endif

" prints truncated global file path
set statusline+=%#CursorLine#\ %.50F%m%=
" prints file type
set statusline+=%#StatusLine#\ \ \ %y

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Windows/Buffers
" keeps window sizes equal after closing
set equalalways

" tab switches windows
nnoremap <Tab> <C-W>w

" creates new vertical split (todo: can I make it so it doesn't first draw the copied buffer?)
nnoremap gv :vsp<CR><C-W>w:e .<CR>

" close active window (if not last one)
nnoremap q :close<CR>

" switching between buffers
nnoremap gn :bnext<CR>
nnoremap gp :bprev<CR>
nnoremap gb :e .<CR>

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

    " todo: this shouldn't print out anything
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Clang Format
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
