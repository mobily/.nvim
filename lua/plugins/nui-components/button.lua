local Component = require("plugins.nui-components.component")

local Line = require("nui.line")
local Text = require("nui.text")

local event = require("nui.utils.autocmd").event
local fn = require("utils.fn")

local Button = Component:extend("Button")

function Button:init(props, parent, renderer)
  Button.super.init(
    self,
    parent,
    renderer,
    vim.tbl_extend(
      "force",
      {
        on_press = fn.ignore,
        on_focus = fn.ignore,
        on_blur = fn.ignore,
        key = "<CR>"
      },
      props
    ),
    {
      buf_options = {
        filetype = props.filetype or ""
      }
    }
  )
end

function Button:mappings()
  local props = self:get_props()
  local renderer = self:get_renderer()

  local on_press = function()
    props.on_press(renderer.state, self)
  end

  return {
    {mode = {"n"}, from = props.key, to = on_press}
  }
end

function Button:events()
  local props = self:get_props()
  local callback =
    vim.schedule_wrap(
    function()
      self:redraw()
    end
  )

  return {
    {
      event = event.BufEnter,
      callback = callback
    },
    {
      event = event.BufLeave,
      callback = callback
    }
  }
end

function Button:get_line()
  local props = self:get_props()

  if props.prepare_line then
    return props.prepare_line()
  end

  local line = Line()
  line:append(props.label, self:make_highlight_group_name(self:is_focused() and "Focused" or ""))
  return line
end

function Button:calculate_size_with()
  local parent = self:get_parent()
  return self:normalize_size_with_border(parent:get_direction() == "column" and 1 or self:get_line():width())
end

function Button:redraw()
  local line = self:get_line()

  vim.api.nvim_set_option_value("modifiable", true, {buf = self.bufnr})
  line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})
end

return Button
