local fn = require("utils.fn")

local HammerSpoon = {}

function HammerSpoon:new(options)
  options = options or {}
  self.__index = self

  options.port = 1122
  options.host = "http://localhost"
  options.state = {}

  return setmetatable(options, self)
end

function HammerSpoon:get(path)
  return self:__curl("GET", path)
end

function HammerSpoon:post(path, body)
  return self:__curl("POST", path, body)
end

function HammerSpoon:set_state(state)
  self.state = vim.tbl_extend("force", self.state, state)
end

function HammerSpoon:__get_full_path(path)
  return self.host .. ":" .. self.port .. "/" .. path
end

function HammerSpoon:__curl(method, path, body)
  local json = vim.fn.json_encode(body or {})
  json = vim.fn.shellescape(json)

  local cmd = {
    "curl",
    "--no-buffer",
    "--silent",
    body ~= nil and "-d " .. json or "",
    "-X " .. method,
    self:__get_full_path(path)
  }

  local result = vim.fn.system(table.concat(cmd, " "))

  return vim.fn.json_decode(result)
end

local hs = HammerSpoon:new()
local augroup = vim.api.nvim_create_augroup("HammerSpoon", {clear = true})

vim.api.nvim_create_user_command(
  "HammerspoonDisplayNotification",
  function(opts)
    hs:post("notification", {value = opts.args})
  end,
  {nargs = "?"}
)

vim.api.nvim_create_user_command(
  "HammerspoonAnnotate",
  function(opts)
    hs:get("annotate")
  end,
  {}
)

vim.api.nvim_create_autocmd(
  "VimEnter",
  {
    group = augroup,
    callback = function()
      hs:post("connect", {servername = vim.api.nvim_eval("v:servername")})
    end
  }
)

vim.api.nvim_create_autocmd(
  "VimLeave",
  {
    group = augroup,
    callback = function()
      hs:post("disconnect", {servername = vim.api.nvim_eval("v:servername")})
    end
  }
)

return hs
