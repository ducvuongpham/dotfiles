local sbar = require("sketchybar")

sbar.begin_config()
sbar.hotload(true)

require("bar")
require("default")
require("items.spaces")
require("items.front_app")
require("items.window_title")
-- recording_spacer must load BEFORE other right-position items so it
-- ends up rightmost (sketchybar fills the right side first-added = rightmost).
require("items.recording_spacer")
require("items.clock")
require("items.battery")
require("items.language")
require("items.bluetooth")
require("items.wifi")
require("items.brightness")
require("items.volume")
require("items.cpu")

sbar.end_config()
sbar.event_loop()
