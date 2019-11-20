
"""""""""""""""""""""""""""""""""""""""""""""""""""" Misc
set nocompatible
set number
set belloff=all
set noswapfile
set mouse=i
set mousehide
set termsize=10x999

" automatically center cursorline to center of screen
autocmd WinEnter * :execute "normal \<S-M>"
autocmd BufEnter * :execute "normal \<S-M>"
autocmd TabEnter * :execute "normal \<S-M>"

"""""""""""""""""""""""""""""""""""""""""""""""""""" Search
set incsearch
set fileignorecase
set ignorecase

" Opens autocompete popup with the tab/shift-tab keys in smart way
inoremap <expr> <TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-N>" : "<TAB>"
inoremap <expr> <S-TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-P>" : "<TAB>"

" which buffers to search for autocomplete via TAB
set complete=w,.,b

"""""""""""""""""""""""""""""""""""""""""""""""""""" Indentation
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set smartindent

" print matching curly brace
inoremap {<CR> {<CR>}<Esc>ko

nnoremap < <<
nnoremap > >>

"""""""""""""""""""""""""""""""""""""""""""""""""""" Folds
set foldmethod=manual

" fold matching brace
nnoremap <C-M> zf%<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""" Colors
color torte

set cursorline
highlight clear CursorLine
highlight Cursor ctermbg=30
highlight CursorLine ctermbg=18
highlight comment ctermfg=darkgreen

set hlsearch
highlight IncSearch ctermbg=red
highlight Search ctermbg=yellow
highlight Visual ctermfg=yellow
highlight Folded ctermfg=yellow

highlight LineNr ctermfg=blue

highlight StatusLine ctermbg=black
highlight StatusLine ctermfg=green
highlight StatusLineNC ctermfg=gray

highlight Pmenu ctermbg=red
highlight Pmenu ctermfg=black
highlight PmenuSel ctermbg=green
highlight PmenuSel ctermfg=black

" todo: need to fix vimdiff colors. current colors are unusable
highlight ErrorMsg ctermfg=red

"""""""""""""""""""""""""""""""""""""""""""""""""""" Windows/Buffers
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

"""""""""""""""""""""""""""""""""""""""""""""""""""" Clang Format

" all taken and adapated from here: https://github.com/rhysd/vim-clang-format
" todo: make sure clang format is located on the system already, else print not found
    " if we don't find the .clang-format file
    "if ! (findfile('.clang-format', fnameescape(expand('%:p:h')).';') != '')

let s:on_windows = has('win32') || has('win64')

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

function! s:getg(name, default) abort
    " backward compatibility
    if exists('g:operator_'.substitute(a:name, '#', '_', ''))
        echoerr 'g:operator_'.substitute(a:name, '#', '_', '').' is deprecated. Please use g:'.a:name
        return g:operator_{substitute(a:name, '#', '_', '')}
    else
        return get(g:, a:name, a:default)
    endif
endfunction

let g:command = s:getg('command', 'clang-format')

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
            invalidity = 1
        endif
        let s:command_available = 1
    else
        invalidity = 0
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
        " todo: shouldn't show error message, only flash the statusbar red
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

