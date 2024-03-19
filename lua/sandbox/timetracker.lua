local fn = require("utils.fn")

local TimeTracker = {}

function TimeTracker:new(options)
  options = options or {}
  self.__index = self
  self:__set_start_time()

  return setmetatable(options, self)
end

function TimeTracker:open(cmd, args)
  local command = self:__build_command(cmd, args)
  local height = self:__count_output_lines(command)

  if self:is_open() then
    self:close()
  end

  self.origin_window = vim.api.nvim_get_current_win()

  self:__save_last_command(cmd, args)

  vim.cmd("split")
  vim.cmd("resize " .. height)

  self:__set_buffer()

  vim.api.nvim_buf_call(self.bufnr, function()
    vim.fn.termopen(fn.trim(command) .. ";#timetracker#")
    vim.api.nvim_input("<Esc>")
  end)
end

function TimeTracker:is_active()
  return self.start_time > 0
end

function TimeTracker:get_status()
  local status_string = ""

  if self:is_active() then
    local tag = self.entry_tag and self.entry_tag .. " " or ""
    status_string = " " .. tag .. os.date("!%0H:%0M:%0S", os.time() - self.start_time)
  end

  return status_string
end

function TimeTracker:notify(msg, level)
  vim.schedule(function()
    -- vim.notify(msg, vim.log.levels.INFO, {title = "TimeTracker"})
    require("fidget").notify(msg, vim.log.levels.INFO, { title = "TimeTracker" })
  end)
end

function TimeTracker:blur()
  if not self.origin_window then
    return
  end

  vim.api.nvim_set_current_win(self.origin_window)
end

function TimeTracker:exec(cmd, args)
  local command = self:__build_command(cmd, args)
  local result = table.concat(vim.fn.systemlist(command), "\n")

  self:__set_start_time()
  self:notify(result)

  return result
end

function TimeTracker:export(args)
  local command = self:__build_command("export", args)
  local result = vim.fn.system(command)

  return vim.fn.json_decode(result)
end

function TimeTracker:track(args)
  local result = self:exec("track", args)
  return not (string.find(result, "cannot overlap") ~= nil)
end

function TimeTracker:start(args)
  local result = self:exec("start", args)
  return not (string.find(result, "cannot overlap") ~= nil)
end

function TimeTracker:stop(args)
  return self:exec("stop", args)
end

function TimeTracker:delete(args)
  return self:exec("delete", args)
end

function TimeTracker:continue(args)
  return self:exec("continue", args)
end

function TimeTracker:annotate(args)
  return self:exec("annotate", args)
end

function TimeTracker:tag(args)
  return self:exec("tag", args)
end

function TimeTracker:cancel()
  return self:exec("cancel")
end

function TimeTracker:close()
  if self:is_open() then
    vim.api.nvim_win_close(self.window, true)
  end
end

function TimeTracker:reload()
  if self.last_command ~= nil then
    return self:open(self.last_command, self.last_args)
  end
end

function TimeTracker:is_open()
  if not self.window then
    return false
  end

  local win_type = vim.fn.win_gettype(self.window)
  local win_open = win_type == "" or win_type == "popup"

  return win_open and vim.api.nvim_win_get_buf(self.window) == self.bufnr
end

function TimeTracker:__set_start_time()
  vim.schedule(function()
    local total = fn.trim(vim.fn.system('timew | grep "Total\\s*[0-9:]*" | sed "s/Total\\s*//g"'))
    local tag = fn.trim(vim.fn.system("timew | grep -o 'Tracking\\s*\"[^\"]*' | sed 's/Tracking \"//g'"))

    self.start_time = -1
    self.entry_tag = tag

    if #total > 0 then
      local hours, minutes, seconds = total:match("(%d+):(%d+):(%d+)")
      local total_seconds = tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
      self.start_time = os.time() - total_seconds
    end
  end)
end

function TimeTracker:__save_last_command(cmd, args, type)
  self.last_command = cmd
  self.last_args = args
end

function TimeTracker:__build_command(cmd, args)
  return "timew " .. cmd .. " " .. (args ~= nil and args or "")
end

function TimeTracker:__count_output_lines(cmd)
  return tonumber(fn.trim(vim.fn.system(cmd .. " | wc -l"))) + 1
end

function TimeTracker:__set_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local window = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, false)

  self.buf = buf
  self.window = window
  self.bufnr = bufnr

  vim.api.nvim_win_set_buf(window, bufnr)
  self:__set_options()
  vim.api.nvim_set_current_buf(bufnr)
end

function TimeTracker:__set_options()
  local options = {
    { "number", false },
    { "relativenumber", false },
    { "buftype", "nofile" },
    { "filetype", "timetracker" },
    { "buflisted", false },
    { "cursorcolumn", false },
    { "cursorline", false },
    { "signcolumn", "no" },
  }

  for index, pair in pairs(options) do
    vim.api.nvim_set_option_value(pair[1], pair[2], {
      scope = "local",
      win = self.window,
    })
  end
end

local timetracker = TimeTracker:new()

vim.api.nvim_create_user_command("TimeTrackerStart", function(opts)
  timetracker:start(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerAnnotate", function(opts)
  timetracker:annotate(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerTag", function(opts)
  timetracker:tag(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerStop", function(opts)
  timetracker:stop(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerTrack", function(opts)
  timetracker:track(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerDelete", function(opts)
  timetracker:delete(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerContinue", function(opts)
  timetracker:continue(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerCancel", function(opts)
  timetracker:cancel()
end, {})

vim.api.nvim_create_user_command("TimeTrackerDayReport", function(opts)
  timetracker:open("day", opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerWeekReport", function(opts)
  timetracker:open("week", opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerMonthReport", function(opts)
  timetracker:open("month", opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerSummary", function(opts)
  timetracker:open("summary", opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("TimeTrackerClose", function(opts)
  timetracker:close()
end, {})

vim.api.nvim_create_user_command("TimeTrackerReload", function(opts)
  timetracker:reload()
end, {})

local augroup = vim.api.nvim_create_augroup("TimeTrackerBuffer", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = augroup,
  callback = function()
    timetracker:close()
  end,
})

-- https://github.com/neovim/neovim/issues/14986#issuecomment-1673203103
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  pattern = { "term://*#timetracker#*" },
  callback = function(event)
    local delete_line_timer = vim.fn.timer_start(
      100,
      function(t)
        local process_exited_line = vim.fn.search("\\[process exited \\d\\]", "bn")
        if process_exited_line > 0 then
          vim.api.nvim_set_option_value("modifiable", true, { buf = event.buf })
          vim.api.nvim_buf_set_lines(event.buf, process_exited_line - 1, process_exited_line, true, { "" })
          vim.api.nvim_set_option_value("modifiable", false, { buf = event.buf })
          vim.fn.timer_stop(t)
        end
      end,
      {
        ["repeat"] = -1,
      } -- repeat indefinitely but will be cancelled after 3 seconds
    )

    -- give at most 3 seconds of an attempt to delete the line
    vim.defer_fn(function()
      vim.fn.timer_stop(delete_line_timer)
    end, 3000)
  end,
})

timetracker.status = function()
  return timetracker:get_status()
end

return timetracker
