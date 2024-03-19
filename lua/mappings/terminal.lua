local utils = require("utils")

local map = utils.keymap_factory("t")
local termcodes = utils.termcodes

map("<Esc>", termcodes("<C-\\><C-N>"), "escape terminal mode")
