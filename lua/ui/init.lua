local M = {}

-- vim.opt.bg = "dark"

M.term = {
  accent = "#ffc400",
  bg = "#1F2430",
  fg = "#CBCCC6",
  tag = "#00a1f9",
  string = "#9ae204",
  regexp = "#95E6CB",
  markup = "#fe6D85",
  comment = "#565656",
  constant = "#ab7aef",
  error = "#FF3333",
  fg_idle = "#565656"
}

vim.g.terminal_color_0 = M.term.bg
vim.g.terminal_color_1 = M.term.markup
vim.g.terminal_color_2 = M.term.string
vim.g.terminal_color_3 = M.term.accent
vim.g.terminal_color_4 = M.term.tag
vim.g.terminal_color_5 = M.term.constant
vim.g.terminal_color_6 = M.term.regexp
vim.g.terminal_color_7 = M.term.fg
vim.g.terminal_color_8 = M.term.fg_idle
vim.g.terminal_color_9 = M.term.error
vim.g.terminal_color_10 = M.term.string
vim.g.terminal_color_11 = M.term.accent
vim.g.terminal_color_12 = M.term.tag
vim.g.terminal_color_13 = M.term.constant
vim.g.terminal_color_14 = M.term.regexp
vim.g.terminal_color_15 = M.term.comment
vim.g.terminal_color_background = M.term.bg
vim.g.terminal_color_foreground = M.term.fg

return M
