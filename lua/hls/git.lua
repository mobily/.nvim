local colors = require("ui.colors")

return {
  DiffAdd = {
    fg = colors.blue["400"]
  },
  DiffAdded = {
    fg = colors.green["400"]
  },
  DiffChange = {
    fg = colors.grey["300"]
  },
  DiffChangeDelete = {
    fg = colors.red["300"]
  },
  DiffModified = {
    fg = colors.primary["500"]
  },
  DiffDelete = {
    fg = colors.red["300"]
  },
  DiffRemoved = {
    fg = colors.red["300"]
  },
  -- git commits
  gitcommitOverflow = {
    fg = colors.green["400"]
  },
  gitcommitSummary = {
    fg = colors.green["400"]
  },
  gitcommitComment = {
    fg = colors.dark["300"]
  },
  gitcommitUntracked = {
    fg = colors.dark["300"]
  },
  gitcommitDiscarded = {
    fg = colors.dark["300"]
  },
  gitcommitSelected = {
    fg = colors.dark["300"]
  },
  gitcommitHeader = {
    fg = colors.primary["500"]
  },
  gitcommitSelectedType = {
    fg = colors.primary["300"]
  },
  gitcommitUnmergedType = {
    fg = colors.primary["300"]
  },
  gitcommitDiscardedType = {
    fg = colors.primary["300"]
  },
  gitcommitBranch = {
    fg = colors.pink["300"],
    bold = true
  },
  gitcommitUntrackedFile = {
    fg = colors.primary["200"]
  },
  gitcommitUnmergedFile = {
    fg = colors.green["400"],
    bold = true
  },
  gitcommitDiscardedFile = {
    fg = colors.green["400"],
    bold = true
  },
  gitcommitSelectedFile = {
    fg = colors.green["200"],
    bold = true
  }
}
