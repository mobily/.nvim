local conf = require("telescope.config").values
local fn = require("utils.fn")
local timetracker = require("plugins.timetracker")
local utils = require("utils")

local M = {}

local make_input = function(title, callback)
  return function()
    timetracker:blur()

    utils.schedule(
      function()
        vim.ui.input(
          {
            prompt = title .. ": ",
            opts = {
              kind = "timetracker"
            }
          },
          function(value)
            if value ~= nil then
              callback(value)
            end
          end
        )
      end
    )
  end
end

local cmd = function(value, args)
  vim.cmd("TimeTracker" .. value .. " " .. (args ~= nil and args or ""))
end

local actions = {
  {
    name = "start",
    command = "Start",
    keymap = "r"
  },
  {
    name = "start (backdate)",
    command = make_input(
      "Enter backdate",
      function(value)
        cmd("Start", value)
      end
    )
  },
  {
    name = "stop",
    command = "Stop",
    keymap = "s"
  },
  {
    name = "cancel",
    command = "Cancel",
    keymap = "c"
  },
  {
    name = "resume last entry",
    command = "Continue"
  },
  {
    name = "resume",
    command = make_input(
      "Enter entry @id",
      function(value)
        cmd("Continue", value)
      end
    )
  },
  {
    name = "add entry",
    command = make_input(
      "Enter custom range",
      function(value)
        cmd("Track", value)
      end
    )
  },
  {
    name = "delete entry",
    command = make_input(
      "Enter entry @id",
      function(value)
        cmd("Delete", value)
      end
    )
  },
  {
    name = "add description",
    keymap = "a",
    command = make_input(
      "Enter entry description",
      function(value)
        cmd("Annotate", value)
      end
    )
  },
  {
    name = "set tag",
    keymap = "t",
    command = make_input(
      "Enter entry tag",
      function(value)
        cmd("Tag", value)
      end
    )
  },
  {
    name = "today report",
    command = "DayReport",
    keymap = "d"
  },
  {
    name = "yesterday report",
    command = "DayReport yesterday"
  },
  {
    name = "current week report",
    command = "WeekReport",
    keymap = "w"
  },
  {
    name = "last week report",
    command = "WeekReport sopw - eopw"
  },
  {
    name = "current month report",
    command = "MonthReport",
    keymap = "m"
  },
  {
    name = "last month report",
    command = "MonthReport sopm - eopm"
  },
  {
    name = "view custom report",
    command = make_input(
      "Enter day | week | month and custom range",
      function(value)
        timetracker:open(value)
      end
    )
  },
  {
    name = "view summary",
    command = "Summary"
  },
  {
    name = "view custom summary",
    command = make_input(
      "Enter custom range",
      function(value)
        cmd("Summary", value)
      end
    )
  },
  {
    name = "refresh last view",
    command = "Refresh"
  },
  {
    name = "close",
    command = "Close"
  }
}

M.actions =
  fn.imap(
  actions,
  function(action)
    return {
      name = action.name,
      keymap = action.keymap,
      handler = function()
        if type(action.command) == "string" then
          return cmd(action.command)
        end

        action.command()
      end
    }
  end
)

M.options = {
  prompt_title = function()
    return "TimeTracker"
  end,
  theme = require("telescope.themes").get_dropdown(
    {
      layout_config = {
        height = 0.3
      }
    }
  )
}

return M
