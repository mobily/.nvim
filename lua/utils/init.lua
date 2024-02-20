local M = {}

M.load_highlight = function(group)
  for hl, col in pairs(group) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

M.keymap_factory = function(mode)
  return function(keybind, custom, description, opts)
    local options = {noremap = true, silent = true}

    if opts then
      options = vim.tbl_extend("force", options, opts)
    end

    if description then
      options = vim.tbl_extend("force", options, {desc = description})
    end

    vim.keymap.set(mode, keybind, custom, options)
  end
end

M.termcodes = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

M.focus_nvim_tree = function(key)
  local k = key or ""

  return function()
    local bufname = vim.api.nvim_buf_get_name(0)

    if string.find(bufname, "NvimTree") then
      vim.api.nvim_input("<C-w>h")
      return
    end

    vim.api.nvim_input(k .. "<C-w>l")
  end
end

M.text_padding = function(str)
  return "\n" .. str:gsub("([^\n]+)", "      %1      ") .. "\n"
end

M.cmd = function(str)
  return "<cmd> " .. str .. " <CR>"
end

M.load_plugin = function(name)
  return function()
    require("plugins." .. name)
  end
end

M.schedule = function(fn, ms)
  ms = ms or 5
  local timer = vim.loop.new_timer()
  timer:start(ms, 0, vim.schedule_wrap(fn))
end

M.preserve_cursor_position = function(fn)
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  fn()

  M.schedule(
    function()
      local lastline = vim.fn.line("$")
      if line > lastline then
        line = lastline
      end
      vim.api.nvim_win_set_cursor(0, {line, col})
    end
  )
end

M.normalize_path = function(path)
  local Path = require("plenary.path")
  local cwd = vim.fn.getcwd()
  return Path:new(path):normalize(cwd)
end

M.get_selected_content = function()
  local curr_buffer = vim.fn.bufnr("%")
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
    end_pos[3] = vim.fn.col("'>")
  else
    local cursor = vim.fn.getpos(".")
    start_pos = cursor
    end_pos = start_pos
  end

  local content =
    table.concat(
    vim.api.nvim_buf_get_text(curr_buffer, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3] - 1, {}),
    "\n"
  )

  return content
end

M.common_keymaps = {
  "a",
  "s",
  "d",
  "l",
  "k",
  "j",
  "q",
  "w",
  "e",
  "p",
  "o",
  "i",
  "r",
  "t",
  "y",
  "u",
  "g",
  "h",
  "f"
}

return M
