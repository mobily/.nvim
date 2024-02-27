local Layout = require("nui.layout")

local TextInput = require("plugins.nui-form.text-input")
local Select = require("plugins.nui-form.select")
local Footer = require("plugins.nui-form.footer")

local fn = require("utils.fn")
local validators = require("plugins.nui-form.validators")

local NuiForm = {}

local set_default_options = function(options)
  return vim.tbl_extend(
    "force",
    {
      height = 3,
      is_focusable = true,
      validate = fn.always(true),
      hidden = fn.always(false)
    },
    vim.F.if_nil(options, {})
  )
end

function NuiForm:new(options)
  options = options or {}
  self.__index = self

  options.width = vim.F.if_nil(options.width, 80)

  options.default_options = {
    label_align = vim.F.if_nil(options.label_align, "left"),
    style = vim.F.if_nil(options.style, "rounded")
  }

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

  return setmetatable(options, self)
end

function NuiForm.text_input(options)
  return {
    type = "text_input",
    options = set_default_options(options)
  }
end

function NuiForm.select(options)
  return {
    type = "select",
    options = set_default_options(options)
  }
end

function NuiForm.footer(options)
  return {
    type = "footer",
    options = set_default_options(options)
  }
end

NuiForm.validator = validators

function NuiForm:set_content(...)
  self:__set_components({...})
end

function NuiForm:open()
  self:__determine_focusable_components()
  self:__set_layout()
  self:__set_trigger_values_for_reload()

  vim.schedule(
    function()
      self.layout:mount()
    end
  )
end

function NuiForm:set_state(key, value)
  self.state[key] = value

  if self.layout then
    self:__set_trigger_values_for_reload()

    if self.layout._.mounted and not vim.deep_equal(self.__last_trigger_values, self.__trigger_values) then
      self:reload()
    end

    self.__last_trigger_values = self.__trigger_values
  end
end

function NuiForm:validate()
  for index, component in ipairs(self.components) do
    if not component:is_hidden() and not component:validate() then
      return false
    end
  end

  return true
end

function NuiForm:reload()
  self:__determine_focusable_components()
  self:__calculate_total_height()

  self.layout:update(
    {
      position = self.position,
      relative = self.relative,
      size = {
        width = self.width,
        height = self.total_height
      }
    },
    self:__get_layout_box()
  )
end

function NuiForm:__set_trigger_values_for_reload()
  self.__trigger_values =
    fn.imap(
    self.components,
    function(component)
      return {component:is_hidden()}
    end
  )

  if not self.__last_trigger_values then
    self.__last_trigger_values = self.__trigger_values
  end
end

function NuiForm:__calculate_total_height()
  self.total_height =
    fn.ireduce(
    self.components,
    function(acc, component)
      return acc + component:get_height()
    end,
    0
  )
end

function NuiForm:__get_layout_box()
  local components =
    fn.ireduce(
    self.components,
    function(acc, component)
      if not component:is_hidden() then
        local size = math.ceil(component:get_height() / self.total_height * 100) .. "%"
        table.insert(acc, Layout.Box(component, {size = size}))
      end

      return acc
    end,
    {}
  )

  return Layout.Box(components, {dir = "col"})
end

function NuiForm:__set_layout()
  self:__calculate_total_height()

  self.layout =
    Layout(
    {
      position = self.position,
      relative = self.relative,
      size = {
        width = self.width,
        height = self.total_height
      }
    },
    self:__get_layout_box()
  )
end

function NuiForm:__determine_focusable_components()
  self.focusable_components =
    fn.ifilter(
    self.components,
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

function NuiForm:__set_components(content)
  self.components =
    fn.ireduce(
    content,
    function(acc, item, index)
      local options = vim.tbl_deep_extend("force", self.default_options, item.options)

      local component =
        fn.switch(
        item.type,
        {
          ["select"] = function()
            return Select(options, self)
          end,
          ["text_input"] = function()
            return TextInput(options, self)
          end,
          ["footer"] = function()
            return Footer(options, self)
          end
        }
      )

      if component then
        table.insert(acc, component)
      end

      return acc
    end,
    {}
  )
end

return NuiForm
