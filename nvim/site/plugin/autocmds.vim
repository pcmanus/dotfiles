if has('autocmd')
    " Disable paste mode on leaving insert mode.
    autocmd InsertLeave * set nopaste

    autocmd BufWritePost */spell/*.add silent! :mkspell! %
endif
