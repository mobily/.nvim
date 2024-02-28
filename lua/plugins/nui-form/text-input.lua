local Component = require("plugins.nui-form.component")

local fn = require("utils.fn")
local event = require("nui.utils.autocmd").event

local TextInput = Component:extend("TextInput")

function TextInput:init(props, form)
  TextInput.super.init(
    self,
    form,
    vim.tbl_extend(
      "force",
      props,
      {
        default_value = vim.F.if_nil(props.default_value, "")
      }
    ),
    {
      buf_options = {
        filetype = props.filetype or ""
      },
      win_options = {
        wrap = props.wrap
      }
    }
  )
end

function TextInput:initial_state()
  return fn.trim(self:get_props().default_value)
end

function TextInput:mappings()
  return {
    {mode = {"i", "n"}, from = "<CR>", to = "\n"}
  }
end

function TextInput:events()
  return {
    {
      event = event.BufEnter,
      callback = vim.schedule_wrap(
        function()
          local has_cmp, cmp = pcall(require, "cmp")

          vim.api.nvim_command("startinsert!")

          if has_cmp then
            cmp.setup.buffer({enabled = false})
          end
        end
      )
    }
  }
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

  local default_value = self:get_props().default_value

  if #default_value > 0 then
    -- local lines = vim.split(default_value, "\n")
    -- vim.api.nvim_buf_set_lines(self.bufnr, 0, #lines, false, lines)
    vim.api.nvim_buf_set_text(self.bufnr, 0, 0, 0, 0, vim.split(default_value, "\n"))
  end
end

return TextInput
