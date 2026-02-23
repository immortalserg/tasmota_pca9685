import matter
import persist

# Объявляем глобальные переменные заранее
relays = []
buttons = []
mcp_chips = {}
pca_chips = {}
devices = []

load("/pca9685.be")
load("/mcp23017.be")
load("/led_config.be")
load("/mcp_config.be")
load("/led_persist.be")
load("/led_control.be")
load("/relay_control.be")
load("/led_handlers.be")
load("/led_restore.be")
load("/led_console.be")
load("/button_handler.be")

tasmota.set_timer(500, def() load("/autoexec2.be") end)
