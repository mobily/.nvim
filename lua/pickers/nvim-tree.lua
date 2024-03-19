local M = {}

local fn = require("utils.fn")
local utils = require("utils")

local make_finder = function(directory)
  local root = vim.loop.cwd()
  local searchDirectory = directory or root
  local rootRelativeCwd = root == searchDirectory and "/" or string.gsub(searchDirectory, root, "")
  local options = {
    cwd = searchDirectory,
    prompt_title = "Search in " .. rootRelativeCwd,
  }

  require("telescope.builtin").live_grep(options)
end

local schedule = function(fn)
  return function(args)
    utils.schedule(function()
      fn(args)
    end)
  end
end

local search_in_node = function(node)
  if not node.absolute_path then
    return make_finder()
  end

  if node.fs_stat.type == "directory" then
    return make_finder(node.absolute_path)
  end

  if node.fs_stat.type == "file" then
    require("nvim-tree.actions.node.open-file").fn("edit", node.absolute_path)
    return require("telescope.builtin").current_buffer_fuzzy_find()
  end
end

-- { key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
-- { key = "<C-e>",                          action = "edit_in_place" },
-- { key = "O",                              action = "edit_no_picker" },
-- { key = { "<C-]>", "<2-RightMouse>" },    action = "cd" },
-- { key = "<C-v>",                          action = "vsplit" },
-- { key = "<C-x>",                          action = "split" },
-- { key = "<C-t>",                          action = "tabnew" },
-- { key = "<",                              action = "prev_sibling" },
-- { key = ">",                              action = "next_sibling" },
-- { key = "P",                              action = "parent_node" },
-- { key = "<BS>",                           action = "close_node" },
-- { key = "<Tab>",                          action = "preview" },
-- { key = "K",                              action = "first_sibling" },
-- { key = "J",                              action = "last_sibling" },
-- { key = "C",                              action = "toggle_git_clean" },
-- { key = "I",                              action = "toggle_git_ignored" },
-- { key = "H",                              action = "toggle_dotfiles" },
-- { key = "B",                              action = "toggle_no_buffer" },
-- { key = "U",                              action = "toggle_custom" },
-- { key = "R",                              action = "refresh" },
-- { key = "a",                              action = "create" },
-- { key = "d",                              action = "remove" },
-- { key = "D",                              action = "trash" },
-- { key = "r",                              action = "rename" },
-- { key = "<C-r>",                          action = "full_rename" },
-- { key = "e",                              action = "rename_basename" },
-- { key = "x",                              action = "cut" },
-- { key = "c",                              action = "copy" },
-- { key = "p",                              action = "paste" },
-- { key = "y",                              action = "copy_name" },
-- { key = "Y",                              action = "copy_path" },
-- { key = "gy",                             action = "copy_absolute_path" },
-- { key = "[e",                             action = "prev_diag_item" },
-- { key = "[c",                             action = "prev_git_item" },
-- { key = "]e",                             action = "next_diag_item" },
-- { key = "]c",                             action = "next_git_item" },
-- { key = "-",                              action = "dir_up" },
-- { key = "s",                              action = "system_open" },
-- { key = "f",                              action = "live_filter" },
-- { key = "F",                              action = "clear_live_filter" },
-- { key = "q",                              action = "close" },
-- { key = "W",                              action = "collapse_all" },
-- { key = "E",                              action = "expand_all" },
-- { key = "S",                              action = "search_node" },
-- { key = ".",                              action = "run_file_command" },
-- { key = "g?",                             action = "toggle_help" },
-- { key = "m",                              action = "toggle_mark" },
-- { key = "bmv",                            action = "bulk_move" },

M.actions = {
  {
    name = "search node contents",
    keymap = "<D-f>",
    plugin_keymap = "<D-f>",
    handler = require("nvim-tree.utils").inject_node(search_in_node),
  },
  -- {
  --   name = "Search node",
  --   keymap = keymaps["project.tree.search.node"],
  --   handler = require("nvim-tree.api").tree.search_node
  -- },
  {
    name = "edit in vertical split",
    keymap = "<D-e>",
    -- plugin_keymap = "<D-CR>",
    handler = require("nvim-tree.api").node.open.vertical,
  },
  {
    name = "edit in horizontal split",
    keymap = "<D-l>",
    -- plugin_keymap = "<C-CR>",
    handler = require("nvim-tree.api").node.open.horizontal,
  },
  {
    name = "edit in tab",
    keymap = "<D-t>",
    handler = require("nvim-tree.api").node.open.tab,
  },
  {
    name = "open with the system app",
    keymap = "<C-o>",
    handler = require("nvim-tree.api").node.run.system,
  },
  {
    name = "add a new node",
    keymap = "<D-a>",
    -- plugin_keymap = "a",
    handler = schedule(require("nvim-tree.api").fs.create),
  },
  {
    name = "delete node",
    keymap = "<D-d>",
    -- plugin_keymap = "d",
    handler = schedule(require("nvim-tree.api").fs.remove),
  },
  {
    name = "trash node",
    keymap = "<C-d>",
    -- plugin_keymap = "D",
    handler = schedule(require("nvim-tree.api").fs.trash),
  },
  {
    name = "rename node",
    keymap = "<D-r>",
    -- plugin_keymap = "r",
    handler = schedule(require("nvim-tree.api").fs.rename),
  },
  {
    name = "fully rename node",
    keymap = "<C-r>",
    -- plugin_keymap = "R",
    handler = require("nvim-tree.api").fs.rename_sub,
  },
  {
    name = "copy",
    keymap = "<D-c>",
    -- plugin_keymap = "c",
    handler = require("nvim-tree.api").fs.copy.node,
  },
  {
    name = "cut",
    keymap = "<D-x>",
    -- plugin_keymap = "x",
    handler = require("nvim-tree.api").fs.cut,
  },
  {
    name = "paste",
    keymap = "<D-v>",
    -- plugin_keymap = "p",
    handler = require("nvim-tree.api").fs.paste,
  },
  {
    name = "copy node name",
    keymap = "<leader>y",
    -- plugin_keymap = "y",
    handler = require("nvim-tree.api").fs.copy.filename,
  },
  {
    name = "copy relative path",
    keymap = "<leader>gg",
    -- plugin_keymap = "gg",
    handler = require("nvim-tree.api").fs.copy.relative_path,
  },
  {
    name = "copy absolute path",
    keymap = "<leader>gy",
    -- plugin_keymap = "gy",
    handler = require("nvim-tree.api").fs.copy.absolute_path,
  },
  {
    name = "refresh",
    keymap = "<leader>r",
    -- plugin_keymap = "R",
    handler = require("nvim-tree.api").tree.reload,
  },
  {
    name = "collapse all nodes",
    keymap = "<leader>w",
    -- plugin_keymap = "W",
    handler = require("nvim-tree.api").tree.collapse_all,
  },
  {
    name = "expand all nodes",
    keymap = "<leader>e",
    plugin_keymap = "E",
    handler = require("nvim-tree.api").tree.expand_all,
  },
  {
    name = "close node",
    keymap = "<D-BS>",
    -- plugin_keymap = "<BS>",
    handler = require("nvim-tree.api").node.navigate.parent_close,
  },
  {
    name = "open node",
    keymap = "<D-o>",
    -- plugin_keymap = "<CR>",
    handler = require("nvim-tree.api").node.open.edit,
  },
  {
    name = "change directory here",
    keymap = "<D-]>",
    handler = require("nvim-tree.api").tree.change_root_to_node,
  },
  -- {
  --   name = "go to node parent",
  --   keymap = keymaps["project.tree.navigate.parent"],
  --   handler = require("nvim-tree.api").node.navigate.parent
  -- },
  -- {
  --   name = "go to first sibling",
  --   keymap = keymaps["project.tree.navigate.sibling.first"],
  --   handler = require("nvim-tree.api").node.navigate.sibling.first
  -- },
  -- {
  --   name = "go to last sibling",
  --   keymap = keymaps["project.tree.navigate.sibling.last"],
  --   handler = require("nvim-tree.api").node.navigate.sibling.last
  -- },
  {
    name = "toggle help",
    keymap = "<leader>?",
    -- plugin_keymap = "g?",
    handler = require("nvim-tree.api").tree.toggle_help,
  },
  -- {
  --   name = "Change root up one directory",
  --   keymap = keymaps["project.tree.root.parent"],
  --   handler = require("nvim-tree.api").tree.change_root_to_parent
  -- },
  {
    name = "toggle custom filter",
    keymap = "<leader>u",
    -- plugin_keymap = "U",
    handler = require("nvim-tree.api").tree.toggle_custom_filter,
  },
  {
    name = "toggle gitignore filter",
    keymap = "<leader>i",
    -- plugin_keymap = "I",
    handler = require("nvim-tree.api").tree.toggle_gitignore_filter,
  },
  {
    name = "toggle dotfiles filter",
    keymap = "<leader>h",
    -- plugin_keymap = "H",
    handler = require("nvim-tree.api").tree.toggle_hidden_filter,
  },
  {
    name = "view info",
    keymap = "<D-i>",
    handler = require("nvim-tree.api").node.show_info_popup,
  },
  {
    name = "close",
    keymap = "<D-w>",
    handler = require("nvim-tree.api").tree.close,
  },
}

M.options = {
  prompt_title = function(node)
    return node.name
  end,
  inject = function(inject_fn)
    return inject_fn(require("nvim-tree.lib").get_node_at_cursor())
  end,
  theme = require("telescope.themes").get_cursor({
    layout_config = {
      height = 0.3,
    },
  }),
}

return M
