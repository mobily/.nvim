local Renderer = require("plugins.nui-components")
local Tree = require("nui.tree")

local Text = require("nui.text")

local fn = require("utils.fn")

local M = {}

M.toggle = function()
  if M.renderer then
    return M.renderer:focus()
  end

  local spectre_state_utils = require("spectre.state_utils")
  local spectre_utils = require("spectre.utils")
  local spectre_search = require("spectre.search")
  local spectre_state = require("spectre.state")
  local spectre_actions = require("spectre.actions")

  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local width = 46
  local height = win_height - 2

  spectre_state.finder_instance = nil
  spectre_state.is_running = false
  spectre_state.query.search_query = ""
  spectre_state.query.replace_query = ""
  spectre_state.search_paths = nil
  spectre_state.groups = {}

  local h =
    Renderer:new(
    {
      width = width,
      height = height,
      relative = "editor",
      position = {
        row = 0,
        col = win_width - width - 1
      },
      on_close = function()
        M.renderer = nil
      end
    }
  )

  M.renderer = h

  local process = function()
    local results =
      fn.kmap(
      spectre_state.groups,
      function(group, filename)
        local children =
          fn.imap(
          group,
          function(item)
            local id = tostring(math.random())

            local diff =
              spectre_utils.get_hl_line_text(
              {
                search_query = spectre_state.query.search_query,
                replace_query = spectre_state.query.replace_query,
                search_text = item.text,
                padding = 0
              },
              spectre_state.regex
            )

            return Tree.Node({text = diff.text, _id = id, diff = diff, entry = item})
          end
        )

        local id = tostring(math.random())
        local node = Tree.Node({text = filename:gsub("^./", ""), _id = id}, children)

        node:expand()

        return node
      end
    )

    h:set_state("search_results", results)
  end

  local replace_handler = function(tree, node)
    return {
      on_done = function(result)
        if result.ref then
          node.ref = result.ref
          tree:render()
        -- vim.notify(vim.inspect(result))
        end
      end,
      on_error = function(result)
      end
    }
  end

  local search_handler = function()
    local start_time = 0
    local total = 0

    spectre_state.groups = {}

    return {
      on_start = function()
        spectre_state.is_running = true
        start_time = vim.loop.hrtime()
      end,
      on_result = function(item)
        if not spectre_state.is_running then
          return
        end

        if not spectre_state.groups[item.filename] then
          spectre_state.groups[item.filename] = {}
        end

        table.insert(spectre_state.groups[item.filename], item)
        total = total + 1
      end,
      on_error = function(message)
        -- print(message)
      end,
      on_finish = function()
        if not spectre_state.is_running then
          return
        end

        local end_time = (vim.loop.hrtime() - start_time) / 1E9

        h:set_state("search_info", string.format("Total: %s match, time: %ss", total, end_time))

        process()

        spectre_state.finder_instance = nil
        spectre_state.is_running = false
      end
    }
  end

  local stop = function()
    if not spectre_state.finder_instance then
      return
    end

    spectre_state.finder_instance:stop()
    spectre_state.finder_instance = nil
  end

  local search = function()
    stop()

    local search_engine = spectre_search["rg"]
    spectre_state.finder_instance = search_engine:new(spectre_state_utils.get_search_engine_config(), search_handler())

    local config = {
      cwd = vim.fn.getcwd(),
      search_text = spectre_state.query.search_query,
      replace_query = spectre_state.query.replace_query,
      path = spectre_state.query.path,
      search_paths = spectre_state.search_paths
    }

    spectre_state.regex = require("spectre.regex.vim")

    if #spectre_state.query.search_query > 2 then
      pcall(
        function()
          spectre_state.finder_instance:search(config)
        end
      )
    else
      h:set_state("search_results", {})
      h:set_state("search_info", nil)
    end
  end

  spectre_state.options["ignore-case"] = true

  local body =
    h.rows(
    h.columns(
      h.checkbox(
        {
          id = "display_replace_mode",
          sign = {
            default = "→",
            checked = "↓"
          },
          padding = {
            top = 1,
            left = 1
          },
          on_change = function(is_checked)
            if is_checked then
              local replace_component = h:get_component_by_id("replace_value")

              if replace_component then
                vim.schedule(
                  function()
                    replace_component:focus()
                  end
                )
              end
            end
          end
        }
      ),
      h.rows(
        h.columns(
          {size = 3},
          h.text_input(
            {
              focus = true,
              flex = 1,
              id = "search_value",
              label = "Search",
              on_change = fn.debounce(
                function(value)
                  spectre_state.query.search_query = value
                  search()
                end,
                400
              )
            }
          ),
          h.checkbox(
            {
              text = "Aa",
              id = "case_insensitive",
              sign = {
                default = "",
                checked = ""
              },
              style = "rounded",
              on_change = function(is_checked)
                spectre_state.options["ignore-case"] = not is_checked
                search()
              end
            }
          )
        ),
        h.text_input(
          {
            size = 1,
            id = "replace_value",
            label = "Replace",
            on_change = fn.debounce(
              function(value)
                spectre_state.query.replace_query = value
                process()
              end,
              400
            ),
            on_state_change = function(state)
              return {
                hidden = not state.display_replace_mode
              }
            end
          }
        ),
        h.text_input(
          {
            size = 1,
            id = "files_to_include",
            label = "Files to include",
            on_change = fn.debounce(
              function(value)
                local search_paths =
                  fn.imap(
                  vim.split(value, ","),
                  function(path)
                    return fn.trim(path)
                  end
                )

                spectre_state.search_paths = #value > 0 and search_paths or nil
                search()
              end,
              400
            )
          }
        ),
        h.gap(
          {
            size = 1,
            on_state_change = function(state)
              return {
                hidden = not state.search_info
              }
            end
          }
        ),
        h.text(
          {
            padding = {
              left = 1,
              right = 1
            },
            on_state_change = function(state)
              return {
                text = state.search_info or "",
                hidden = not state.search_info
              }
            end
          }
        ),
        h.gap(1),
        h.tree(
          {
            id = "file_tree",
            style = "none",
            flex = 1,
            padding = {
              left = 1,
              right = 1
            },
            mappings = function(component)
              return {
                {
                  mode = {"n"},
                  from = "r",
                  to = function()
                    local tree = component:get_tree()
                    local focused_node = component:get_focused_node()

                    if not focused_node then
                      return
                    end

                    local has_children = focused_node:has_children()

                    if not has_children then
                      local replacer_creator = spectre_state_utils.get_replace_creator()
                      local replacer =
                        replacer_creator:new(
                        spectre_state_utils.get_replace_engine_config(),
                        replace_handler(tree, focused_node)
                      )

                      local entry = focused_node.entry

                      replacer:replace(
                        {
                          lnum = entry.lnum,
                          col = entry.col,
                          cwd = vim.fn.getcwd(),
                          display_lnum = 0,
                          filename = entry.filename,
                          search_text = spectre_state.query.search_query,
                          replace_text = spectre_state.query.replace_query
                        }
                      )
                    end
                  end
                }
              }
            end,
            prepare_node = function(node, line, component)
              local has_devicons, devicons = pcall(require, "nvim-web-devicons")
              local has_children = node:has_children()

              line:append(string.rep("  ", node:get_depth() - 1))

              if has_children then
                local icon, icon_highlight =
                  devicons.get_icon(node.text, string.match(node.text, "%a+$"), {default = true})

                line:append(node:is_expanded() and " " or " ", component:make_highlight_group_name("SpectreIcon"))
                line:append(icon .. " ", icon_highlight)
                line:append(node.text, component:make_highlight_group_name("SpectreFileName"))

                return line
              end

              local is_replacing = #node.diff.replace > 0
              local search_highlight_group =
                component:make_highlight_group_name(is_replacing and "SpectreSearchOldValue" or "SpectreSearchValue")
              local default_text_highlight = component:make_highlight_group_name("SpectreCodeLine")

              local _, empty_spaces = string.find(node.diff.text, "^%s*")

              local ref = node.ref
              if ref then
                line:append("✔ ", component:make_highlight_group_name("SpectreReplaceSuccess"))
              end

              if #node.diff.search > 0 then
                local code_text = fn.trim(node.diff.text)

                fn.ieach(
                  node.diff.search,
                  function(value, index)
                    local start = value[1] - empty_spaces
                    local end_ = value[2] - empty_spaces

                    if index == 1 then
                      line:append(string.sub(code_text, 1, start), default_text_highlight)
                    end

                    local search_text = string.sub(code_text, start + 1, end_)
                    line:append(search_text, search_highlight_group)

                    local replace_diff_value = node.diff.replace[index]

                    if replace_diff_value then
                      local replace_text =
                        string.sub(
                        code_text,
                        replace_diff_value[1] + 1 - empty_spaces,
                        replace_diff_value[2] - empty_spaces
                      )
                      line:append(replace_text, component:make_highlight_group_name("SpectreSearchNewValue"))
                      end_ = replace_diff_value[2] - empty_spaces
                    end

                    if index == #node.diff.search then
                      line:append(string.sub(code_text, end_ + 1), default_text_highlight)
                    end
                  end
                )
              else
                line:append(code_text, default_text_highlight)
              end

              return line
            end,
            on_select = function(node, tree)
              if node:has_children() then
                if node:is_expanded() then
                  node:collapse()
                else
                  node:expand()
                end
                return tree:render()
              end

              local entry = node.entry
              local origin_winid = h:get_origin_winid()

              if vim.api.nvim_win_is_valid(origin_winid) then
                local escaped_filename = vim.fn.fnameescape(entry.filename)

                vim.api.nvim_set_current_win(origin_winid)
                vim.api.nvim_command([[execute "normal! m` "]])
                vim.cmd("e " .. escaped_filename)
                vim.api.nvim_win_set_cursor(0, {entry.lnum, entry.col - 1})
              end
            end,
            on_state_change = function(state)
              if not state.search_results then
                return {
                  hidden = true
                }
              end

              return {
                hidden = #state.search_results == 0,
                data = state.search_results
              }
            end
          }
        )
        -- h.gap(1),
        -- h.columns(
        --   {
        --     size = 1,
        --     on_state_change = function(state)
        --       return {
        --         hidden = not (state.search_results and #state.replace_value > 0)
        --       }
        --     end
        --   },
        --   h.gap({flex = 1}),
        --   h.button(
        --     {
        --       label = "Replace All",
        --       on_press = function()
        --       end
        --     }
        --   ),
        --   h.gap(1),
        --   h.button(
        --     {
        --       label = "Clear",
        --       on_press = function()
        --       end
        --     }
        --   )
        -- )
      )
    )
  )

  h:render(body)
end

return M
