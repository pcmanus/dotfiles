scriptencoding utf-8

" General Settings {{{

set encoding=utf-8
set modelines=0     " I don't use modelines

set tabstop=4       " Nb of space for a tab
set shiftwidth=4    " Nb of space for an indent
set expandtab       " Use spaces instead of tabs
set autoindent      " On newline, use the indentation of the preceding line
set smarttab        " Make tabs being indents at the beginning of the line
set smartindent     " Smart indenting, indent after { etc...
set backspace=2     " Allow backspace over autoindent, eol and start of insert

set wak=no          " Don't use Alt to access menu
set showmatch       " Briefly highlight the matching parenthesis on insertion
set matchpairs+=<:> " Make < and > match as well
set nowrap          " Long lines don't get wrapped
set autowrite       " Save the file in a number of occasion
set autoread        " Automatically read changed files
set scrolloff=2     " Keep two line when scrolling
set cursorline      " Highlight current line
set novisualbell    " Don't flash the screen
set laststatus=2    " Always show the status line

set showcmd         " Show current cmd and size of visual selection
set ruler           " Show cursor position
set history=100     " Remember that much of cmd history
set noswapfile      " Please, no swap file
set tabpagemax=30   " Number of tabs allowed at the same time
set formatoptions=tcqrnl

set virtualedit+=block " Allow to move selection where there is no characters

set list            " Show non-printing characters by default
set listchars=tab:▸\ ,trail:·,extends:❯,precedes:❮
set fillchars=diff:⣿,vert:│

set splitbelow      " when splitting horizontally, put new windows below current
set splitright      " when splitting vertically, put new windows right of current

set lazyredraw     " Do not redraw during macros, faster
set colorcolumn=+1 " Color column after textwidth

" Time out on key codes but not mappings (makes terminal Vim work sanely).
set notimeout
set ttimeout
set ttimeoutlen=10

set synmaxcol=200 " don't bother syntax highlighting long lines

au FocusLost * :silent! wall " Save when losing focus
au VimResized * :wincmd =    " Resize splits when the window is resized

" Returns to the same line when reopening a file
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Open quickfix automatically if need be
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

set foldtext=functions#foldtext()

" }}}

" Searching {{{

set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch

" }}}

" Wildmenu (command) completion {{{

set wildmenu
set wildmode=list:longest
set wildignore+=*.o,*.obj,*.class,*.pyc
set wildignore+=.hg,.git,.svn
set wildignore+=*.aux,*.out,*.toc
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg

" }}}

" Plugins {{{
" }}}
