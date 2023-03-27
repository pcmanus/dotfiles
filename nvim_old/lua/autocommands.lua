local cmd = vim.cmd

cmd 'au BufNewFile,BufRead *.md setlocal spell'
cmd 'au BufNewFile,BufRead *.md setlocal textwidth=120'
-- cmd 'au BufNewFile,BufRead *.md setlocal foldmethod=expr'

cmd 'au BufNewFile,BufRead $HOME/Git/dotfiles/nvim/*.lua setlocal foldmethod=marker'
cmd 'au BufNewFile,BufRead $HOME/.config/neomutt/*.muttrc setlocal filetype=muttrc'

-- Save when losing focus
cmd 'au FocusLost * :silent! wall'

-- Resize splits when the window is resized
cmd 'au VimResized * :wincmd ='

cmd 'au BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact'
