syn region foldImports start=/\(^\s*\n^import\)\@<= .\+;/ end=+^\s*$+ transparent fold keepend
setlocal foldmethod=marker
setlocal foldmarker={,}

noremap <leader>r zmi<Esc>

"function! JavaFoldLine() " {{{
"    let foldedlinecount = v:foldend - v:foldstart
"    let line = getline(v:foldstart)
"    return line . ' (' . foldedlinecount . ' lines) ' . '…'
"endfunction " }}}

"au BufEnter $HOME/Git/cassandra/** setlocal makeprg=ant\ -q
"au BufEnter $HOME/Git/cassandra/** setlocal errorformat=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#

"au BufEnter $HOME/Git/java-driver/** setlocal makeprg=mvn\ compile\ -q\ -f\ pom.xml
"au BufEnter $HOME/Git/java-driver/** setlocal errorformat=\[ERROR]\ %f:[%l\\,%v]\ %m
