local M = {}

local strings = require("plenary.strings")
local fn = require("utils.fn")
local utils = require("utils")

local mappings = {
  ["<"] = "",
  [">"] = "",
  ["D"] = "⌘",
  ["A"] = "⌥",
  ["C"] = "⌃",
  ["-"] = " ",
  ["BS"] = "⌫",
  ["CR"] = "↩",
  ["leader"] = vim.g.mapleader .. " "
}

local ignore = function(fn)
  fn()
end

local default_make_actions = function(actions)
  return function(fn)
    fn(actions)
  end
end

M.make = function(picker)
  local actions = picker.actions or {}
  local options = picker.options or {}
  local make_actions = options.make_actions or default_make_actions(actions)
  local inject = options.inject or ignore

  make_actions(
    function(actions)
      inject(
        function(value)
          options = vim.tbl_extend("force", options, {prompt_title = options.prompt_title(value)})

          if options.theme then
            options = vim.tbl_extend("force", options.theme, options)
          end

          local items =
            vim.tbl_extend(
            "error",
            fn.imap(
              actions,
              function(action)
                local keymap = action.keymap

                if keymap then
                  keymap =
                    fn.kreduce(
                    mappings,
                    function(acc, value, index)
                      return string.gsub(acc, index, value)
                    end,
                    keymap
                  )
                end

                return {
                  name = action.name,
                  keymap = keymap,
                  handler = action.handler
                }
              end
            ),
            {
              on_select = function(context_menu)
                local selection = context_menu.state.get_selected_entry()

                local close = function()
                  context_menu.actions.close(context_menu.buffer)
                end

                local select = function()
                  return selection.value.handler(value)
                end

                if options.on_select then
                  return options.on_select(select, close)
                end

                close()
                select()
              end
            }
          )

          local entry_display = require("telescope.pickers.entry_display")
          local displayer =
            entry_display.create(
            {
              separator = " · ",
              items = {
                -- calculating the max width needed for the first column
                fn.ireduce(
                  items,
                  function(item, result)
                    item.width = math.max(item.width, strings.strdisplaywidth(result.keymap or ""))
                    return item
                  end,
                  {width = 1}
                ),
                {remaining = true}
              }
            }
          )
          local make_display = function(entry)
            local keymap = entry.value.keymap or ""

            return displayer(
              {
                {keymap, "PickerKeymap"},
                entry.value.name
              }
            )
          end
          local entry_maker = function(item)
            return {
              value = item,
              ordinal = item.name,
              display = make_display
            }
          end

          local finder =
            require("telescope.finders").new_table(
            {
              results = fn.imap(
                items,
                function(item)
                  return item
                end
              ),
              entry_maker = entry_maker
            }
          )
          local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()
          local default_options = {
            finder = finder,
            sorter = sorter,
            attach_mappings = function(prompt_buffer_number, map)
              local telescope_actions = require("telescope.actions")
              local telescope_state = require("telescope.actions.state")

              for _, action in pairs(actions) do
                if action.keymap then
                  map(
                    "i",
                    action.keymap,
                    function()
                      local close = function()
                        telescope_actions.close(prompt_buffer_number)
                      end

                      local select = function()
                        return action.handler(value)
                      end

                      if options.on_select then
                        return options.on_select(select, close)
                      end

                      close()
                      select()
                    end
                  )
                end
              end

              -- On select item
              telescope_actions.select_default:replace(
                function()
                  items.on_select(
                    {
                      buffer = prompt_buffer_number,
                      state = telescope_state,
                      actions = telescope_actions
                    }
                  )
                end
              )

              -- Disabling any kind of multiple selection
              telescope_actions.add_selection:replace(
                function()
                end
              )
              telescope_actions.remove_selection:replace(
                function()
                end
              )
              telescope_actions.toggle_selection:replace(
                function()
                end
              )
              telescope_actions.select_all:replace(
                function()
                end
              )
              telescope_actions.drop_all:replace(
                function()
                end
              )
              telescope_actions.toggle_all:replace(
                function()
                end
              )

              return true
            end
          }

          local mode = vim.fn.mode()
          if mode == "v" or mode == "V" then
            vim.api.nvim_command("normal! y")
          end

          require("telescope.pickers").new(options, default_options):find()
        end
      )
    end
  )
end

return M
