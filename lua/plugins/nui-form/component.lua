local Popup = require("nui.popup")
local utils = require("plugins.nui-form.utils")

local Component = Popup:extend("Component")

function Component:init(form, options, popup_options)
  popup_options =
    vim.tbl_deep_extend(
    "force",
    {
      enter = false,
      focusable = true,
      size = {
        width = form.width
      },
      win_options = {
        winblend = 0
      },
      zindex = 100
    },
    vim.F.if_nil(popup_options, {})
  )

  self.instance = {
    form = form,
    options = options
  }

  Component.super.init(self, popup_options)

  utils.attach_prev_next_focus(self)
  utils.attach_form_events(self)
end

function Component:mount()
  Component.super.mount(self)
  utils.set_initial_focus(self)
end

function Component:unmount()
  Component.super.unmount(self)

  vim.schedule(
    function()
      vim.api.nvim_command("stopinsert")
    end
  )
end

function Component:set_state(value)
  self:get_form():set_state(self:get_key(), value)
end

function Component:get_state()
  return self:get_form().state[self:get_key()]
end

function Component:validate()
  return self:get_options().validate(self:get_state())
end

function Component:is_hidden()
  return self:get_options().hidden(self:get_form().state)
end

function Component:is_focusable()
  return self:get_options().is_focusable
end

function Component:set_focus_index(index)
  self.instance.options.focus_index = index
end

function Component:get_height(index)
  return self:is_hidden() and 0 or self:get_options().height
end

function Component:get_form()
  return self.instance.form
end

function Component:get_options()
  return self.instance.options
end

function Component:get_key()
  return self:get_options().key
end

function Component:on_state_change()
  if self:is_hidden() then
  end
end

return Component
