local engine = require("pickers.spectre.engine")
local fn = require("utils.fn")
local n = require("nui-components")
local search_tree = require("pickers.spectre.components.search_tree")

local M = {}

function M.toggle()
  if M.renderer then
    return M.renderer:focus()
  end

  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local width = 46
  local height = win_height - 2

  local renderer = n.create_renderer({
    width = width,
    height = height,
    relative = "editor",
    position = {
      row = 0,
      col = win_width - width - 1,
    },
  })

  local signal = n.create_signal({
    search_query = "",
    replace_query = "",
    search_paths = {},
    is_replace_field_visible = false,
    is_case_insensitive_checked = false,
    search_info = "",
    search_results = {},
  })

  local subscription = signal:observe(function(prev, curr)
    local diff = fn.isome({ "search_query", "is_case_insensitive_checked", "search_paths" }, function(key)
      return not vim.deep_equal(prev[key], curr[key])
    end)

    if diff then
      if #curr.search_query > 2 then
        engine.search(curr, signal)
      else
        signal.search_info = ""
        signal.search_results = {}
      end
    end

    if not (prev.replace_query == curr.replace_query) then
      signal.search_results = engine.process(curr)
    end
  end)

  renderer:add_mappings({
    {
      mode = { "n", "i" },
      from = "<leader>c",
      to = function()
        renderer:close()
      end,
    },
  })

  renderer:on_unmount(function()
    subscription:unsubscribe()
    M.renderer = nil
  end)

  M.renderer = renderer

  local body = n.rows(n.columns(
    n.checkbox({
      default_sign = "→",
      checked_sign = "↓",
      padding = {
        top = 1,
        left = 1,
      },
      value = signal.is_replace_field_visible,
      on_change = function(is_checked)
        signal.is_replace_field_visible = is_checked

        if is_checked then
          local replace_component = renderer:get_component_by_id("replace_query")

          if replace_component then
            vim.schedule(function()
              replace_component:focus()
            end)
          end
        end
      end,
    }),
    n.rows(
      n.columns(
        { size = 3 },
        n.text_input({
          focus = true,
          flex = 1,
          max_lines = 1,
          border_label = "Search",
          on_change = fn.debounce(function(value)
            signal.search_query = value
          end, 400),
        }),
        n.checkbox({
          label = "Aa",
          default_sign = "",
          checked_sign = "",
          border_style = "rounded",
          value = signal.is_case_insensitive_checked,
          on_change = function(is_checked)
            signal.is_case_insensitive_checked = is_checked
          end,
        })
      ),
      n.text_input({
        size = 1,
        max_lines = 1,
        id = "replace_query",
        border_label = "Replace",
        on_change = fn.debounce(function(value)
          signal.replace_query = value
        end, 400),
        hidden = signal.is_replace_field_visible:map(function(value)
          return not value
        end),
      }),
      n.text_input({
        size = 1,
        max_lines = 1,
        border_label = "Files to include",
        value = signal.search_paths:map(function(paths)
          return table.concat(paths, ",")
        end),
        on_change = fn.debounce(function(value)
          signal.search_paths = fn.ireject(fn.imap(vim.split(value, ","), fn.trim), function(path)
            return path == ""
          end)
        end, 400),
      }),
      n.rows(
        {
          flex = 0,
          hidden = signal.search_info:map(function(value)
            return value == ""
          end),
        },
        n.gap(1),
        n.text(signal.search_info, {
          padding = {
            left = 1,
            right = 1,
          },
        })
      ),
      n.gap(1),
      search_tree({
        style = "none",
        flex = 1,
        padding = {
          left = 1,
          right = 1,
        },
        data = signal.search_results,
        origin_winid = renderer:get_origin_winid(),
        hidden = signal.search_results:map(function(value)
          return #value == 0
        end),
      })
      -- n.gap(1),
      -- n.columns(
      --   {
      --     size = 1,
      --     on_state_change = function(state)
      --       return {
      --         hidden = not (state.search_results and #state.replace_value > 0)
      --       }
      --     end
      --   },
      --   n.gap({flex = 1}),
      --   n.button(
      --     {
      --       label = "Replace All",
      --       on_press = function()
      --       end
      --     }
      --   ),
      --   n.gap(1),
      --   n.button(
      --     {
      --       label = "Clear",
      --       on_press = function()
      --       end
      --     }
      --   )
      -- )
    )
  ))

  renderer:render(body)
end

return M
