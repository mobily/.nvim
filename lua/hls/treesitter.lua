local colors = require("ui.colors")

return {
  -- Api.Auth._ (all capitalized)
  ["@constructor"] = {
    fg = colors.primary["200"],
  },
  ["@keyword"] = {
    fg = colors.primary["500"],
  },
  ["@keyword.function"] = {
    fg = colors.primary["500"],
  },
  -- return
  ["@keyword.return"] = {
    fg = colors.primary["500"],
  },
  -- new
  ["@keyword.operator"] = {
    fg = colors.primary["500"],
    italic = true,
  },
  ["@type"] = {
    fg = colors.primary["200"],
  },
  ["@type.builtin"] = {
    fg = colors.primary["200"],
  },
  ["@variable"] = {
    fg = colors.grey["300"],
  },
  -- undefined
  ["@variable.builtin"] = {
    fg = colors.pink["200"],
    italic = true,
  },
  ["@constant.builtin"] = {
    fg = colors.grey["300"],
  },
  ["@constant.macro"] = {
    fg = colors.grey["300"],
  },
  -- null
  ["@constant.builtin"] = {
    fg = colors.pink["200"],
    italic = true,
  },
  ["@function"] = {
    fg = colors.primary["500"],
  },
  ["@function.builtin"] = {
    fg = colors.primary["500"],
  },
  ["@function.macro"] = {
    fg = colors.grey["300"],
  },
  ["@function.method"] = {
    fg = colors.pink["100"],
  },
  ["@annotation"] = {
    fg = colors.pink["400"],
  },
  ["@attribute"] = {
    fg = colors.primary["300"],
  },
  ["@character"] = {
    fg = colors.grey["300"],
  },
  ["@error"] = {
    fg = colors.grey["300"],
  },
  ["@exception"] = {
    fg = colors.grey["300"],
  },
  ["@float"] = {
    fg = colors.grey["300"],
  },
  ["@method"] = {
    fg = colors.primary["500"],
  },
  ["@namespace"] = {
    fg = colors.grey["300"],
  },
  ["@none"] = {
    fg = colors.grey["500"],
  },
  ["@parameter"] = {
    fg = colors.grey["300"],
  },
  ["@reference"] = {
    fg = colors.grey["500"],
  },
  ["@punctuation.bracket"] = {
    fg = colors.pink["300"],
  },
  ["@punctuation.delimiter"] = {
    fg = colors.pink["300"],
  },
  ["@punctuation.special"] = {
    fg = colors.grey["300"],
  },
  ["@string.regex"] = {
    fg = colors.primary["300"],
  },
  ["@string.escape"] = {
    fg = colors.primary["300"],
  },
  ["@symbol"] = {
    fg = colors.green["200"],
  },
  ["@tag"] = {
    link = "Tag",
  },
  ["@tag.attribute"] = {
    link = "@property",
  },
  ["@tag.delimiter"] = {
    fg = colors.pink["300"],
  },
  ["@text"] = {
    fg = colors.grey["500"],
  },
  ["@text.strong"] = {
    bold = true,
  },
  ["@text.emphasis"] = {
    fg = colors.grey["300"],
  },
  ["@text.strike"] = {
    fg = colors.dark["300"],
    strikethrough = true,
  },
  ["@text.literal"] = {
    fg = colors.grey["300"],
  },
  ["@text.uri"] = {
    fg = colors.grey["300"],
    underline = true,
  },
  -- variable.global
  ["@definition"] = {
    sp = colors.dark["300"],
    underline = true,
  },
  TSDefinitionUsage = {
    sp = colors.dark["300"],
    underline = true,
  },
  ["@scope"] = {
    bold = true,
  },
  ["@field"] = {
    fg = colors.grey["300"],
  },
  ["@field.key"] = {
    fg = colors.primary["500"],
  },
  ["@property"] = {
    fg = colors.grey["300"],
  },
  ["@include"] = {
    link = "Include",
  },
  ["@conditional"] = {
    link = "Conditional",
  },
}
