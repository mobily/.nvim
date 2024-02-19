local ui = require "ui"
local colors = require "ui.colors"

return {
  GlancePreviewNormal = {
    bg = colors.dark["500"]
  },
  GlancePreviewMatch = {
    bg = colors.dark["400"]
  },
  GlanceListFilename = {
    fg = colors.primary["500"]
  },
  GlanceListNormal = {
    link = "GlancePreviewNormal"
  },
  GlanceListMatch = {
    bg = colors.dark["400"]
  },
  GlanceListCount = {
    fg = colors.green["300"]
  },
  GlanceWinBarFilename = {
    link = "GlancePreviewNormal"
  },
  GlanceWinBarTitle = {
    link = "GlancePreviewNormal"
  },
  GlanceWinBarFilepath = {
    bg = colors.dark["500"],
    fg = colors.dark["300"]
  },
  GlanceFoldIcon = {
    fg = colors.dark["400"]
  },
  GlanceIndent = {
    link = "GlanceFoldIcon"
  }
}
