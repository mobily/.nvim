local group_id = vim.api.nvim_create_augroup("custom_highlighting", {clear = true})

vim.api.nvim_create_autocmd(
  "BufEnter",
  {
    group = group_id,
    pattern = "*.md",
    callback = function()
      vim.cmd [[
iabbrev todo- 🞏
iabbrev done- 🞪
iabbrev note- 🞶
iabbrev event- ⏺
iabbrev move- ⏸
]]

      -- lines containing 'done' items: ×
      vim.cmd.syntax([[match JournalDone /^🞪.*/]])
      -- lines containing 'todo' items: ·
      vim.cmd.syntax([[match JournalTodo /^🞏.*/]])
      -- lines containing 'event' items: o
      vim.cmd.syntax([[match JournalEvent /^⏺.*/]])
      -- lines containing 'note' items: -
      vim.cmd.syntax([[match JournalNote /^🞶.*/]])
      -- lines containing 'moved' items: >
      vim.cmd.syntax([[match JournalMoved /^⏸.*/]])

      vim.cmd.syntax([[match JournalWeek /^Week.*/]])
    end
  }
)

local make_gcal_command = function(date)
  return ":read !gcal -q PL -s Monday -n " ..
    date ..
      " | sed 's/=.*//g' | sed 's/:/ /g' | sed 's/<\\(.*\\)>/ \\1 /g' | sed 's/,[[:space:]]*/, /g' | sed 's/[[:space:]]*[-+]/ -/g'"
end

vim.api.nvim_create_user_command(
  "JournalEntry",
  function(opts)
    month = #opts.args == 0 and os.date("%m") or opts.args

    vim.cmd(make_gcal_command(month))
    vim.api.nvim_input("o<CR><CR>Week 1 -------------<CR><Esc>")
    vim.api.nvim_input("oWeek 2 -------------<CR><Esc>")
    vim.api.nvim_input("oWeek 3 -------------<CR><Esc>")
    vim.api.nvim_input("oWeek 4 -------------<CR><Esc>")

    vim.api.nvim_input("30kdddd")
    vim.api.nvim_input("30j")
  end,
  {nargs = "?"}
)

vim.api.nvim_create_user_command(
  "JournalMonth",
  function(opts)
    month = #opts.args == 0 and os.date("%m") or opts.args

    vim.cmd(make_gcal_command(month))
  end,
  {nargs = "?"}
)

vim.api.nvim_create_user_command(
  "JournalWeek",
  function()
    vim.api.nvim_input("iWEEK 1 -------------")
  end,
  {}
)
