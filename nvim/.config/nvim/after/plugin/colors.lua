vim.g.sonokai_enable_italic = 1
vim.cmd.colorscheme('sonokai')

local ok, colorizer = pcall(require, 'colorizer')
if ok then
  colorizer.setup()
end
