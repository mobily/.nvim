local utils = require("utils")
local buffers = require("utils.buffers")
local fn = require("utils.fn")
local harpoon = require("harpoon")

local map = utils.keymap_factory("n")
local map_with_visual = utils.keymap_factory({"n", "v"})

local cmd = utils.cmd

local hop = require("hop")
local telescope_ui = require("ui.telescope")

local is_default_buffer = function()
  return buffers.is_not_focused_buffer("NvimTree_1", "mind", "spectre", "gen.nvim")
end

map("s", hop.hint_patterns, "hop patterns")
map("f", hop.hint_char2, "hop char")
map("<leader>w", hop.hint_words, "hop words")
map("<leader>q", hop.hint_lines, "hop lines")

map("<ESC>", cmd "noh", "no highlight")

map("<C-n>", cmd "NvimTreeToggle", "toggle nvimtree")
map("<D-=>", utils.focus_nvim_tree("<Esc>"), "focus nvimtree")

map("<leader>t", cmd "ToggleTerm", "toggle terminal")
map("<leader>1", cmd "ToggleTerm 1", "toggle terminal #1")
map("<leader>2", cmd "ToggleTerm 2 dir=horizontal", "toggle terminal #2")
map("<leader>3", cmd "ToggleTerm 3 dir=horizontal", "toggle terminal #3")
map("<leader>a", cmd "ToggleTermToggleAll", "toggle all terminals")

map("<leader>s", cmd "SwapSplit", "swap split")
map("<leader>v", cmd "vsplit", "vertical split")
map("<leader>h", cmd "split", "horizontal split")
map("<leader>c", cmd "close", "close split")

map(
  "<D-s>",
  function()
    if is_default_buffer() then
      vim.api.nvim_command("write!")
    end
  end,
  "save file"
)

map_with_visual(
  "<D-F>",
  function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" then
      require("spectre").open_visual({select_word = true})
    else
      require("spectre").toggle()
    end
  end,
  "find & replace"
)

map(
  "<D-[>",
  function()
    local is_tabline_hidden = vim.api.nvim_eval("&showtabline") == 0

    if is_tabline_hidden then
      harpoon:list():prev()
    else
      buffers.prev_buffer()
    end
  end,
  "goto prev buffer"
)
map(
  "<D-]>",
  function()
    local is_tabline_hidden = vim.api.nvim_eval("&showtabline") == 0

    if is_tabline_hidden then
      harpoon:list():next()
    else
      buffers.next_buffer()
    end
  end,
  "goto next buffer"
)
map(
  "<D-w>",
  function()
    local win_amount = #vim.api.nvim_tabpage_list_wins(0)
    local is_tree_visible = require("nvim-tree.view").is_visible()
    local is_mind_visible = vim.g.mind_is_visible

    win_amount = is_tree_visible and win_amount - 1 or win_amount
    win_amount = is_mind_visible and win_amount - 1 or win_amount

    if win_amount == 1 then
      buffers.close_buffer()
    else
      vim.cmd("close")
    end
  end,
  "close buffer or split"
)

map("<S-Tab>", "<<_", "unindent")
map("<Tab>", ">>_", "indent")

map("<D-c>", "yy", "copy line")
map("<D-x>", "dd<Up>", "cut line")

map("<D-v>", "gp", "paste")

map(
  "<D-z>",
  function()
    utils.preserve_cursor_position(
      function()
        vim.api.nvim_input("u")
      end
    )
  end,
  "undo"
)
map(
  "<D-r>",
  function()
    utils.preserve_cursor_position(
      function()
        vim.api.nvim_input("<C-r>")
      end
    )
  end,
  "redo"
)

map("<D-a>", "ggVG", "select whole file")
map("<D-M-BS>", "<S-s>", "delete line")
map("<D-BS>", '"_diw', "delete word")

map("<M-Left>", "b", "move cursor left")
map("<M-Right>", "e", "move cursor right")
map("<M-Up>", "5k", "move cursor up")
map("<M-Down>", "5j", "move cursor down")
map("<D-Up>", "1G", "beginning of file")
map("<D-Down>", "G", "end of file")
map("<D-Left>", "^", "beginning of line")
map("<D-Right>", "$", "end of line")
map("<D-n>", cmd "enew", "new buffer")

map("<D-L>", "<Plug>(dial-increment)", "dial inc")
map("<D-K>", "<Plug>(dial-decrement)", "dial dec")

