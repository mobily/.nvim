local fn = require("utils.fn")
local n = require("nui-components")

local function replace_handler(tree, node)
  return {
    on_done = function(result)
      if result.ref then
        node.ref = result.ref
        tree:render()
      end
    end,
    on_error = function(_) end,
  }
end

local function mappings(search_query, replace_query)
  local spectre_state_utils = require("spectre.state_utils")

  return function(component)
    return {
      {
        mode = { "n" },
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
              replacer_creator:new(spectre_state_utils.get_replace_engine_config(), replace_handler(tree, focused_node))

            local entry = focused_node.entry

            replacer:replace({
              lnum = entry.lnum,
              col = entry.col,
              cwd = vim.fn.getcwd(),
              display_lnum = 0,
              filename = entry.filename,
              search_text = search_query:get(),
              replace_text = replace_query:get(),
            })
          end
        end,
      },
    }
  end
end

local function prepare_node(node, line, component)
  local _, devicons = pcall(require, "nvim-web-devicons")
  local has_children = node:has_children()

  line:append(string.rep("  ", node:get_depth() - 1))

  if has_children then
    local icon, icon_highlight = devicons.get_icon(node.text, string.match(node.text, "%a+$"), { default = true })

    line:append(node:is_expanded() and " " or " ", component:make_hl("SpectreIcon"))
    line:append(icon .. " ", icon_highlight)
    line:append(node.text, component:make_hl("SpectreFileName"))

    return line
  end

  local is_replacing = #node.diff.replace > 0
  local search_highlight_group = component:make_hl(is_replacing and "SpectreSearchOldValue" or "SpectreSearchValue")
  local default_text_highlight = component:make_hl("SpectreCodeLine")

  local _, empty_spaces = string.find(node.diff.text, "^%s*")
  local ref = node.ref

  if ref then
    line:append("✔ ", component:make_hl("SpectreReplaceSuccess"))
  end

  if #node.diff.search > 0 then
    local code_text = fn.trim(node.diff.text)

    fn.ieach(node.diff.search, function(value, index)
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
          string.sub(code_text, replace_diff_value[1] + 1 - empty_spaces, replace_diff_value[2] - empty_spaces)
        line:append(replace_text, component:make_hl("SpectreSearchNewValue"))
        end_ = replace_diff_value[2] - empty_spaces
      end

      if index == #node.diff.search then
        line:append(string.sub(code_text, end_ + 1), default_text_highlight)
      end
    end)
  end

  return line
end

local function on_select(origin_winid)
  return function(node, component)
    local tree = component:get_tree()

    if node:has_children() then
      if node:is_expanded() then
        node:collapse()
      else
        node:expand()
      end
      return tree:render()
    end

    local entry = node.entry

    if vim.api.nvim_win_is_valid(origin_winid) then
      local escaped_filename = vim.fn.fnameescape(entry.filename)

      vim.api.nvim_set_current_win(origin_winid)
      vim.api.nvim_command([[execute "normal! m` "]])
      vim.cmd("e " .. escaped_filename)
      vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
    end
  end
end

local function search_tree(props)
  props = fn.merge({
    mappings = mappings(props.search_query, props.replace_query),
    prepare_node = prepare_node,
    on_select = on_select(props.origin_winid),
  }, props)

  return n.tree(props)
end

return search_tree
