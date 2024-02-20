local theme = require("lualine.themes.auto")
local colors = require("ui.colors")

local default_colors = {
  bg = "none",
  fg = colors.dark["300"]
}

theme.insert.a.bg = colors.green["400"]
theme.visual.a.bg = colors.pink["300"]
theme.replace.a.bg = colors.purple["300"]
theme.command.a.bg = colors.primary["500"]

theme.normal.b = default_colors
theme.insert.b = default_colors
theme.visual.b = default_colors
theme.replace.b = default_colors
theme.command.b = default_colors

theme.normal.c = default_colors
theme.insert.c = default_colors
theme.visual.c = default_colors
theme.replace.c = default_colors
theme.command.c = default_colors

return theme
