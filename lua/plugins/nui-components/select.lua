local Tree = require("plugins.nui-components.tree")

local Line = require("nui.line")
local NuiTree = require("nui.tree")

local fn = require("utils.fn")
local event = require("nui.utils.autocmd").event
local is_type = require("nui.utils").is_type

local Select = Tree:extend("Select")

function Select.option(content, data)
  if not data then
    if is_type("table", content) and content.text then
      data = content
    else
      data = {text = content}
    end
  else
    data.text = content
  end

  data._type = "option"
  data._id = data.id or tostring(math.random())

  return NuiTree.Node(data)
end

function Select.separator(content)
  return NuiTree.Node(
    {
      _id = tostring(math.random()),
      _type = "separator",
      text = vim.F.if_nil(content, "")
    }
  )
end

function Select:init(props, parent, renderer)
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

  Select.super.init(self, props, parent, renderer)
end

function Select:initial_state()
  local props = self:get_props()

  return fn.ireduce(
    props.default_value,
    function(acc, id)
      local selected =
        fn.ifind(
        props.data,
        function(item)
          return item._id == id
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

function Select:events()
  return {
    {
      event = event.BufEnter,
      callback = vim.schedule_wrap(
        function()
          local props = self:get_props()
          local renderer = self:get_renderer()

          if props.shrink_to and not (renderer.relative == "cursor") then
            if not (self.__last_size == props.size) then
              self:update_props({size = self.__last_size})
              renderer:redraw()
            end
          end
        end
      )
    },
    {
      event = event.BufLeave,
      callback = vim.schedule_wrap(
        function()
          local renderer = self:get_renderer()
          local props = self:get_props()

          if props.shrink_to and not (renderer.relative == "cursor") then
            self:call_if_mounted(
              function()
                self.__last_size = props.size

                self:update_props({size = props.shrink_to})
                renderer:redraw()
              end
            )
          end
        end
      )
    }
  }
end

function Select:set_actions()
  local props = self:get_props()
  local renderer = self:get_renderer()

  Select.super.set_actions(self)

  local actions = {
    prepare_node = function(node)
      local line = Line()

      local is_selected =
        fn.isome(
        self:get_state(),
        function(item)
          return item.id == node._id
        end
      )

      if props.prepare_node then
        return props.prepare_node(node, is_selected, line)
      end

      if is_selected then
        line:append(node.text, self:make_highlight_group_name("OptionSelected"))
      else
        local is_separator = node._type == "separator"
        line:append(node.text, self:make_highlight_group_name(is_separator and "Separator" or "Option"))
      end

      return line
    end,
    should_skip_item = function(node)
      local is_separator = node._type == "separator"

      if props.should_skip_item then
        return props.should_skip_item(node, is_separator)
      end

      return is_separator
    end,
    on_select = function()
      local current_state = self:get_state()
      local tree = self:get_tree()
      local focused_node = self:get_focused_node()

      local obj = {
        id = focused_node.id,
        text = focused_node.text,
        value = focused_node.value
      }

      if props.multiselect then
        local index =
          fn.find_index(
          current_state,
          function(node)
            return node.id == focused_node._id
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

      tree:render()

      props.on_select(self:get_state(), focused_node, renderer.state, self)
    end
  }

  self.__actions = vim.tbl_extend("force", self.__actions, actions)
end

return Select
