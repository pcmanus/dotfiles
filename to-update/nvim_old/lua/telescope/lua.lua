local actions = require('telescope.actions')
require("telescope").setup {
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
        },
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
            width = 0.75,
            horizontal = {
                mirror = false,
                preview_width = 0.5
            },
            vertical = {
                mirror = false
            }
        },
        file_sorter = require "telescope.sorters".get_fuzzy_file,
        file_ignore_patterns = {},
        generic_sorter = require "telescope.sorters".get_generic_fuzzy_sorter,
        path_display = { shorten = 10 },
        winblend = 0,
        border = {},
        borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        color_devicons = true,
        use_less = true,
        set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
        file_previewer = require "telescope.previewers".vim_buffer_cat.new,
        grep_previewer = require "telescope.previewers".vim_buffer_vimgrep.new,
        qflist_previewer = require "telescope.previewers".vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require "telescope.previewers".buffer_previewer_maker,
        mappings = {
            i = {
                ["<C-x>"] = false,
                ["<C-c>"] = actions.close,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            },
            n = {
                ["<C-n>"] = actions.move_selection_next,
                ["<C-p>"] = actions.move_selection_previous,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            },
        }
    }
}

local utils = require('utils')
utils.nmap('<leader>f', [[<Cmd>lua require('telescope.builtin').find_files()<CR>]])
utils.nmap('<leader>b', [[<Cmd>lua require('telescope.builtin').buffers()<CR>]])
utils.nmap('<leader>g', [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]])
