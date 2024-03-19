local M = {}

local fn = require("utils.fn")
local utils = require("utils")

local schedule = function(fn)
  return function(args)
    utils.schedule(function()
      fn(args)
    end)
  end
end

-- local function on_code_action_results(results, ctx, options)
--   -- If options.apply is given, and there are just one remaining code action,
--   -- apply it directly without querying the user.
--   if options and options.apply and #action_tuples == 1 then
--     on_user_choice(action_tuples[1])
--     return
--   end

--   vim.ui.select(
--     action_tuples,
--     {
--       prompt = "Code actions:",
--       kind = "codeaction",
--       format_item = function(action_tuple)
--         local title = action_tuple[2].title:gsub("\r\n", "\\r\\n")
--         return title:gsub("\n", "\\n")
--       end
--     },
--     on_user_choice
--   )
-- end

M.options = {
  prompt_title = function()
    return "Code actions"
  end,
  make_actions = function(make)
    local ctx = {
      diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
    }
    local params = vim.lsp.util.make_range_params()

    params.context = ctx

    vim.lsp.buf_request_all(vim.api.nvim_get_current_buf(), "textDocument/codeAction", params, function(results)
      local action_tuples = {}

      for client_id, result in pairs(results) do
        for _, action in pairs(result.result or {}) do
          table.insert(action_tuples, { client_id, action })
        end
      end

      if #action_tuples == 0 then
        vim.notify("No code actions available", vim.log.levels.INFO)
        return
      end

      local apply_action = function(action, client)
        if action.edit then
          require("vim.lsp.util").apply_workspace_edit(action.edit, client.offset_encoding)
        end
        if action.command then
          local command = type(action.command) == "table" and action.command or action
          local fn = client.commands[command.command] or vim.lsp.commands[command.command]
          if fn then
            local enriched_ctx = vim.deepcopy(ctx)
            enriched_ctx.client_id = client.id
            fn(command, enriched_ctx)
          else
            local params = {
              command = command.command,
              arguments = command.arguments,
              workDoneToken = command.workDoneToken,
            }
            client.request("workspace/executeCommand", params, nil, ctx.bufnr)
          end
        end
      end

      local on_user_choice = function(action_tuple)
        if not action_tuple then
          return
        end
        -- textDocument/codeAction can return either Command[] or CodeAction[]
        --
        -- CodeAction
        --  ...
        --  edit?: WorkspaceEdit    -- <- must be applied before command
        --  command?: Command
        --
        -- Command:
        --  title: string
        --  command: string
        --  arguments?: any[]
        --
        local client = vim.lsp.get_client_by_id(action_tuple[1])
        local action = action_tuple[2]
        if
          not action.edit
          and client
          and vim.tbl_get(client.server_capabilities, "codeActionProvider", "resolveProvider")
        then
          client.request("codeAction/resolve", action, function(err, resolved_action)
            if err then
              vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
              return
            end
            apply_action(resolved_action, client)
          end)
        else
          apply_action(action, client)
        end
      end

      local keymap_index = 0

      local actions = fn.imap(action_tuples, function(action_tuple, index)
        local title = action_tuple[2].title

        keymap_index = keymap_index + 1

        return {
          name = string.gsub(title, "^%u", string.lower),
          keymap = utils.common_keymaps[keymap_index],
          handler = schedule(function()
            on_user_choice(action_tuple)
          end),
        }
      end)

      if #actions > 0 then
        make(actions)
      end
    end)
  end,
  theme = require("telescope.themes").get_cursor({
    layout_config = {
      height = 0.3,
    },
  }),
}

return M
