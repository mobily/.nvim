local colors = require "ui.colors"

return {
  -- nvim cmp
  CmpItemAbbr = {
    fg = colors.grey["300"]
  },
  CmpItemAbbrMatch = {
    fg = colors.blue["400"],
    bold = true
  },
  CmpBorder = {
    fg = colors.dark["400"]
  },
  CmpDocBorder = {
    fg = colors.dark["500"],
    bg = colors.dark["500"]
  },
  CmPmenu = {
    bg = colors.dark["500"]
  },
  -- cmp item kinds
  CmpItemKindConstant = {
    fg = colors.blue["200"]
  },
  CmpItemKindFunction = {
    fg = colors.primary["200"]
  },
  CmpItemKindIdentifier = {
    fg = colors.grey["300"]
  },
  CmpItemKindField = {
    fg = colors.grey["300"]
  },
  CmpItemKindVariable = {
    fg = colors.primary["500"]
  },
  CmpItemKindSnippet = {
    fg = colors.pink["300"]
  },
  CmpItemKindText = {
    fg = colors.green["300"]
  },
  CmpItemKindStructure = {
    fg = colors.primary["500"]
  },
  CmpItemKindType = {
    fg = colors.primary["200"]
  },
  CmpItemKindKeyword = {
    fg = colors.primary["500"]
  },
  CmpItemKindMethod = {
    fg = colors.primary["500"]
  },
  CmpItemKindConstructor = {
    fg = colors.blue["300"]
  },
  CmpItemKindFolder = {
    fg = colors.grey["300"]
  },
  CmpItemKindModule = {
    fg = colors.primary["200"]
  },
  CmpItemKindProperty = {
    fg = colors.grey["300"]
  },
  -- CmpItemKindEnum = { fg = "" },
  CmpItemKindUnit = {
    fg = colors.primary["500"]
  },
  -- CmpItemKindClass = { fg = "" },
  CmpItemKindFile = {
    fg = colors.grey["300"]
  },
  -- CmpItemKindInterface = { fg = "" },
  CmpItemKindColor = {
    fg = colors.red["300"]
  },
  CmpItemKindReference = {
    fg = colors.grey["300"]
  },
  -- CmpItemKindEnumMember = { fg = "" },
  CmpItemKindStruct = {
    fg = colors.primary["500"]
  },
  -- CmpItemKindValue = { fg = "" },
  -- CmpItemKindEvent = { fg = "" },
  CmpItemKindOperator = {
    fg = colors.grey["300"]
  },
  CmpItemKindTypeParameter = {
    fg = colors.grey["300"]
  },
  CmpItemKindCopilot = {
    fg = colors.green["400"]
  }
}
