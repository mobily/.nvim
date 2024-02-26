local Component = require("plugins.nui-form.component")

local event = require("nui.utils.autocmd").event
local utils = require("plugins.nui-form.utils")
local fn = require("utils.fn")

local TextInput = Component:extend("TextInput")

function TextInput:init(options, form)
  TextInput.super.init(
    self,
    form,
    vim.tbl_extend(
      "force",
      options,
      {
        default_value = vim.F.if_nil(options.default_value, "")
      }
    ),
    {
      border = {
        style = options.style,
        text = {
          top = options.label,
          top_align = options.label_align
        }
      },
      buf_options = {
        filetype = options.filetype or ""
      }
    }
  )

  self:set_state(fn.trim(self:get_options().default_value))

  utils.keymap(self.bufnr, {"i", "n"}, "<CR>", "\n")

  self:on(
    event.BufEnter,
    vim.schedule_wrap(
      function()
        local has_cmp, cmp = pcall(require, "cmp")

        vim.api.nvim_command("startinsert!")

        if has_cmp then
          cmp.setup.buffer({enabled = false})
        end
      end
    )
  )
end

function TextInput:mount()
  TextInput.super.mount(self)

  vim.api.nvim_buf_attach(
    self.bufnr,
    false,
    {
      on_lines = function()
        local value = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        self:set_state(fn.trim(table.concat(value, "\n")))
      end
    }
  )

  local default_value = self:get_options().default_value

  if #default_value > 0 then
    -- local lines = vim.split(default_value, "\n")
    -- vim.api.nvim_buf_set_lines(self.bufnr, 0, #lines, false, lines)
    vim.api.nvim_buf_set_text(self.bufnr, 0, 0, 0, 0, vim.split(default_value, "\n"))
  end
end

return TextInput
