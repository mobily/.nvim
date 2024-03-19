local utils = require("utils")

local map = utils.keymap_factory("i")

map("<D-=>", utils.focus_nvim_tree("<Esc>"), "focus nvimtree")
map("<D-Up>", "<C-o>1G", "file beginning")
map("<D-Down>", "<C-o>G", "end of file")
map("<D-Left>", "<C-o>^", "start of line")
map("<D-Right>", "<C-o>$", "end of line")

map("<D-z>", "<C-o>u", "undo")
map("<D-r>", "<C-o><C-r>", "redo")
map("<D-BS>", "<C-w>", "delete word to the left")

map("<D-x>", "<C-o>dd", "cut line")
map("<D-c>", "<C-o>yy", "copy line")
map("<D-v>", "<Esc>gpa", "paste")
map("<M-Left>", "<C-o>b", "move cursor left")
map("<M-Right>", "<C-o>e<Right>", "move cursor right")
map("<M-Up>", "<C-o>5k", "move cursor up")
map("<M-Down>", "<C-o>5j", "move cursor down")

map("<C-j>", "<Esc><C-w>h", "window left")
map("<C-l>", "<Esc><C-w>l", "window right")
map("<C-k>", "<Esc><C-w>j", "window down")
map("<C-i>", "<Esc><C-w>k", "window up")

map("<Tab>", "<C-T>", "indent")
map("<S-Tab>", "<C-D>", "unindent")

map("<D-s>", function()
  vim.api.nvim_command("write")
end, "save file")

map("<D-/>", function()
  vim.api.nvim_input("<Esc>gcca")
end, "comment line")

map("<D-S-BS>", function()
  vim.api.nvim_input("<Esc>")
  local lastline = vim.api.nvim_eval('line(".") == line("$")')

  if lastline == 1 then
    vim.api.nvim_input('"_ddi')
    return
  end

  vim.api.nvim_input('"_dd<Up>i')
end, "delete line")
