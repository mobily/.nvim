local conf = require("telescope.config").values
local fn = require("utils.fn")
local timetracker = require("sandbox.timetracker")
local utils = require("utils")

local Form = require("nui-components")

local M = {}

local make_input = function(title, callback)
  return function()
    timetracker:blur()

    utils.schedule(function()
      vim.ui.input({
        prompt = title .. ": ",
        opts = {
          kind = "timetracker",
        },
      }, function(value)
        if value ~= nil then
          callback(value)
        end
      end)
    end)
  end
end

local cmd = function(value, args)
  vim.cmd("TimeTracker" .. value .. " " .. (args ~= nil and args or ""))
end

local escape = vim.fn.shellescape

local normalize_tags = function(tbl)
  local tags = fn.ireduce(tbl, function(acc, tag)
    table.insert(acc, escape(tag.text))
    return acc
  end, {})

  return table.concat(tags, " ")
end

local join = function(...)
  return table.concat({ ... }, " ")
end

local validator = Form.validator
local form_footer = Form.footer()
local form_tags = Form.select({
  height = 8,
  key = "tags",
  icon = "󰓹",
  label = "Tags",
  multiselect = true,
  validate = validator.is_not_empty,
  data = {
    "Work",
    "Meetings",
    "Research",
    "Personal",
    "Reading",
    "Learning",
    "Other",
    "Break",
  },
})
local form_description = Form.text_input({
  height = 5,
  key = "description",
  icon = "󰏫",
  label = "Description",
})
local form_range = Form.text_input({
  key = "range",
  icon = "󰃮",
  label = "Range",
  focus = true,
  validate = validator.is_not_empty,
})
local form_backdate = Form.text_input({
  key = "backdate",
  icon = "󰃮",
  label = "Backdate",
  focus = true,
  validate = validator.is_not_empty,
})
local form_id = Form.text_input({
  key = "id",
  icon = "󰛄",
  label = "@id",
  focus = true,
  validate = validator.compose(validator.is_not_empty, validator.contains("@")),
})

local actions = {
  {
    name = "start",
    command = "Start",
    keymap = "r",
  },
  {
    name = "start (custom input)",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          local is_success = timetracker:start(state.backdate)

          if not is_success then
            return
          end

          if not (state.description == "") then
            timetracker:annotate(escape(state.description))
          end

          if #state.tags > 0 then
            timetracker:tag(normalize_tags(state.tags))
          end
        end,
      })

      form:set_content(form_backdate, form_description, form_tags, form_footer)
      form:open()
    end,
  },
  {
    name = "stop",
    command = "Stop",
    keymap = "s",
  },
  {
    name = "cancel",
    command = "Cancel",
    keymap = "c",
  },
  {
    name = "resume last entry",
    command = "Continue",
  },
  {
    name = "resume",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          timetracker:continue(state.id)
        end,
      })

      form:set_content(form_id, form_footer)
      form:open()
    end,
  },
  {
    name = "add entry",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          local is_success = timetracker:track(state.backdate)

          if not is_success then
            return
          end

          local entries = timetracker:export(state.range)

          if #entries > 0 then
            local last_entry_id = "@" .. entries[1].id

            if not (state.description == "") then
              local description = join(escape(state.description), last_entry_id)
              timetracker:annotate(description)
            end

            if #state.tags > 0 then
              local tags = join(normalize_tags(state.tags), last_entry_id)
              timetracker:tag(tags)
            end
          end
        end,
      })

      form:set_content(form_backdate, form_description, form_tags, form_footer)
      form:open()
    end,
  },
  {
    name = "delete entry",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          timetracker:delete(state.id)
        end,
      })

      form:set_content(form_id, form_footer)
      form:open()
    end,
  },
  {
    name = "add description",
    keymap = "a",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          local value = join(escape(state.description), state.id)
          timetracker:annotate(value)
        end,
      })

      form:set_content(form_id, form_description, form_footer)
      form:open()
    end,
  },
  {
    name = "set tag",
    keymap = "t",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          local tags = join(normalize_tags(state.tags), state.id)
          timetracker:tag(tags)
        end,
      })

      form:set_content(form_id, form_tags, form_footer)
      form:open()
    end,
  },
  {
    name = "today report",
    command = "DayReport",
    keymap = "d",
  },
  {
    name = "yesterday report",
    command = "DayReport yesterday",
  },
  {
    name = "current week report",
    command = "WeekReport",
    keymap = "w",
  },
  {
    name = "last week report",
    command = "WeekReport sopw - eopw",
  },
  {
    name = "current month report",
    command = "MonthReport",
    keymap = "m",
  },
  {
    name = "last month report",
    command = "MonthReport sopm - eopm",
  },
  {
    name = "view custom report",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          local value = join(state.type[1].id, state.range)
          timetracker:open(value)
        end,
      })

      form:set_content(
        form_range,
        form.select({
          height = 5,
          key = "type",
          icon = "󰨲",
          label = "Type",
          data = {
            { text = "Day", id = "day" },
            { text = "Week", id = "week" },
            { text = "Month", id = "month" },
          },
          validate = validator.is_not_empty,
        }),
        form_footer
      )
      form:open()
    end,
  },
  {
    name = "view summary",
    command = "Summary",
  },
  {
    name = "view custom summary",
    command = function()
      local form = Form:new({
        on_submit = function(state)
          timetracker:open(join("summary", state.range))
        end,
      })

      form:set_content(form_range, form_footer)
      form:open()
    end,
  },
  {
    name = "reload last view",
    command = "Reload",
  },
  {
    name = "close",
    command = "Close",
  },
}

M.actions = fn.imap(actions, function(action)
  return {
    name = action.name,
    keymap = action.keymap,
    handler = function()
      if type(action.command) == "string" then
        return cmd(action.command)
      end

      action.command()
    end,
  }
end)

M.options = {
  prompt_title = function()
    return "TimeTracker"
  end,
  theme = require("telescope.themes").get_dropdown({
    layout_config = {
      height = 0.3,
    },
  }),
}

return M
