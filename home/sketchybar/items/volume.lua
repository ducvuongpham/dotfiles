local sbar = require("sketchybar")
local colors = require("colors")

local function pick_icon(n, muted)
  if muted then return "󰝟" end
  if n == 0 then return "󰕿" end
  if n < 40 then return "󰖀" end
  return "󰕾"
end

-- Main bar item
local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { color = colors.sky },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  popup = { align = "center", height = 30 },
})

-- Popup: slider + output device list
local volume_slider = sbar.add("slider", "volume.slider", 130, {
  position = "popup." .. volume.name,
  background = {
    height = 6,
    color = colors.surface2,
    border_width = 0,
    corner_radius = 3,
  },
  slider = {
    highlight_color = colors.mauve,
    background = { height = 6, corner_radius = 3, color = colors.surface2 },
    knob = { string = "󰊠", drawing = true, color = colors.lavender },
  },
  -- $PERCENTAGE is set by sketchybar; use shell double-quotes around the applescript so it expands.
  click_script = [[osascript -e "set volume output volume $PERCENTAGE"]],
  label = { drawing = false },
  icon = { string = "󰕾", color = colors.sky, padding_left = 8, padding_right = 8 },
  padding_left = 8,
  padding_right = 8,
})

local function set_volume_label(n, muted)
  volume:set({
    icon = { string = pick_icon(n, muted) },
    label = { string = (muted and "muted" or (n .. "%")) },
  })
  volume_slider:set({ slider = { percentage = n } })
end

-- Output device picker entries (one per popup row, populated dynamically).
local audio_outputs = {} -- name → item
local function refresh_outputs(active)
  sbar.exec("/opt/homebrew/bin/SwitchAudioSource -a -t output -f cli", function(out)
    -- Remove old entries we no longer need.
    local seen = {}
    for line in (out or ""):gmatch("[^\r\n]+") do
      seen[line] = true
      if not audio_outputs[line] then
        local safe = line:gsub("'", "'\\''")
        audio_outputs[line] = sbar.add("item", "volume.out." .. line:gsub("%W", "_"), {
          position = "popup." .. volume.name,
          icon = { string = "󰓃", color = colors.subtext0, padding_left = 10 },
          label = { string = line, color = colors.text, padding_right = 10 },
          background = { color = colors.transparent, height = 22 },
          click_script = "/opt/homebrew/bin/SwitchAudioSource -s '" .. safe .. "'",
        })
      end
      audio_outputs[line]:set({
        icon = { color = (line == active and colors.green or colors.subtext0) },
      })
    end
    for name, it in pairs(audio_outputs) do
      if not seen[name] then it:remove(); audio_outputs[name] = nil end
    end
  end)
end

-- Click on the bar item toggles popup; refresh outputs first.
volume:subscribe("mouse.clicked", function()
  sbar.exec("/opt/homebrew/bin/SwitchAudioSource -t output -c", function(active)
    refresh_outputs((active or ""):match("^%s*(.-)%s*$"))
  end)
  volume:set({ popup = { drawing = "toggle" } })
end)

volume:subscribe("mouse.exited.global", function()
  volume:set({ popup = { drawing = false } })
end)

-- React to system volume change events sketchybar fires.
volume:subscribe("volume_change", function(env)
  set_volume_label(tonumber(env.INFO) or 0, false)
end)

-- Initial state
sbar.exec([[osascript -e 'output volume of (get volume settings)']], function(out)
  set_volume_label(tonumber(out) or 0, false)
end)
