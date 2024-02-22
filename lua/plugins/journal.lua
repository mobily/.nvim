local group_id = vim.api.nvim_create_augroup("JournalHighlights", {clear = true})

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
iabbrev pause- ⏸
iabbrev move- 🞂
]]

      vim.cmd.syntax([[match JournalDone /^🞪.*/]])
      vim.cmd.syntax([[match JournalTodo /^🞏.*/]])
      vim.cmd.syntax([[match JournalEvent /^⏺.*/]])
      vim.cmd.syntax([[match JournalNote /^🞶.*/]])
      vim.cmd.syntax([[match JournalPaused /^⏸.*/]])
      vim.cmd.syntax([[match JournalMoved /^🞂.*/]])
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
