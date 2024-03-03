local Component = require("plugins.nui-components.component")

local fn = require("utils.fn")
local event = require("nui.utils.autocmd").event

local TextInput = Component:extend("TextInput")

function TextInput:init(props, parent, renderer)
  props =
    vim.tbl_extend(
    "force",
    {
      size = 1,
      default_value = "",
      on_change = fn.ignore,
      on_focus = fn.ignore,
      on_blur = fn.ignore,
      label_align = "left",
      style = "rounded"
    },
    props
  )

  local popup_options = {
    buf_options = {
      filetype = props.filetype or ""
    },
    win_options = {
      wrap = props.wrap
    },
    border = {
      style = props.style
    }
  }

  TextInput.super.init(self, parent, renderer, props, popup_options)
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
  local props = self:get_props()

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
    },
    {
      event = event.BufLeave,
      callback = function()
        vim.api.nvim_command("stopinsert")
      end
    }
  }
end

function TextInput:mount()
  local props = self:get_props()
  local renderer = self:get_renderer()

  TextInput.super.mount(self)

  vim.api.nvim_buf_attach(
    self.bufnr,
    false,
    {
      on_lines = function()
        local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        local value = fn.trim(table.concat(lines, "\n"))

        self:set_state(value)
        props.on_change(value, renderer.state, self)
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
