local sbar = require("sketchybar")
local colors = require("colors")

-- AeroSpace workspaces 1-9.
-- Highlight states (per-workspace background color):
--   focused         (active monitor's current ws) → mauve
--   visible-other   (shown on another connected monitor) → surface2
--   hidden          (not displayed) → surface0
local items = {}

for i = 1, 9 do
  items[i] = sbar.add("item", "space." .. i, {
    icon = {
      string = tostring(i),
      padding_left = 10,
      padding_right = 10,
      color = colors.subtext0,
      highlight_color = colors.base,
    },
    label = { drawing = false },
    background = {
      color = colors.surface0,
      border_width = 0,
      height = 26,
      corner_radius = 6,
    },
    padding_left = 2,
    padding_right = 2,
    click_script = "aerospace workspace " .. i,
  })
end

local function refresh(focused)
  -- Query AeroSpace for the workspace currently visible on each monitor.
  sbar.exec("aerospace list-workspaces --monitor all --visible", function(out)
    local visible = {}
    for ws in (out or ""):gmatch("[^\r\n]+") do
      visible[ws:match("^%s*(.-)%s*$")] = true
    end

    for i = 1, 9 do
      local ws = tostring(i)
      local color, highlight
      if ws == focused then
        color = colors.mauve
        highlight = true
      elseif visible[ws] then
        color = colors.surface2
        highlight = false
      else
        color = colors.surface0
        highlight = false
      end
      items[i]:set({
        background = { color = color },
        icon = { highlight = highlight },
      })
    end
  end)
end

items[1]:subscribe({ "aerospace_workspace_change", "front_app_switched", "system_woke", "forced" }, function(env)
  refresh(env.FOCUSED_WORKSPACE)
end)

-- Initial paint: ask AeroSpace which workspace is currently focused so the
-- bar shows the right colors before the first workspace change.
sbar.exec("aerospace list-workspaces --focused", function(out)
  refresh((out or ""):match("^%s*(.-)%s*$"))
end)
