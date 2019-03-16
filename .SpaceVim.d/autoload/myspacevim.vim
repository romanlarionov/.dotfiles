
function! myspacevim#before() abort

    " this sets up SpaceVim to use my custom ~/.clang-format file on load
    let g:neoformat_c_clangformat = {
        \ 'exe': 'clang-format',
        \ 'args': ['-style=file'],
        \ 'stdin': 1,
        \ }

    " remaps space+f+f (file->format) to clang format
    noremap <Space>ff :Neoformat<cr>

    if s:SYS.isWindows

    endif

endfunction
