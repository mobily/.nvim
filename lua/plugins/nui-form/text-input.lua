local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local utils = require("plugins.nui-form.utils")

local TextInput = Input:extend("TextInput")

function TextInput:init(options, form)
  local popup_options = {
    enter = false,
    focusable = true,
    size = {
      width = form.width
    },
    win_options = {
      winblend = 0
    },
    zindex = 100,
    border = {
      style = options.style,
      text = {
        top = options.label,
        top_align = options.label_align
      }
    }
  }

  TextInput.super.init(
    self,
    popup_options,
    {
      on_change = function(value)
        form:set_state(options.key, value)
      end
    }
  )

  self.instance = {
    form = form,
    options = options
  }

  self._.win_enter = false
  self._.win_options.winblend = 0

  -- add support for default value
  self:set_state("")

  utils.keymap(self.bufnr, {"i", "n"}, "<CR>", "<Nop>")
  utils.attach_prev_next_focus(self)
  utils.attach_form_events(self)

  self:on(
    event.BufEnter,
    vim.schedule_wrap(
      function()
        vim.api.nvim_command("startinsert!")
      end
    )
  )
end

function TextInput:mount()
  TextInput.super.mount(self)
  utils.set_initial_focus(self)
end

function TextInput:set_state(value)
  self.instance.form:set_state(self.instance.options.key, value)
end

function TextInput:get_state()
  return self.instance.form.state[self.instance.options.key]
end

function TextInput:validate()
  return self.instance.options.validate(self:get_state())
end

return TextInput
