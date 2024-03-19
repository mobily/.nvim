local utils = require("utils")

local map = utils.keymap_factory("v")
local map = utils.keymap_factory("v")

map("<C-l>", "<Plug>(dial-increment)", "dial inc")
map("<C-k>", "<Plug>(dial-decrement)", "dial dec")

map("<D-c>", "y", "copy")
map("<D-x>", "d", "cut")
map("<D-v>", "P", "paste")
map("<D-z>", "<Esc>u", "undo")
map("<D-r>", "<Esc><C-r>", "redo")
map("<D-s>", function()
  vim.api.nvim_command("write")
end, "save file")

map("<D-/>", function()
  vim.api.nvim_input("gc")
end, "comment lines")

map("<BS>", '"_d', "delete selected")

-- map("<D-S-Down>", ":m'>+<CR>gv=gv", "")
-- map("<D-S-Up>", ":m-2<CR>gv=gv", "")

map("<D-d>", function()
  -- vim.api.nvim_input(":s/")
  vim.api.nvim_input("*Ncgn")
end, "find and replace")

map("<PageDown>", function()
  vim.api.nvim_input("y<PageDown>")
end, "")

map("<D-g>", function()
  vim.api.nvim_input(":s/")
end, "find and replace")

map("<S-Tab>", "<gv", "unindent")
map("<Tab>", ">gv", "indent")

map("i", "I", "insert mode")
map("a", "A", "insert mode")

map("<Home>", "^I", "prepend to each line")
map("<End>", "$A", "append to each line")
