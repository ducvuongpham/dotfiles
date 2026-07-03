-- ── Snacks (eager — bigfile detection must run before any buffer opens) ────────
require("snacks").setup {
  bigfile = {
    enabled = true,
    notify = true,
    size = 1.5 * 1024 * 1024,
    line_length = 1000,
    setup = function(ctx)
      vim.cmd "NoMatchParen"
      vim.wo.foldmethod = "manual"
      vim.wo.statuscolumn = ""
      vim.wo.conceallevel = 0
      vim.b.minianimate_disable = true
      vim.schedule(function()
        vim.bo[ctx.buf].syntax = ctx.ft
      end)
    end,
  },
  -- Toast notifications: replaces vim.notify with a stacked, dismissable popup.
  -- noice.nvim routes :messages / errors / lsp messages here.
  notifier = {
    enabled = true,
    timeout = 2000,
    style = "fancy",
    top_down = false,
    -- Wider toasts + wrapping so long errors aren't ellipsised. Up to 80% of
    -- screen width / 60% height before content scrolls.
    width = { min = 40, max = 0.8 },
    height = { min = 1, max = 0.6 },
    margin = { top = 0, right = 1, bottom = 0 },
    level = vim.log.levels.TRACE,
  },
  -- Default styles for popup-like windows: enable wrap so even non-toast
  -- snacks views (history, picker) show full long lines.
  styles = {
    notification = { wo = { wrap = true } },
    notification_history = { wo = { wrap = true } },
  },
}

-- ── Dressing (eager — overrides vim.ui before any prompts appear) ─────────────
require("dressing").setup {}

-- ── Clever-f (VimL — already sourced via packs.lua load=true) ────────────────
vim.g.clever_f_intelligent_case = 1
vim.g.clever_f_fix_key_direction = 1
vim.g.clever_f_show_prompt = 1
vim.g.clever_f_mark_char = 1

-- ── Treesitter ────────────────────────────────────────────────────────────────
-- Extensions deferred to first BufReadPre — highlighting is a built-in and
-- runs eagerly via the FileType autocmd below.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    pcall(function()
      require("nvim-treesitter").install {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "go",
        "rust",
        "c",
        "cpp",
        "bash",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
      }

      require("treesitter-context").setup {
        enable = true,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        zindex = 50,
      }

      local rd = require "rainbow-delimiters"
      require("rainbow-delimiters.setup").setup {
        strategy = {
          [""] = rd.strategy["global"],
          vim = rd.strategy["local"],
        },
        query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }

      require("nvim-ts-autotag").setup()
    end)
  end,
})

