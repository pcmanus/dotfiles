return {
  -- Colorscheme
  { 'sainnhe/sonokai', lazy = true },

  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/lazydev.nvim',
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
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
    version = "^8",
    ft = { "rust" },
    -- `vim.g.rustaceanvim` is read when the plugin loads, so it has to be set
    -- from `init` rather than `config`.
    init = function()
      vim.g.rustaceanvim = {
        server = {
          settings = function(project_root, default_settings)
            local settings = require('rustaceanvim.config.server')
                .load_rust_analyzer_settings(project_root, { default_settings = default_settings })

            -- atai_core's `agent_core` hides whole node backends behind non-default
            -- cargo features. rust-analyzer resolves the crate graph with default
            -- features only, so those files land in no crate at all and lose hover,
            -- goto and references entirely -- turn the features on so they get
            -- analyzed.
            --
            -- `ffmpeg` is analysis-only: ffmpeg-next 8.1 does not compile against
            -- FFmpeg 9 headers (removed `AVCodec` fields and codec ids), which would
            -- take `agent_core` down with it and cost us every on-save diagnostic in
            -- the crate. Analysis needs no successful build, so `check.features`
            -- keeps clippy on the set that does compile.
            --
            -- Detected by the crate's path rather than the repo directory name, so
            -- this also applies inside a `wt` worktree under ~/.worktrees.
            if project_root and vim.uv.fs_stat(project_root .. '/common/atai_rs/agent_core/Cargo.toml') then
              local buildable = {
                'agent_core/newton-cuda',
                'agent_core/whisper',
                'agent_core/omega',
              }
              local analysis_only = vim.list_extend(vim.deepcopy(buildable), { 'agent_core/ffmpeg' })

              -- The loader hands back a table shared across projects.
              settings = vim.deepcopy(settings)
              local ra = settings['rust-analyzer']
              ra.cargo = vim.tbl_deep_extend('force', ra.cargo or {}, { features = analysis_only })
              ra.check = vim.tbl_deep_extend('force', ra.check or {}, { features = buildable })
            end

            return settings
          end,
        },
      }
    end,
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
  },

  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    -- NOTE: the `main` branch is a full, incompatible rewrite of nvim-treesitter.
    -- `setup()` only takes `install_dir`; the old `ensure_installed`/`auto_install`/
    -- `highlight` options are gone, and highlighting is NOT auto-enabled anymore.
    -- We install parsers explicitly and start the highlighter via a FileType autocmd.
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'lua', 'rust', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
        'svelte', 'html', 'css', 'typescript', 'javascript', 'yaml',
      }
      require('nvim-treesitter').install(parsers)

      -- Enable treesitter highlighting (and, via injections, TS inside
      -- `<script lang="ts">` in svelte files) for any buffer whose language
      -- has an installed parser.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then
            return
          end
          local ok, added = pcall(vim.treesitter.language.add, lang)
          if ok and added then
            vim.treesitter.start(args.buf, lang)
          end
        end,
      })
    end,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      latex = { enabled = false },
    },
  }
}
