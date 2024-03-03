local colors = require("ui.colors")

return {
  PickerKeymap = {
    fg = colors.primary["300"],
    italic = true
  },
  CursorLineNr = {
    fg = colors.dark["50"]
  },
  LineNr = {
    fg = colors.dark["300"]
  },
  Cursor = {
    fg = colors.dark["500"],
    bg = colors.dark["500"]
  },
  QuickFixLine = {
    bg = colors.dark["500"],
    sp = "none"
  },
  SignColumn = {
    fg = colors.dark["100"],
    sp = "NONE"
  },
  ColorColumn = {
    bg = colors.dark["500"],
    sp = "none"
  },
  CursorColumn = {
    bg = colors.dark["500"],
    sp = "none"
  },
  CursorLine = {
    bg = "none",
    sp = "none"
  },
  Comment = {
    fg = colors.dark["300"]
  },
  Pmenu = {
    bg = colors.dark["700"]
  },
  PmenuSbar = {
    bg = colors.dark["700"]
  },
  PmenuSel = {
    bg = colors.dark["400"],
    fg = colors.primary["500"]
  },
  PmenuThumb = {
    bg = colors.dark["300"]
  },
  Normal = {
    fg = colors.dark["50"],
    bg = colors.dark["500"]
  },
  WinSeparator = {
    fg = colors.dark["600"]
  },
  WinSeparator = {
    fg = colors.dark["400"]
  },
  FloatShadow = {
    bg = colors.dark["100"]
  },
  Italic = {
    italic = true
  },
  Bold = {
    bold = true
  },
  UnderLined = {
    fg = colors.green["300"]
  },
  MatchWord = {
    bg = colors.dark["500"],
    fg = colors.white
  },
  MatchParen = {
    link = "MatchWord"
  },
  Conceal = {
    bg = "NONE"
  },
  -- floating windows
  FloatBorder = {
    fg = colors.dark["400"]
  },
  NormalFloat = {
    bg = colors.dark["500"]
  },
  NvimInternalError = {
    fg = colors.red["400"]
  },
  Debug = {
    fg = colors.grey["300"]
  },
  Directory = {
    fg = colors.primary["400"]
  },
  Error = {
    fg = colors.dark["700"],
    bg = colors.grey["300"]
  },
  ErrorMsg = {
    fg = colors.grey["300"],
    bg = colors.dark["700"]
  },
  Exception = {
    fg = colors.grey["300"]
  },
  FoldColumn = {
    fg = colors.primary["300"],
    bg = colors.dark["500"]
  },
  Folded = {
    fg = colors.grey["300"],
    bg = colors.dark["500"]
  },
  IncSearch = {
    fg = colors.dark["500"],
    bg = colors.pink["300"]
  },
  Macro = {
    fg = colors.grey["300"]
  },
  ModeMsg = {
    fg = colors.green["300"]
  },
  MoreMsg = {
    fg = colors.green["300"]
  },
  Question = {
    fg = colors.primary["400"]
  },
  Search = {
    fg = colors.dark["500"],
    bg = colors.primary["400"]
  },
  Substitute = {
    fg = colors.dark["500"],
    bg = colors.primary["400"],
    sp = "none"
  },
  SpecialKey = {
    fg = colors.grey["300"]
  },
  TooLong = {
    fg = colors.grey["300"]
  },
  -- telescope match results
  Visual = {
    bg = colors.primary["300"],
    fg = colors.dark["500"]
  },
  VisualNOS = {
    fg = colors.grey["300"]
  },
  WarningMsg = {
    fg = colors.grey["300"]
  },
  WildMenu = {
    fg = colors.grey["300"],
    bg = colors.primary["400"]
  },
  Title = {
    fg = colors.primary["400"],
    sp = "none"
  },
  NonText = {
    fg = colors.grey["300"]
  },
  -- spell
  SpellBad = {
    undercurl = true,
    sp = colors.grey["300"]
  },
  SpellLocal = {
    undercurl = true,
    sp = colors.primary["300"]
  },
  SpellCap = {
    undercurl = true,
    sp = colors.primary["400"]
  },
  SpellRare = {
    undercurl = true,
    sp = colors.primary["500"]
  },
  healthSuccess = {
    bg = colors.green["300"],
    fg = colors.dark["500"]
  }
}
