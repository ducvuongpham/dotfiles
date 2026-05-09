-- ── Theme ─────────────────────────────────────────────────────────────────────
require("catppuccin").setup {
  flavour = "macchiato",
  highlight_overrides = {
    macchiato = function(c)
      return {
        Comment            = { style = { "italic" } },
        ["@comment"]       = { style = { "italic" } },
        -- Stronger contrast for selection: brighter macchiato sapphire-tinted bg.
        Visual             = { bg = "#4a6f9a", fg = c.text },
        TelescopeSelection = { bg = "#4a6f9a" },
        -- Fold column: subtle arrow color like VSCode's gutter
        FoldColumn         = { fg = c.overlay1, bg = "NONE" },
        -- Folded line background: slightly highlighted like VSCode
        Folded             = { fg = c.text, bg = c.surface0, style = { "italic" } },
        -- ufo ellipsis ("⋯ N lines") — matches VSCode's dimmed fold hint
        UfoFoldedEllipsis  = { fg = c.overlay2, bg = "NONE" },
      }
    end,
  },
}
vim.cmd.colorscheme "catppuccin"

-- ── Base46 (NvChad theming engine — generates highlight cache) ────────────────
-- Must run AFTER colorscheme to avoid highlights being wiped by ColorScheme event
pcall(function()
  require("base46").load_all_highlights()
end)

-- base46 overrides catppuccin's highlight_overrides for some groups (notably
-- Visual). Re-apply our overrides AFTER base46 so they actually take effect.
local function apply_overrides()
  vim.api.nvim_set_hl(0, "Visual",             { bg = "#494d64" })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#494d64" })
end
apply_overrides()
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_overrides })

-- ── Statusline ────────────────────────────────────────────────────────────────
require("lualine").setup {
  options = {
    theme = "catppuccin-macchiato",
    disabled_filetypes = { statusline = { "dashboard", "alpha" } },
  },
}

-- ── Breadcrumbs ───────────────────────────────────────────────────────────────
require("barbecue").setup {}

-- ── Which-key ─────────────────────────────────────────────────────────────────
require("which-key").setup {}

-- ── NvChad UI (tabufline + colorify) ──────────────────────────────────────────
pcall(function()
  require("nvchad").setup {
    tabufline = { enabled = true, lazyload = false },
    statusline = { enabled = false },
  }
  require("nvchad.colorify").setup()
end)
