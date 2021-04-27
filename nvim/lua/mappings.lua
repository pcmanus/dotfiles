vim.g.mapleader = ' '

local utils = require('utils')
local cmd = vim.cmd
local imap = utils.imap
local nmap = utils.nmap
local cmap = utils.cmap

-- Better escaping
imap('jj', '<Esc>')

-- Write, Quit and Exit shortcuts
nmap('<Leader>w', ':w!<CR>')
nmap('<Leader>q', ':quit<CR>')
nmap('<Leader>x', ':xit<CR>')

-- Open last buffer
nmap('<Leader><Leader>', '<C-^>')

-- Copy whole buffer to system clipboard
nmap('<Leader>c', 'gg"+yG')

-- Keep the cursor in place while joining lines
nmap('J', 'mzJ`z')

-- Enter and Backspace {{{

-- Enter to follow link in normal mode
-- (gets remapped locally when we have lsp to goto definition)
nmap('<CR>', '<c-]>')
-- Backspace to go back in normal mode
nmap('<BS>', '<c-t>')

-- Reset enter and backspace when in the command
cmd 'au CmdwinEnter * nnoremap <CR> <CR>'
cmd 'au CmdwinEnter * nnoremap <BS> <BS>'
cmd 'au CmdwinLeave * nnoremap <CR> <c-]>'
cmd 'au CmdwinLeave * nnoremap <BS> <c-t>'

-- }}}

-- Window controls {{{

-- Making splits
nmap('<leader>v', ':vsplit<CR>')
nmap('<leader>h', ':split<CR>')

-- Navigation
nmap('<C-h>', '<C-w>h')
nmap('<C-j>', '<C-w>j')
nmap('<C-k>', '<C-w>k')
nmap('<C-l>', '<C-w>l')

-- }}}
