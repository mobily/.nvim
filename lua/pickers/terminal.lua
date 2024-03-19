local M = {}

local fn = require("utils.fn")
local Terminal = require("toggleterm.terminal").Terminal

local utils = require("utils")
local map = utils.keymap_factory("n")
local cmd = utils.cmd

local schedule = function(fn)
  return function(args)
    utils.schedule(function()
      fn(args)
    end)
  end
end

-- https://github.com/akinsho/flutter-tools.nvim/blob/main/lua/flutter-tools/menu.lua
local get_flutter_commands = function()
  local commands = {}

  local commands_module = require("flutter-tools.commands")
  if commands_module.is_running() then
    commands = {
      {
        id = "flutter-tools-hot-reload",
        label = "Flutter tools: Hot reload",
        hint = "Reload a running flutter project",
        command = require("flutter-tools.commands").reload,
      },
      {
        id = "flutter-tools-hot-restart",
        label = "Flutter tools: Hot restart",
        hint = "Restart a running flutter project",
        command = require("flutter-tools.commands").restart,
      },
      {
        id = "flutter-tools-visual-debug",
        label = "Flutter tools: Visual Debug",
        hint = "Add the visual debugging overlay",
        command = require("flutter-tools.commands").visual_debug,
      },
      {
        id = "flutter-tools-quit",
        label = "Flutter tools: Quit",
        hint = "Quit running flutter project",
        command = require("flutter-tools.commands").quit,
      },
      {
        id = "flutter-tools-detach",
        label = "Flutter tools: Detach",
        hint = "Quit running flutter project but leave the process running",
        command = require("flutter-tools.commands").detach,
      },
      {
        id = "flutter-tools-widget-inspector",
        label = "Flutter tools: Widget Inspector",
        hint = "Toggle the widget inspector",
        command = require("flutter-tools.commands").widget_inspector,
      },
      {
        id = "flutter-tools-construction-lines",
        label = "Flutter tools: Construction Lines",
        hint = "Display construction lines",
        command = require("flutter-tools.commands").construction_lines,
      },
    }
  else
    commands = {
      {
        id = "flutter-tools-run",
        label = "Flutter tools: Run",
        hint = "Start a flutter project",
        command = require("flutter-tools.commands").run,
      },
    }
  end

  vim.list_extend(commands, {
    {
      id = "flutter-tools-pub-get",
      label = "Flutter tools: Pub get",
      hint = "Run pub get in the project directory",
      command = require("flutter-tools.commands").pub_get,
    },
    {
      id = "flutter-tools-pub-upgrade",
      label = "Flutter tools: Pub upgrade",
      hint = "Run pub upgrade in the project directory",
      command = require("flutter-tools.commands").pub_upgrade,
    },
    {
      id = "flutter-tools-list-devices",
      label = "Flutter tools: List Devices",
      hint = "Show the available physical devices",
      command = require("flutter-tools.devices").list_devices,
    },
    {
      id = "flutter-tools-list-emulators",
      label = "Flutter tools: List Emulators",
      hint = "Show the available emulator devices",
      command = require("flutter-tools.devices").list_emulators,
    },
    {
      id = "flutter-tools-open-outline",
      label = "Flutter tools: Open Outline",
      hint = "Show the current files widget tree",
      command = require("flutter-tools.outline").open,
    },
    {
      id = "flutter-tools-generate",
      label = "Flutter tools: Generate ",
      hint = "Generate code",
      command = require("flutter-tools.commands").generate,
    },
    {
      id = "flutter-tools-clear-dev-log",
      label = "Flutter tools: Clear Dev Log",
      hint = "Clear previous logs in the output buffer",
      command = require("flutter-tools.log").clear,
    },
  })

  local dev_tools = require("flutter-tools.dev_tools")

  if dev_tools.is_running() then
    vim.list_extend(commands, {
      {
        id = "flutter-tools-copy-profiler-url",
        label = "Flutter tools: Copy Profiler Url",
        hint = "Run the app and the DevTools first",
        command = require("flutter-tools.commands").copy_profiler_url,
      },
      {
        id = "flutter-tools-open-dev-tools",
        label = "Flutter tools: Open Dev Tools",
        hint = "Run the app and the Dev Tools first",
        command = require("flutter-tools.commands").open_dev_tools,
      },
    })
  else
    vim.list_extend(commands, {
      {
        id = "flutter-tools-start-dev-tools",
        label = "Flutter tools: Start Dev Tools",
        hint = "Open flutter dev tools in the browser",
        command = require("flutter-tools.dev_tools").start,
      },
    })
  end

  return commands
