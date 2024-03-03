local colors = require("ui.colors")

return {
  NuiComponentsTreeItemFocused = {
    bg = colors.dark["400"]
  },
  NuiComponentsSelectItemFocused = {
    bg = colors.dark["400"]
  },
  NuiComponentsSelectOption = {
    fg = colors.dark["100"]
  },
  NuiComponentsSelectOptionSelected = {
    fg = colors.pink["200"]
  },
  NuiComponentsSelectSeparator = {
    fg = colors.yellow["200"]
    -- fg = colors.dark["300"]
  },
  NuiComponentsFooterConfirmButton = {
    fg = colors.yellow["300"]
  },
  NuiComponentsFooterCancelButton = {
    fg = colors.primary["700"]
  },
  NuiComponentsButton = {},
  NuiComponentsButtonFocused = {
    fg = colors.primary["700"],
    bg = colors.yellow["100"]
  },
  NuiComponentsCheckboxLabel = {
    fg = colors.dark["100"]
  },
  NuiComponentsCheckboxLabelChecked = {
    fg = colors.pink["100"]
  },
  NuiComponentsCheckboxIconChecked = {
    fg = colors.pink["100"]
  },
  -- Spectre
  NuiComponentsTreeSpectreIcon = {
    fg = colors.dark["300"]
  },
  -- NuiComponentsTreeSpectreFileName = {
  --   fg = colors.dark["50"]
  -- },
  NuiComponentsTreeSpectreCodeLine = {
    fg = colors.dark["200"]
  },
  NuiComponentsTreeSpectreSearchValue = {
    fg = colors.dark["50"],
    bg = colors.dark["300"]
  },
  NuiComponentsTreeSpectreSearchOldValue = {
    fg = colors.dark["700"],
    bg = colors.red["200"],
    strikethrough = true
  },
  NuiComponentsTreeSpectreSearchNewValue = {
    fg = colors.dark["700"],
    bg = colors.green["200"]
  },
  NuiComponentsTreeSpectreReplaceSuccess = {
    fg = colors.green["200"]
  }
}
