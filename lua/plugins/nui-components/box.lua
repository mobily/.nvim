local Component = require("plugins.nui-components.component")
local Layout = require("nui.layout")

local fn = require("utils.fn")

local Box = Component:extend("Box")

function Box:init(props, parent, renderer)
  Box.super.init(
    self,
    parent,
    renderer,
    vim.tbl_extend(
      "force",
      {
        size = 1
      },
      props
    )
  )

  self:update_props({is_focusable = false})
end

return Box
