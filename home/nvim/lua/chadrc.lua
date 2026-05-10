---@class ChadrcConfig
local M = {}

-- NvChad ships only the mocha palette under the name "catppuccin". Override the
-- palette with macchiato so base46 stops repainting buffers/UI in mocha colors
-- (which clashed with catppuccin.nvim's macchiato flavour and the rest of the
-- system theme).
M.base46 = {
  theme = "catppuccin",
  transparency = false,
  changed_themes = {
    catppuccin = {
      base_30 = {
        white = "#cad3f5",
        darker_black = "#1e2030",
        black = "#24273a",
        black2 = "#2a2c3f",
        one_bg = "#363a4f",
        one_bg2 = "#494d64",
        one_bg3 = "#5b6078",
        grey = "#6e738d",
        grey_fg = "#777c91",
        grey_fg2 = "#8087a2",
        light_grey = "#939ab7",
        red = "#ed8796",
        baby_pink = "#ee99a7",
        pink = "#f5bde6",
        line = "#494d64",
        green = "#a6da95",
        vibrant_green = "#b5e6a4",
        nord_blue = "#91d7e3",
        blue = "#8aadf4",
        yellow = "#eed49f",
        sun = "#f5deb0",
        purple = "#c6a0f6",
        dark_purple = "#b7bdf8",
        teal = "#8bd5ca",
        orange = "#f5a97f",
        cyan = "#91d7e3",
        statusline_bg = "#1e2030",
        lightbg = "#363a4f",
        pmenu_bg = "#a6da95",
        folder_bg = "#8aadf4",
        lavender = "#b7bdf8",
      },
      base_16 = {
        base00 = "#24273a",
        base01 = "#2a2c3f",
        base02 = "#363a4f",
        base03 = "#494d64",
        base04 = "#5b6078",
        base05 = "#b8c0e0",
        base06 = "#c2c8e1",
        base07 = "#cad3f5",
        base08 = "#ed8796",
        base09 = "#f5a97f",
        base0A = "#eed49f",
        base0B = "#a6da95",
        base0C = "#8bd5ca",
        base0D = "#8aadf4",
        base0E = "#c6a0f6",
        base0F = "#ed8796",
      },
    },
  },
}

M.ui = {
  tabufline = { enabled = true, lazyload = false },
  statusline = { enabled = false },
}

return M
