
function! myspacevim#before() abort

    " this sets up SpaceVim to use my custom ~/.clang-format file on load
    let g:neoformat_c_clangformat = {
        \ 'exe': 'clang-format',
        \ 'args': ['-style=file'],
        \ 'stdin': 1,
        \ }

    nnoremap <Space>mgg :GtagsCursor<cr>
    let g:indentLine_enabled = 0

    "if s:SYS.isWindows
    "endif
endfunction

function! myspacevim#after() abort
    colorscheme default
endfunction

