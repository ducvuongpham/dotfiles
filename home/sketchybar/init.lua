local sbar = require("sketchybar")

sbar.begin_config()
sbar.hotload(true)

require("bar")
require("default")
require("items.spaces")
require("items.front_app")
require("items.window_title")
require("items.clock")
require("items.battery")
require("items.volume")
require("items.cpu")

sbar.end_config()
sbar.event_loop()
