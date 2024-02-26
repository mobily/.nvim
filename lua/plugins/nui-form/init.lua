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
  options.on_submit = vim.F.if_nil(options.on_submit, utils.ignore)
  options.on_close = vim.F.if_nil(options.on_close, utils.ignore)

  self.focusable_components = {}
  self.state = {}

  return setmetatable(options, self)
end

function NuiForm.text_input(options)
  return {
    type = "text_input",
    options = utils.set_default_options(options)
  }
end

function NuiForm.select(options)
  return {
    type = "select",
    options = utils.set_default_options(options)
  }
end

function NuiForm.footer(options)
  return {
    type = "footer",
    options = utils.set_default_options(options)
  }
end

NuiForm.validator = validators

function NuiForm:set_content(...)
  self:__make_components({...})
end

function NuiForm:open()
  self:__make_focusable_components()
  self:__make_layout()

  vim.schedule(
    function()
      self.layout:mount()
    end
  )
end

function NuiForm:set_state(key, value)
  self.state[key] = value

  if not self.layout then
    return
  end

  if self.layout._.mounted then
    fn.ieach(
      self.components,
      function(component)
        vim.schedule(
          function()
            -- how to hide a window temporarily?
            component:on_state_change()
          end
        )
      end
    )
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

function NuiForm:__make_layout()
  local total_height =
    fn.ireduce(
    self.components,
    function(acc, component)
      return acc + component:get_height()
    end,
    0
  )

  local components =
    fn.ireduce(
    self.components,
    function(acc, component)
      if not component:is_hidden() then
        local size = math.ceil(component:get_height() / total_height * 100) .. "%"
        table.insert(acc, Layout.Box(component, {size = size}))
      end

      return acc
    end,
    {}
  )

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
    Layout.Box(components, {dir = "col"})
  )
end

function NuiForm:__make_focusable_components()
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

function NuiForm:__make_components(content)
  self.components =
    fn.ireduce(
    content,
    function(acc, item, index)
      local options = vim.tbl_deep_extend("force", self.default_options, item.options)
      -- local size = math.ceil(options.height / total_height * 100) .. "%"

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
      form.footer()
    )

    form:open()
  end,
  {}
)

return NuiForm
