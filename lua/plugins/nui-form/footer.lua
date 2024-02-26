local Popup = require("nui.popup")
local Line = require("nui.line")
local Text = require("nui.text")

local utils = require("plugins.nui-form.utils")
local to_macos_keys = require("utils").to_macos_keys

local Footer = Popup:extend("Footer")

function Footer:init(options, form)
  local popup_options = {
    enter = false,
    focusable = true,
    size = {
      width = form.width
    },
    win_options = {
      winblend = 0
    }
  }

  self.instance = {
    form = form,
    options = options
  }

  Footer.super.init(self, popup_options)

  utils.attach_prev_next_focus(self)
end

function Footer:mount()
  Footer.super.mount(self)

  local form = self.instance.form
  local line = Line()
  local submit_key = to_macos_keys(form.keymap.submit)
  local close_key = to_macos_keys(form.keymap.close)

  line:append("(" .. submit_key .. ") Confirm", "NuiFooterConfirmButton")
  line:append(" ")
  line:append("(" .. close_key .. ") Cancel", "NuiFooterCancelButton")

  table.insert(line._texts, 1, Text((" "):rep(form.width - line:width())))

  local pad_left = line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})

  utils.set_initial_focus(self)
end

function Footer:get_state()
  return nil
end

function Footer:validate()
  return true
end

return Footer