-- Enable treesitter highlighting for all file types (Neovim 0.11+ built-in)
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- ── Telescope (lazy: deferred to VimEnter) ───────────────────────────────────
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local telescope = require "telescope"
    local actions = require "telescope.actions"

    local history_dir = vim.fn.expand "~/.local/share/nvim/databases"
    if vim.fn.isdirectory(history_dir) == 0 then
      vim.fn.mkdir(history_dir, "p")
    end

    -- Image preview for the standard file pickers (find_files → <leader>ff /
    -- <leader>fa, oldfiles, etc.). Overriding buffer_previewer_maker routes every
    -- file preview through here: image entries render via image.nvim (kitty
    -- protocol) in the preview window, everything else uses the built-in maker.
    local previewers = require "telescope.previewers"
    local image = require "image"
    local default_maker = previewers.buffer_previewer_maker
    local image_exts = {
      png = true, jpg = true, jpeg = true, gif = true,
      webp = true, avif = true, svg = true, svgz = true,
    }
    -- Clear EVERY image image.nvim is holding in a given window (not a single
    -- tracked handle): async renders can leak a handle when the selection moves
    -- faster than vim.schedule fires, so query image.nvim for the live set.
    local function clear_images_in(win)
      if not win then return end
      for _, img in ipairs(image.get_images { window = win }) do
        pcall(function() img:clear() end)
      end
    end
    -- Bumped on every maker call; a scheduled render checks it's still current so
    -- a stale (superseded) selection never draws over the new one.
    local render_seq = 0
    local function image_previewer_maker(filepath, bufnr, opts)
      local win = opts and opts.winid
      render_seq = render_seq + 1
      local my_seq = render_seq
      clear_images_in(win) -- wipe the previous entry's image(s) synchronously
      local ext = filepath:match "%.([%w]+)$"
      ext = ext and ext:lower()
      if not (ext and image_exts[ext]) then
        return default_maker(filepath, bufnr, opts)
      end
      -- Validate the file is rasterizable BEFORE handing it to image.nvim. Some
      -- images (icon-font / viewBox-only SVGs, corrupt files) make ImageMagick
      -- emit "negative or zero image size" and image.nvim then raises inside a
      -- vim.system callback that runs in the event loop — NOT under a pcall — so
      -- it spams a traceback. Running identify ourselves turns that into a
      -- captured non-zero exit, letting us fall back to the text previewer.
      vim.system(
        { "magick", "identify", "-format", "%w %h\n", filepath },
        { text = true },
        vim.schedule_wrap(function(res)
          if my_seq ~= render_seq then return end -- superseded by a newer selection
          if not vim.api.nvim_buf_is_valid(bufnr) then return end
          local w, h = (res.stdout or ""):match "(%d+)%s+(%d+)"
          local ok_dims = res.code == 0 and w and tonumber(w) > 0 and tonumber(h) > 0
          if ok_dims and win and vim.api.nvim_win_is_valid(win) then
            vim.bo[bufnr].modifiable = true
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
            local ok, img = pcall(image.from_file, filepath, {
              window = win, buffer = bufnr, with_virtual_padding = true,
            })
            if ok and img and my_seq == render_seq then
              pcall(function() img:render() end)
            end
          else
            default_maker(filepath, bufnr, opts) -- unrenderable → show source as text
          end
        end)
      )
    end
    -- Clear any lingering preview image when a window (the preview) closes.
    vim.api.nvim_create_autocmd("WinClosed", {
      group = vim.api.nvim_create_augroup("TelescopeImagePreview", { clear = true }),
      callback = function(ev)
        clear_images_in(tonumber(ev.match))
      end,
    })

    telescope.setup {
      defaults = {
        buffer_previewer_maker = image_previewer_maker,
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
        sorting_strategy = "ascending",
        -- ripgrep args used by live_grep / grep_string. --hidden includes
        -- dotfiles; --glob '!**/.git/*' keeps .git internals out.
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob", "!**/.git/*",
        },
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          width = 0.87,
          height = 0.80,
        },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
          },
          n = {
            ["q"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
          },
        },
        history = {
          path = history_dir .. "/telescope_history.sqlite3",
          limit = 500,
        },
      },
    }
    telescope.load_extension "smart_history"
    telescope.load_extension "fzf"
  end,
})

-- ── NvimTree (lazy: toggle command) ──────────────────────────────────────────
require("nvim-tree").setup(require "configs.nvimtree")

-- ── Conform (lazy: first BufWritePre) ─────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  once = true,
  callback = function()
    pcall(function()
      require("conform").setup(require "configs.conform")
    end)
  end,
})

-- ── Render Markdown (lazy: first markdown/Avante buffer) ──────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "Avante" },
  once = true,
  callback = function()
    pcall(function()
      require("render-markdown").setup { file_types = { "markdown", "Avante" } }
    end)
  end,
})

-- ── Trouble ───────────────────────────────────────────────────────────────────
require("trouble").setup {
  modes = {
    preview_float = {
      mode = "diagnostics",
      preview = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Preview",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.3, height = 0.3 },
        zindex = 200,
      },
    },
  },
}

-- ── nvim-ufo (lazy: first BufReadPre) ─────────────────────────────────────────
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    require("ufo").setup {
      -- Simple table provider avoids promise-chain reentrancy inside the decorator
      provider_selector = function(_, filetype, buftype)
        -- Skip ufo on special buffers (blame.nvim panel, NvimTree, etc.). Their
        -- buftype is "nofile", which makes the treesitter provider throw
        -- UfoFallbackException; as the terminal provider it has no fallback, so
        -- the rejection surfaces unhandled (e.g. on :BlameToggle).
        if buftype ~= "" or filetype == "NvimTree" then return "" end
        local lang = vim.treesitter.language.get_lang(filetype) or filetype
        local has_folds = vim.treesitter.query.get(lang, "folds") ~= nil
        return has_folds and { "lsp", "treesitter" } or { "lsp", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        local newVirtText = {}
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    }
  end,
})

-- ── Early retirement (lazy: VimEnter) ─────────────────────────────────────────
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("early-retirement").setup {
      retirementAgeMins = 0,
      minimumBufferNum = 6,
      notificationOnAutoClose = true,
    }
  end,
})
