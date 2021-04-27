local utils = require('utils')

utils.opt('o', 'completeopt', "menuone,noselect")

vim.g.vsnip_filetypes = {
    typescriptreact = {"typescript"}
}

require'compe'.setup {
  max_kind_width = 100,
  source = {
    path = {kind = "  "},
    buffer = {kind = "  "},
    calc = {kind = "  "},
    -- vsnip = {kind = "  "},
    nvim_lsp = {kind = "  "},
    nvim_lua = {kind = "  "},
    spell = {kind = "  "},
    tags = false,
    treesitter = {kind = "  "},
    emoji = {kind = " ﲃ ", filetypes={"markdown", "text"}}
    -- for emoji press : (idk if that in compe tho)
  };

}

-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- ﬘
-- 
-- 
-- 
-- m
-- 
-- 
-- 
-- 


local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
  --   return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  -- elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
  --   return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

utils.imap("<Tab>", "v:lua.tab_complete()", {expr = true})
utils.smap("<Tab>", "v:lua.tab_complete()", {expr = true})
utils.imap("<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
utils.smap("<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

utils.imap("<C-Space>", "compe#complete()", {expr = true, silent = true})
utils.imap("<CR>", [[compe#confirm("<CR>")]], {expr = true, silent = true})
utils.imap("<C-e>", [[compe#close("<C-e>")]], {expr = true, silent = true})
