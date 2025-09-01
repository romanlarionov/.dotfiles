""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Misc
"{

let skip_defaults_vim = 1

set number
set novisualbell

" save on focus lost
autocmd FocusLost * nested silent! wall

" copies all yank commands to clipboard
set clipboard=unnamed

" don't override clipboard contents after pasting over highlighted text
xnoremap p P

if exists(":termsize")
    set termsize=10x999
endif

if g:vsvim == 0

    set nocompatible
    set nospell
    set noswapfile
    set belloff=all

    " <Ctrl-Backspace> deletes the previous word in insert mode
    inoremap <C-BS> <C-w>

    " TODO: think this is triggering for visual studio still
    " keep cursor column the same after yanking then pasting a line above or below
    function! s:PasteLinewise(cmd) abort
        " Only do this for linewise yanks
        if getregtype('"') !=# 'V'
          " If not linewise, just run normal p/P
          execute 'normal!' a:cmd
          return
        endif
        
        let l:col = col('.') " Save current column
        " Paste line
        execute 'normal!' a:cmd
        call cursor(line('.'), l:col) " Restore column
    endfunction

    " Remap p and P in normal mode for linewise yanks
    nnoremap <silent> p :call <SID>PasteLinewise('p')<CR>
    nnoremap <silent> P :call <SID>PasteLinewise('P')<CR>

    " set the character for vertical separating column between windows
    set fillchars+=vert:│

	filetype plugin on " plugins are enabled

    augroup misc_group
        autocmd!

        " use vertical split for help
        autocmd FileType help wincmd L

        if g:vsvim == 0
            " treat shader files like C++
            autocmd BufNewFile,BufRead *.vs,*.fs,*.ps,*.comp,*.gs,*.vert,*.frag,*.pix,
                \*.geom,*.tess,*.glsl,*.hlsl,*.hlsli,*.usf,*.ush set filetype=cpp

            autocmd VimResized * if &equalalways | wincmd = | endif
        endif

        " redraw with the cursorline in the middle of the screen
        autocmd BufEnter,WinEnter,WinNew,VimResized *,*.* norm zz
    augroup END
endif

let mapleader = " "

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Building
"{

if g:vsvim == 0

    " Detect if a local build script is present and execute it
    function! BuildProject(line1, ...) abort
        let g:build_script = ".build.sh"
        if !exists('s:build_script_available')
            if g:build_script == "" || !filereadable(g:build_script)
                echoerr 'Could not find ./.build.sh'
                return
            endif
            let s:build_script_available = 1
        endif

        let build_cmd = './' . g:build_script

        " Provide arguments if specified
        if a:line1 != "--build"
            let args = printf(' %s', a:line1)
            let build_cmd .= args
        endif

        let l:output = systemlist(build_cmd)
        let l:bufname = 'Build Output'

        " Look for an open window displaying our scratch buffer
        for l:win in range(1, winnr('$'))
            if bufname(winbufnr(l:win)) ==# l:bufname
                " Found it: jump there
                execute l:win . 'wincmd w'
                " Replace its contents
                call setline(1, l:output)
                if line('$') > len(l:output)
                    execute (len(l:output)+1) . ',$delete'
                endif
                return
            endif
        endfor

        " Open a scratch buffer to display the contents of the command's stdout
        belowright split
        resize 15
        enew
        file Build Output
        setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
        let b:build_scratch_buf = 1
        call setline(1, l:output)
    endfunction

    command! -range=% -nargs=1 BuildProject call BuildProject(<f-args>)
    nnoremap <silent> <C-B> :BuildProject --build<CR>
    nnoremap <silent> <F5> :BuildProject --start_debugging<CR>
    nnoremap <silent> <S-F5> :BuildProject --stop_debugging<CR>
endif

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Sessions
"{

if g:vsvim == 0

    let g:session_file = ""
    let g:session_dir = ""
    function! SaveSession()
        if g:session_dir != "" && g:session_file != ""
            if !isdirectory(shellescape(g:session_dir))
                execute 'silent !mkdir -p ' shellescape(g:session_dir)
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

    " disable writing to ~/.viminfo on exit in favor of sessions
    set viminfo=""
endif

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Search
"{

set incsearch
set ignorecase

