local sbar = require("sketchybar")
local colors = require("colors")

-- Current input source. macOS exposes the active layout id via:
--   defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID
-- We parse the trailing suffix (US / Japanese / etc) for a short label.
local lang = sbar.add("item", "language", {
  position = "right",
  icon = { string = "󰗊", color = colors.lavender },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  update_freq = 2,
})

local function short_label(id)
  if not id or id == "" then return "?" end
  if id:find("Japanese") then return "JA"
  elseif id:find("US") or id:find("ABC") then return "EN"
  elseif id:find("Vietnam") then return "VI"
  else return id:match("[^.]+$") or "?" end
end

lang:subscribe({ "routine", "system_woke", "forced" }, function()
  sbar.exec(
    [[defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null]],
    function(out)
      lang:set({ label = { string = short_label((out or ""):gsub("%s+$", "")) } })
    end
  )
end)
