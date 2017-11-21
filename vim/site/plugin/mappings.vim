" Vim custom mappings
"
" Author: Sylvain Lebresne <lebresne@gmail.com>

" System clipboard interactions
noremap <leader>y "*y
noremap <leader>p :set paste<CR>"*p<CR>:set nopaste<CR>
noremap <leader>P :set paste<CR>"*P<CR>:set nopaste<CR>
vnoremap <leader>y "*ygv

" Vertical split
noremap <leader>v <C-w>v

noremap <silent> <leader>n :noh<cr>:call clearmatches()<cr>

" Fuzzy finder
nnoremap <leader>f :FuzzyOpen .<CR>
nnoremap <leader>g :FuzzyOpen<CR>
nnoremap <leader>b :FuzzyBuffers<CR>

" Open last buffer.
nnoremap <Leader><Leader> <C-^>
nnoremap <Leader>q :quit<CR>
nnoremap <Leader>w :write<CR>
nnoremap <Leader>x :xit<CR>

" Fix (most) syntax highlighting problems in current buffer (mnemonic: coloring).
nnoremap <silent> <LocalLeader>c :syntax sync fromstart<CR>

" }}}

" Fuck you, help key.
noremap  <F1> :set invfullscreen<CR>
inoremap <F1> <ESC>:set invfullscreen<CR>a

" Keep the cursor in place while joining lines
nnoremap J mzJ`z

" Sudo to write
cnoremap w!! w !sudo tee % >/dev/null

" Page up/down
nmap <silent> <Meta-j> <PageDown>
nmap <silent> <Meta-k> <PageUp>

" Tab switching on linux
nmap <silent> th :tabprevious<CR>
nmap <silent> tl :tabnext<CR>

" Open file by gf in tabs
map gf :tabnew <cfile><CR>

" Avoid unintentional switches to Ex mode.
nnoremap Q <nop>
" For each time K has produced timely, useful results, I have pressed it 10,000
" times without meaning to, triggering an annoying delay.
nnoremap K <nop>

nnoremap <CR> <c-]>
nnoremap <BS> <c-t>

" Reset enter and backspace when in the command
autocmd CmdwinEnter * nnoremap <CR> <CR>
autocmd CmdwinEnter * nnoremap <BS> <BS>
autocmd CmdwinLeave * nnoremap <CR> <c-]>
autocmd CmdwinLeave * nnoremap <BS> <c-t>

" Easy buffer navigation {{{
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
" }}}


" List navigation {{{
nnoremap <left>  :cprev<cr>zvzz
nnoremap <right> :cnext<cr>zvzz
nnoremap <up>    :lprev<cr>zvzz
nnoremap <down>  :lnext<cr>zvzz
" }}}

" Command mode mappings {{{
cnoremap <C-a> <Home>
cnoremap <C-e> <End>


" }}}
