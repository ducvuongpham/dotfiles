-- ── image.nvim ────────────────────────────────────────────────────────────────
-- Inline image rendering via the kitty graphics protocol. The terminal supports
-- it and tmux `allow-passthrough on` is already set (see home/tmux/tmux.conf).
-- processor = "magick_cli" shells out to the ImageMagick `magick` binary, so no
-- luarocks / FFI build is needed.
local image = require "image"

-- Extensions treated as image files (used for both the hijack and the toggle).
local img_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.svg", "*.svgz" }

image.setup {
  backend = "kitty",
  processor = "magick_cli",
  integrations = {
    -- In documents (markdown etc.), render in normal mode and hide the image
    -- while editing so the source line under it is visible.
    markdown = {
      enabled = true,
      clear_in_insert_mode = true,
      only_render_image_at_cursor = false,
      filetypes = { "markdown", "vimwiki", "codecompanion" },
    },
    asciidoc = { enabled = true, clear_in_insert_mode = true },
    neorg = { enabled = true },
    typst = { enabled = true },
  },
  max_height_window_percentage = 50,
  -- MUST stay false: pets.nvim keeps an always-on floating window on top of the
  -- editor. With overlap-clear on, image.nvim treats that float as covering the
  -- main-window image and refuses to render it (log: `overlap` → success:false),
  -- while the pet itself still shows. Trade-off: images no longer auto-hide
  -- behind cmp/noice popups, which is acceptable.
  window_overlap_clear_enabled = false,
  -- Both left OFF: they hide ALL images when nvim isn't "focused" / its tmux
  -- window isn't active, which also hides the always-on pets (and focus events
  -- don't propagate reliably through Rio+tmux, so images stayed hidden entirely).
  editor_only_render_when_focused = false,
  tmux_show_only_in_active_window = false,
  -- Opening one of these files directly renders it as an image (file hijack).
  -- SVG works: ImageMagick has the librsvg delegate compiled in, so magick_cli
  -- rasterizes *.svg / *.svgz to a bitmap before the kitty backend draws it.
  hijack_file_patterns = img_patterns,
}

-- ── Image ⇄ source toggle for hijacked image files ───────────────────────────
-- image.nvim's hijack renders the image into an EMPTIED, non-modifiable buffer
-- (modifiable=false, buftype=nowrite, lines wiped), so `i` is a no-op and the
-- file's real content is gone from the buffer. A plain InsertEnter toggle can't
-- work. Instead, provide an explicit two-state toggle per buffer:
--   • image view  → the hijacked render (clean image, locked buffer)
--   • source view → the real file bytes reloaded into a modifiable buffer
-- `to_source` reloads with `noautocmd edit!` so the hijack (which fires on
-- BufWinEnter) does NOT re-run; `to_image` runs a normal `edit` so it does.
local grp = vim.api.nvim_create_augroup("ImageFileToggle", { clear = true })

-- Keys that mean "start editing" — in image view they reveal the source first.
local edit_keys = { "i", "a", "I", "A", "o", "O", "c", "s" }

local function to_source()
  local buf = vim.api.nvim_get_current_buf()
  for _, img in ipairs(image.get_images { buffer = buf }) do
    img:clear()
  end
  vim.cmd "noautocmd edit!" -- reload real content without re-triggering the hijack
  vim.bo[buf].modifiable = true
  vim.bo[buf].buftype = ""
  vim.cmd "filetype detect" -- e.g. *.svg → xml/svg syntax highlighting
  -- Drop the reveal maps so `i`/`a`/… now insert normally in the source buffer.
  for _, k in ipairs(edit_keys) do
    pcall(vim.keymap.del, "n", k, { buffer = buf })
  end
  vim.b[buf].image_source_view = true
end

local function to_image()
  vim.cmd "edit" -- BufWinEnter fires → hijack re-empties + re-renders the image
end

-- On (re-)entering an image-file window, image.nvim's hijack runs on the same
-- event; we add the escape hatch on top: reveal-to-edit keys + a way back.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = grp,
  pattern = img_patterns,
  callback = function(ev)
    local buf = ev.buf
    vim.b[buf].image_source_view = false
    local opts = { buffer = buf, silent = true, nowait = true, desc = "image: reveal source to edit" }
    for _, k in ipairs(edit_keys) do
      vim.keymap.set("n", k, to_source, opts)
    end
    vim.keymap.set("n", "<leader>iv", to_image, { buffer = buf, silent = true, desc = "image: back to image view" })
    vim.api.nvim_buf_create_user_command(buf, "ImageView", to_image, { desc = "Render this image file" })
    vim.api.nvim_buf_create_user_command(buf, "ImageSource", to_source, { desc = "Show this image file's raw source" })
  end,
})
