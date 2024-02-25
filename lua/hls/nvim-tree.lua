local colors = require("ui.colors")

return {
  NvimTreeNormal = {
    bg = colors.dark["500"]
  },
  NvimTreeFolderIcon = {
    fg = colors.dark["300"]
  },
  NvimTreeFolderName = {
    fg = colors.grey["300"]
  },
  NvimTreeEmptyFolderName = {
    link = "NvimTreeFolderName"
  },
  NvimTreeOpenedFile = {
    fg = colors.blue["200"]
  },
  NvimTreeOpenedFolderName = {
    link = "NvimTreeFolderName"
  },
  NvimTreeIndentMarker = {
    fg = colors.dark["400"]
  },
  NvimTreeFolderArrowOpen = {
    fg = colors.dark["400"]
  },
  NvimTreeFolderArrowClosed = {
    fg = colors.dark["400"]
  },
  NvimTreeSpecialFile = {
    fg = colors.pink["200"],
    underline = true
  },
  NvimTreeGitDirty = {
    fg = colors.primary["200"]
  },
  NvimTreeGitNew = {
    link = "NvimTreeFolderName"
  },
  NvimTreeGitDeleted = {
    fg = colors.red["200"]
  },
  NvimTreeGitIgnored = {
    link = "NvimTreeFolderIcon"
  },
  NvimTreeGitStaged = {
    fg = colors.green["200"]
  },
  NvimTreeCursorLine = {
    bg = colors.dark["600"]
  },
  NvimTreeFileIgnored = {
    link = "NvimTreeGitIgnored"
  },
  NvimTreeEndOfBuffer = {
    fg = colors.dark["400"]
  },
  NvimTreeNormalNC = {
    link = "NvimTreeNormal"
  },
  NvimTreeWinSeparator = {
    fg = colors.dark["500"],
    bg = colors.dark["500"]
  }
  -- NvimTreeWindowPicker = {
  --   fg = colors.red,
  --   bg = colors.black2
  -- },
}
