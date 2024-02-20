local M = {}

local fn = require("utils.fn")

M.prev_buffer = function()
  vim.cmd("BufferLineCyclePrev")
end

M.next_buffer = function()
  vim.cmd("BufferLineCycleNext")
end

M.head = function(tbl)
  return tbl[1]
end

M.close_buffer = function(bufnr)
  if vim.bo.buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local bufhidden = vim.bo.bufhidden

    local bufinfo = M.head(vim.fn.getbufinfo(bufnr))

    if bufinfo and bufinfo.changed == 0 then
      M.prev_buffer()
      vim.cmd("confirm bd" .. bufnr)
      return
    end

    vim.notify("save file, bruh!")
  end
end

M.is_focused_buffer = function(...)
  local bufname = vim.fn.expand "%"

  return fn.isome(
    {...},
    function(value)
      return value == bufname
    end
  )
end

M.is_not_focused_buffer = function(...)
  return not M.is_focused_buffer(...)
end

return M
