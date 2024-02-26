local Component = require("plugins.nui-form.component")

local Line = require("nui.line")
local Tree = require("nui.tree")

local event = require("nui.utils.autocmd").event
local utils = require("plugins.nui-form.utils")
local fn = require("utils.fn")
local is_type = require("nui.utils").is_type

local Select = Component:extend("Select")

local select_item = function(content, data)
  if not data then
    if is_type("table", content) and content.text then
      data = content
    else
      data = {text = content}
    end
  else
    data.text = content
  end

  data._type = "item"
  data._id = data.id or tostring(math.random())

  return Tree.Node(data)
end

local focus_item = function(menu, direction, current_linenr)
  local curr_linenr = current_linenr or vim.api.nvim_win_get_cursor(menu.winid)[1]

  local next_linenr = nil

  if direction == "next" then
    if curr_linenr == #menu.tree:get_nodes() then
      next_linenr = 1
    else
      next_linenr = curr_linenr + 1
    end
  elseif direction == "prev" then
    if curr_linenr == 1 then
      next_linenr = #menu.tree:get_nodes()
    else
      next_linenr = curr_linenr - 1
    end
  end

  local next_node = menu.tree:get_node(next_linenr)

  if next_linenr then
    vim.api.nvim_win_set_cursor(menu.winid, {next_linenr, 0})
    menu.on_change(next_node)
  end
end

function Select:init(options, form)
  self.items =
    fn.ireduce(
    options.data,
    function(acc, item, index)
      table.insert(
        acc,
        type(item) == "string" and select_item(item, {id = index, value = item.value}) or
          select_item(item.text, {id = item.id, value = item.value})
      )
      return acc
    end,
    {}
  )

  Select.super.init(
    self,
    form,
    vim.tbl_extend(
      "force",
      options,
      {
        default_value = vim.F.if_nil(options.default_value, {})
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
      win_options = {
        cursorline = true,
        scrolloff = 1,
        sidescrolloff = 0
      }
    }
  )

  local initial_state =
    fn.ireduce(
    self:get_options().default_value,
    function(acc, id)
      local selected =
        fn.ifind(
        self.items,
        function(item)
          return item.id == id
        end
      )

      if selected then
        table.insert(acc, selected)
      end

      return acc
    end,
    {}
  )

  self:set_state(initial_state)

  self:__setup_props()

  self.prepare_item = function(node)
    local line = Line()

    local is_selected =
      fn.isome(
      self:get_state(),
      function(item)
        return item.id == node.id
      end
    )

    if is_selected then
      line:append(node.text, "NuiSelectItemSelected")
    else
      line:append(node.text)
    end

    return line
  end

  self:on(
    event.BufEnter,
    vim.schedule_wrap(
      function()
        vim.api.nvim_command("stopinsert")
      end
    )
  )
end

function Select:__setup_props()
  self.on_focus_next = function()
    focus_item(self, "next")
  end

  self.on_focus_prev = function()
    focus_item(self, "prev")
  end

  self.on_change = function(node)
    self.current_entry = node
  end

  self.on_select = function()
    local current_state = self:get_state()
    local obj = {id = self.current_entry.id, text = self.current_entry.text, value = self.current_entry.value}

    if self:get_options().multiselect then
      local index =
        fn.find_index(
        current_state,
        function(node)
          return node.id == self.current_entry.id
        end
      )

      if index then
        table.remove(current_state, index)
      else
        table.insert(current_state, obj)
      end

      self:set_state(current_state)
    else
      self:set_state({obj})
    end

    self.tree:render()
  end
end

function Select:mount()
  Select.super.mount(self)

  utils.keymap(self.bufnr, {"i", "n"}, "<CR>", self.on_select)
  utils.keymap(self.bufnr, {"i", "n"}, "<Space>", self.on_select)
  utils.keymap(self.bufnr, {"i", "n"}, "j", self.on_focus_next)
  utils.keymap(self.bufnr, {"i", "n"}, "<Down>", self.on_focus_next)
  utils.keymap(self.bufnr, {"i", "n"}, "k", self.on_focus_prev)
  utils.keymap(self.bufnr, {"i", "n"}, "<Up>", self.on_focus_prev)

  self.tree =
    Tree(
    {
      winid = self.winid,
      ns_id = self.ns_id,
      nodes = self.items,
      get_node_id = function(node)
        return node._id
      end,
      prepare_node = self.prepare_item
    }
  )

  local ns = vim.api.nvim_create_namespace(self._.id)
  vim.api.nvim_set_hl(ns, "CursorLine", {link = "NuiSelectItem"})
  vim.api.nvim_win_set_hl_ns(self.winid, ns)

  self.tree:render()

  for linenr = 1, #self.tree:get_nodes() do
    local node, target_linenr = self.tree:get_node(linenr)
    vim.api.nvim_win_set_cursor(self.winid, {target_linenr, 0})
    self.on_change(node)
    break
  end
end

return Select
