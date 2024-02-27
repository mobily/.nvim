local Component = require("plugins.nui-form.component")

local Line = require("nui.line")
local Text = require("nui.text")

local to_macos_keys = require("utils").to_macos_keys

local Footer = Component:extend("Footer")

function Footer:init(props, form)
  Footer.super.init(self, form, vim.tbl_extend("force", props, {is_focusable = false}))
end

function Footer:mount()
  Footer.super.mount(self)

  local form = self:get_form()

  local line = Line()

  local submit_key = to_macos_keys(form.keymap.submit)
  local close_key = to_macos_keys(form.keymap.close)

  line:append("(" .. submit_key .. ") Confirm", "NuiFooterConfirmButton")
  line:append(" ")
  line:append("(" .. close_key .. ") Cancel", "NuiFooterCancelButton")

  table.insert(line._texts, 1, Text((" "):rep(form.width - line:width())))

  local pad_left = line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})
end

function Footer:validate()
  return true
end

function Footer:disable_label()
  return true
end

return Footer
