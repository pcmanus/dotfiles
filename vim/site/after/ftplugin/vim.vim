setlocal iskeyword-=#
setlocal foldmethod=marker
setlocal textwidth=78
au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
