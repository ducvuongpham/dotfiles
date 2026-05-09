local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

-- Native-style battery: icon by level + charging bolt; click → popup with
-- time-remaining, source, cycle count, condition; entry to Battery preferences.
local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { color = colors.green },
  label = { color = colors.text },
  update_freq = 60,
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
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

local row_status = sbar.add("item", "battery.row.status", {
  position = "popup." .. battery.name,
  icon = { string = "󱐋", color = colors.yellow, padding_left = 14, padding_right = 8 },
  label = { string = "—", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_time = sbar.add("item", "battery.row.time", {
  position = "popup." .. battery.name,
  icon = { string = "󰥔", color = colors.sky, padding_left = 14, padding_right = 8 },
  label = { string = "—", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_health = sbar.add("item", "battery.row.health", {
  position = "popup." .. battery.name,
  icon = { string = "󰣐", color = colors.red, padding_left = 14, padding_right = 8 },
  label = { string = "—", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_lowpower = sbar.add("item", "battery.row.lowpower", {
  position = "popup." .. battery.name,
  icon = { string = "󰁹", color = colors.green, padding_left = 14, padding_right = 8 },
  label = { string = "Low Power Mode: —", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  -- Toggle: read current state, flip it. NOPASSWD sudoers rule is in modules/darwin/default.nix.
  click_script = [[bash -c 'cur=$(pmset -g | awk "/lowpowermode/ {print \$2}"); [ "$cur" = "1" ] && n=0 || n=1; sudo /usr/bin/pmset -a lowpowermode $n && sketchybar --trigger power_source_change']],
})

local row_energy = sbar.add("item", "battery.row.energy", {
  position = "popup." .. battery.name,
  icon = { string = "󰈸", color = colors.peach, padding_left = 14, padding_right = 8 },
  label = { string = "No Apps Using Significant Energy", color = colors.subtext0, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
})

local row_settings = sbar.add("item", "battery.row.settings", {
  position = "popup." .. battery.name,
  icon = { string = "󰒓", color = colors.lavender, padding_left = 14, padding_right = 8 },
  label = { string = "Battery Settings…", color = colors.text, padding_right = 14, font = { size = 12.0 } },
  background = { color = colors.transparent, height = 24 },
  click_script = [[open "x-apple.systempreferences:com.apple.preference.battery"]],
})

local function pick_icon(pct, charging)
  if charging then return "󰂄" end
  if pct >= 90 then return "󰁹" end
  if pct >= 75 then return "󰂁" end
  if pct >= 60 then return "󰂀" end
  if pct >= 45 then return "󰁿" end
  if pct >= 30 then return "󰁽" end
  if pct >= 15 then return "󰁻" end
  return "󰁺"
end

local function pick_color(pct, charging)
  if charging then return colors.yellow end
  if pct >= 60 then return colors.green end
  if pct >= 25 then return colors.peach end
  return colors.red
end

local function refresh()
  sbar.exec("pmset -g batt", function(out)
    out = out or ""
    local pct = tonumber(out:match("(%d+)%%")) or 0
    local on_ac = out:find("AC Power") ~= nil
    local time = out:match("(%d+:%d+) remaining") or out:match("(%d+:%d+) until") or ""
    local charged = out:find("charged") ~= nil

    battery:set({
      icon = { string = pick_icon(pct, on_ac and not charged), color = pick_color(pct, on_ac) },
      label = { string = pct .. "%" },
    })

    local status_text
    if charged then status_text = "Fully charged"
    elseif on_ac then status_text = "Charging"
    else status_text = "On battery" end
    row_status:set({ label = { string = status_text } })

    if time ~= "" then
      row_time:set({ label = { string = (on_ac and "Until full: " or "Remaining: ") .. time } })
    else
      row_time:set({ label = { string = on_ac and "Calculating…" or "Calculating…" } })
    end
  end)

  sbar.exec(
    [[system_profiler SPPowerDataType | awk -F': *' '/Cycle Count/{c=$2} /Condition/{cond=$2} END{print c "|" cond}']],
    function(out)
      local cycles, cond = (out or ""):match("^([^|]*)|([^\n]*)")
      cycles = (cycles or ""):gsub("%s+$", "")
      cond = (cond or ""):gsub("%s+$", "")
      local text = (#cond > 0 and cond or "?") .. (cycles ~= "" and ("  ·  " .. cycles .. " cycles") or "")
      row_health:set({ label = { string = text } })
    end
  )

  -- Low Power Mode (system-wide flag from pmset).
  sbar.exec("pmset -g | awk '/lowpowermode/ {print $2}'", function(out)
    local on = ((out or ""):match("(%d)") == "1")
    row_lowpower:set({
      icon = { color = (on and colors.peach or colors.subtext0) },
      label = { string = "Low Power Mode: " .. (on and "On" or "Off") },
    })
  end)

  -- Apps using significant energy: any process > 20% CPU.
  sbar.exec(
    [[top -l 1 -n 5 -o cpu -stats "command,cpu" 2>/dev/null | awk 'NR>12 && $2+0 > 20 {gsub(/^ +/, ""); print $1 " (" $2 "%)"}' | head -3]],
    function(out)
      local lines = {}
      for line in (out or ""):gmatch("[^\r\n]+") do table.insert(lines, line) end
      if #lines == 0 then
        row_energy:set({ label = { string = "No Apps Using Significant Energy", color = colors.subtext0 } })
      else
        row_energy:set({ label = { string = table.concat(lines, ", "), color = colors.text } })
      end
    end
  )
end

local function close_self() battery:set({ popup = { drawing = false } }) end
popups.register("battery", close_self)

battery:subscribe({ "routine", "system_woke", "power_source_change", "forced" }, refresh)
battery:subscribe("mouse.clicked", function()
  popups.close_all_except("battery")
  refresh()
  battery:set({ popup = { drawing = "toggle" } })
end)
battery:subscribe(
  { "front_app_switched", "aerospace_workspace_change", "system_woke", "space_change" },
  close_self
)

refresh()
