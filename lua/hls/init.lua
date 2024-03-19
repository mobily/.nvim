local utils = require("utils")

local hls = {
  require("hls.theme"),
  require("hls.syntax"),
  require("hls.lsp"),
  require("hls.alpha"),
  require("hls.git"),
  require("hls.treesitter"),
  require("hls.dev-icons"),
  require("hls.nvim-tree"),
  require("hls.telescope"),
  require("hls.mason"),
  require("hls.cmp"),
  require("hls.blankline"),
  require("hls.glance"),
  require("hls.hop"),
  require("hls.marks"),
  require("hls.mind"),
  require("hls.rainbow"),
  require("hls.journal"),
  require("hls.nui"),
}

for _, hl in pairs(hls) do
  utils.load_highlight(hl)
end
