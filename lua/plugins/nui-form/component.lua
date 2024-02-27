local Popup = require("nui.popup")

local event = require("nui.utils.autocmd").event
local fn = require("utils.fn")

local Component = Popup:extend("Component")

function Component:init(form, props, popup_options)
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

  if not self:disable_label() then
    local icon = props.icon and " " .. props.icon or ""

    popup_options =
      vim.tbl_extend(
      "force",
      popup_options,
      {
        border = {
          style = props.style,
          text = {
            top = icon .. " " .. props.label .. " ",
            top_align = props.label_align
          }
        }
      }
    )
  end

  self.__form = form
  self.__props = props

  Component.super.init(self, popup_options)

  self:__set_initial_state()
end

function Component:mount()
  Component.super.mount(self)

  self:__attach_events()
  self:__attach_mappings()
  self:__set_initial_focus()
end

function Component:unmount()
  Component.super.unmount(self)

  vim.schedule(
    function()
      vim.api.nvim_command("stopinsert")
    end
  )
end

function Component:__set_initial_focus()
  if self:get_props().focus then
    vim.api.nvim_set_current_win(self.winid)
  end
end

function Component:__attach_events()
  local form = self:get_form()

  local default_events = {}

  local events =
    fn.ireduce(
    self:events(),
    function(acc, event)
      table.insert(acc, event)
      return acc
    end,
    default_events
  )

  fn.ieach(
    events,
    function(tbl)
      self:on(tbl.event, tbl.callback)
    end
  )
end

function Component:__attach_mappings()
  local form = self:get_form()

  local default_mappings = {
    {
      mode = {"n"},
      from = "<leader>c",
      to = function()
        form.layout:unmount()
        form.on_close()
      end
    },
    {
      mode = {"n"},
      from = form.keymap.close,
      to = function()
        form.layout:unmount()
        form.on_close()
      end
    },
    {
      mode = {"i", "n"},
      from = form.keymap.submit,
      to = function()
        if form:validate() then
          form.layout:unmount()
          form.on_submit(form.state)
        end
      end
    },
    {
      mode = {"i", "n"},
      from = "<Tab>",
      to = function()
        local index = self:get_props().focus_index
        local next = form.focusable_components[index + 1] or form.focusable_components[1]

        vim.api.nvim_set_current_win(next.winid)
      end
    },
    {
      mode = {"i", "n"},
      from = "<S-Tab>",
      to = function()
        local index = self:get_props().focus_index
        local prev = form.focusable_components[index - 1] or form.focusable_components[#form.focusable_components]

        vim.api.nvim_set_current_win(prev.winid)
      end
    }
  }

  local mappings =
    fn.ireduce(
    self:mappings(),
    function(acc, event)
      table.insert(acc, event)
      return acc
    end,
    default_mappings
  )

  local map = function(mode, from, to)
    self:map(mode, from, to, {noremap = true, silent = true})
  end

  fn.ieach(
    mappings,
    function(mapping)
      if type(mapping.mode) == "table" then
        return fn.ieach(
          mapping.mode,
          function(mode)
            map(mode, mapping.from, mapping.to)
          end
        )
      end

      map(mapping.mode, mapping.from, mapping.to)
    end
  )
end

function Component:__set_initial_state()
  local state = self:initial_state()

  if state then
    self:set_state(state)
  end
end

function Component:get_form()
  return self.__form
end

function Component:get_props()
  return self.__props
end

function Component:initial_state()
  return nil
end

function Component:events()
  return {}
end

function Component:mappings()
  return {}
end

function Component:set_state(value)
  self:get_form():set_state(self:get_key(), value)
end

function Component:get_state()
  return self:get_form().state[self:get_key()]
end

function Component:validate()
  return self:get_props().validate(self:get_state())
end

function Component:is_hidden()
  return self:get_props().hidden(self:get_form().state)
end

function Component:is_focusable()
  return self:get_props().is_focusable
end

function Component:set_focus_index(index)
  self:extend_props(
    {
      focus_index = index
    }
  )
end

function Component:disable_label()
  return false
end

function Component:get_height(index)
  return self:is_hidden() and 0 or self:get_props().height
end

function Component:extend_props(tbl)
  self.__props = vim.tbl_extend("force", self.__props, tbl)
end

function Component:get_key()
  return self:get_props().key
end

return Component
