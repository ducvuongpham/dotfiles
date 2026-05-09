local sbar = require("sketchybar")
local colors = require("colors")

-- Per-display brightness controls via BetterDisplay CLI.
-- One bar item per display (icon + own %), one slider per display in popup.
local BDCLI = "/opt/homebrew/bin/betterdisplaycli"

local function list_displays()
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

local displays = list_displays()
local bar_items = {}   -- uuid → bar item
local sliders = {}     -- uuid → { slider, name }

-- Reuse a single popup from the first bar item; rest just toggle it.
local primary_uuid = displays[1] and displays[1].uuid or nil

for i, d in ipairs(displays) do
  local key = "brightness." .. d.uuid:gsub("%W", "_")
  local bar_item = sbar.add("item", key, {
    position = "right",
    icon = { string = "󰃟", color = colors.yellow },
    label = { color = colors.text },
    background = { color = colors.surface0 },
    padding_left = 4,
    padding_right = 4,
    popup = (i == 1) and {
      align = "center",
      height = 32,
      background = {
        color = colors.mantle,
        border_color = colors.surface2,
        border_width = 1,
        corner_radius = 9,
      },
    } or nil,
  })
  bar_items[d.uuid] = { item = bar_item, name = d.name }
end

-- Add one slider per display under the primary's popup.
if primary_uuid then
  for _, d in ipairs(displays) do
    local key = "brightness.slider." .. d.uuid:gsub("%W", "_")
    local s = sbar.add("slider", key, 220, {
      position = "popup.brightness." .. primary_uuid:gsub("%W", "_"),
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
    sliders[d.uuid] = { slider = s, name = d.name }
  end
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
      local bar_entry = bar_items[uuid]
      if bar_entry then
        bar_entry.item:set({ label = { string = n .. "%" } })
      end
    end)
  end
end

local function toggle_popup()
  if not primary_uuid then return end
  refresh()
  bar_items[primary_uuid].item:set({ popup = { drawing = "toggle" } })
end

for _, entry in pairs(bar_items) do
  entry.item:subscribe("mouse.clicked", toggle_popup)
  entry.item:subscribe("mouse.exited.global", function()
    if primary_uuid then
      bar_items[primary_uuid].item:set({ popup = { drawing = false } })
    end
  end)
  entry.item:subscribe({ "routine", "system_woke", "forced" }, refresh)
end

refresh()
