-- ── pets.nvim ─────────────────────────────────────────────────────────────────
-- Animated companion pets in a floating terrarium, rendered via image.nvim.
-- Loaded after plugins.image so require("image").setup has already run.
-- With the async magick_cli processor the plugin auto-prewarms frames; install
-- the `magick` LuaRock + set processor = "magick_rock" in plugins/image.lua for
-- the smoothest result.
require("pets").setup {
  position = "bottom-right",
  size = { width = 40, height = 12 },
  -- image.nvim moves the terminal cursor to place sprites, which flickers the
  -- cursor inside tmux. idle_only pauses pets while you type/move the cursor and
  -- resumes when idle, so the cursor stays put while you work.
  idle_only = true,
  hide_cursor = false, -- ineffective through tmux; idle_only handles it instead
  -- One pet on launch so it's obvious it works; remove to start empty.
  default_pets = { { type = "dog", name = "Rex" } },
}
