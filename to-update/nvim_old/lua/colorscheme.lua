local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)

cmd "syntax enable"
cmd "syntax on"

vim.g.sonokai_enable_italic = 1
-- vim.g.sonokai_dim_inactive_windows = 1
cmd.colorscheme('sonokai')
