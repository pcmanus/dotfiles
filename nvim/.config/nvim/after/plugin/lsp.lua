-- Diagnostics

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    }
  }
})

local diag_opts = { silent = true }
vim.keymap.set('n', '<leader>k', function() vim.diagnostic.jump({ count = -1 }) end, diag_opts)
vim.keymap.set('n', '<leader>j', function() vim.diagnostic.jump({ count = 1 }) end, diag_opts)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, diag_opts)
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist, diag_opts)


-- LSP proper

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, remap = false, silent = true })
    end

    nmap('<leader>r', vim.lsp.buf.rename, '[R]ename')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('<CR>', vim.lsp.buf.definition, 'Goto Definition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- K -> hover is set by neovim's runtime on LspAttach by default
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    -- Format on save for Rust files (rust-analyzer uses rustfmt, same as cargo fmt)
    if vim.bo[bufnr].filetype == 'rust' then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })

      -- Re-run clippy when the file is reloaded from disk (e.g. autoread)
      vim.api.nvim_create_autocmd('FileChangedShellPost', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf_notify(bufnr, 'textDocument/didSave', {
            textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          })
        end,
      })
    end

    nmap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')
  end,
})


require('lazydev').setup({
  library = {
    -- Load luvit definitions when `vim.uv` is used.
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
    },
  }
})

vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
require('mason-lspconfig').setup({
  ensure_installed = { "lua_ls" },
})

-- Turn on lsp status information
require('fidget').setup({})

-- Completion
local cmp = require('cmp')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  completion = {
    autocomplete = false
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'crates' },
  },
})

-- Crates: for Cargo.toml completions
require('crates').setup {
    lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
    },
    -- cmp = {
    --   enabled = true
    -- },
}


-- Python
-- basedpyright: type checking, goto definition, rename, references, etc.
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "off",
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.enable("basedpyright")

-- Ruff: linting + formatting
--vim.lsp.config("ruff", {
--  init_options = {
--    settings = {
--      -- Keep config in pyproject.toml / ruff.toml when possible
--    },
--  },
--})
--
--vim.lsp.enable("ruff")
