local Popup = require("nui.popup")
local Layout = require("nui.layout")

local event = require("nui.utils.autocmd").event
local fn = require("utils.fn")

local Component = Popup:extend("Component")

function Component:init(parent, renderer, props, popup_options)
  popup_options =
    vim.tbl_deep_extend(
    "force",
    {
      enter = false,
      focusable = true,
      win_options = {
        winblend = 0
      },
      zindex = 100
    },
    vim.F.if_nil(popup_options, {})
  )

  props =
    vim.tbl_extend(
    "force",
    {
      hidden = false,
      validate = fn.always(true),
      on_state_change = fn.always(nil),
      mappings = fn.always({}),
      events = fn.always({}),
      is_focusable = true,
      direction = "row",
      on_focus = fn.ignore,
      on_blur = fn.ignore,
      on_mount = fn.ignore,
      on_unmount = fn.ignore,
      id = tostring(math.random())
    },
    props
  )

  if props.style and not (props.style == "none") then
    popup_options =
      vim.tbl_deep_extend(
      "force",
      popup_options,
      {
        border = {
          style = props.style,
          text = {
            top = "",
            top_align = "left"
          }
        }
      }
    )
  end

  if props.padding then
    popup_options =
      vim.tbl_deep_extend(
      "force",
      popup_options,
      {
        border = {
          padding = props.padding
        }
      }
    )
  end

  self.__id = props.id
  self.__parent = parent
  self.__renderer = renderer
  self.__props = props
  self.__previous_props = props

  Component.super.init(self, popup_options)

  self:__set_initial_state()
  self:__set_label()
end

function Component:mount()
  local props = self:get_props()

  Component.super.mount(self)

  self:__attach_events()
  self:__attach_mappings()
  self:__set_initial_focus()

  self:redraw()

  vim.schedule(
    function()
      props.on_mount(self)
    end
  )
end

function Component:unmount()
  local props = self:get_props()

  Component.super.unmount(self)

  vim.schedule(
    function()
      props.on_unmount(self)
      vim.api.nvim_command("stopinsert")
    end
  )
end

function Component:__set_label()
  local props = self:get_props()

  if props.style and not (props.style == "none") then
    local label = vim.F.if_nil(props.label, "")
    local edge = "top"
    local align = "left"

    if type(props.label) == "table" then
      local icon = props.label.icon and " " .. props.label.icon or ""
      label = icon .. " " .. props.label.text .. " "

      edge = vim.F.if_nil(props.label.edge, edge)
      align = vim.F.if_nil(props.label.align, align)
    end

    self:set_border_text(edge, label, align)
  end
end

function Component:__set_initial_focus()
  if self:get_props().focus then
    self:focus()
  end
end

function Component:__attach_events()
  local renderer = self:get_renderer()
  local props = self:get_props()

  local default_events = {
    {
      event = event.BufEnter,
      callback = vim.schedule_wrap(
        function()
          self:call_if_mounted(
            function()
              self.__focused = true
              renderer:set_last_focused_component(self)
              props.on_focus(renderer.state, self)
            end
          )
        end
      )
    },
    {
      event = event.BufLeave,
      callback = vim.schedule_wrap(
        function()
          self:call_if_mounted(
            function()
              self.__focused = false
              renderer:set_last_focused_component(self)
              props.on_blur(renderer.state, self)
            end
          )
        end
      )
    }
  }

  local events = fn.concat(props.events(self), self:events(), default_events)

  fn.ieach(
    events,
    function(tbl)
      self:on(tbl.event, tbl.callback)
    end
  )
end