if g:vsvim == 0

    set fileignorecase

    " fuzzy finding
    set wildmenu
    set wildignorecase
    set wildmode=full,list:full
    set wildignore+=*.o,*.jpg,*.obj,*.mtl,*.png,*.docx,*.exe
    set wildignore+=*/node_modules/*,*/build/*,*/.git/*,*/deps/*,*Debug/*,*Release/*

    " add ~/.tags directory when searching for a tag
    set tags+=~/.tags/*

    for tagfile in split(globpath('$HOME/.tags/', '*'), '\n')
        let &tags .=',' . tagfile
    endfor

    " treat tag paths as global
    set notagrelative

    " Show a tag definition inside a popup window
    function! PopupTag(tag) abort
        " If no tag given, use the word under the cursor
        let l:tagname = a:tag ==# '' ? expand('<cword>') : a:tag
        
        " Get the tag location using taglist()
        let l:matches = taglist(l:tagname)
        if empty(l:matches)
            echo "Tag not found: " . l:tagname
            return
        endif
        
        " We'll just take the first match (you could extend to menu)
        let l:m = l:matches[0]
        
        " Read some lines from the file around the match
        let l:file = l:m['filename']
        
        " Figure out the line number
        let l:lnum = 0
        if l:m['cmd'] =~# '^\d\+$'
            " Direct line number
            let l:lnum = str2nr(l:m['cmd'])
        elseif l:m['cmd'] =~# '^/.\+/$'
            " It's a search pattern: strip slashes
            let l:pat = l:m['cmd'][1:-2]
            let l:filelines = readfile(l:file)
            for lnum in range(1, len(l:filelines))
                if l:filelines[lnum - 1] =~ l:pat
                    let l:lnum = lnum
                    break
                endif
            endfor
        endif
        
        if l:lnum == 0
            echo "Can't locate tag position for: " . l:tagname
            return
        endif
        
        " Get num_lines+2 lines of context
        let l:num_lines = 8
        let l:start = max([1, l:lnum - 1])
        let l:end   = l:lnum + l:num_lines
        let l:lines = readfile(l:file, '', l:end)[l:start - 1 : l:end - 1]
        
        let l:opts = {
            \ 'pos': 'topright',
            \ 'line': 'cursor+1',
            \ 'moved': 'word',
            \ 'col': 'cursor',
            \ 'minwidth': 400,
            \ 'border': [0,0,0,0],
            \ 'scrollbar': 1,
            \ }
        
        call popup_create(l:lines, l:opts)
    endfunction

    " F12 brings up a popup menu with the tag definition as a preview
    command! -nargs=? PopupTag call PopupTag(<q-args>)
    nnoremap <silent> <F12> :call PopupTag('')<CR>

    " Ctrl-F starts fuzzy finding files
    nnoremap <C-F> :find *

    " opens autocompete popup with the tab/shift-tab keys in smart way
    inoremap <expr> <TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-N>" : "<TAB>"
    inoremap <expr> <S-TAB> matchstr(getline('.'), '\%' . (col('.')-1) . 'c.') =~ '\S' ? "<C-P>" : "<TAB>"

    " which buffers to search for autocomplete via TAB
    set complete=w,.,b,u,t

endif

" '*' key won't match whole words
nnoremap <silent> * g*

" sets path vim searches with 'find' to the current dir + recursively downwards
set path=.,,**

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Movement
"{

if g:vsvim == 0

    set nomousefocus
    set mousehide

    if has("mouse")
        set mouse=a
    endif

endif

set scrolloff=5

" keep cursor location the same when using the scroll wheel
nnoremap <ScrollWheelUp> 3<C-U>:set scroll=0<CR>
nnoremap <ScrollWheelDown> 3<C-D>:set scroll=0<CR>

nnoremap <S-K> <C-U>
nnoremap <S-J> <C-D>
nnoremap <S-L> $
nnoremap <S-H> ^

xnoremap <S-K> <C-U>
xnoremap <S-J> <C-D>
xnoremap <S-L> $
xnoremap <S-H> ^

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Indentation
"{

set autoindent
"set cindent
set expandtab
set tabstop=4
set shiftwidth=4

if g:vsvim == 0
    set smarttab
    set smartindent
    set shiftround
endif

" allow backspace to go to previous line
set backspace=indent,eol,start

nnoremap < <<
nnoremap > >>

" tab indents whole line in visual mode
xnoremap <TAB> >gv
xnoremap <S-TAB> <gv

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Formatting
"{

if g:vsvim == 0
    set formatoptions+=ro
    set foldopen=hor,search,undo

    " opens curly braces with cursor in indented position between
    inoremap <expr> <cr> getline(".")[col(".")-2:col(".")-1]=="{}" ? "<cr><bs><esc>O" : "<cr>"

    " fold matching brace
    nnoremap <C-M> zf%<CR>

    " In normal mode, pressing 'l' will open a fold if at end of a folded line
    nnoremap <expr> l foldclosed('.') == line('.') ? 'zo' : 'l'
endif

" print matching braces
inoremap { {}<Esc>i
"inoremap ( ()<Esc>i
"inoremap [ []<Esc>i
"inoremap " ""<Esc>i
"inoremap ' ''<Esc>i

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Colors
"{

" mintty identifies itself as xterm-compatible
if &term =~ 'xterm-256color'
    if &t_Co =~ 8
        " Use at least 256 colors
        set t_Co = 256
    endif
endif

set cursorline
set hlsearch

if g:vsvim == 0
    syntax enable
    syntax sync minlines=16 maxlines=64

    set synmaxcol=256

    " highlight matching braces
    set showmatch

    highlight Comment      cterm=none                   ctermfg=darkgreen
    highlight ErrorMsg     cterm=none ctermbg=darkred   ctermfg=black

    highlight IncSearch    cterm=bold ctermbg=darkgray  ctermfg=yellow
    highlight Search       cterm=none ctermbg=darkgray  ctermfg=yellow
    highlight Visual       cterm=none ctermbg=darkgray
    highlight Folded       cterm=bold                   ctermfg=yellow

    highlight LineNr       cterm=none                   ctermfg=blue
    highlight CursorLine   cterm=none ctermbg=black
    highlight CursorLineNr cterm=bold                   ctermfg=yellow
    highlight TabLine      cterm=none ctermbg=darkgray  ctermfg=white
    highlight VertSplit    cterm=none ctermbg=black     ctermfg=darkgray

    highlight StatusLine   cterm=none ctermbg=darkblue  ctermfg=black
    highlight StatusLineNC cterm=none ctermbg=darkblue  ctermfg=black

    highlight Pmenu        cterm=none ctermbg=darkgreen ctermfg=black
    highlight PmenuSel     cterm=none ctermbg=blue      ctermfg=black

    highlight DiffAdd      cterm=none ctermbg=darkgray  ctermfg=darkgreen
    highlight DiffChange   cterm=none ctermbg=darkgray  ctermfg=darkgreen
    highlight DiffDelete   cterm=none ctermbg=darkgray  ctermfg=darkred  
    highlight DiffText     cterm=none ctermbg=darkgray  ctermfg=darkred

    " insert mode sets line number highlight green
    autocmd InsertEnter    * highlight CursorLineNr ctermbg=green ctermfg=black
    autocmd InsertLeavePre * highlight CursorLineNr ctermbg=black ctermfg=yellow

endif

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Statusline
"{

set laststatus=2

if g:vsvim == 0
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

endif

"}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Windows/Buffers
"{

if g:vsvim == 0

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

endif

" keep cursor position when switching between open buffers
set nostartofline

" tab switches windows
nnoremap <Tab> <C-W>w
nnoremap <S-Tab> <C-W><S-w>

" split window
nnoremap <leader>v :vsp .<CR>
nnoremap <leader>h :sp .<CR>

" close active window (if not last one)
nnoremap <leader>q :close<CR>

if g:vsvim == 0

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

    function! ShowBufferPopup() abort
        " Collect listed buffers
        let s:buffers = []
        for buf in getbufinfo({'buflisted':1})
            let name = buf.name !=# '' ? fnamemodify(buf.name, ':.') : '[No Name]'
            "let name = buf.name !=# '' ? buf.name : '[No Name]'
            call add(s:buffers, printf('%3d %s', buf.bufnr, name))
        endfor
        
        if empty(s:buffers)
            let s:buffers = ['No open buffers']
        endif
        
        " Define callback for selecting a buffer
        function! s:BufSelect(id, result) abort
            if a:result > 0 && a:result <= len(s:buffers)
                let line = s:buffers[a:result - 1]
                let bufnr = str2nr(split(line)[0])
                if bufnr > 0
                    execute 'buffer' bufnr
                endif
            endif
        endfunction
        
        let opts = {
            \ 'title': 'Loaded Buffers',
            \ 'scrollbar': 1,
            \ 'pos': 'center',
            \ 'padding': [0,3,0,0],
            \ 'border': [],
            \ 'minwidth': 30,
            \ 'time': 10000,
            \ 'maxheight': 10,
            \ 'filter': 'popup_filter_menu',
            \ 'callback': function('s:BufSelect'),
            \ }
        
        call popup_menu(s:buffers, opts)
    endfunction

    " show a popup menu with selectable buffers to jump to
    nnoremap <silent> <leader>l :call ShowBufferPopup()<CR>
endif

" switching between buffers
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>

" switch to last viewed buffer
nnoremap <C-TAB> <C-^>

" swap buffers between opened windows
nnoremap <leader>s <C-w><C-r>

" opening/closing buffers
nnoremap <leader>b :e .<CR>
nnoremap <silent> <leader>d :Bclose<CR>

"}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Clang Format
"{

if g:vsvim == 0

    " TODO: there seems to be a bug after I apply clang format for the formatting that
    " vim understands.
    " i.e. if I have folds (which understand the curly braces), vim has an understanding
    " of that which isn't updated after I replace the text with the clang format.
    " I need to force a restart of vim to reset.

    function! s:config_path() abort
        return findfile('.clang-format', fnameescape(expand('%:p:h')).';')
    endfunction

    function! s:replace(line1, line2, ...) abort

        if !(&ft == 'c' || &ft == 'cpp')
            echoerr "clang-format only works for C/C++."
            return
        endif

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
            echoerr "Couldn't find a .clang-format config file in any parent directories."
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
endif
"}
