local Component = require("plugins.nui-components.component")

local Popup = require("nui.popup")
local Layout = require("nui.layout")
local fn = require("utils.fn")

local Gap = Component:extend("Gap")

function Gap:init(props, parent, renderer)
  Gap.super.init(
    self,
    parent,
    renderer,
    {
      is_focusable = false,
      size = vim.F.if_nil(props.size, 1),
      flex = props.flex
    },
    {
      focusable = false
    }
  )
end

function Gap:render()
  local props = self:get_props()
  return Layout.Box(self, {size = self:get_size()})
end

return Gap
