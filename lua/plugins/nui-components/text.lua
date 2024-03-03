local Component = require("plugins.nui-components.component")

local Line = require("nui.line")
local fn = require("utils.fn")

local Text = Component:extend("Text")

function Text:init(props, parent, renderer)
  Text.super.init(
    self,
    parent,
    renderer,
    vim.tbl_extend(
      "force",
      {
        is_focusable = false,
        size = 1,
        text = ""
      },
      props
    ),
    {
      focusable = false
    }
  )
end

function Text:get_line()
  local line = Line()
  local props = self:get_props()

  if props.prepare_line then
    return props.prepare_line(line, props.text)
  end

  line:append(props.text, self:make_highlight_group_name("Default"))

  return line
end

function Text:redraw()
  local line = self:get_line()

  vim.api.nvim_set_option_value("modifiable", true, {buf = self.bufnr})
  line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})
end

function Text:calculate_size_with()
  local parent = self:get_parent()
  return self:normalize_size_with_border(parent:get_direction() == "column" and 1 or self:get_line():width())
end

return Text
