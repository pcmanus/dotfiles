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
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
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
  'nvim-tree/nvim-web-devicons',

  -- Colorizer
  'catgoose/nvim-colorizer.lua',

  -- Fancy boxes for renaming/completion/...
  'stevearc/dressing.nvim',

    {
    "mrcjkb/rustaceanvim",
    version = "^5", -- follow the plugin's recommended major version
    ft = { "rust" },
  },
}
