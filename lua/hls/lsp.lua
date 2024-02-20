local colors = require("ui.colors")

return {
  -- LSP References
  LspReferenceText = {
    fg = colors.dark["700"],
    bg = colors.grey["100"]
  },
  LspReferenceRead = {
    fg = colors.dark["700"],
    bg = colors.grey["100"]
  },
  LspReferenceWrite = {
    fg = colors.dark["700"],
    bg = colors.grey["100"]
  },
  -- Lsp Diagnostics
  DiagnosticHint = {
    fg = colors.blue["400"]
  },
  DiagnosticError = {
    fg = colors.red["300"]
  },
  DiagnosticWarn = {
    fg = colors.orange["500"]
  },
  DiagnosticInformation = {
    fg = colors.green["400"]
  },
  LspSignatureActiveParameter = {
    fg = colors.dark["500"],
    bg = colors.primary["500"]
  },
  RenamerTitle = {
    fg = colors.black,
    bg = colors.red["300"]
  },
  RenamerBorder = {
    fg = colors.red["300"]
  },
  LspSignatureHint = {
    fg = colors.green["400"]
  }
}
