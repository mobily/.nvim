local M = {}

M.augroup = vim.api.nvim_create_augroup("NuiForm", {clear = true})

M.keymap = function(buffer, mode, from, to)
  vim.keymap.set(mode, from, to, {noremap = true, silent = true, buffer = buffer})
end

M.ignore = function()
end

M.set_default_height = function(options)
  return vim.tbl_extend("force", {height = 3}, vim.F.if_nil(options, {}))
end

M.attach_prev_next_focus = function(element)
  local bufnr = element.bufnr
  local form = element.instance.form
  local index = element.instance.options.index

  M.keymap(
    bufnr,
    {"i", "n"},
    "<Tab>",
    function()
      local next = form.focusable_elements[index + 1] or form.focusable_elements[1]
      vim.api.nvim_set_current_win(next.winid)
    end
  )

  M.keymap(
    bufnr,
    {"i", "n"},
    "<S-Tab>",
    function()
      local prev = form.focusable_elements[index - 1] or form.focusable_elements[#form.focusable_elements]
      vim.api.nvim_set_current_win(prev.winid)
    end
  )
end

M.set_initial_focus = function(element)
  if element.instance.options.focus then
    vim.api.nvim_set_current_win(element.winid)
  end
end

M.attach_form_events = function(element)
  local bufnr = element.bufnr
  local form = element.instance.form

  vim.api.nvim_create_autocmd(
    "WinClosed",
    {
      group = M.augroup,
      buffer = bufnr,
      callback = function(event)
        form.layout:unmount()
        form.on_close()
      end
    }
  )

  M.keymap(
    bufnr,
    {"n"},
    form.keymap.close,
    function()
      form.layout:unmount()
      form.on_close()
    end
  )

  M.keymap(
    bufnr,
    {"i", "n"},
    form.keymap.submit,
    function()
      if form:validate() then
        form.layout:unmount()
        form.on_submit(form.state)
      end
    end
  )
end

return M
