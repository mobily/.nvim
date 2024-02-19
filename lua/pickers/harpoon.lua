local harpoon = require("harpoon")
local conf = require("telescope.config").values

local toggle_telescope = function(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers").new(
    {},
    {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table(
        {
          results = file_paths
        }
      ),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({})
    }
  ):find()
end

local M = {}

M.toggle = toggle_telescope

M.actions = {
  {
    name = "list",
    keymap = "l",
    handler = function()
      toggle_telescope(harpoon:list())
    end
  },
  {
    name = "append",
    keymap = "a",
    handler = function()
      harpoon:list():append()
    end
  },
  {
    name = "prepend",
    keymap = "p",
    handler = function()
      harpoon:list():prepend()
    end
  },
  {
    name = "remove",
    keymap = "p",
    handler = function()
      harpoon:list():remove()
    end
  }
}

M.options = {
  prompt_title = function()
    return "Harpoon"
  end,
  theme = require("telescope.themes").get_dropdown(
    {
      layout_config = {
        height = 0.2
      }
    }
  )
}

return M
