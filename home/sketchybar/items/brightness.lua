local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

-- Per-display brightness via BetterDisplay CLI.
--   Bar item: one per display, renders only on its own monitor, shows its own %.
--   Popup:    each bar item's popup contains sliders for ALL displays so you
--             can adjust any display from any monitor's bar item.
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
  table.sort(list, function(a, b) return a.displayID < b.displayID end)
  return list
end

local displays = list_displays()

-- Map: uuid → { item, sliders = { [target_uuid] = slider } }
local entries = {}

local function make_slider(parent_name, target)
  return sbar.add("slider", parent_name .. ".s." .. target.uuid:gsub("%W", "_"), 220, {
    position = "popup." .. parent_name,
    background = { drawing = false },
    slider = {
      highlight_color = colors.peach,
      background = { height = 6, corner_radius = 3, color = colors.surface2 },
      knob = { string = "󰇥", drawing = true, color = colors.yellow },
    },
    click_script = string.format(
      [[%s set --UUID=%s --brightness="$(echo "scale=2; $PERCENTAGE/100" | bc)"]],
      BDCLI, target.uuid
    ),
    label = {
      string = target.name,
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
end

for i, d in ipairs(displays) do
  local key = "brightness." .. d.uuid:gsub("%W", "_")
  local item = sbar.add("item", key, {
    position = "right",
    display = i,
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
  entries[d.uuid] = { item = item, sliders = {} }
end

-- For every (popup_owner, target_display) pair, add a slider in the owner's popup.
for _, owner in ipairs(displays) do
  local owner_entry = entries[owner.uuid]
  for _, target in ipairs(displays) do
    owner_entry.sliders[target.uuid] = make_slider(owner_entry.item.name, target)
  end
end

local function refresh_all()
  for _, target in ipairs(displays) do
    sbar.exec(string.format("%s get --UUID=%s --brightness", BDCLI, target.uuid), function(out)
      local frac = (out or ""):match("([%d%.]+)")
      local n = math.floor((tonumber(frac) or 0) * 100 + 0.5)
      -- Bar item label = own %.
      local own = entries[target.uuid]
      if own then own.item:set({ label = { string = n .. "%" } }) end
      -- Each popup's slider for this target gets updated.
      for _, owner_entry in pairs(entries) do
        local s = owner_entry.sliders[target.uuid]
        if s then
          s:set({
            label = { string = target.name .. "  " .. n .. "%" },
            slider = { percentage = n },
          })
        end
      end
    end)
  end
end

local function close_all_brightness_popups()
  for _, e in pairs(entries) do e.item:set({ popup = { drawing = false } }) end
end

popups.register("brightness", close_all_brightness_popups)

for uuid, owner_entry in pairs(entries) do
  owner_entry.item:subscribe({ "routine", "system_woke", "forced" }, refresh_all)
  owner_entry.item:subscribe("mouse.clicked", function()
    sbar.exec(os.getenv("HOME") .. "/.local/share/sketchybar_lua/focus-mouse-monitor", function()
      popups.close_all_except("brightness")
      for u, e in pairs(entries) do
        if u ~= uuid then e.item:set({ popup = { drawing = false } }) end
      end
      refresh_all()
      owner_entry.item:set({ popup = { drawing = "toggle" } })
    end)
  end)
  owner_entry.item:subscribe(
    { "front_app_switched", "aerospace_workspace_change", "system_woke", "space_change" },
    close_all_brightness_popups
  )
end

refresh_all()
