local colors = require("ui.colors")

return {
  -- true/false
  Boolean = {
    fg = colors.purple["200"],
  },
  Character = {
    fg = colors.grey["100"],
  },
  -- if
  Conditional = {
    fg = colors.primary["600"],
  },
  -- ;
  Delimiter = {
    fg = colors.pink["500"],
  },
  Float = {
    fg = colors.purple["200"],
  },
  -- string
  String = {
    fg = colors.green["200"],
  },
  -- number
  Number = {
    fg = colors.purple["200"],
  },
  -- Props, string, Date, number, boolean
  Type = {
    fg = colors.primary["200"],
    sp = "none",
  },
  Typedef = {
    fg = colors.primary["300"],
  },
  Constant = {
    fg = colors.primary["300"],
  },
  -- import
  Include = {
    fg = colors.primary["400"],
  },
  -- =>, =
  Operator = {
    fg = colors.grey["300"],
    sp = "none",
  },
  -- <Component._>
  Tag = {
    fg = colors.primary["500"],
  },
  Define = {
    fg = colors.primary["500"],
    sp = "none",
  },
  Variable = {
    fg = colors.grey["300"],
  },
  Function = {
    fg = colors.primary["400"],
  },
  Identifier = {
    fg = colors.grey["300"],
    sp = "none",
  },
  Keyword = {
    fg = colors.primary["500"],
  },
  Label = {
    fg = colors.primary["400"],
  },
  PreProc = {
    fg = colors.primary["400"],
  },
  Repeat = {
    fg = colors.primary["400"],
  },
  Special = {
    fg = colors.primary["300"],
  },
  SpecialChar = {
    fg = colors.pink["300"],
  },
  Statement = {
    fg = colors.grey["300"],
  },
  StorageClass = {
    fg = colors.primary["400"],
  },
  Structure = {
    fg = colors.primary["500"],
  },
  Todo = {
    fg = colors.primary["400"],
    bg = colors.dark["500"],
  },
}
