return {
  -- Colorscheme
  { 'sainnhe/sonokai', lazy = true },

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      {
        'j-hui/fidget.nvim',
        tag = 'legacy',
        event = 'LspAttach',
      },

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },

  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      -- Additional text objects via treesitter
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

  -- Fancier statusline
  'nvim-lualine/lualine.nvim',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Navigate undos
  'mbbill/undotree',

  -- Visual indentation markers
  "lukas-reineke/indent-blankline.nvim",

  --- Git stuffs
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',

  -- Devicons
  'kyazdani42/nvim-web-devicons',
  'ryanoasis/vim-devicons',
  'yamatsum/nvim-web-nonicons',

  -- Colorizer
  'norcalli/nvim-colorizer.lua',

  -- Fancy boxes for renaming/completion/...
  'stevearc/dressing.nvim',
}
