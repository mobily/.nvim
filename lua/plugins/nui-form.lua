local utils = require("utils")
local fn = require("utils.fn")
local colors = require("ui.colors")

local Layout = require("nui.layout")
local Input = require("nui.input")
local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Line = require("nui.line")
local Text = require("nui.text")

local event = require("nui.utils.autocmd").event

local NuiForm = {}

local augroup = vim.api.nvim_create_augroup("NuiForm", {clear = true})

local keymap = function(buffer, mode, from, to)
  vim.keymap.set(mode, from, to, {noremap = true, silent = true, buffer = buffer})
end

local ignore = function()
end

local set_default_height = function(options)
  return vim.tbl_extend("force", {height = 3}, vim.F.if_nil(options, {}))
end

local TextInput = Input:extend("TextInput")
local Select = Menu:extend("Select")
local Footer = Popup:extend("Footer")

local attach_prev_next_focus = function(bufnr, index, form)
  keymap(
    bufnr,
    {"i", "n"},
    "<Tab>",
    function()
      local next = form.focusable_elements[index + 1] or form.focusable_elements[1]
      vim.api.nvim_set_current_win(next.winid)
    end
  )

  keymap(
    bufnr,
    {"i", "n"},
    "<S-Tab>",
    function()
      local prev = form.focusable_elements[index - 1] or form.focusable_elements[#form.focusable_elements]
      vim.api.nvim_set_current_win(prev.winid)
    end
  )
end

local attach_form_events = function(bufnr, form)
  vim.api.nvim_create_autocmd(
    "WinClosed",
    {
      group = augroup,
      buffer = bufnr,
      callback = function(event)
        form.layout:unmount()
        form.on_close()
      end
    }
  )

  keymap(
    bufnr,
    {"n"},
    form.cancel,
    function()
      form.layout:unmount()
      form.on_close()
    end
  )

  keymap(
    bufnr,
    {"i", "n"},
    form.confirm,
    function()
      form.layout:unmount()
      form.on_submit(form.state)
    end
  )
end

function TextInput:init(text_input_options, form)
  local popup_options = {
    enter = false,
    focusable = true,
    size = {
      width = form.width
    },
    win_options = {
      winblend = 0
    },
    zindex = 100,
    border = {
      style = text_input_options.style,
      text = {
        top = text_input_options.label,
        top_align = text_input_options.label_align
      }
    }
  }

  local options = {
    on_change = function(value)
      form:set_state(text_input_options.key, value)
    end
  }

  TextInput.super.init(self, popup_options, options)

  self.element_options = text_input_options

  self._.win_enter = false
  self._.win_options.winblend = 0

  -- add support for default value
  form:set_state(text_input_options.key, "")

  keymap(self.bufnr, {"i", "n"}, "<CR>", "<Nop>")
  attach_prev_next_focus(self.bufnr, text_input_options.index, form)
  attach_form_events(self.bufnr, form)

  self:on(
    event.BufEnter,
    vim.schedule_wrap(
      function()
        vim.api.nvim_command("startinsert!")
      end
    )
  )
end

function TextInput:mount()
  TextInput.super.mount(self)

  if self.element_options.focus then
    vim.api.nvim_set_current_win(self.winid)
  end
end

function Select:init(select_options, form)
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
      style = select_options.style,
      text = {
        top = select_options.label,
        top_align = select_options.label_align
      }
    }
  }

  local lines =
    fn.ireduce(
    select_options.data,
    function(acc, value, index)
      local item = type(value) == "string" and Menu.item(value, {id = index}) or Menu.item(value.text, {id = value.id})
      table.insert(acc, item)
      return acc
    end,
    {}
  )

  form:set_state(select_options.key, {})

  local options = {
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
        form.state[select_options.key],
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

  Select.super.init(self, popup_options, options)

  attach_prev_next_focus(self.bufnr, select_options.index, form)
  attach_form_events(self.bufnr, form)

  self.element_options = select_options

  local select = function()
    local current_state = form.state[select_options.key]
    local obj = {id = self._.current_entry.id, text = self._.current_entry.text}

    if select_options.multiselect then
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

      form:set_state(select_options.key, current_state)
    else
      form:set_state(select_options.key, {obj})
    end

    self.tree:render()
  end

  keymap(self.bufnr, {"i", "n"}, "<CR>", select)
  keymap(self.bufnr, {"i", "n"}, "<Space>", select)
end

function Select:mount()
  Select.super.mount(self)

  local ns = vim.api.nvim_create_namespace(self._.id)
  vim.api.nvim_set_hl(ns, "CursorLine", {link = "NuiSelectItem"})
  vim.api.nvim_win_set_hl_ns(self.winid, ns)
end

function Footer:init(footer_options, form)
  local popup_options = {
    enter = false,
    focusable = true,
    size = {
      width = form.width
    },
    win_options = {
      winblend = 0
    }
  }

  self.form = form
  self.element_options = footer_options

  Footer.super.init(self, popup_options)
  attach_prev_next_focus(self.bufnr, footer_options.index, form)
end

function Footer:mount()
  Footer.super.mount(self)
  local line = Line()

  local confirm_key = utils.mapping_to_macos(self.form.confirm)
  local cancel_key = utils.mapping_to_macos(self.form.cancel)

  line:append("(" .. confirm_key .. ") Confirm", "NuiFooterConfirmButton")
  line:append(" ")
  line:append("(" .. cancel_key .. ") Cancel", "NuiFooterCancelButton")

  table.insert(line._texts, 1, Text((" "):rep(self.form.width - line:width())))

  local pad_left = line:render(self.bufnr, -1, 1)
  vim.api.nvim_set_option_value("modifiable", false, {buf = self.bufnr})
end

function NuiForm:new(options)
  options = options or {}
  self.__index = self

  options.width = vim.F.if_nil(options.width, 60)

  options.default_options = {
    label_align = vim.F.if_nil(options.label_align, "left"),
    style = vim.F.if_nil(options.style, "rounded"),
    is_focusable = true
  }

  options.confirm = vim.F.if_nil(options.confirm, "<D-CR>")
  options.cancel = vim.F.if_nil(options.cancel, "<Esc>")
  options.position = vim.F.if_nil(options.position, "50%")
  options.relative = vim.F.if_nil(options.relative, "editor")

  self.focusable_elements = {}
  self.state = {}
  self.on_submit = vim.F.if_nil(options.on_submit, ignore)
  self.on_close = vim.F.if_nil(options.on_close, ignore)

  return setmetatable(options, self)
end

function NuiForm.text_input(options)
  return {
    type = "text_input",
    options = set_default_height(options)
  }
end

function NuiForm.select(options)
  return {
    type = "select",
    options = set_default_height(options)
  }
end

function NuiForm.footer(options)
  return {
    type = "footer",
    options = set_default_height(options)
  }
end

function NuiForm:set_content(...)
  self.content = {...}
end

function NuiForm:open()
  self.focusable_elements = {}

  local total_height = self:__get_total_height(self.content)
  local elements = self:__get_layout(self.content)

  self.layout =
    Layout(
    {
      position = self.position,
      relative = self.relative,
      size = {
        width = self.width,
        height = total_height
      }
    },
    Layout.Box(elements, {dir = "col"})
  )

  vim.schedule(
    function()
      self.layout:mount()
    end
  )
end

function NuiForm:__set_default_height(options)
  return vim.tbl_extend("force", {height = 3}, vim.F.if_nil(options, {}))
end

function NuiForm:set_state(key, value)
  self.state[key] = value
end

function NuiForm:__get_total_height(elements)
  return fn.ireduce(
    elements,
    function(acc, item)
      return acc + item.options.height
    end,
    0
  )
end

function NuiForm:__get_layout(elements)
  local total_height = self:__get_total_height(elements)

  local layout =
    fn.ireduce(
    elements,
    function(acc, item, index)
      local options = vim.tbl_deep_extend("force", self.default_options, item.options)
      local size = math.ceil(options.height / total_height * 100) .. "%"

      options.index = index

      local element =
        fn.switch(
        item.type,
        {
          ["select"] = function()
            return Select(options, self)
          end,
          ["text_input"] = function()
            return TextInput(options, self)
          end,
          ["footer"] = function()
            return Footer(options, self)
          end
        }
      )

      if element then
        if element.element_options.is_focusable then
          table.insert(self.focusable_elements, element)
        end
        table.insert(acc, Layout.Box(element, {size = size}))
      end

      return acc
    end,
    {}
  )

  return layout
end

vim.api.nvim_create_user_command(
  "OpenNuiForm",
  function(opts)
    local form =
      NuiForm:new(
      {
        on_submit = function(state)
          vim.notify(vim.inspect(state))
        end
      }
    )

    form:set_content(
      form.text_input(
        {
          key = "backdate",
          label = " 󰃮 Backdate ",
          focus = true
        }
      ),
      form.text_input(
        {
          height = 5,
          key = "description",
          label = " 󰏫 Description "
        }
      ),
      form.select(
        {
          height = 8,
          key = "tags",
          label = " 󰓹 Tag ",
          data = {
            "Work",
            "Meetings",
            "Research",
            "Personal",
            "Reading",
            "Learning",
            "Other",
            "Break"
          }
        }
      ),
      form.footer({is_focusable = false})
    )

    form:open()
  end,
  {}
)

return NuiForm
