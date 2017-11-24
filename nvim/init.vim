" Vim config file
"
" Author: Sylvain Lebresne <lebresne@gmail.com>

" Plugins
call plug#begin('~/.local/share/nvim/plugged')
" Using a locally modified version: should push upstream and re-enable
"Plug 'cloudhead/neovim-fuzzy'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'sheerun/vim-polyglot'
Plug 'chriskempson/base16-vim'
Plug 'ervandew/supertab'
Plug 'ludovicchabant/vim-gutentags'
call plug#end()

" Leader
let mapleader = "\<Space>"
let maplocalleader = "\\"

" Color scheme

set background=dark
let base16colorspace=256 " For 256 colors terminal
colorscheme base16-tomorrow-night

