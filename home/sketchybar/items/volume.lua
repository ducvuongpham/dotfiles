local sbar = require("sketchybar")
local colors = require("colors")

local function pick_icon(n, muted)
  if muted then return "󰝟" end
  if n == 0 then return "󰕿" end
  if n < 40 then return "󰖀" end
  return "󰕾"
end

-- Bar item.
local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { color = colors.sky },
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

local volume_slider = sbar.add("slider", "volume.slider", 200, {
  position = "popup." .. volume.name,
  background = { drawing = false },
  slider = {
    highlight_color = colors.mauve,
    background = { height = 6, corner_radius = 3, color = colors.surface2 },
    knob = { string = "󰊠", drawing = true, color = colors.lavender },
  },
  click_script = [[osascript -e "set volume output volume $PERCENTAGE"]],
  label = { drawing = false },
  icon = {
    string = "󰕾",
    color = colors.sky,
    padding_left = 14,
    padding_right = 10,
    font = { size = 14.0 },
  },
  padding_left = 4,
  padding_right = 14,
})

local function set_volume_label(n, muted)
  volume:set({
    icon = { string = pick_icon(n, muted) },
    label = { string = (muted and "muted" or (n .. "%")) },
  })
  volume_slider:set({ slider = { percentage = n } })
end

-- Audio output device picker.
local SAS = "/opt/homebrew/bin/SwitchAudioSource"
local audio_outputs = {}

local function refresh_outputs(active)
  -- `SwitchAudioSource -a -t output` lists output devices, one per line.
  sbar.exec(SAS .. " -a -t output", function(out)
    local seen = {}
    for line in (out or ""):gmatch("[^\r\n]+") do
      local name = line:match("^%s*(.-)%s*$")
      if name == "" then goto continue end
      seen[name] = true

      if not audio_outputs[name] then
        local key = "volume.out." .. name:gsub("%W", "_")
        local safe = name:gsub("'", "'\\''")
        audio_outputs[name] = sbar.add("item", key, {
          position = "popup." .. volume.name,
          icon = {
            string = (name == active and "󰓃" or " "),
            color = (name == active and colors.green or colors.subtext0),
            padding_left = 14,
            padding_right = 8,
            font = { size = 13.0 },
          },
          label = {
            string = name,
            color = colors.text,
            padding_right = 14,
            font = { size = 12.0 },
            max_chars = 30,
          },
          background = { color = colors.transparent, height = 24 },
          click_script = SAS .. " -s '" .. safe .. "' && sketchybar --trigger volume_outputs_changed",
        })
      else
        audio_outputs[name]:set({
          icon = {
            string = (name == active and "󰓃" or " "),
            color = (name == active and colors.green or colors.subtext0),
          },
        })
      end

      ::continue::
    end
    for n, it in pairs(audio_outputs) do
      if not seen[n] then it:remove(); audio_outputs[n] = nil end
    end
  end)
end

-- Custom event so re-clicking output refreshes UI.
sbar.add("event", "volume_outputs_changed")

local function refresh_active(then_open)
  sbar.exec(SAS .. " -t output -c", function(active)
    refresh_outputs((active or ""):match("^%s*(.-)%s*$"))
    if then_open then
      volume:set({ popup = { drawing = "toggle" } })
    end
  end)
end

volume:subscribe("mouse.clicked", function() refresh_active(true) end)
volume:subscribe("volume_outputs_changed", function() refresh_active(false) end)
volume:subscribe(
  { "mouse.exited.global", "front_app_switched", "aerospace_workspace_change", "system_woke" },
  function() volume:set({ popup = { drawing = false } }) end
)

volume:subscribe("volume_change", function(env)
  set_volume_label(tonumber(env.INFO) or 0, false)
end)

sbar.exec([[osascript -e 'output volume of (get volume settings)']], function(out)
  set_volume_label(tonumber(out) or 0, false)
end)
