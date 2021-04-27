local utils = require('utils')
local opt = utils.opt

opt('w', 'number', true)             -- Show line numbers ...
opt('w', 'relativenumber', true)     -- .. and relative ones
opt('w', 'cursorline', true)         -- Highlight the current line
opt('o', 'showmatch', true)          -- Briefly highlight the matching parenthesis on insertion
opt('o', 'showmode', false)          -- Don't show --INSERT-- below the status line

opt('o', 'hidden', true)             -- Keep buffer around
opt('b', 'modeline', false)          -- Don't care about modelines
opt('w', 'wrap', false)              -- Wrapping is for loosers

opt('o', 'autowrite', true)          -- Save files in many cases.

opt('o', 'splitbelow', true)         -- Split horizontally below
opt('o', 'splitright', true)         -- Split vertically right

opt('o', 'scrolloff', 4)             -- Keep that many line when scrolling

opt('o', 'clipboard', 'unnamedplus') -- Copy paste between vim and everything else
opt('o', 'mouse', 'a')               -- Enable mouse all the time

opt('b', 'swapfile', false)          -- That's just annoying

opt('w', 'list', true)               -- Show the characters in listchars
opt('w', 'listchars', 'tab:▸ ,trail:·,extends:❯,precedes:❮')

opt('o', 'lazyredraw', true)         -- Do not redraw during macros, faster

opt('b', 'undofile', true)           -- Saves undos in a file

opt('w', 'signcolumn', 'yes')        -- Always display to avoid "jumps"

vim.o.shortmess = vim.o.shortmess .. 'c'  -- Avoid completion messages


-- Indents {{{
local indent = 2

opt('b', 'shiftwidth', indent)   -- Nb of space for an indent
opt('b', 'tabstop', indent)      -- Nb of space for a tab
opt('b', 'expandtab', true)      -- Spaces instead of tabs
opt('b', 'smartindent', true)    -- Auto-indent after {, ...
-- }}}
