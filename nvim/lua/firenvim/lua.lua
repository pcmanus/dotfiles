vim.g.firenvim_config = {
  -- globalSettings = {
  --   alt = 'alphanum',
  -- },
  localSettings = {
    ['.*'] = {
      cmdline = 'neovim',
      content = 'text',
      priority = 0,
      selector = 'textarea:not([readonly]), div[role="textbox"]',
      takeover = 'never'
    },
    ['https?://twitter.com.*'] = {
      takeover = 'never',
      priority = 1
    },
    ['https?://mail.google.com.*'] = {
      takeover = 'never',
      priority = 1
    }
  }
}

vim.cmd([[let $LANG='en_US.UTF-8']])

vim.cmd('au BufEnter github.com_*.txt set filetype=markdown')
vim.cmd('au BufEnter github.com_*.txt set spell')

vim.cmd('au BufEnter mail.google.com_*.txt set syntax=mail')
vim.cmd('au BufEnter mail.google.com_*.txt set spell')

local utils = require('utils')
utils.opt('o', 'guifont', 'Hack Nerd Font Mono:h12')
utils.opt('o', 'laststatus', 0)
