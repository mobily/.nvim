local Layout = require("nui.layout")

local TextInput = require("plugins.nui-form.text-input")
local Select = require("plugins.nui-form.select")
local Footer = require("plugins.nui-form.footer")

local fn = require("utils.fn")
local utils = require("plugins.nui-form.utils")
local validators = require("plugins.nui-form.validators")

local NuiForm = {}

function NuiForm:new(options)
  options = options or {}
  self.__index = self

  options.width = vim.F.if_nil(options.width, 80)

  options.default_options = {
    label_align = vim.F.if_nil(options.label_align, "left"),
    style = vim.F.if_nil(options.style, "rounded"),
    is_focusable = true,
    validate = vim.F.if_nil(
      options.validate,
      function()
        return true
      end
    )
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
  options.on_submit = vim.F.if_nil(options.on_submit, utils.ignore)
  options.on_close = vim.F.if_nil(options.on_close, utils.ignore)

  self.focusable_elements = {}
  self.state = {}

  return setmetatable(options, self)
end

function NuiForm.text_input(options)
  return {
    type = "text_input",
    options = utils.set_default_height(options)
  }
end

function NuiForm.select(options)
  return {
    type = "select",
    options = utils.set_default_height(options)
  }
end

function NuiForm.footer(options)
  return {
    type = "footer",
    options = utils.set_default_height(options)
  }
end

NuiForm.validator = validators

function NuiForm:set_content(...)
  self.content = {...}
end

function NuiForm:open()
  self.focusable_elements = {}
  self.all_elements = {}

  local total_height = self:__get_total_height(self.content)
  local elements = self:__get_layout(self.content)

  self.layout =
    Layout(
    {
      position = self.position,
      relative = self.relative,
      size = {
        width = self.width,
        height = total_height
      }
    },
    Layout.Box(elements, {dir = "col"})
  )

  vim.schedule(
    function()
      self.layout:mount()
    end
  )
end

function NuiForm:__set_default_height(options)
  return vim.tbl_extend("force", {height = 3}, vim.F.if_nil(options, {}))
end

function NuiForm:set_state(key, value)
  self.state[key] = value
end

function NuiForm:validate()
  for index, element in ipairs(self.all_elements) do
    if not element:validate() then
      return false
    end
  end

  return true
end

function NuiForm:__get_total_height(elements)
  return fn.ireduce(
    elements,
    function(acc, item)
      return acc + item.options.height
    end,
    0
  )
end

function NuiForm:__get_layout(elements)
  local total_height = self:__get_total_height(elements)

  local layout =
    fn.ireduce(
    elements,
    function(acc, item, index)
      local options = vim.tbl_deep_extend("force", self.default_options, item.options)
      local size = math.ceil(options.height / total_height * 100) .. "%"

      options.index = index

      local element =
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

      if element then
        if element.instance.options.is_focusable then
          table.insert(self.focusable_elements, element)
        end

        table.insert(self.all_elements, element)

        table.insert(acc, Layout.Box(element, {size = size}))
      end

      return acc
    end,
    {}
  )

  return layout
end

vim.api.nvim_create_user_command(
  "OpenNuiForm",
  function(opts)
    local form =
      NuiForm:new(
      {
        on_submit = function(state)
          vim.notify(vim.inspect(state))
        end
      }
    )

    form:set_content(
      form.text_input(
        {
          key = "backdate",
          label = " 󰃮 Backdate ",
          focus = true,
          validate = form.validator.compose(form.validator.min_length(3), form.validator.max_length(8))
        }
      ),
      form.text_input(
        {
          height = 5,
          key = "description",
          label = " 󰏫 Description "
        }
      ),
      form.select(
        {
          height = 8,
          key = "tags",
          label = " 󰓹 Tag ",
          data = {
            "Work",
            "Meetings",
            "Research",
            "Personal",
            "Reading",
            "Learning",
            "Other",
            "Break"
          }
        }
      ),
      form.footer({is_focusable = false})
    )

    form:open()
  end,
  {}
)

return NuiForm
