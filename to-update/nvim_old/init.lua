--
-- Neovim init file.
--

require('plugins')
require('settings')
require('colorscheme')
require('mappings')
require('autocommands')

-- Plugins setup
require('colorizer').setup()
require('nvim-web-devicons').setup()

require('gitsigns.lua')
require('telescope.lua')
require('treesitter.lua')
--require('lsp.lua')
require('lsp2.lua')
require('cmp.lua')
require('lualine.lua')

-- Language specific settings (outside LSP)
require('typescript.lua')

-- Firenvim: only loading when started by firenvim
if vim.g.started_by_firenvim then
  require('firenvim.lua')
end
