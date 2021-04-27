local cmd = vim.api.nvim_command

-- autocmd FileType typescript setlocal spell
cmd([[
augroup AU_TYPESCRIPT
autocmd FileType typescript setlocal foldmethod=indent
autocmd FileType typescript setlocal foldlevel=0
autocmd FileType typescript setlocal foldnestmax=4
autocmd FileType typescript setlocal foldenable
augroup END
]])
