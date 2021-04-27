local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)

cmd "syntax enable"
cmd "syntax on"

vim.g.sonokai_enable_italic = 1
cmd 'colorscheme sonokai'