function Component:__attach_mappings()
  local props = self:get_props()
  local renderer = self:get_renderer()

  local default_mappings = {
    {
      mode = {"n"},
      from = "<leader>c",
      to = function()
        renderer.layout:unmount()
        renderer.on_close()
      end
    },
    {
      mode = {"n"},
      from = renderer.keymap.close,
      to = function()
        renderer.layout:unmount()
        renderer.on_close()
      end
    },
    {
      mode = {"i", "n"},
      from = renderer.keymap.submit,
      to = function()
        if renderer:validate() then
          renderer.layout:unmount()
          renderer.on_submit(renderer.state)
        end
      end
    },
    {
      mode = {"i", "n"},
      from = "<Tab>",
      to = function()
        local index = self:get_focus_index()
        local next = renderer.focusable_components[index + 1] or renderer.focusable_components[1]

        vim.api.nvim_set_current_win(next.winid)
      end
    },
    {
      mode = {"i", "n"},
      from = "<S-Tab>",
      to = function()
        local index = self:get_focus_index()
        local prev =
          renderer.focusable_components[index - 1] or renderer.focusable_components[#renderer.focusable_components]

        vim.api.nvim_set_current_win(prev.winid)
      end
    }
  }

  local mappings = fn.concat(props.mappings(self), self:mappings(), default_mappings)

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

function Component:set_border_text(edge, text, align)
  self.border:set_text(edge, text, align)
end

function Component:focus()
  if vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_set_current_win(self.winid)
  end
end

function Component:make_highlight_group_name(name)
  return "NuiComponents" .. self.class.name .. name
end

function Component:get_renderer()
  return self.__renderer
end

function Component:get_props()
  return self.__props
end

function Component:get_previous_props()
  return self.__previous_props
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
  local id = self:get_id()

  if id then
    self:get_renderer():set_state(id, value)
  end
end

function Component:get_state()
  return self:get_renderer().state[self:get_id()]
end

function Component:validate()
  return self:get_props().validate(self:get_state())
end

function Component:is_hidden()
  local parent = self:get_parent()
  local props = self:get_props()

  if parent then
    return props.hidden or parent:is_hidden()
  end

  return props.hidden
end

function Component:is_focused()
  return self.__focused
end

function Component:is_focusable()
  return self:get_props().is_focusable
end

function Component:is_mounted()
  return self._.mounted
end

function Component:call_if_mounted(fn)
  if self:is_mounted() then
    fn()
  end
end

function Component:set_focus_index(index)
  self:update_props({focus_index = index})
end

function Component:get_focus_index()
  return self:get_props().focus_index
end

function Component:normalize_size_with_border(size)
  local parent = self:get_parent()

  if parent then
    local direction = parent:get_direction()
    local border_delta_size = direction == "row" and self.border._.size_delta.width or self.border._.size_delta.height

    return size + border_delta_size
  end

  return size
end

function Component:calculate_size_with()
  local props = self:get_props()
  local parent = self:get_parent()

  local parent_size = parent:get_size()
  local children = parent:get_children()
  local direction = parent:get_direction()

  if type(props.flex) == "number" then
    local total_content_size =
      fn.ireduce(
      children,
      function(acc, child)
        local cond = not (child:get_id() == self:get_id()) and not child:get_props().flex and not child:is_hidden()

        if cond then
          local size = child:get_size()
          return acc + (direction == "row" and size.width or size.height)
        end

        return acc
      end,
      0
    )

    local total_flex =
      fn.ireduce(
      children,
      function(acc, child)
        local props = child:get_props()

        if props.flex and not child:is_hidden() then
          return acc + props.flex
        end

        return acc
      end,
      0
    )

    local calculate = function(value)
      return (value - total_content_size) / total_flex * props.flex
    end

    local value =
      math.floor(math.max(0, calculate(direction == "row" and parent_size.width or parent_size.height)) + 0.5)

    return value
  end

  return self:normalize_size_with_border(props.size)
end

-- function Component:get_position()
--   local parent = self:get_parent()

--   local default_position = {
--     row = 0,
--     col = 0
--   }

--   if not parent then
--     return default_position
--   end

--   local children = parent:get_children()
--   local direction = parent:get_direction()
--   local parent_position = parent:get_position()

--   local border = self.border

--   local border_col = 0
--   local border_row = 0

--   if border and not (border._.type == "none") then
--     border_col = math.floor(border._.size_delta.width / 2 + 0.5)
--     border_row = math.floor(border._.size_delta.height / 2 + 0.5)
--   end

--   local position =
--     fn.ireduce(
--     children or {},
--     function(acc, child)
--       if acc.done then
--         return acc
--       end

--       if child:get_id() == self:get_id() then
--         acc.done = true
--         return acc
--       end

--       local size = child:get_size()

--       if direction == "column" then
--         acc.row = acc.row + size.height
--       else
--         acc.col = acc.col + size.width
--       end

--       return acc
--     end,
--     {
--       row = parent_position.row,
--       col = parent_position.col,
--       done = false
--     }
--   )

--   return {
--     row = position.row + border_row,
--     col = position.col + border_col
--   }
-- end

-- function Component:update_layout(config)
--   config = config or {}
--   config.position = self:get_position()

--   Component.super.update_layout(self, config)
-- end

function Component:get_id()
  return self.__id
end

function Component:get_size(index)
  local renderer = self:get_renderer()
  local parent = self:get_parent()

  if not parent then
    return {
      width = renderer.width,
      height = renderer.height
    }
  end

  local direction = parent:get_direction()
  local parent_size = parent:get_size()
  local is_hidden = self:is_hidden()
  local size = is_hidden and 0 or self:calculate_size_with()

  if direction == "column" then
    return {
      width = parent_size.width,
      height = size
    }
  end

  return {
    width = size,
    height = parent_size.height
  }
end

function Component:get_direction()
  return self:get_props().direction
end

function Component:update_props(tbl)
  self.__previous_props = vim.deepcopy(self:get_props())
  self.__props = vim.tbl_extend("force", self.__props, tbl)
end

function Component:compare_props()
  return vim.deep_equal(self.__previous_props, self.__props)
end

function Component:get_children()
  return self.__children
end

function Component:get_only_child()
  return self:get_children()[1]
end

function Component:get_parent()
  return self.__parent
end

function Component:on_layout_change(state)
  local props = self:get_props()
  local new_props = props.on_state_change(state)

  if new_props then
    if type(new_props.hidden) == "boolean" then
      self:update_props({hidden = new_props.hidden})
      return new_props.hidden
    end
  end

  return props.hidden
end

function Component:on_state_change(state)
  local props = self:get_props()
  local new_props = props.on_state_change(state)

  if new_props then
    self:update_props(new_props)

    if self:is_mounted() and not self:compare_props() then
      local mode = vim.fn.mode()
      local current_winid = vim.api.nvim_get_current_win()
      local cond = current_winid == self.winid and mode == "i"

      if cond then
        vim.api.nvim_command("stopinsert")
      end

      self:redraw()

      vim.schedule(
        function()
          if cond then
            vim.api.nvim_command("startinsert!")
          end
        end
      )
    end
  end
end

function Component:set_children(children)
  self.__children = children
end

function Component:render()
  local props = self:get_props()
  local children = self:get_children()

  if children then
    return Layout.Box(
      fn.ireduce(
        children,
        function(acc, child)
          if not child:is_hidden() then
            table.insert(acc, child:render())
          end

          return acc
        end,
        {}
      ),
      {
        size = self:get_size(),
        dir = self:get_direction()
      }
    )
  end

  return Layout.Box(self, {size = self:get_size()})
end

function Component:redraw()
end

return Component
