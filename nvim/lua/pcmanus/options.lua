vim.opt.number = true              -- Show line numbers ...
vim.opt.relativenumber = true      -- .. and relative ones
vim.opt.cursorline = true          -- Highlight the current line
vim.opt.showmode = false           -- Don't show --INSERT-- below the status line
vim.opt.wrap = false               -- Wrapping is for loosers

vim.opt.autowrite = true           -- Save files in many cases.

vim.opt.splitbelow = true          -- Split horizontally below
vim.opt.splitright = true          -- Split vertically right

vim.opt.scrolloff = 4              -- Keep that many line when scrolling

vim.opt.clipboard = 'unnamedplus'  -- Copy paste between vim and everything else
vim.opt.mouse = 'a'                -- Enable mouse all the time

vim.opt.list = true                -- Show the characters in listchars
vim.opt.listchars = 'tab:▸ ,trail:·,extends:❯,precedes:❮'

vim.opt.termguicolors = true       -- It's the 21st century ...

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"         -- Always display to avoid "jumps"

vim.opt.updatetime = 50

vim.opt.completeopt = "menuone,noselect"

vim.opt.smartindent = true         -- Auto-indent after '{'. etc...

-- Netrw
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

