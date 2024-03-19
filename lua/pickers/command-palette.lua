local M = {}

local fn = require("utils.fn")
local harpoon = require("harpoon")
local telescope_ui = require("ui.telescope")

local actions = {
  {
    space = "harpoon",
    name = "prepend mark",
    command = function()
      harpoon:list():prepend()
    end,
    keymap = "lp",
  },
  {
    space = "harpoon",
    name = "append mark",
    command = function()
      harpoon:list():append()
    end,
    keymap = "la",
  },
  {
    space = "harpoon",
    name = "remove mark",
    command = function()
      harpoon:list():remove()
    end,
    keymap = "ld",
  },
  {
    space = "harpoon",
    name = "display all marks",
    command = function()
      local menu = require("pickers.harpoon")
      menu.toggle(harpoon:list())
    end,
    keymap = "ll",
  },
  {
    space = "journal",
    name = "add new entry",
    command = "JournalEntry",
  },
  {
    space = "spectre",
    name = "find & replace",
    command = function()
      require("spectre").toggle()
    end,
    keymap = "<D-F>",
  },
  {
    space = "trouble",
    name = "diagnostics",
    command = "TroubleToggle",
    keymap = "td",
  },
  {
    space = "scissors",
    name = "add new snippet",
    command = "ScissorsAddNewSnippet",
  },
  {
    space = "scissors",
    name = "edit snippet",
    command = "ScissorsEditSnippet",
  },
  {
    space = "telescope",
    name = "resume",
    command = "resume",
    keymap = "<D-p>",
  },
  {
    space = "telescope",
    name = "buffers",
    command = "buffers",
    keymap = "<D-b>",
  },
  {
    space = "telescope",
    name = "undo",
    command = "undo",
    keymap = "<D-u>",
  },
  {
    space = "telescope",
    name = "find files",
    command = "find_files",
    keymap = "<D-f>",
  },
  {
    space = "telescope",
    name = "recently closed buffers",
    command = "oldfiles cwd_only=true",
    keymap = "<D-o>",
  },
  {
    space = "telescope",
    name = "live grep",
    command = "live_grep",
    keymap = "<D-/>",
  },
  {
    space = "telescope",
    name = "marks",
    command = "marks",
    keymap = "<D-m>",
  },
  {
    space = "telescope",
    name = "diagnostics",
    command = "diagnostics",
    keymap = "<D-d>",
  },
  {
    space = "telescope",
    name = "projects",
    command = "projects",
  },
  {
    space = "telescope",
    name = "search in file",
    -- command = "current_buffer_fuzzy_find",
    command = function()
      require("telescope.builtin").current_buffer_fuzzy_find({
        entry_maker = telescope_ui.gen_from_buffer_lines(),
      })
    end,
    keymap = "/",
  },
  {
    space = "telescope",
    name = "search history",
    command = "search_history",
  },
  {
    space = "telescope",
    name = "command-line history",
    command = "command_history",
  },
  {
    space = "telescope",
    name = "execute command",
    command = "commands",
  },
  {
    space = "telescope",
    name = "keymaps",
    command = "keymaps",
  },
  {
    space = "telescope",
    name = "git commits",
    command = "git_commits",
  },
  {
    space = "telescope",
    name = "git branches",
    command = "git_branches",
  },
  {
    space = "telescope",
    name = "git status",
    command = "git_status",
  },
  {
    space = "telescope",
    name = "vim options",
    command = "vim_options",
  },
  {
    space = "telescope",
    name = "vim help",
    command = "help_tags",
  },
  {
    space = "telescope",
    name = "list all pickers",
    command = "",
  },
  {
    space = "tree",
    name = "find file in the explorer",
    keymap = "te",
    command = "NvimTreeFindFile",
  },
  {
    space = "mind",
    keymap = "mm",
    name = "open main",
    command = "MindOpenMain",
  },
  {
    space = "mind",
    keymap = "mp",
    name = "open project",
    command = "MindOpenProject",
  },
  {
    space = "mind",
    keymap = "mc",
    name = "close",
    command = "MindClose",
  },
  {
    space = "mind",
    keymap = "mo",
    name = "browse notes",
    command = "MindFindNotes",
  },
  {
    space = "mind",
    keymap = "ms",
    name = "search notes",
    command = "MindGrepNotes",
  },
  {
    space = "buffers",
    name = "toggle pin",
    command = "BufferLineTogglePin",
  },
  {
    space = "buffers",
    keymap = "hs",
    name = "horizontal split",
    command = "20split",
  },
  {
    space = "buffers",
    keymap = "vs",
    name = "vertical split",
    command = "vsplit",
  },
  {
    space = "buffers",
    keymap = "co",
    name = "close other",
    command = "BWipeout other",
  },
  {
    space = "buffers",
    keymap = "cl",
    name = "close left",
    command = "BufferLineCloseLeft",
  },
  {
    space = "buffers",
    keymap = "cr",
    name = "close right",
    command = "BufferLineCloseRight",
  },
  {
    space = "buffers",
    keymap = "ca",
    name = "close all",
    command = "BWipeout all",
  },
  {
    space = "tabs",
    keymap = "tt",
    name = "toggle tabs",
    command = ":execute 'set showtabline=' . (&showtabline ==# 0 ? 2 : 0)",
  },
}

M.actions = fn.imap(actions, function(action)
  return {
    name = action.space .. ": " .. action.name,
    keymap = action.keymap,
    handler = function()
      fn.switch(action.space, {
        ["telescope"] = function()
          if action.name == "resume" then
            require("telescope.builtin").resume({
              cache_index = 2,
            })
            return
          end
          if type(action.command) == "string" then
            return vim.cmd("Telescope " .. action.command)
          end

          action.command()
        end,
        ["ollama"] = function()
          if type(action.command) == "string" then
            return vim.cmd("Gen " .. action.command)
          end

          action.command()
        end,
        ["default"] = function()
          if type(action.command) == "string" then
            return vim.cmd(action.command)
          end

          action.command()
        end,
      })
    end,
  }
end)

M.options = {
  prompt_title = function()
    return "Command Palette"
  end,
  theme = require("telescope.themes").get_dropdown({
    layout_config = {
      height = 0.3,
    },
  }),
}

return M
