import matter
import persist

load("/pca9685.be")
load("/led_config.be")
load("/led_persist.be")
load("/led_control.be")
load("/led_handlers.be")
load("/led_restore.be")
load("/led_console.be")

tasmota.set_timer(500, def() load("/autoexec2.be") end)
