local M = {}

M.actions = {
  {
    name = "definitions",
    keymap = "<D-d>",
    handler = function()
      vim.cmd("Glance definitions")
    end,
  },
  {
    name = "implementations",
    keymap = "<D-i>",
    handler = function()
      vim.cmd("Glance implementations")
    end,
  },
  {
    name = "type definitions",
    keymap = "<D-t>",
    handler = function()
      vim.cmd("Glance type_definitions")
    end,
  },
  {
    name = "references",
    keymap = "<D-r>",
    handler = function()
      vim.cmd("Glance references")
    end,
  },
}

M.options = {
  prompt_title = function()
    return "LSP / Glance"
  end,
  theme = require("telescope.themes").get_cursor({
    layout_config = {
      height = 0.2,
    },
  }),
}

return M
