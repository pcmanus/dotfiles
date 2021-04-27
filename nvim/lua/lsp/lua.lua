local lsp = require('lspconfig')
local utils = require('utils')
local on_attach = function(client, bufnr)
  local function bmap(...) utils.b_map(bufnr, 'n', ...) end
  local function bvmap(...) utils.b_map(bufnr, 'v', ...) end
  local function bopt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  bopt('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  bmap('<CR>', '<Cmd>lua vim.lsp.buf.definition()<CR>')
  bmap('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
  bmap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
  bmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  bmap('<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')

  bmap('K', '<Cmd>lua vim.lsp.buf.hover()<CR>')
  bmap('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

  bmap('<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')

  bmap('<C-p>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  bmap('<C-n>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')

  bmap('<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
  bmap('<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
  bmap('<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
  bmap('<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  bmap('<leader>ll', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    bmap("<leader>=", "<cmd>lua vim.lsp.buf.formatting()<CR>")
  end
  if client.resolved_capabilities.document_range_formatting then
    bvmap("<leader>=", "<cmd>lua vim.lsp.buf.range_formatting()<CR>")
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

vim.fn.sign_define("LspDiagnosticsSignError",
  {texthl = "LspDiagnosticsSignError", text = "", numhl = "LspDiagnosticsSignError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
  {texthl = "LspDiagnosticsSignWarning", text = "", numhl = "LspDiagnosticsSignWarning"})
vim.fn.sign_define("LspDiagnosticsSignHint",
  {texthl = "LspDiagnosticsSignHint", text = "", numhl = "LspDiagnosticsSignHint"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
  {texthl = "LspDiagnosticsSignInformation", text = "", numhl = "LspDiagnosticsSignInformation"})

-- Servers with no specific configuration
local servers = { "rust_analyzer", "graphql", "html", "vimls" }
for _, server in ipairs(servers) do
  lsp[server].setup { on_attach = on_attach }
end

-- JSON
lsp.jsonls.setup {
  on_attach = on_attach,
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
      end
    }
  }
}

-- Lua
local sumneko_root_path = '/Users/pcmanus/Git/lua-language-server'
local sumneko_binary = sumneko_root_path.."/bin/macOS/lua-language-server"
lsp.sumneko_lua.setup {
  on_attach = on_attach,
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Typescript
lsp.tsserver.setup {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    on_attach(client, bufnr)
  end
}

-- Diagnostics
local filetypes = {
  typescript = "eslint",
  typescriptreact = "eslint",
}
local linters = {
  eslint = {
    sourceName = "eslint",
    command = "eslint_d",
    rootPatterns = {".eslintrc.js", "package.json"},
    debounce = 100,
    args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = {[2] = "error", [1] = "warning"}
  }
}
local formatters = {
  prettier = {command = "prettier", args = {"--stdin-filepath", "%filepath"}}
}
local formatFiletypes = {
  typescript = "prettier",
  typescriptreact = "prettier"
}
lsp.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = vim.tbl_keys(filetypes),
  init_options = {
    filetypes = filetypes,
    linters = linters,
    formatters = formatters,
    formatFiletypes = formatFiletypes
  }
}
