local M = {}

local fn = require("utils.fn")
local previewers = require("telescope.previewers")
local utils = require("utils")

local make_picker = function(results, opts)
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local config = require("telescope.config").values

  opts = opts or {}

  require("telescope.pickers")
    .new(opts, {
      finder = finders.new_table({
        results = results,
        entry_maker = make_entry.gen_from_marks(opts),
      }),
      previewer = config.grep_previewer(opts),
      sorter = config.generic_sorter(opts),
      push_cursor_on_edit = true,
      push_tagstack_on_edit = true,
    })
    :find()
end

local make_bookmarks_picker = function()
  local groups = require("marks").bookmark_state.groups

  -- local buffers = {}
  -- local bufnrs = {}

  local bookmarks = {}

  for _, group in pairs(groups) do
    for bufnr, buffer_marks in pairs(group.marks) do
      for lnum, mark in pairs(buffer_marks) do
        local name = utils.normalize_path(vim.fn.getbufinfo(bufnr)[1].name)

        -- local name = fn.trim(vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1])
        local col = mark.col + 1

        local text = string.format("%s %6d %4d %s", group.sign, lnum, col, name)

        table.insert(bookmarks, {
          line = text,
          lnum = lnum,
          col = col,
          filename = vim.api.nvim_buf_get_name(bufnr),
        })

        -- local flag = bufnr == vim.fn.bufnr "" and "%" or (bufnr == vim.fn.bufnr "#" and "#" or " ")

        -- table.insert(bufnrs, bufnr)
        -- table.insert(
        --   buffers,
        --   {
        --     bufnr = bufnr,
        --     flag = flag,
        --     info = vim.fn.getbufinfo(bufnr)[1]
        --   }
        -- )

        -- {
        --   -- bufnr = bufnr,
        --   -- lnum = line,
        --   -- col = mark.col + 1,
        --   name = group_nr .. " · " .. fn.trim(text),
        --   handler = function()
        --   end
        -- }
      end
    end
  end

  make_picker(bookmarks, {
    prompt_title = "Bookmarks",
  })

  -- vim.notify(vim.inspect(buffers))

  -- local max_bufnr = math.max(unpack(bufnrs))
  -- local bufnr_width = #tostring(max_bufnr)
end

local make_marks = function(bufnr, buffer_state, opts)
  opts = opts or {}

  marks = opts.marks or {}

  local map_name = opts.map_name
    or function(bufnr, lnum)
      return utils.normalize_path(vim.fn.getbufinfo(bufnr)[1].name)
    end

  for mark, data in pairs(buffer_state.placed_marks) do
    local lnum = data.line
    local name = map_name(bufnr, lnum)
    local col = data.col + 1

    local text = string.format("%s %6d %4d %s", mark, lnum, col, name)

    table.insert(marks, {
      line = text,
      lnum = lnum,
      col = col,
      filename = vim.api.nvim_buf_get_name(bufnr),
    })
  end

  return marks
end

local make_marks_picker = function()
  -- local bufnrs =
  --   fn.ifilter(
  --   vim.api.nvim_list_bufs(),
  --   function(buffer)
  --     if 1 ~= vim.fn.buflisted(buffer) then
  --       return false
  --     end

  --     -- if buffer == vim.api.nvim_get_current_buf() then
  --     --   return false
  --     -- end

  --     -- if not vim.api.nvim_buf_is_loaded(b) then
  --     --   return false
  --     -- end

  --     return true
  --   end
  -- )

  -- for _, bufnr in pairs(bufnrs) do
  --   require("marks").mark_state:refresh(bufnr)
  -- end

  local buffers = require("marks").mark_state.buffers
  local marks = {}

  for bufnr, buffer_state in pairs(buffers) do
    make_marks(bufnr, buffer_state, { marks = marks })
  end

  make_picker(marks, {
    prompt_title = "Marks",
  })
end

local make_buffer_marks_picker = function()
  local buffers = require("marks").mark_state.buffers
  local bufnr = vim.api.nvim_get_current_buf()

  if not buffers[bufnr] then
    return
  end

  local marks = make_marks(bufnr, buffers[bufnr], {
    map_name = function(bufnr, lnum)
      return fn.trim(vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1])
    end,
  })

  make_picker(marks, {
    prompt_title = "Buffer Marks",
  })
end

local toggle_bookmark = function(bookmark)
  return function()
    local marks = require("marks")
    local groups = marks.bookmark_state.groups

    local has_bookmark = false

    local current_bufnr = vim.api.nvim_get_current_buf()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    for group_nr, group in pairs(groups) do
      for bufnr, buffer_marks in pairs(group.marks) do
        for lnum, mark in pairs(buffer_marks) do
          if line == lnum and current_bufnr == bufnr then
            has_bookmark = true
            break
          end
        end
      end
    end

    if has_bookmark then
      return marks.bookmark_state:delete_mark_cursor()
    end

    marks.bookmark_state:place_mark(bookmark)
  end
end

local delete_buffer_bookmarks = function()
  local marks = require("marks")
  local utils = require("marks.utils")
  local groups = marks.bookmark_state.groups

  local current_bufnr = vim.api.nvim_get_current_buf()

  for group_nr, group in pairs(groups) do
    for bufnr, buffer_marks in pairs(group.marks) do
      for lnum, mark in pairs(buffer_marks) do
        if current_bufnr == bufnr then
          if mark.sign_id then
            utils.remove_sign(current_bufnr, mark.sign_id, "BookmarkSigns")
          end

          vim.api.nvim_buf_del_extmark(current_bufnr, group.ns, mark.extmark_id)
          break
        end
      end
    end

    group.marks[current_bufnr] = nil
  end
end

M.actions = {
  {
    name = "toggle bookmark · ",
    keymap = "<D-1>",
    handler = toggle_bookmark(1),
  },
  {
    name = "toggle bookmark · ",
    keymap = "<D-2>",
    handler = toggle_bookmark(2),
  },
  {
    name = "toggle mark",
    keymap = "m",
    handler = require("marks").toggle,
  },
  {
    name = "delete buffer bookmarks",
    keymap = "dd",
    handler = delete_buffer_bookmarks,
  },
  {
    name = "delete buffer marks",
    keymap = "dm",
    handler = require("marks").delete_buf,
  },
  {
    name = "list current buffer marks",
    keymap = "<D-m>",
    handler = make_buffer_marks_picker,
  },
  {
    name = "list all marks",
    keymap = "<D-a>",
    handler = make_marks_picker,
  },
  {
    name = "list all bookmarks",
    keymap = "<D-l>",
    handler = make_bookmarks_picker,
  },
}

M.options = {
  prompt_title = function(args)
    return "Marks"
  end,
  theme = require("telescope.themes").get_cursor({
    layout_config = {
      height = 0.3,
    },
  }),
}

return M
