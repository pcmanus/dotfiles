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

on_filetype('typescript', function()
  vim.cmd [[setlocal foldmethod=indent]]
  vim.cmd [[setlocal foldlevel=0]]
  vim.cmd [[setlocal foldnestmax]]
  vim.cmd [[setlocal foldenable]]
end)

autocmd({'BufNewFile', 'BufRead'}, {
  group = init_lua_augroup,
  pattern = '*.md',
  callback = function ()
    vim.cmd [[setlocal spell]]
    vim.cmd [[setlocal textwidth=120]]
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
