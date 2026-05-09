-- Hammerspoon: 3-finger trackpad swipes → AeroSpace workspace next/prev.
-- macOS NSEvent.swipe is fired by the OS when 3-finger swipe lands on a
-- recognized horizontal motion. We listen via hs.eventtap and dispatch.

local AEROSPACE = "/opt/homebrew/bin/aerospace"

local function aerospace(...)
  local args = { ... }
  hs.task.new(AEROSPACE, nil, args):start()
end

-- NSEventTypeSwipe is type 31. hs.eventtap.event.types.gesture (29) covers
-- gesture-class events on some macOS versions; subscribe to both.
local SWIPE_TYPE = 31
local types = { SWIPE_TYPE }
if hs.eventtap.event.types.gesture then
  table.insert(types, hs.eventtap.event.types.gesture)
end

local last_fire = 0
local DEBOUNCE_MS = 250

local watcher = hs.eventtap.new(types, function(event)
  -- Read raw deltaX from NSEvent. Negative = swipe right (?). macOS reports
  -- swipe direction via gestureAxisX / NSEvent.deltaX.
  local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX) or 0
  if dx == 0 then
    -- swipe events sometimes encode direction in raw NSEvent fields not exposed
    -- by Hammerspoon's property bridge. Try the rawData path:
    local raw = event:getRawEventData()
    if type(raw) == "table" and raw.NSEventData then
      dx = raw.NSEventData.deltaX or 0
    end
  end
  if dx == 0 then return false end

  local now = hs.timer.absoluteTime() / 1e6  -- ms
  if now - last_fire < DEBOUNCE_MS then return false end
  last_fire = now

  if dx > 0 then
    aerospace("workspace", "prev")
  else
    aerospace("workspace", "next")
  end
  return false
end)

watcher:start()

-- A small visual confirmation that the config loaded.
hs.alert.show("Hammerspoon loaded — aerospace swipe ready", 1.5)
