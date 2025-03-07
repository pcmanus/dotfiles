require("neodev").setup({})

require('mason').setup()
local mason_lsp = require('mason-lspconfig')

mason_lsp.setup {
  ensure_installed = {
    "cssls",
    "html",
    "jsonls",
    "sumneko_lua",
    "rust_analyzer",
    "vimls",
    "yamlls",
    "graphql",
    "tsserver",
  }
}

-- Better gutter signs for diagnostics
vim.fn.sign_define("DiagnosticSignError", {texthl = "DiagnosticSignError", text = "", numhl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {texthl = "DiagnosticSignWarn", text = "", numhl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticsSignHint", {texthl = "DiagnosticSignHint", text = "", numhl = "DiagnosticSignHint"})
vim.fn.sign_define("DiagnosticSignInfo", {texthl = "DiagnosticSignInfo", text = "", numhl = "DiagnosticSignInfo"})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with( vim.lsp.handlers.signature_help, { border = "rounded" })

-- Base global mappings
local gopts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, gopts)
vim.keymap.set('n', '<C-p>', vim.diagnostic.goto_prev, gopts)
vim.keymap.set('n', '<C-n>', vim.diagnostic.goto_next, gopts)
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist, gopts)

local on_attach = function(_, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<CR>', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
end

local lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local opts = {
  on_attach = on_attach,
  capabilities = capabilities,
}


mason_lsp.setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name)
    lsp[server_name].setup(opts)
  end,

  ["tsserver"] = function()
    require("typescript").setup {
      debug = false,
      go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
      },
      server = opts,
    }
  end,
}
