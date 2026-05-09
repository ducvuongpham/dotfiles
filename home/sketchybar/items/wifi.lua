local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = "󰖩", color = colors.blue },
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

local row_status = sbar.add("item", "wifi.row.status", {
  position = "popup." .. wifi.name,
  icon = { string = "󰖩", color = colors.blue, padding_left = 14, padding_right = 8 },
  label = { string = "—", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_toggle = sbar.add("item", "wifi.row.toggle", {
  position = "popup." .. wifi.name,
  icon = { string = "󰤨", color = colors.peach, padding_left = 14, padding_right = 8 },
  label = { string = "Toggle Wi-Fi", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  click_script = [[bash -c 'p=$(networksetup -getairportpower en0 | awk "{print \$NF}"); if [ "$p" = "On" ]; then networksetup -setairportpower en0 off; else networksetup -setairportpower en0 on; fi; sketchybar --trigger wifi_changed']],
})

local row_settings = sbar.add("item", "wifi.row.settings", {
  position = "popup." .. wifi.name,
  icon = { string = "󰒓", color = colors.lavender, padding_left = 14, padding_right = 8 },
  label = { string = "Network Settings…", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  click_script = [[sketchybar --set wifi popup.drawing=off && open "x-apple.systempreferences:com.apple.wifi-settings-extension"]],
})

sbar.add("event", "wifi_changed")

local function refresh()
  sbar.exec(
    [[bash -c 'pwr=$(networksetup -getairportpower en0 | awk "{print \$NF}"); active=no; /sbin/ifconfig en0 | grep -q "status: active" && active=yes; echo "$pwr|$active"']],
    function(out)
      local power, active = (out or ""):match("([^|]*)|(.*)")
      power = (power or ""):gsub("%s+$", "")
      active = (active or ""):gsub("%s+$", "")
      local off = power ~= "On"
      local connected = (not off) and active == "yes"

      local icon, color
      if off then
        icon = "󰖪"; color = colors.subtext0
      elseif connected then
        icon = "󰖩"; color = colors.blue
      else
        icon = "󰖩"; color = colors.peach
      end

      wifi:set({ icon = { string = icon, color = color }, label = { drawing = false } })
      local status_label
      if off then status_label = "Wi-Fi Off"
      elseif connected then status_label = "Connected"
      else status_label = "Not connected" end
      row_status:set({
        label = { string = status_label },
        icon = { color = off and colors.subtext0 or colors.blue },
      })
    end
  )
end

local function close_self() wifi:set({ popup = { drawing = false } }) end
popups.register("wifi", close_self)

wifi:subscribe({ "routine", "system_woke", "forced", "wifi_changed", "wifi_change" }, refresh)
local FMM = os.getenv("HOME") .. "/.local/share/sketchybar_lua/focus-mouse-monitor"
wifi:subscribe("mouse.clicked", function()
  sbar.exec(FMM, function()
    popups.close_all_except("wifi")
    refresh()
    wifi:set({ popup = { drawing = "toggle" } })
  end)
end)
wifi:subscribe(
  { "front_app_switched", "aerospace_workspace_change", "system_woke", "space_change" },
  close_self
)

refresh()
