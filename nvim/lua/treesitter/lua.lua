require('nvim-treesitter.configs').setup {
  ensure_installed = "all",
  ignore_install = { "haskell" }, -- Doesn't compile for some reason
  highlight = {
    enable = true
  },
  --indent = {
  --  enable = true
  --}
}
