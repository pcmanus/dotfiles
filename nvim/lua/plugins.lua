 -- Auto compile when there are changes in plugins.lua
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile'

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use 'sainnhe/sonokai'

  -- Language packs
  use 'sheerun/vim-polyglot'

  -- Colorizer
  use 'norcalli/nvim-colorizer.lua'

  -- Fuzzy finding
  use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/lsp_extensions.nvim'  -- Provide inlay hints

  -- Tree-sitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Devicons
  use 'kyazdani42/nvim-web-devicons'
  use 'ryanoasis/vim-devicons'
  use 'yamatsum/nvim-web-nonicons'

  -- Firenvim
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

  -- Signs for git chunks (seems broken; don't know if I care)
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Completion
  use 'hrsh7th/nvim-compe'

  -- Statusline
  use 'glepnir/galaxyline.nvim'

  -- Better highlighting for typescript (handles spells only in comments in particular)
  use 'leafgarland/typescript-vim'
end)