map(
  "<D-S-BS>",
  function()
    lastline = vim.api.nvim_eval('line(".") == line("$")')

    if lastline == 1 then
      vim.api.nvim_input('"_dd')
      return
    end

    vim.api.nvim_input('"_dd<Up>')
  end,
  "delete line"
)

map("<D-f>", cmd "Telescope live_grep", "grep files")

map("<D-C-Right>", cmd "vertical resize +5", "resize split vertically")
map("<D-C-Left>", cmd "vertical resize -5", "resize split vertically")
map("<D-C-Down>", cmd "resize +5", "resize split horizontally")
map("<D-C-Up>", cmd "resize -5", "resize split horizontally")

map("<D-S-Left>", "<C-w>h", "window left")
map("<D-S-Right>", "<C-w>l", "window right")
map("<D-S-Down>", "<C-w>j", "window down")
map("<D-S-Up>", "<C-w>k", "window up")

map(
  "<D-/>",
  function()
    vim.api.nvim_input("gcc")
  end,
  "comment line"
)
-- map("<D-S-Down>", "<Plug>GoNMLineDown", "move line down")
-- map("<D-S-Up>", "<Plug>GoNMLineUp", "move line up")
map(
  "<D-d>",
  function()
    vim.api.nvim_input("*``cgn")
  end,
  "find and replace"
)

map(
  "<D-g>",
  function()
    vim.api.nvim_input(":%s/")
  end,
  "find and replace"
)

map(
  "<D-1>",
  function()
    vim.lsp.buf.hover()
  end,
  "display lsp type"
)

map(
  "<D-;>",
  function()
    vim.diagnostic.open_float(
      {
        border = "rounded"
      }
    )
  end,
  "display diagnostics"
)

map(
  "<D-.>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.code-action")
      require("ui.picker").make(menu)
    end
    -- vim.lsp.buf.code_action()
  end,
  "code action"
)

map(
  "<D-m>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.marks")
      require("ui.picker").make(menu)
    end
  end,
  "marks"
)

-- map(
--   "<D-0>",
--   function()
--     local cwd = vim.fn.getcwd()

--     vim.api.nvim_input(":wa<CR>")

--     if not (cwd == "/") then
--       vim.api.nvim_input(":SaveSession<CR>")
--     end

--     utils.schedule(
--       function()
--         require("workspaces").open()
--       end
--     )
--   end,
--   "save session and open workspace"
-- )

map_with_visual(
  "<D-p>",
  function()
    local bufname = vim.fn.expand "%"

    local menu =
      fn.switch(
      bufname,
      {
        ["NvimTree_1"] = function()
          return require("pickers.nvim-tree")
        end,
        ["mind"] = function()
          return require("pickers.mind")
        end,
        ["default"] = function()
          return require("pickers.command-palette")
        end
      }
    )

    require("ui.picker").make(menu)
  end
)

map(
  "<PageUp>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.timetracker")
      require("ui.picker").make(menu)
    end
  end
)

map(
  "<PageDown>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.ollama")
      menu.toggle()
    end
  end
)

map(
  "<Home>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.spectre")
      menu.toggle()
    end
  end
)

map(
  "<D-o>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.glance")
      require("ui.picker").make(menu)
    end
  end
)

map(
  "<D-0>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.terminal")
      require("ui.picker").make(menu)
    end
  end
)

map(
  "<leader>j",
  function()
    local mind = require("mind")
    local mind_ui = require("mind.ui")
    local mind_node = require("mind.node")
    local mind_commands = require("mind.commands")

    mind.wrap_project_tree_fn(
      function(args)
        mind_commands.commands.move_above(args)
      end
    )
  end
)

map(
  "/",
  function()
    require("telescope.builtin").current_buffer_fuzzy_find {
      entry_maker = telescope_ui.gen_from_buffer_lines()
    }
  end
)

map(
  "<D-CR>",
  function()
    if is_default_buffer() then
      local menu = require("pickers.harpoon")
      menu.toggle(harpoon:list())
    end
  end
)

map(
  "<leader>la",
  function()
    local harpoon = require("harpoon")
    harpoon:list():append()
  end
)

map(
  "<leader>lp",
  function()
    local harpoon = require("harpoon")
    harpoon:list():prepend()
  end
)

map(
  "<leader>ld",
  function()
    local harpoon = require("harpoon")
    harpoon:list():remove()
  end
)

map("gx", '<cmd>call jobstart(["open", expand("<cfile>")], {"detach": v:true})<CR>')
