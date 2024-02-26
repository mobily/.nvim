local Menu = require("nui.menu")
local utils = require("plugins.nui-form.utils")
local fn = require("utils.fn")

local Line = require("nui.line")
local Select = Menu:extend("Select")

function Select:init(options, form)
  local popup_options = {
    enter = false,
    focusable = true,
    size = {
      width = form.width
    },
    win_options = {
      winblend = 0
    },
    border = {
      style = options.style,
      text = {
        top = options.label,
        top_align = options.label_align
      }
    }
  }

  self.instance = {
    form = form,
    options = options
  }

  local lines =
    fn.ireduce(
    options.data,
    function(acc, value, index)
      local item = type(value) == "string" and Menu.item(value, {id = index}) or Menu.item(value.text, {id = value.id})
      table.insert(acc, item)
      return acc
    end,
    {}
  )

  self:set_state({})

  Select.super.init(
    self,
    popup_options,
    {
      lines = lines,
      keymap = {
        focus_next = {"j", "<Down>"},
        focus_prev = {"k", "<Up>"},
        close = {},
        submit = {}
      },
      on_change = function(value)
        self._.current_entry = value
      end,
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
          line:append(node.text)
        end

        return line
      end
    }
  )

  local select = function()
    local current_state = self:get_state()
    local obj = {id = self._.current_entry.id, text = self._.current_entry.text}

    if options.multiselect then
      local index =
        fn.find_index(
        current_state,
        function(node)
          return node.id == self._.current_entry.id
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

  utils.attach_prev_next_focus(self)
  utils.attach_form_events(self)

  utils.keymap(self.bufnr, {"i", "n"}, "<CR>", select)
  utils.keymap(self.bufnr, {"i", "n"}, "<Space>", select)
end

function Select:mount()
  Select.super.mount(self)

  local ns = vim.api.nvim_create_namespace(self._.id)
  vim.api.nvim_set_hl(ns, "CursorLine", {link = "NuiSelectItem"})
  vim.api.nvim_win_set_hl_ns(self.winid, ns)

  utils.set_initial_focus(self)
end

function Select:set_state(value)
  self.instance.form:set_state(self.instance.options.key, value)
end

function Select:get_state()
  return self.instance.form.state[self.instance.options.key]
end

function Select:validate()
  return self.instance.options.validate(self:get_state())
end

return Select
