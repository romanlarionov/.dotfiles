
function! myspacevim#before() abort

    let g:neoformat_c_clangformat = {
        \ 'exe': 'clang-format',
        \ 'args': ['-style=file'],
        \ 'stdin': 1,
        \ }

    let g:neoformat_only_msg_on_error = 1
    let g:vimfiler_ignore_pattern = ''
    let g:indentLine_enabled = 0

    "if s:SYS.isWindows
    "endif
endfunction

function! myspacevim#after() abort

    set visualbell
    set t_vb=
    colorscheme default

    " 'gd' acts as go-to-definition using gtags 
    nnoremap gd :GtagsCursor<cr>

    " update gtags db (for current file) on save
    autocmd BufWritePre,FileType *.h,*.cpp :GtagsGenerate

endfunction

