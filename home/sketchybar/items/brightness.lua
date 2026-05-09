local sbar = require("sketchybar")
local colors = require("colors")

-- BetterDisplay CLI: list displays, set/get brightness per UUID.
-- Each display gets its own slider in the popup.
local BDCLI = "/opt/homebrew/bin/betterdisplaycli"

local brightness = sbar.add("item", "brightness", {
  position = "right",
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

-- Enumerate displays synchronously at startup via io.popen so we can build the
-- exact list of slider items before sketchybar locks the config.
local function list_displays()
  local cmd = [[bash -c 'echo "[$(]] .. BDCLI .. [[ get --identifiers)]" | /opt/homebrew/bin/jq -r ".[] | select(.UUID != null and .deviceType == \"Display\") | \(.UUID)|\(.name)"']]
  -- Simpler: use a here-doc inside a single bash invocation to avoid quoting hell.
  -- jq comes from nix profile, PATH-resolved.
  local script = string.format(
    [[bash -c 'echo "[$(%s get --identifiers)]" | jq -r ".[] | select(.deviceType == \"Display\") | \"\(.UUID)|\(.name)\""']],
    BDCLI
  )
  local p = io.popen(script)
  if not p then return {} end
  local out = p:read("*a")
  p:close()
  local list = {}
  for line in out:gmatch("[^\r\n]+") do
    local uuid, name = line:match("^([^|]+)|(.+)$")
    if uuid and name then
      table.insert(list, { uuid = uuid, name = name })
    end
  end
  return list
end

local sliders = {} -- uuid → { slider, name }

for _, d in ipairs(list_displays()) do
  local key = "brightness.slider." .. d.uuid:gsub("%W", "_")
  local s = sbar.add("slider", key, 220, {
    position = "popup." .. brightness.name,
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
      string = d.name,                 -- updated in refresh() to "name  N%"
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
  sliders[d.uuid] = { slider = s, name = d.name }
end

local function refresh()
  for uuid, entry in pairs(sliders) do
    local cmd = string.format("%s get --UUID=%s --brightness", BDCLI, uuid)
    sbar.exec(cmd, function(out)
      local frac = (out or ""):match("([%d%.]+)")
      local n = math.floor((tonumber(frac) or 0) * 100 + 0.5)
      entry.slider:set({
        label = { string = entry.name .. "  " .. n .. "%" },
        slider = { percentage = n },
      })
    end)
  end
  -- Bar headline: average of all displays.
  local total, count = 0, 0
  for uuid, _ in pairs(sliders) do
    local cmd = string.format("%s get --UUID=%s --brightness", BDCLI, uuid)
    sbar.exec(cmd, function(out)
      local frac = (out or ""):match("([%d%.]+)")
      local n = math.floor((tonumber(frac) or 0) * 100 + 0.5)
      total = total + n
      count = count + 1
      brightness:set({ label = { string = math.floor(total / count + 0.5) .. "%" } })
    end)
  end
end

brightness:subscribe({ "routine", "system_woke", "forced" }, refresh)
brightness:subscribe("mouse.clicked", function()
  refresh()
  brightness:set({ popup = { drawing = "toggle" } })
end)
brightness:subscribe("mouse.exited.global", function()
  brightness:set({ popup = { drawing = false } })
end)

refresh()
