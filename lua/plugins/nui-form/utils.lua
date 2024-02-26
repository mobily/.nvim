local M = {}

M.augroup = vim.api.nvim_create_augroup("NuiForm", {clear = true})

M.keymap = function(buffer, mode, from, to)
  vim.keymap.set(mode, from, to, {noremap = true, silent = true, buffer = buffer})
end

M.ignore = function()
end

M.always = function(value)
  return function()
    return value
  end
end

M.set_default_options = function(options)
  return vim.tbl_extend(
    "force",
    {
      height = 3,
      is_focusable = true,
      validate = M.always(true),
      hidden = M.always(false)
    },
    vim.F.if_nil(options, {})
  )
end

M.attach_prev_next_focus = function(component)
  local bufnr = component.bufnr
  local form = component:get_form()
  local options = component:get_options()

  M.keymap(
    bufnr,
    {"i", "n"},
    "<Tab>",
    function()
      local index = options.focus_index
      local next = form.focusable_components[index + 1] or form.focusable_components[1]
      vim.api.nvim_set_current_win(next.winid)
    end
  )

  M.keymap(
    bufnr,
    {"i", "n"},
    "<S-Tab>",
    function()
      local index = options.focus_index
      local prev = form.focusable_components[index - 1] or form.focusable_components[#form.focusable_components]
      vim.api.nvim_set_current_win(prev.winid)
    end
  )
end

M.set_initial_focus = function(component)
  if component:get_options().focus then
    vim.api.nvim_set_current_win(component.winid)
  end
end

M.attach_form_events = function(component)
  local bufnr = component.bufnr
  local form = component:get_form()

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
