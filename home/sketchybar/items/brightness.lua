local sbar = require("sketchybar")
local colors = require("colors")

-- Per-display brightness via BetterDisplay CLI. The bar item for each display
-- only renders on that display (sketchybar `display = N`), so each monitor
-- shows its own brightness independently.
local BDCLI = "/opt/homebrew/bin/betterdisplaycli"

local function list_displays()
  local script = string.format(
    [[bash -c 'echo "[$(%s get --identifiers)]" | jq -r ".[] | select(.deviceType == \"Display\") | \"\(.UUID)|\(.displayID)|\(.name)\""']],
    BDCLI
  )
  local p = io.popen(script)
  if not p then return {} end
  local out = p:read("*a")
  p:close()
  local list = {}
  for line in out:gmatch("[^\r\n]+") do
    local uuid, dispID, name = line:match("^([^|]+)|([^|]+)|(.+)$")
    if uuid and name then
      table.insert(list, { uuid = uuid, displayID = tonumber(dispID), name = name })
    end
  end
  -- sort by displayID so order is stable / matches macOS arrangement
  table.sort(list, function(a, b) return a.displayID < b.displayID end)
  return list
end

local displays = list_displays()

for i, d in ipairs(displays) do
  local key = "brightness." .. d.uuid:gsub("%W", "_")
  local item = sbar.add("item", key, {
    position = "right",
    display = i,                       -- only render on this monitor
    icon = { string = "󰃟", color = colors.yellow },
    label = { color = colors.text },
    background = { color = colors.surface0 },
    padding_left = 4,
    padding_right = 4,
    popup = {
      align = "center",
      height = 32,
      background = {
        color = colors.mantle,
        border_color = colors.surface2,
        border_width = 1,
        corner_radius = 9,
      },
    },
  })

  local slider = sbar.add("slider", key .. ".slider", 220, {
    position = "popup." .. item.name,
    background = { drawing = false },
    slider = {
      highlight_color = colors.peach,
      background = { height = 6, corner_radius = 3, color = colors.surface2 },
      knob = { string = "󰊠", drawing = true, color = colors.yellow },
    },
    click_script = string.format(
      [[%s set --UUID=%s --brightness="$(echo "scale=2; $PERCENTAGE/100" | bc)"]],
      BDCLI, d.uuid
    ),
    label = {
      string = d.name,
      color = colors.subtext0,
      font = { size = 11.0 },
      max_chars = 30,
      padding_right = 12,
      padding_left = 6,
    },
    icon = {
      string = "󰃟",
      color = colors.yellow,
      padding_left = 14,
      padding_right = 6,
      font = { size = 13.0 },
    },
    padding_left = 4,
    padding_right = 12,
  })

  local function refresh()
    sbar.exec(string.format("%s get --UUID=%s --brightness", BDCLI, d.uuid), function(out)
      local frac = (out or ""):match("([%d%.]+)")
      local n = math.floor((tonumber(frac) or 0) * 100 + 0.5)
      item:set({ label = { string = n .. "%" } })
      slider:set({
        label = { string = d.name .. "  " .. n .. "%" },
        slider = { percentage = n },
      })
    end)
  end

  item:subscribe({ "routine", "system_woke", "forced" }, refresh)
  item:subscribe("mouse.clicked", function()
    refresh()
    item:set({ popup = { drawing = "toggle" } })
  end)
  item:subscribe("mouse.exited.global", function()
    item:set({ popup = { drawing = false } })
  end)

  refresh()
end
