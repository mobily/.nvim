local Component = require("plugins.nui-form.component")

local Line = require("nui.line")
local Tree = require("nui.tree")

local fn = require("utils.fn")
local event = require("nui.utils.autocmd").event
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

local separator = function(content)
  return Tree.Node(
    {
      _id = tostring(math.random()),
      _type = "separator",
      text = vim.F.if_nil(content, "")
    }
  )
end

local function focus_item(instance, direction, current_linenr)
  local props = instance:get_props()
  local curr_linenr = current_linenr or vim.api.nvim_win_get_cursor(instance.winid)[1]
  local next_linenr = nil

  if direction == "next" then
    if curr_linenr == #instance.tree:get_nodes() then
      next_linenr = 1
    else
      next_linenr = curr_linenr + 1
    end
  elseif direction == "prev" then
    if curr_linenr == 1 then
      next_linenr = #instance.tree:get_nodes()
    else
      next_linenr = curr_linenr - 1
    end
  end

  local next_node = instance.tree:get_node(next_linenr)

  if props.should_skip_item(next_node) then
    return focus_item(instance, direction, next_linenr)
  end

  if next_linenr then
    vim.api.nvim_win_set_cursor(instance.winid, {next_linenr, 0})
    props.on_change(next_node)
  end
end

function Select:init(props, form)
  self:__set_items(props.data)

  Select.super.init(
    self,
    form,
    vim.tbl_extend(
      "force",
      props,
      {
        default_value = vim.F.if_nil(props.default_value, {})
      }
    ),
    {
      win_options = {
        cursorline = true,
        scrolloff = 1,
        sidescrolloff = 0
      }
    }
  )

  self:__extend_props()
end

function Select:initial_state()
  return fn.ireduce(
    self:get_props().default_value,
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
end

function Select:mappings()
  local props = self:get_props()
  local mode = {"i", "n"}

  return {
    {mode = mode, from = "<CR>", to = props.on_select},
    {mode = mode, from = "<Space>", to = props.on_select},
    {mode = mode, from = "j", to = props.on_focus_next},
    {mode = mode, from = "<Down>", to = props.on_focus_next},
    {mode = mode, from = "<k>", to = props.on_focus_prev},
    {mode = mode, from = "<Up>", to = props.on_focus_prev}
  }
end

function Select:events()
  return {
    {
      event = event.BufEnter,
      callback = vim.schedule_wrap(
        function()
          local props = self:get_props()

          vim.api.nvim_command("stopinsert")

          if props.shrink_on_blur then
            local form = self:get_form()

            if not (self.__last_height == props.height) then
              self:extend_props({height = self.__last_height})
              form:reload()
            end
          end
        end
      )
    },
    {
      event = event.BufLeave,
      callback = vim.schedule_wrap(
        function()
          local props = self:get_props()

          if props.shrink_on_blur then
            if self._.mounted then
              local form = self:get_form()

              self.__last_height = props.height

              self:extend_props({height = 3})
              form:reload()
            end
          end
        end
      )
    }
  }
end

function Select:__set_items(data)
  self.items =
    fn.ireduce(
    data,
    function(acc, item, index)
      local element

      if item.type == "separator" then
        element = separator(item.text)
      else
        element =
          type(item) == "string" and select_item(item, {id = index, value = item.value}) or
          select_item(item.text, {id = item.id, value = item.value})
      end

      table.insert(acc, element)
      return acc
    end,
    {}
  )
end

function Select:__extend_props()
  local props = {
    prepare_item = function(node)
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
        line:append(node.text, node._type == "separator" and "NuiSelectSeparator" or "NuiSelectItem")
      end

      return line
    end,
    should_skip_item = function(node)
      return node._type == "separator"
    end,
    on_focus_next = function()
      focus_item(self, "next")
    end,
    on_focus_prev = function()
      focus_item(self, "prev")
    end,
    on_change = function(node)
      self.current_entry = node
    end,
    on_select = function()
      local current_state = self:get_state()
      local obj = {id = self.current_entry.id, text = self.current_entry.text, value = self.current_entry.value}

      if self:get_props().multiselect then
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
  }

  self:extend_props(props)
end

function Select:mount()
  local props = self:get_props()

  Select.super.mount(self)

  self.tree =
    Tree(
    {
      winid = self.winid,
      ns_id = self.ns_id,
      nodes = self.items,
      get_node_id = function(node)
        return node._id
      end,
      prepare_node = props.prepare_item
    }
  )

  local ns = vim.api.nvim_create_namespace(self._.id)
  vim.api.nvim_set_hl(ns, "CursorLine", {link = "NuiSelectItemActive"})
  vim.api.nvim_win_set_hl_ns(self.winid, ns)

  self.tree:render()

  for linenr = 1, #self.tree:get_nodes() do
    local node, target_linenr = self.tree:get_node(linenr)
    vim.api.nvim_win_set_cursor(self.winid, {target_linenr, 0})
    props.on_change(node)
    break
  end
end

return Select
