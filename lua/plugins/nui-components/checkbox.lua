local Component = require("plugins.nui-components.component")

local Line = require("nui.line")
local Text = require("nui.text")

local fn = require("utils.fn")

local Checkbox = Component:extend("Checkbox")

function Checkbox:init(props, parent, renderer)
  Checkbox.super.init(
    self,
    parent,
    renderer,
    vim.tbl_deep_extend(
      "force",
      {
        on_change = fn.ignore,
        key = "<CR>",
        value = false,
        sign = {
          checked = "[·]",
          default = "[ ]"
        },
        text = ""
      },
      props
    )
  )

  self.__current_value = props.default_value
end

function Checkbox:initial_state()
  return self:get_props().default_value
end

function Checkbox:mappings()
  local props = self:get_props()
  local renderer = self:get_renderer()

  local on_change = function()
    self.__current_value = not self.__current_value
    self:set_state(self.__current_value)

    props.on_change(self.__current_value, renderer.state, self)
    self:redraw()
  end

  return {
    {mode = {"n"}, from = props.key, to = on_change}
  }
end

function Checkbox:is_checked()
  return self.__current_value
end

function Checkbox:get_line()
  local props = self:get_props()
  local is_checked = self:is_checked()

  if props.prepare_line then
    return props.prepare_line(props.text, props.sign, is_checked)
  end

  local line = Line()

  if is_checked then
    line:append(props.sign.checked, self:make_highlight_group_name("IconChecked"))
  else
    line:append(props.sign.default, self:make_highlight_group_name("Icon"))
  end

  local separator = is_checked and (#props.sign.checked > 0 and " " or "") or (#props.sign.default > 0 and " " or "")
  line:append(separator)
  line:append(props.text, self:make_highlight_group_name(is_checked and "LabelChecked" or "Label"))

  return line
end

function Checkbox:redraw()
  local line = self:get_line()

  vim.api.nvim_set_option_value("modifiable", true, {buf = self.bufnr})
  line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})
end

function Checkbox:calculate_size_with()
  local parent = self:get_parent()
  return self:normalize_size_with_border(parent:get_direction() == "column" and 1 or self:get_line():width())
end

return Checkbox
