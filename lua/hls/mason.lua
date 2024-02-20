local colors = require("ui.colors")

return {
  MasonHeader = {
    bg = colors.primary["500"],
    fg = colors.dark["500"]
  },
  MasonHighlight = {
    fg = colors.blue["200"]
  },
  MasonHighlightBlock = {
    fg = colors.dark["500"],
    bg = colors.green["400"]
  },
  MasonHighlightBlockBold = {
    link = "MasonHighlightBlock"
  },
  MasonHeaderSecondary = {
    link = "MasonHighlightBlock"
  },
  MasonMuted = {
    fg = colors.grey["300"]
  },
  MasonMutedBlock = {
    fg = colors.grey["300"],
    bg = colors.dark["500"]
  }
}
