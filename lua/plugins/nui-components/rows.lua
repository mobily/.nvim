local Box = require("plugins.nui-components.box")

local Layout = require("nui.layout")
local fn = require("utils.fn")

local Rows = Box:extend("Rows")

function Rows:init(props, parent, renderer)
  Rows.super.init(self, vim.tbl_extend("force", props, {direction = "column"}), parent, renderer)
end

return Rows
