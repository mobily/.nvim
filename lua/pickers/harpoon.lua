local harpoon = require("harpoon")
local conf = require("telescope.config").values
local M = {}

M.toggle_telescope = function(harpoon_files)
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

return M
