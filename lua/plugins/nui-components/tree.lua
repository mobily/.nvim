local Component = require("plugins.nui-components.component")

local Line = require("nui.line")
local NuiTree = require("nui.tree")

local fn = require("utils.fn")

local function focus_item(instance, direction, current_linenr)
  local actions = instance:get_actions()
  local tree = instance:get_tree()

  local curr_linenr = current_linenr or vim.api.nvim_win_get_cursor(instance.winid)[1]
  local next_linenr = nil

  if direction == "next" then
    if curr_linenr == instance:get_max_lines() then
      next_linenr = 1
    else
      next_linenr = curr_linenr + 1
    end
  elseif direction == "prev" then
    if curr_linenr == 1 then
      next_linenr = instance:get_max_lines()
    else
      next_linenr = curr_linenr - 1
    end
  end

  local next_node = tree:get_node(next_linenr)

  if next_node then
    if actions.should_skip_item(next_node) then
      return focus_item(instance, direction, next_linenr)
    end
  end

  if next_linenr then
    vim.api.nvim_win_set_cursor(instance.winid, {next_linenr, 0})
    actions.on_change(next_node)
  end
end

local Tree = Component:extend("Tree")

function Tree:init(props, parent, renderer)
  props =
    vim.tbl_extend(
    "force",
    {
      size = 1,
      default_value = {},
      on_select = fn.ignore,
      on_change = fn.ignore,
      label_align = "left",
      style = "rounded",
      data = {}
    },
    props
  )

  local popup_options = {
    win_options = {
      cursorline = true,
      scrolloff = 1,
      sidescrolloff = 0
    },
    border = {
      style = props.style
    }
  }

  Tree.super.init(self, parent, renderer, props, popup_options)

  self:set_actions()
end

function Tree:mappings()
  local actions = self:get_actions()
  local mode = {"i", "n"}

  return {
    {mode = mode, from = "<CR>", to = actions.on_select},
    {mode = mode, from = "<Space>", to = actions.on_select},
    {mode = mode, from = "j", to = actions.on_focus_next},
    {mode = mode, from = "<Down>", to = actions.on_focus_next},
    {mode = mode, from = "<k>", to = actions.on_focus_prev},
    {mode = mode, from = "<Up>", to = actions.on_focus_prev}
  }
end

function Tree:set_actions()
  local props = self:get_props()
  local renderer = self:get_renderer()

  self.__actions = {
    prepare_node = function(node)
      local line = Line()

      if props.prepare_node then
        return props.prepare_node(node, line, self)
      end

      return line
    end,
    should_skip_item = function(node)
      if props.should_skip_item then
        return props.should_skip_item(node)
      end

      return false
    end,
    on_focus_next = function()
      focus_item(self, "next")
    end,
    on_focus_prev = function()
      focus_item(self, "prev")
    end,
    on_change = function(node)
      self.__focused_node = node
      props.on_change(node, renderer.state, self)
    end,
    on_select = function()
      local current_state = self:get_state()
      local tree = self:get_tree()

      if props.on_select then
        props.on_select(self.__focused_node, tree, self)
      end
    end
  }
end

function Tree:get_focused_node()
  return self.__focused_node
end

function Tree:get_max_lines()
  return self.__max_lines
end

function Tree:__set_max_lines()
  local actions = self:get_actions()
  local tree = self:get_tree()

  local function rec(node_ids, initial_value)
    return fn.ireduce(
      node_ids,
      function(acc, node_id)
        local node = tree:get_node(node_id)

        if not node then
          return acc
        end

        local child_ids = node:get_child_ids()

        if #child_ids > 0 then
          return rec(child_ids, acc)
        end

        return acc + (node:get_depth() > 1 and 1 or 0)
      end,
      initial_value
    )
  end

  self.__max_lines =
    rec(
    fn.imap(
      tree:get_nodes(),
      function(node)
        return node._id
      end
    ),
    #tree:get_nodes()
  )
end

function Tree:get_actions()
  return self.__actions
end

function Tree:attach_change_handler()
  local actions = self:get_actions()
  local tree = self:get_tree()

  if not self.winid then
    return
  end

  for linenr = 1, self:get_max_lines() do
    local node, target_linenr = tree:get_node(linenr)
    vim.api.nvim_win_set_cursor(self.winid, {target_linenr, 0})
    actions.on_change(node)
    break
  end

  if vim.api.nvim_win_is_valid(self.winid) then
    local ns = vim.api.nvim_create_namespace(self:get_id())

    vim.api.nvim_set_hl(ns, "CursorLine", {link = self:make_highlight_group_name("ItemFocused")})
    vim.api.nvim_win_set_hl_ns(self.winid, ns)
  end
end

function Tree:get_tree()
  return self.__tree
end

function Tree:redraw()
  local tree = self:get_tree()
  local props = self:get_props()

  if tree then
    tree:set_nodes(props.data)
    self:__set_max_lines()

    vim.schedule(
      function()
        tree:render(1)
        self:attach_change_handler()
      end
    )
  end
end

function Tree:mount()
  local props = self:get_props()
  local actions = self:get_actions()

  Tree.super.mount(self)

  self.__tree =
    NuiTree(
    {
      bufnr = self.bufnr,
      ns_id = self.ns_id,
      nodes = props.data,
      get_node_id = function(node)
        return node._id
      end,
      prepare_node = actions.prepare_node
    }
  )

  self.__tree:render()
  self:__set_max_lines()

  self:attach_change_handler()
end

return Tree
