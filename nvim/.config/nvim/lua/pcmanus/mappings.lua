local opts = { remap = false, silent = true }

-- Better escaping
vim.keymap.set('i', 'jj', '<Esc>', opts)
vim.keymap.set('i', 'jk', '<Esc>', opts)

-- Write, Quit and Exit shortcuts
vim.keymap.set('n', '<Leader>w', ':w!<CR>', opts)
vim.keymap.set('n', '<Leader>q', ':quit<CR>', opts)
vim.keymap.set('n', '<Leader>x', ':xit<CR>', opts)

-- Open last buffer
vim.keymap.set('n', '<Leader><Leader>', '<C-^>', opts)

-- Keep the cursor in place while joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Copy whole buffer to system clipboard
vim.keymap.set('n', '<Leader>c', 'gg"+yG', opts)

-- Enter and Backspace to follow link and come back.
vim.keymap.set('n', '<CR>', '<c-]>', opts)
vim.keymap.set('n', '<BS>', '<c-t>', opts)

-- Reset enter and backspace when in the command
vim.cmd [[au CmdwinEnter * nnoremap <CR> <CR>]]
vim.cmd [[au CmdwinEnter * nnoremap <BS> <BS>]]
vim.cmd [[au CmdwinLeave * nnoremap <CR> <c-]>]]
vim.cmd [[au CmdwinLeave * nnoremap <BS> <c-t>]]

-- Making splits
vim.keymap.set('n', '<leader>v', ':vsplit<CR>', opts)
vim.keymap.set('n', '<leader>h', ':split<CR>', opts)

-- Navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Disable stuffs we don't nee
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', opts)

-- Make the current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Open netrw
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
