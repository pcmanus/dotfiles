local gl = require("galaxyline")
local gls = gl.section
local condition = require('galaxyline.condition')
local vcs = require("galaxyline.provider_vcs")
local file_info = require("galaxyline.provider_fileinfo")

gl.short_line_list = {" "} -- keeping this table { } as empty will show inactive statuslines

local colors = {
    black = "#252b32",
    lightbg = "#383b44",
    light_grey = "#D8DEE9",
    grey = "#AAAAAA",
    dark_green = "#65a380",
    light_green = "#A3BE8C",
    darkblue = "#61afef",
    green = "#BBE67E",
    orange = "#D08770",
    purple = "#B48EAD",
    blackish = "#22262C",
    red = "#DF8890",
    --red = "#BF616A",
    blue = "#81A1C1",
    yellow = "#EBCB8B",
    cyan = "#8FBCBB",
}

local function current_mode()
  local alias = {
    n      = 'NORMAL',
    i      = 'INSERT',
    c      = 'COMMAND',
    V      = 'VISUAL',
    [''] = 'VISUAL',
    v      = 'VISUAL',
    ['r?'] = 'OTHER',
    rm     = 'OTHER',
    R      = 'REPLACE',
    Rv     = 'VIRTUAL',
    s      = 'SELECT',
    S      = 'SELECT',
    ['r']  = 'OTHER',
    [''] = 'SELECT',
    t      = 'TERMINAL',
    ['!']  = 'OTHER',
  }
  return alias[vim.fn.mode()]
end

local mode_color = {
  NORMAL = colors.blue,
  INSERT = colors.light_green,
  COMMAND = colors.red,
  VISUAL = colors.orange,
  REPLACE = colors.yellow,
  TERMINAL = colors.darkblue,
  SELECT = colors.green,
  OTHER = colors.purple,
}

-- Utility Functions {{{

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

local left_section = 1
local function left(section)
    gls.left[left_section] = section
    left_section = left_section + 1
end

local right_section = 1
local function right(section)
    gls.right[right_section] = section
    right_section = right_section + 1
end

local function c(character)
  return function()
    return character
  end
end

-- }}}

-- Left Section {{{

-- File info {{{

--▌
--█
left({
    ViMode = {
        provider = function()
          vim.api.nvim_command('hi GalaxyViMode guifg=' .. mode_color[current_mode()])
          return "█"
        end,
        highlight = {colors.lightbg, colors.lightbg},
    }
})

left({
    LeftSpace1 = {
        provider = c(" "),
        condition = condition.buffer_not_empty,
        highlight = {colors.light_grey, colors.lightbg}
    }
})

left({
    FileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {file_info.get_file_icon_color, colors.lightbg},
    }
})

left({
    FileName = {
        provider = full_filename,
        condition = condition.buffer_not_empty,
        highlight = {colors.light_grey, colors.lightbg},
        separator = " ",
        separator_highlight = {colors.light_grey, colors.lightbg, 'bold'}
    }
})

left({
    FileType = {
      provider = function()
        return vim.bo.filetype
      end,
      condition = condition.buffer_not_empty,
      highlight = {colors.grey, colors.lightbg}
    }
})

left({
    LeftSpace2 = {
        provider = c(" "),
        condition = condition.buffer_not_empty,
        highlight = {colors.black, colors.lightbg}
    }
})

left({
    Teech = {
        provider = c(" "),
        condition = condition.buffer_not_empty,
        highlight = {colors.lightbg, colors.black}
    }
})


-- }}}

-- Git Info {{{
-- 落  
left({
    DiffAdd = {
        provider = "DiffAdd",
        icon = "  ",
        highlight = {colors.light_green, colors.black}
    }
})

--   
left({
    DiffModified = {
        provider = "DiffModified",
        icon = "  ",
        highlight = {colors.blue, colors.black}
   }
})

--   
left({
    DiffRemove = {
        provider = "DiffRemove",
        icon = "  ",
        highlight = {colors.red, colors.black}
    }
})

left({
    LeftSpace3 = {
        provider = c(" "),
        highlight = {colors.black, colors.black}
    }
})
-- }}}

-- LSP Info {{{

-- 
left({
    DiagnosticError = {
      provider = "DiagnosticError",
      icon = "  ",
      highlight = {colors.red, colors.black}
    }
})

left({
    DiagnosticWarn = {
      provider = "DiagnosticWarn",
      icon = "  ",
      highlight = {colors.yellow, colors.black}
    }
})

left({
    DiagnosticInfo = {
      provider = "DiagnosticInfo",
      icon = '  ',
      highlight = {colors.blue, colors.black}
    }
})

left({
    DiagnosticHint = {
        provider = "DiagnosticHint",
        icon = '  ',
        highlight = {colors.grey, colors.black}
    }
})
-- }}}

-- }}}

-- Right Section {{{


right({
    GitIcon = {
        provider = c("  "),
        condition = vcs.check_git_workspace,
        highlight = {colors.orange, colors.black}
    }
})

right({
    GitBranch = {
        provider = "GitBranch",
        condition = vcs.check_git_workspace,
        highlight = {colors.orange, colors.black},
    }
})

right({
    RightSpace1 = {
        provider = c("  "),
        highlight = {colors.black, colors.black}
    }
})

right({
    FileSize = {
        provider = "FileSize",
        condition = condition.buffer_not_empty,
        highlight = {colors.grey, colors.black},
    }
})

right({
    PerCent = {
        provider = "LinePercent",
        highlight = {colors.light_grey, colors.black}
    }
})

-- }}}
