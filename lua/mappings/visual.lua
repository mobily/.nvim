local utils = require "utils"

local map = utils.keymap_factory("v")
local map = utils.keymap_factory("v")

-- local tc = require("nvim-treeclimber")

-- map("<D-l>", tc.select_expand, "select expand")
-- map("<D-k>", tc.select_shrink, "select shrink")
-- map("<D-Up>", tc.select_backward, "select grow backward")
-- map("<D-Down>", tc.select_forward, "select grow forward")
-- map("<D-Left>", tc.select_grow_backward, "select grow backward")
-- map("<D-Right>", tc.select_grow_forward, "select grow forward")

map("<C-l>", "<Plug>(dial-increment)", "dial inc")
map("<C-k>", "<Plug>(dial-decrement)", "dial dec")

map("<D-c>", "y", "copy")
map("<D-x>", "d", "cut")
map("<D-v>", "P", "paste")
map("<D-z>", "<Esc>u", "undo")
map("<D-r>", "<Esc><C-r>", "redo")
map(
  "<D-s>",
  function()
    vim.api.nvim_command("write")
  end,
  "save file"
)
map(
  "<D-/>",
  function()
    vim.api.nvim_input("gc")
  end,
  "comment lines"
)
map("<BS>", '"_d', "delete selected")
-- map("<D-S-Down>", ":m'>+<CR>gv=gv", "")
-- map("<D-S-Up>", ":m-2<CR>gv=gv", "")

function _G.put(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end

map(
  "<D-d>",
  function()
    -- vim.api.nvim_input(":s/")
    vim.api.nvim_input("*Ncgn")
  end,
  "find and replace"
)

map(
  "<D-g>",
  function()
    vim.api.nvim_input(":s/")
  end,
  "find and replace"
)

map("<S-Tab>", "<gv", "unindent")
map("<Tab>", ">gv", "indent")

map("i", "I", "insert mode")
map("a", "A", "insert mode")

map("<Home>", "^I", "append to each line")
map("<End>", "$A", "append to each line")
