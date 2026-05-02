local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local init_lua_augroup = augroup('InitLua', {})

local function on_filetype(ft, cb)
  autocmd('FileType', {
    group = init_lua_augroup,
    pattern = ft,
    callback = cb,
  })
end

autocmd({'BufNewFile', 'BufRead'}, {
  group = init_lua_augroup,
  pattern = '*.md',
  callback = function ()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 120
  end
})

-- Check for external file changes on focus/buffer switch.
-- When autoread reloads a file, treesitter fold expressions are re-evaluated
-- and all folds snap shut (foldlevelstart=0). Save fold state before checktime
-- and restore it after any reload to preserve the user's fold state.
autocmd({ 'FocusGained', 'BufEnter' }, {
  group = init_lua_augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype ~= '' then return end
    pcall(vim.cmd, 'silent! mkview! 1')
    vim.cmd('silent! checktime')
  end
})

autocmd('FileChangedShellPost', {
  group = init_lua_augroup,
  pattern = '*',
  callback = function()
    pcall(vim.cmd, 'silent! loadview 1')
  end
})

-- Save when losing focus
autocmd({'FocusLost'}, {
  group = init_lua_augroup,
  pattern = '*',
  command = 'silent! wall'
})


-- Resize splits when the window is resized
autocmd({'VimResized'}, {
  group = init_lua_augroup,
  pattern = '*',
  command = 'windcmd ='
})

autocmd('TextYankPost', {
  group = init_lua_augroup,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 300,
    })
  end,
})
