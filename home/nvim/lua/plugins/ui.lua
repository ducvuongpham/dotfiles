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

-- ── Noice (cmdline popup + message routing) ─────────────────────────────────
-- Floating cmdline replaces the bottom statusline cmdline. Messages, errors,
-- and LSP popups route to snacks.notifier (see editor.lua) for toast-style UX.
require("noice").setup {
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_history = "messages",
    view_search = "virtualtext",
  },
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    progress = { enabled = false }, -- fidget.nvim handles LSP progress
    hover = { enabled = true, silent = true },
    signature = { enabled = true },
  },
  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
  routes = {
    -- Skip "written" / "no lines in buffer" noise.
    { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
    { filter = { event = "msg_show", find = "No lines in buffer" }, opts = { skip = true } },
  },
}

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
