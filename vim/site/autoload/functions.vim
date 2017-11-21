let s:middot='·'
let s:raquo='»'
let s:small_l='ℓ'

" Override default `foldtext()`, which produces something like:
"
"   +---  2 lines: source $HOME/.vim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim--------------------------------
"
" Instead returning:
"
"   » [2ℓ]: source $HOME/.vim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim
"
function! functions#foldtext() abort
  let l:lines='[' . (v:foldend - v:foldstart + 1) . s:small_l . ']'
  let l:first=substitute(getline(v:foldstart), '\v *', '', '')
  let l:dashes=substitute(v:folddashes, '-', s:middot, 'g')
  return s:raquo . ' ' . l:lines . ': ' . l:first
  "return s:raquo . '  ' . l:lines . l:dashes . ': ' . l:first
endfunction

function! functions#plaintext() abort
    setlocal spell
    setlocal textwidth=78
endfunction


function! functions#fuzzybuffers() abort
  " Get open buffers.
  let bufs = filter(range(1, bufnr('$')),
    \ 'buflisted(v:val) && bufnr("%") != v:val && bufnr("#") != v:val && empty(getbufvar(v:val, "&buftype")) && !empty(bufname(v:val))')
  let bufs = map(bufs, 'expand(bufname(v:val))')

  " Add the '#' buffer at the head of the list.
  if bufnr('#') > 0 && bufnr('%') != bufnr('#')
    let altbufname = expand(bufname('#'))
    if !empty(altbufname) && buflisted(altbufname) && empty(getbufvar(altbufname, "&buftype"))
      call insert(bufs, altbufname)
    end
  endif

  let opts = { 'lines': g:fuzzy_winheight, 'statusfmt': 'Buffers %s (%d files)', 'root': '.' }
  function! opts.handler(bufs)
    return { 'name': join(a:result) }
  endfunction

  return s:fuzzy(result, opts)
endfunction

