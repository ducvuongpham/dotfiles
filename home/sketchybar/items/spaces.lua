local sbar = require("sketchybar")
local colors = require("colors")

-- AeroSpace workspaces 1-9. AeroSpace fires `aerospace_workspace_change` event
-- (configured in aerospace.toml) with $FOCUSED_WORKSPACE in env.
for i = 1, 9 do
  local workspace = sbar.add("item", "space." .. i, {
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

  workspace:subscribe("aerospace_workspace_change", function(env)
    local focused = env.FOCUSED_WORKSPACE == tostring(i)
    workspace:set({
      icon = { highlight = focused },
      background = { color = focused and colors.mauve or colors.surface0 },
    })
  end)
end
