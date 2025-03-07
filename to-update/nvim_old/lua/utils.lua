local utils = {}

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

function utils.opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= 'o' then scopes['o'][key] = value end
end

function utils.map(mode, lhs, rhs, opts)
    local options = {noremap = true, silent = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function utils.b_map(bufnr, mode, lhs, rhs, opts)
    local options = {noremap = true, silent = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
end

function utils.nmap(lhs, rhs, opts)
    utils.map('n', lhs, rhs, opts)
end

function utils.imap(lhs, rhs, opts)
    utils.map('i', lhs, rhs, opts)
end

function utils.cmap(lhs, rhs, opts)
    utils.map('c', lhs, rhs, opts)
end

function utils.smap(lhs, rhs, opts)
    utils.map('s', lhs, rhs, opts)
end

function utils.xmap(lhs, rhs, opts)
    utils.map('x', lhs, rhs, opts)
end

return utils
