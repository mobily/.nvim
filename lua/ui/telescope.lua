local M = {}
-- support for hls - https://github.com/nvim-telescope/telescope.nvim/blob/e8c01bab917537ba4f54193c29b77bf4a04584d3/lua/telescope/builtin/__files.lua#L411
M.gen_from_buffer_lines = function(opts)
  local entry_display = require("telescope.pickers.entry_display")
  local utils = require("telescope.utils")
  local make_entry = require("telescope.make_entry")

  opts = opts or {}

  local displayer =
    entry_display.create {
    items = {
      {remaining = true}
    }
  }

  local make_display = function(entry)
    return displayer {
      -- {entry.lnum, opts.lnum_highlight_group or "TelescopeResultsSpecialComment"},
      {
        entry.text,
        function()
          if not opts.line_highlights then
            return {}
          end

          -- local line_hl = opts.line_highlights[entry.lnum] or {}
          -- local result = {}

          -- for col, hl in pairs(line_hl) do
          --   table.insert(result, {{col, col + 1}, hl})
          -- end

          -- return result
        end
      }
    }
  end

  return function(entry)
    return make_entry.set_default_entry_mt(
      {
        ordinal = entry.text,
        display = make_display,
        filename = entry.filename,
        lnum = entry.lnum,
        text = entry.text
      },
      opts
    )
  end
end

return M
