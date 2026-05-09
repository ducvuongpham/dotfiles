local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

local BU = "/opt/homebrew/bin/blueutil"

local bt = sbar.add("item", "bluetooth", {
  position = "right",
  icon = { string = "󰂯", color = colors.sapphire },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  update_freq = 30,
  popup = {
    align = "center",
    height = 30,
    background = {
      color = colors.mantle,
      border_color = colors.surface2,
      border_width = 1,
      corner_radius = 9,
    },
  },
})

local row_status = sbar.add("item", "bluetooth.row.status", {
  position = "popup." .. bt.name,
  icon = { string = "󰂯", color = colors.sapphire, padding_left = 14, padding_right = 8 },
  label = { string = "—", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_toggle = sbar.add("item", "bluetooth.row.toggle", {
  position = "popup." .. bt.name,
  icon = { string = "󰂲", color = colors.peach, padding_left = 14, padding_right = 8 },
  label = { string = "Toggle Bluetooth", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  click_script = string.format(
    [[bash -c 'p=$(%s --power); if [ "$p" = "1" ]; then %s --power 0; else %s --power 1; fi; sketchybar --trigger bluetooth_changed']],
    BU, BU, BU
  ),
})

local row_settings = sbar.add("item", "bluetooth.row.settings", {
  position = "popup." .. bt.name,
  icon = { string = "󰒓", color = colors.lavender, padding_left = 14, padding_right = 8 },
  label = { string = "Bluetooth Settings…", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  click_script = [[sketchybar --set bluetooth popup.drawing=off && open "x-apple.systempreferences:com.apple.BluetoothSettings"]],
})

sbar.add("event", "bluetooth_changed")

-- Per-device rows are rebuilt each refresh.
local device_items = {}

local function refresh()
  sbar.exec(BU .. " --power", function(power_out)
    local on = (power_out or ""):match("(%d)") == "1"
    bt:set({
      icon = { string = on and "󰂯" or "󰂲", color = on and colors.sapphire or colors.subtext0 },
    })
    row_status:set({ label = { string = on and "Bluetooth On" or "Bluetooth Off" } })

    if not on then
      bt:set({ label = { string = "" } })
      for _, it in pairs(device_items) do it:remove() end
      device_items = {}
      return
    end

    sbar.exec(BU .. " --connected --format json", function(devs_out)
      local seen = {}
      local count = 0
      local s = (type(devs_out) == "string") and devs_out or ""
      for line in s:gmatch("\"name\":%s*\"([^\"]+)\"") do
        seen[line] = true
        count = count + 1
        if not device_items[line] then
          local key = "bluetooth.dev." .. line:gsub("%W", "_")
          local safe = line:gsub("'", "'\\''")
          device_items[line] = sbar.add("item", key, {
            position = "popup." .. bt.name,
            icon = { string = "󰂱", color = colors.green, padding_left = 14, padding_right = 8 },
            label = { string = line, color = colors.text, padding_right = 14, font = { size = 12.0 }, max_chars = 28 },
            background = { color = colors.transparent, height = 22 },
          })
        end
      end
      for name, it in pairs(device_items) do
        if not seen[name] then it:remove(); device_items[name] = nil end
      end

      bt:set({ label = { string = count > 0 and tostring(count) or "" } })
    end)
  end)
end

local function close_self() bt:set({ popup = { drawing = false } }) end
popups.register("bluetooth", close_self)

bt:subscribe({ "routine", "system_woke", "forced", "bluetooth_changed" }, refresh)
bt:subscribe("mouse.clicked", function()
  popups.close_all_except("bluetooth")
  refresh()
  bt:set({ popup = { drawing = "toggle" } })
end)
bt:subscribe(
  { "front_app_switched", "aerospace_workspace_change", "system_woke", "space_change" },
  close_self
)

refresh()
