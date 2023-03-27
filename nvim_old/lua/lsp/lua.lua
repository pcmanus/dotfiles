local lsp = require('lspconfig')
local utils = require('utils')

vim.diagnostic.config({
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    format = function(d)
      local t = vim.deepcopy(d)
      if d.code then
        t.message = string.format("%s [%s]", t.message, t.code):gsub("1. ", "")
      end
      return t.message
    end,
  },
})


local on_attach = function(client, bufnr)
  local function bmap(...) utils.b_map(bufnr, 'n', ...) end
  local function bvmap(...) utils.b_map(bufnr, 'v', ...) end
  local function bopt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  bopt('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  bmap('<CR>', '<Cmd>lua vim.lsp.buf.definition()<CR>')
  bmap('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
  bmap('gr', '<cmd>Telescope lsp_references<CR>')
  bmap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  bmap('<leader>D', '<cmd>Telescope lsp_type_definitions<CR>')
  bmap('<leader>a', '<cmd>Telescope lsp_code_actions<CR>')

  bmap('K', '<Cmd>lua vim.lsp.buf.hover()<CR>')
  bmap('<leader-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

  bmap('<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>')

  bmap('<C-p>', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
  bmap('<C-n>', '<cmd>lua vim.diagnostic.goto_next()<CR>')

  bmap('<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
  bmap('<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
  bmap('<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
  bmap('<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
  bmap('<leader>E', '<cmd>Telescope diagnostics bufnr=0<CR>')
  bmap('<leader>ll', '<cmd>lua vim.diagnostic.set_loclist()<CR>')

  -- Set some keybinds conditional on server capabilities
  if client.server_capabilities.document_formatting then
    bmap("<leader>=", "<cmd>lua vim.lsp.buf.formatting()<CR>")
  end
  if client.server_capabilities.document_range_formatting then
    bvmap("<leader>=", "<cmd>lua vim.lsp.buf.range_formatting()<CR>")
  end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
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


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with( vim.lsp.handlers.signature_help, { border = "rounded" })

vim.fn.sign_define("DiagnosticSignError",
  {texthl = "DiagnosticSignError", text = "", numhl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn",
  {texthl = "DiagnosticSignWarn", text = "", numhl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticsSignHint",
  {texthl = "DiagnosticSignHint", text = "", numhl = "DiagnosticSignHint"})
vim.fn.sign_define("DiagnosticSignInfo",
  {texthl = "DiagnosticSignInfo", text = "", numhl = "DiagnosticSignInfo"})

-- Servers with no specific configuration
local servers = { "rust_analyzer", "graphql", "html", "vimls" }
for _, server in ipairs(servers) do
  lsp[server].setup { on_attach = on_attach }
end

---- Lua
--local sumneko_binary_path = vim.fn.exepath('lua-language-server')
--local sumneko_root_path = vim.fn.fnamemodify(sumneko_binary_path, ':h:h:h')
--local runtime_path = vim.split(package.path, ';')
--table.insert(runtime_path, "lua/?.lua")
--table.insert(runtime_path, "lua/?/init.lua")
--
--
--local luadev = require("lua-dev").setup({
--  --cmd = {sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua"};
--  on_attach = on_attach,
--  -- add any options here, or leave empty to use the default settings
--  -- lspconfig = {
--  --   cmd = {"lua-language-server"}
--  -- },
--})

lsp.sumneko_lua.setup
{
  -- cmd = {sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua"};
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

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


-- Typescript
lsp.tsserver.setup {
  init_options = require("nvim-lsp-ts-utils").init_options,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.document_formatting = false

    local ts_utils = require("nvim-lsp-ts-utils")

    -- defaults
    ts_utils.setup({
        debug = false,
        disable_commands = false,
        enable_import_on_completion = false,

        -- import all
        import_all_timeout = 5000, -- ms
        -- lower numbers = higher priority
        import_all_priorities = {
            same_file = 1, -- add to existing import statement
            local_files = 2, -- git files or files with relative path markers
            buffer_content = 3, -- loaded buffer content
            buffers = 4, -- loaded buffer names
        },
        import_all_scan_buffers = 100,
        import_all_select_source = false,

        -- filter diagnostics
        filter_out_diagnostics_by_severity = {},
        filter_out_diagnostics_by_code = {},

        -- inlay hints
        auto_inlay_hints = true,
        inlay_hints_highlight = "Comment",

        -- update imports on file move
        update_imports_on_move = false,
        require_confirmation_on_move = false,
        watch_dir = nil,
    })

    -- required to fix code action ranges and filter diagnostics
    ts_utils.setup_client(client)

    -- no default maps, so you may want to define some here
    local opts = { silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)
  end
}


--local null_ls = require('null-ls')
--
--null_ls.setup({
--  --debug=true,
--  on_attach = on_attach,
--  sources = {
--    null_ls.builtins.formatting.stylua,
--    -- null_ls.builtins.diagnostics.eslint_d.with({
--    --   prefer_local = "node_modules/.bin",
--    -- }),
--    -- null_ls.builtins.code_actions.eslint_d.with({
--    --   prefer_local = "node_modules/.bin",
--    -- }),
--    null_ls.builtins.completion.spell,
--  }
--})
