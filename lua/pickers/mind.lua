local M = {}

local utils = require("utils")

local commands = require("mind.commands").commands

local schedule = function(fn)
  return function(args)
    utils.schedule(function()
      fn(args)
    end)
  end
end

M.actions = {
  {
    name = "open",
    keymap = "<D-o>",
    handler = commands.open_data,
  },
  {
    name = "add a new node above",
    handler = schedule(commands.add_above),
  },
  {
    name = "add a new node below",
    handler = schedule(commands.add_below),
  },
  {
    name = "add a new node inside at the beginning",
    keymap = "<D-i>",
    handler = schedule(commands.add_inside_start),
  },
  {
    name = "add a new node inside at the end",
    keymap = "<D-a>",
    handler = schedule(commands.add_inside_end),
  },
  {
    name = "delete node",
    handler = schedule(commands.delete),
  },
  {
    name = "delete file",
    handler = schedule(commands.delete_file),
  },
  {
    name = "delete node and file",
    handler = schedule(function(args)
      local mind_ui = require("mind.ui")
      local mind_node = require("mind.node")
      local mind_data = require("mind.data")
      local tree = args.get_tree()
      local save_tree = args.save_tree
      local opts = args.opts

      local parent, node = mind_node.get_node_and_parent_by_line(tree, args.current_line)

      mind_ui.with_confirmation(string.format("Delete '%s'?", node.contents[1].text), function()
        local index = mind_node.find_parent_index(parent, node)

        local file_path = args.current_node.data
        mind_data.delete_data_file(file_path)

        args.current_node.data = nil

        mind_node.delete_node(parent, index)
        mind_ui.rerender(tree, opts)
        save_tree()
      end)
    end),
  },
  {
    name = "rename",
    keymap = "<D-r>",
    handler = schedule(commands.rename),
  },
  {
    name = "copy link",
    keymap = "<D-c>",
    handler = commands.copy_node_link,
  },
  {
    name = "make url (turn node into a URL node)",
    handler = schedule(commands.make_url),
  },
  {
    name = "change icon",
    handler = schedule(commands.change_icon_menu),
  },
  {
    name = "select",
    handler = commands.select,
  },
  {
    name = "move selected node above",
    handler = commands.move_above,
  },
  {
    name = "move selected node below",
    handler = commands.move_below,
  },
  {
    name = "move selected node inside at the beginning",
    handler = schedule(commands.move_inside_start),
  },
  {
    name = "move selected node inside at the end",
    handler = schedule(commands.move_inside_end),
  },
  -- {
  --   name = "toggle node",
  --   handler = commands.toggle_node
  -- },
  -- {
  --   name = "toggle node's parent (if any)",
  --   handler = commands.toggle_parent
  -- }
}

M.options = {
  prompt_title = function(args)
    local current_node = args.current_node.contents[1]

    if current_node then
      return "Note: " .. current_node.text
    end

    return "Mind"
  end,
  inject = function(fn)
    local line, _ = fn.unpack(vim.api.nvim_win_get_cursor(0))
    local mind = require("mind")
    local mind_node = require("mind.node")

    local current_line = line - 1

    return mind.wrap_project_tree_fn(function(args)
      return fn(vim.tbl_extend("force", args, {
        current_node = mind_node.get_node_by_line(args.get_tree(), current_line),
        current_line = current_line,
      }))
    end)
  end,
  theme = require("telescope.themes").get_cursor({
    layout_config = {
      height = 0.2,
    },
  }),
}

return M
