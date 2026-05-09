local sbar = require("sketchybar")
local colors = require("colors")

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { color = colors.sky },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
})

local function pick_icon(n, muted)
  if muted then return "󰝟" end
  if n == 0 then return "󰕿" end
  if n < 40 then return "󰖀" end
  return "󰕾"
end

volume:subscribe("volume_change", function(env)
  local n = tonumber(env.INFO) or 0
  volume:set({
    icon = { string = pick_icon(n, false) },
    label = { string = n .. "%" },
  })
end)

-- initial state
sbar.exec([[osascript -e 'output volume of (get volume settings)']], function(out)
  local n = tonumber(out) or 0
  volume:set({
    icon = { string = pick_icon(n, false) },
    label = { string = n .. "%" },
  })
end)
