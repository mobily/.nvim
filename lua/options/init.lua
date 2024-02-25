vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("$HOME") .. "/.flutter/bin"
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("$HOME") .. "/.rbenv/shims"

vim.opt.guifont = {"JetBrainsMonoMedium Nerd Font", ":h14"}
-- vim.opt.guifont = {"Hack", ":h16"}
vim.opt.guicursor = "n-v-c-sm:hor25,i-ci-ve:ver25,r-cr-o:block"
vim.opt.autoindent = true

vim.opt.laststatus = 3
vim.opt.showmode = false

vim.opt.title = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true

vim.wo.relativenumber = true

vim.cmd "set noequalalways"

-- indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.fillchars = {eob = " "}
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"

-- numbers
vim.opt.number = true
vim.opt.numberwidth = 2
vim.opt.ruler = false

-- disable nvim intro
vim.opt.shortmess:append "sI"

vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 400
vim.opt.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
vim.opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append "<>[]hl"

vim.g.mapleader = "\\"
vim.g.luasnippets_path = vim.fn.expand("$HOME") .. "/.config/nvim/lua/snippets"
-- vim.g.editorconfig = false

if vim.g.neovide then
  vim.g.neovide_input_use_logo = true
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_input_macos_alt_is_meta = 1
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_floating_shadow = false
end

-- disable some builtin vim plugins
local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin"
}

for _, plugin in pairs(default_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

local default_providers = {
  "node",
  "perl",
  "python3",
  "ruby"
}

for _, provider in ipairs(default_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end
