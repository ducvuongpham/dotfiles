local sbar = require("sketchybar")
local colors = require("colors")

-- AeroSpace workspaces 1-9.
-- Highlights:
--   focused        → yellow background, icon highlighted
--   visible-other  → surface2 (shown on another monitor)
--   has-windows    → surface0 (off-screen but populated)
--   empty          → drawing = false (hidden) unless it's focused
--
-- Label = concatenated app glyphs for windows in the workspace, mapped via
-- sketchybar-app-font's icon_map.sh (fetched once into ~/.local/share).

-- icon_map.lua is a `{ [app_name] = ":icon_token:" }` table fetched at activation.
-- The sketchybar-app-font font has ligatures that render :icon_token: as glyphs.
package.path = os.getenv("HOME") .. "/.local/share/sketchybar_lua/?.lua;" .. package.path
local ok, icon_table = pcall(require, "icon_map")
if not ok then icon_table = {} end
local function app_icon(name)
  return icon_table[name] or ":default:"
end

local items = {}
for i = 1, 9 do
  items[i] = sbar.add("item", "space." .. i, {
    icon = {
      string = tostring(i),
      padding_left = 10,
      padding_right = 6,
      color = colors.subtext0,
      highlight_color = colors.base,
    },
    label = {
      drawing = true,
      string = "",
      font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
      color = colors.text,
      padding_left = 0,
      padding_right = 8,
    },
    background = {
      color = colors.surface0,
      border_width = 0,
      height = 26,
      corner_radius = 6,
    },
    padding_left = 2,
    padding_right = 2,
    drawing = true,
    click_script = "aerospace workspace " .. i,
  })
end

local function lookup_icons(app_names)
  local icons = {}
  for _, name in ipairs(app_names) do
    local token = app_icon(name)
    if token and token ~= "" then table.insert(icons, token) end
  end
  return icons
end

local function refresh(focused)
  -- Visible workspaces (one per monitor).
  sbar.exec("aerospace list-workspaces --monitor all --visible", function(visible_out)
    local visible = {}
    for ws in (visible_out or ""):gmatch("[^\r\n]+") do
      visible[ws:match("^%s*(.-)%s*$")] = true
    end

    for i = 1, 9 do
      local ws = tostring(i)

      -- List apps in this workspace; one icon per window. Sort by
      -- window-id (numeric, stable) so the order doesn't shuffle as
      -- focus moves between windows.
      sbar.exec(
        "aerospace list-windows --workspace " .. ws .. " --format '%{window-id} %{app-name}'",
        function(apps_out)
          local entries = {}
          for line in (apps_out or ""):gmatch("[^\r\n]+") do
            local id, name = line:match("^%s*(%d+)%s+(.+)%s*$")
            if id and name then
              table.insert(entries, { id = tonumber(id), name = name })
            end
          end
          table.sort(entries, function(a, b) return a.id < b.id end)
          local apps = {}
          for _, e in ipairs(entries) do table.insert(apps, e.name) end

          local is_focused = (ws == focused)
          local is_visible = visible[ws] or false
          local has_apps = #apps > 0

          -- empty + not focused/visible = hide. An empty workspace that's
          -- still the visible one on its monitor (e.g. external monitor
          -- with no apps yet) keeps drawing so the user can tell which
          -- workspace number that monitor is on.
          local draw = has_apps or is_focused or is_visible

          local color
          if is_focused then color = colors.yellow
          elseif is_visible then color = colors.surface2
          else color = colors.surface0 end

          items[i]:set({
            drawing = draw,
            background = { color = color },
            icon = { highlight = is_focused },
          })

          if not draw then return end

          -- Resolve glyphs synchronously (icon_map.lua is in-process).
          local icons = lookup_icons(apps)
          local label = ""
          for _, g in ipairs(icons) do label = label .. g .. " " end
          items[i]:set({ label = { string = label:gsub("%s+$", "") } })
        end
      )
    end
  end)
end

local function refresh_query()
  sbar.exec("aerospace list-workspaces --focused", function(out)
    refresh((out or ""):match("^%s*(.-)%s*$"))
  end)
end

items[1]:subscribe("aerospace_workspace_change", function(env)
  refresh(env.FOCUSED_WORKSPACE)
end)
items[1]:subscribe({
  "front_app_switched",
  "system_woke",
  "display_change",    -- monitor reconnect / arrangement change
  "display_wake",      -- screen turning back on
  "forced",
  "window_focus",
  "space_windows_change",
  "routine",           -- periodic safety net (update_freq below)
}, function()
  refresh_query()
end)

-- Safety-net poll. After sleep/wake the system_woke/display_wake events
-- sometimes fire before AeroSpace has reconnected, leaving the indicator
-- stuck on its pre-sleep state. A 5s routine tick catches anything the
-- event subscriptions miss without meaningful overhead.
items[1]:set({ update_freq = 5 })

refresh_query()
