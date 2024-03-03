local Layout = require("nui.layout")

local TextInput = require("plugins.nui-components.text-input")
local Select = require("plugins.nui-components.select")
local Button = require("plugins.nui-components.button")
local Columns = require("plugins.nui-components.columns")
local Rows = require("plugins.nui-components.rows")
local Box = require("plugins.nui-components.box")
local Gap = require("plugins.nui-components.gap")
local Checkbox = require("plugins.nui-components.checkbox")
local Tree = require("plugins.nui-components.tree")
local Text = require("plugins.nui-components.text")

local fn = require("utils.fn")
local validators = require("plugins.nui-components.validators")

local Renderer = {}

local normalize_layout_component = function(constructor, props, ...)
  local children = {...}

  if not props.size and not props.flex then
    table.insert(children, 1, props)

    return {
      constructor = constructor,
      props = {flex = 1},
      children = children
    }
  end

  if type(props) == "number" then
    return {
      constructor = constructor,
      props = {flex = props},
      children = children
    }
  end

  return {
    constructor = constructor,
    props = props,
    children = children
  }
end

function Renderer:new(options)
  options = options or {}
  self.__index = self

  options.width = vim.F.if_nil(options.width, 80)

  options.keymap =
    vim.tbl_extend(
    "force",
    {
      submit = "<D-CR>",
      close = "<Esc>"
    },
    vim.F.if_nil(options.keymap, {})
  )

  options.position = vim.F.if_nil(options.position, "50%")
  options.relative = vim.F.if_nil(options.relative, "editor")
  options.on_submit = vim.F.if_nil(options.on_submit, fn.ignore)
  options.on_close = vim.F.if_nil(options.on_close, fn.ignore)

  self.focusable_components = {}
  self.state = {}

  self.__origin_winid = vim.api.nvim_get_current_win()

  return setmetatable(options, self)
end

function Renderer.text_input(props)
  return {
    constructor = TextInput,
    props = props
  }
end

function Renderer.select(props)
  return {
    constructor = Select,
    props = props
  }
end

function Renderer.tree(props)
  return {
    constructor = Tree,
    props = props
  }
end

Renderer.option = Select.option
Renderer.separator = Select.separator

function Renderer.button(props)
  return {
    constructor = Button,
    props = props
  }
end

function Renderer.checkbox(props)
  return {
    constructor = Checkbox,
    props = props
  }
end

function Renderer.text(props)
  return {
    constructor = Text,
    props = props
  }
end

function Renderer.gap(props)
  if type(props) == "number" then
    props = {size = props}
  end

  return {
    constructor = Gap,
    props = props
  }
end

function Renderer.box(props, ...)
  return normalize_layout_component(Box, props, ...)
end

function Renderer.columns(props, ...)
  return normalize_layout_component(Columns, props, ...)
end

function Renderer.rows(props, ...)
  return normalize_layout_component(Rows, props, ...)
end

Renderer.validator = validators

function Renderer:render(content)
  self:__set_components_tree({content})
  self:__flatten_components_tree()
  self:__determine_redraw_need()
  self:__determine_focusable_components()
  self:__set_layout()

  vim.schedule(
    function()
      self.layout:mount()
    end
  )
end

function Renderer:set_state(key, value)
  self.state[key] = value
  self:__redraw_on_layout_changes()
  self:__listen_on_state_changes()
end

function Renderer:validate()
  -- TODO: recursive
  -- for index, component in ipairs(self.components) do
  --   if not component:is_hidden() and not component:validate() then
  --     return false
  --   end
  -- end

  return true
end

function Renderer:redraw()
  vim.schedule(
    function()
      self:__determine_focusable_components()
      self.layout:update(self:__get_layout_options(), self:__get_layout_box())
    end
  )
end

function Renderer:get_component_by_id(id)
  return fn.ifind(
    self.flatten_tree,
    function(component)
      return component:get_id() == id
    end
  )
end

function Renderer:get_origin_winid()
  return self.__origin_winid
end

function Renderer:__get_layout_options()
  return {
    position = self.position,
    relative = self.relative,
    size = {
      width = self.width,
      height = self.height
    }
  }
end

function Renderer:__get_layout_box()
  local components =
    fn.ireduce(
    self.tree,
    function(acc, component)
      if not component:is_hidden() then
        table.insert(acc, component:render())
      end

      return acc
    end,
    {}
  )

  return Layout.Box(components, {dir = "col"})
end

function Renderer:__set_layout()
  self.layout = Layout(self:__get_layout_options(), self:__get_layout_box())
end

function Renderer:__listen_on_state_changes()
  if self.layout then
    fn.ieach(
      self.flatten_tree,
      function(component)
        component:on_state_change(self.state)
      end
    )
  end
end

function Renderer:__redraw_on_layout_changes()
  if self.layout then
    local trigger_values = self:__determine_redraw_need()

    if self.layout._.mounted then
      if not vim.deep_equal(self.__last_trigger_values, trigger_values) then
        self:redraw()
      end
    end

    self.__last_trigger_values = trigger_values
  end
end

function Renderer:__determine_redraw_need()
  local trigger_values =
    fn.imap(
    self.flatten_tree,
    function(component)
      return component:on_layout_change(self.state)
    end
  )

  if not self.__last_trigger_values then
    self.__last_trigger_values = trigger_values
  end

  return trigger_values
end

function Renderer:__determine_focusable_components()
  self.focusable_components =
    fn.ifilter(
    self.flatten_tree,
    function(component)
      return component:is_focusable() and not component:is_hidden()
    end
  )

  fn.ieach(
    self.focusable_components,
    function(component, index)
      component:set_focus_index(index)
    end
  )
end

function Renderer:__set_components_tree(root)
  local function rec(content, parent)
    return fn.ireduce(
      content,
      function(acc, element, index)
        if not element.constructor then
          return acc
        end

        local component = element.constructor(element.props, parent, self)

        if element.children then
          component:set_children(rec(element.children, component))
        end

        table.insert(acc, component)

        return acc
      end,
      {}
    )
  end

  self.tree = rec(root)
end

function Renderer:set_last_focused_component(component)
  self.__last_focused_component = component
end

function Renderer:get_last_focused_component()
  return self.__last_focused_component
end

function Renderer:focus()
  if self.layout then
    local last_focused_component = self:get_last_focused_component()

    if last_focused_component then
      last_focused_component:focus()
    else
      local first_focusable_component =
        fn.ifind(
        self.flatten_tree,
        function(component)
          return component:get_props().focus
        end
      )

      if first_focusable_component then
        first_focusable_component:focus()
      end
    end
  end
end

function Renderer:__flatten_components_tree()
  local function rec(components, initial_value)
    return fn.ireduce(
      components,
      function(acc, component)
        local children = component:get_children()

        if children then
          rec(children, acc)
        end

        table.insert(acc, component)

        return acc
      end,
      initial_value
    )
  end

  self.flatten_tree = rec(self.tree, {})
end

return Renderer
