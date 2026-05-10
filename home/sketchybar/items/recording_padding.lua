-- Dynamic right-padding for the macOS recording indicator (the green/orange
-- dot Control Center shows when camera or microphone is in use). Adds ~26px
-- of breathing room on the right edge of the bar so the dot doesn't overlap
-- the rightmost item, but only while a recording session is actually active.
--
-- Camera detection: VDCAssistant (the Virtual Device Coordinator) is spawned
-- on demand whenever any process opens the camera, and exits when nothing is
-- using it.
--
-- Mic detection: pmset assertion `IOMobileFramebuffer` doesn't help; instead
-- we look for `Microphone` or `AVCaptureSession` strings in the Power
-- Assertion list, which most apps create while recording.

local sbar = require("sketchybar")

local DEFAULT_PADDING = 6
local RECORDING_PADDING = 30

local detect_script = [[
  if pgrep -q VDCAssistant 2>/dev/null; then
    echo 1
  elif pmset -g assertions 2>/dev/null | grep -qiE "Microphone|AVCaptureSession|AudioInput"; then
    echo 1
  else
    echo 0
  fi
]]

local recording = sbar.add("item", "recording_padding", {
  drawing = false, -- invisible item; we only use it for its update tick
  update_freq = 2,
})

recording:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec(detect_script, function(out)
    local active = out and out:match("1") ~= nil
    sbar.bar({ padding_right = active and RECORDING_PADDING or DEFAULT_PADDING })
  end)
end)
