local colors = require("ui.colors")

return {
  TelescopeBorder = {
    fg = colors.dark["400"],
    bg = colors.dark["500"],
  },
  TelescopePromptBorder = {
    fg = colors.dark["400"],
    bg = colors.dark["500"],
  },
  TelescopePromptNormal = {
    fg = colors.grey["300"],
    bg = colors.dark["600"],
  },
  TelescopePromptPrefix = {
    fg = colors.dark["300"],
  },
  TelescopePreviewMessageFillchar = {
    bg = colors.dark["500"],
  },
  TelescopePreviewTitle = {
    fg = colors.grey["300"],
    bg = colors.dark["500"],
  },
  TelescopePromptTitle = {
    fg = colors.dark["500"],
    bg = colors.primary["300"],
  },
  TelescopeResultsTitle = {
    fg = colors.grey["300"],
    bg = colors.dark["500"],
  },
  TelescopeSelection = {
    bg = colors.dark["400"],
    fg = colors.grey["300"],
  },
  TelescopeResultsDiffAdd = {
    fg = colors.green["400"],
  },
  TelescopeResultsDiffChange = {
    fg = colors.primary["400"],
  },
  TelescopeResultsDiffDelete = {
    fg = colors.red["400"],
  },
  TelescopeResultsSpecialComment = {
    fg = colors.dark["300"],
  },
  TelescopeSelectionCaret = {
    link = "TelescopeBorder",
  },
  TelescopeResultsNormal = {
    fg = colors.dark["300"],
  },
  TelescopePreviewLine = {
    bg = colors.dark["400"],
  },
}
