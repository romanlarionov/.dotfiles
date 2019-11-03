
"""""""""""""""""""""""""""""""""""""""""""""""""""" Misc
set nocompatible
set number
set belloff=all
set noswapfile
set mouse=i
set mousehide
set termsize=10x999

" performs exclusive yank when in visual mode (leave out highlighted column)
set selection=exclusive

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
inoremap {<CR> {<CR>}<Esc>ko<TAB>

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
highlight StatusLineNC ctermfg=red

highlight Pmenu ctermbg=red
highlight Pmenu ctermfg=black
highlight PmenuSel ctermbg=green
highlight PmenuSel ctermfg=black

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

