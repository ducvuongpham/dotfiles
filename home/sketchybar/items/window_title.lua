local sbar = require("sketchybar")
local colors = require("colors")

-- Title of the currently-focused window (truncated). AeroSpace doesn't fire
-- a dedicated event for window-title change, so we re-query on focus events
-- and on a slow timer.
local title = sbar.add("item", "window_title", {
  position = "left",
  icon = { drawing = false },
  label = {
    color = colors.subtext0,
    max_chars = 60,
    padding_left = 8,
    padding_right = 8,
  },
  background = { color = colors.transparent },
  updates = true,
  update_freq = 1,        -- 1s polling fallback for click-based focus changes
  padding_left = 6,
  click_script = [[$HOME/.local/share/sketchybar_lua/focus-mouse-monitor]],
})

local function refresh()
  sbar.exec(
    "aerospace list-windows --focused --format '%{window-title}'",
    function(out)
      local t = (out or ""):match("^%s*(.-)%s*$")
      title:set({ label = { string = t } })
    end
  )
end

-- Custom event fired by aerospace bindings (alt-h/j/k/l) so we refresh on
-- focus change within the same app/workspace too.
sbar.add("event", "aerospace_focus_change")

title:subscribe({
  "routine",
  "front_app_switched",
  "aerospace_workspace_change",
  "aerospace_focus_change",
  "system_woke",
  "forced",
}, refresh)

refresh()
