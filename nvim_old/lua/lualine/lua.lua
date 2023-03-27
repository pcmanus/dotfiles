local lualine = require('lualine')

-- Color table for highlights
local colors = {
  black = "#252b32",
  bg = "#383b44",
  fg = "#D8DEE9",
  grey = "#AAAAAA",
  dark_green = "#65a380",
  light_green = "#A3BE8C",
  darkblue = "#61afef",
  green = "#BBE67E",
  orange = "#D08770",
  violet = "#B48EAD",
  blackish = "#22262C",
  red = "#DF8890",
  --red = "#BF616A",
  blue = "#81A1C1",
  yellow = "#EBCB8B",
  cyan = "#8FBCBB",
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
  has_lsp = function()
    local clients = vim.lsp.get_active_clients()
    return not (next(clients) == nil)
  end,
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = '',
    section_separators = '',
    theme = {
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Utility Functions {{{

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

local function file_readonly(readonly_icon)
  if vim.bo.filetype == 'help' then
    return ''
  end
  local icon = readonly_icon or ''
  if vim.bo.readonly == true then
    return " " .. icon .. " "
  end
  return ''
end

local function full_filename(modified_icon, readonly_icon)
  local file = vim.fn.fnamemodify(vim.fn.expand('%'), ":~:.")
  if vim.fn.empty(file) == 1 then return '' end
  if string.len(file_readonly(readonly_icon)) ~= 0 then
    return file .. file_readonly(readonly_icon)
  end
  local icon = modified_icon or ''
  if vim.bo.modifiable then
    if vim.bo.modified then
      return file .. ' ' .. icon .. '  '
    end
  end
  return file .. ' '
end

-- }}}

-- Left Section {{{

ins_left({
  -- mode component
  function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.red,
      i = colors.green,
      v = colors.blue,
      [''] = colors.blue,
      V = colors.blue,
      c = colors.violet,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      [''] = colors.orange,
      ic = colors.yellow,
      R = colors.violet,
      Rv = colors.violet,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      ['r?'] = colors.cyan,
      ['!'] = colors.red,
      t = colors.red,
    }
    vim.api.nvim_command('hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. ' guibg=' .. colors.bg)
    -- return ''
    return "█"
  end,
  color = 'LualineMode',
  padding = { left = 0, right = 1 },
})

--ins_left({
--  full_filename,
--  cond = conditions.buffer_not_empty,
--  color = { gui = 'bold' },
--})
ins_left({
  'filename',
  path = 1,
  shorting_target = 40, -- leaves 40 spaces for other targets
  symbols = {
    modified = '[+]',      -- Text to show when the file is modified.
    readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
    unnamed = '[No Name]', -- Text to show for unnamed buffers.
  },
  cond = conditions.buffer_not_empty,
  color = { gui = 'bold' },
})

ins_left({
  'filetype',
  color = { fg = colors.grey },
})

ins_right({
  'diff',
  symbols = { added = ' ', modified = '柳 ', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
})

ins_left({
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ' },
  colored=true,
  diagnostics_color = {
    error = { fg = colors.red },
    warn = { fg = colors.yellow },
    info = { fg = colors.cyan },
    hint = { fg = colors.grey },
  },
})
-- }}}

-- Middle Section {{{
ins_left({
  function()
    return '%='
  end,
})

ins_left({
  -- Lsp server name .
  function()
    local msg = 'No Active Lsp'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = '',
  cond = conditions.has_lsp,
  color = { fg = colors.grey, gui = 'bold' },
})
-- }}}

-- Right Section {{{

-- Add components to right sections

ins_right({
  'branch',
  icon = '',
  color = { fg = colors.orange, gui = 'bold' },
})

ins_right({ 'location', color = { fg = colors.blue, gui = 'bold' } })

ins_right({ 'progress', color = { fg = colors.grey, gui = 'bold' } })


ins_right({
  -- filesize component
  'filesize',
  cond = conditions.buffer_not_empty,
})

ins_right({
  'o:encoding', -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = { fg = colors.dark_green, gui = 'bold' },
})

ins_right({
  'fileformat',
  fmt = string.upper,
  cond = conditions.buffer_not_empty,
  color = { fg = colors.green, gui = 'bold' },
})

-- }}}

-- Now don't forget to initialize lualine
lualine.setup(config)