end

local theme = require("telescope.themes").get_dropdown({
  layout_config = {
    height = 0.3,
  },
})

local is_flutter_project = function()
  local cwd = vim.fn.getcwd()
  local output = io.popen('find "' .. cwd .. '" -type f -name "pubspec.yaml" -maxdepth 1')

  for path in output:lines() do
    local file = io.open(path, "rb")

    if file then
      file:close()
      return true
    end
  end

  return false
end

local make_flutter_actions = function(make)
  local actions = {}
  local keymap_index = 0

  local actions = fn.imap(get_flutter_commands(), function(flutter)
    keymap_index = keymap_index + 1

    return {
      name = string.lower(flutter.label:gsub("Flutter tools: ", "")) .. " (" .. string.lower(flutter.hint) .. ")",
      keymap = utils.common_keymaps[keymap_index],
      handler = schedule(function()
        if type(flutter.command) == "string" then
          return vim.cmd(flutter.command)
        end

        flutter.command(flutter.id)
      end),
    }
  end)

  if #actions > 0 then
    make(actions)
  end
end

local make_package_json_actions = function(make)
  local actions = {}
  local cwd = vim.fn.getcwd()
  local keymap_index = 0

  local output =
    io.popen('find "' .. cwd .. '" -type f -name "package.json" ! -path "' .. cwd .. '/**/node_modules/*" -maxdepth 2')

  for path in output:lines() do
    local file = io.open(path, "rb")

    if file then
      local json = file:read("*a")
      local scripts = vim.fn.json_decode(json)["scripts"]

      for name, command in pairs(scripts) do
        local package_path = vim.fn.fnamemodify(path:gsub("/package.json", ""), ":t")

        table.insert(actions, {
          name = package_path .. ": " .. name,
          handler = function()
            return {
              command = command,
              path = path:gsub("/package.json", ""),
            }
          end,
        })
      end
    end

    file:close()
  end

  table.sort(actions, function(a, b)
    return a.name < b.name
  end)

  actions = fn.imap(actions, function(action)
    keymap_index = keymap_index + 1
    return {
      name = action.name,
      keymap = utils.common_keymaps[keymap_index],
      handler = action.handler,
    }
  end)

  if #actions > 0 then
    make(actions)
  end
end

local package_json_on_select = function(select, close)
  vim.ui.input({
    prompt = "Enter command arguments: ",
    default = "",
    completion = "file",
    opts = {
      kind = "terminal",
    },
  }, function(input)
    close()
    local selected = select()

    M.terminal = Terminal:new({
      cmd = input and (selected.command .. " " .. input) or selected.command,
      direction = "float",
      float_opts = {
        border = "rounded",
      },
      dir = selected.path,
      close_on_exit = false,
      on_open = function(term)
        vim.cmd("startinsert!")
        map("<ESC>", cmd("close"), nil, { buffer = term.bufnr })
      end,
    }):toggle()
  end)
end

M.terminal = nil

M.options = {
  prompt_title = function()
    local is_flutter = is_flutter_project()
    return is_flutter and "Flutter Commands" or "Terminal actions"
  end,
  make_actions = function(make)
    local is_flutter = is_flutter_project()
    if is_flutter then
      return make_flutter_actions(make)
    end

    return make_package_json_actions(make)
  end,
  on_select = function(select, close)
    local is_flutter = is_flutter_project()

    if is_flutter then
      close()
      return select()
    end

    package_json_on_select(select, close)
  end,
  theme = theme,
}

_command_terminal_toggle = function()
  if M.terminal then
    M.terminal:toggle()
  end
end

map("<leader>4", "<cmd>lua _command_terminal_toggle()<CR>")

return M
