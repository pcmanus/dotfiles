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
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'}
    }
  }

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'folke/lsp-colors.nvim'
  use 'jose-elias-alvarez/typescript.nvim'
  use 'onsails/lspkind-nvim'
  use 'folke/neodev.nvim'

  -- Tree-sitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Devicons
  use 'kyazdani42/nvim-web-devicons'
  use 'ryanoasis/vim-devicons'
  use 'yamatsum/nvim-web-nonicons'

  -- Firenvim
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

  -- Signs for git chunks
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use "rafamadriz/friendly-snippets"

  -- Statusline
  use 'nvim-lualine/lualine.nvim'

  -- Better highlighting for typescript (handles spells only in comments in particular)
  use 'leafgarland/typescript-vim'

  -- Git handling
  use 'tpope/vim-fugitive'

  -- Give us some variable name conversion methods
  --use 'tpope/vim-abolish'
end)
