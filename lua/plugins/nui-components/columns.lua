local Box = require("plugins.nui-components.box")

local Layout = require("nui.layout")
local fn = require("utils.fn")

local Columns = Box:extend("Columns")

function Columns:init(props, parent, renderer)
  Columns.super.init(self, vim.tbl_extend("force", props, {direction = "row"}), parent, renderer)
end

return Columns
