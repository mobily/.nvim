local colors = require("ui.colors")

return {
  MindNodeRoot = {
    fg = colors.primary["300"],
  },
  MindClosedMarker = {
    fg = colors.dark["400"],
  },
  MindOpenMarker = {
    fg = colors.dark["400"],
  },
  MindNodeLeaf = {
    fg = colors.dark["200"],
  },
  MindNodeParent = {
    fg = colors.green["200"],
  },
  MindLocalMarker = {
    fg = colors.grey["300"],
  },
  MindDataMarker = {
    fg = colors.dark["400"],
  },
  MindURLMarker = {
    fg = colors.pink["200"],
  },
  MindModifierEmpty = {
    fg = colors.red["200"],
  },
  MindSelectMarker = {
    fg = colors.primary["300"],
  },
}
