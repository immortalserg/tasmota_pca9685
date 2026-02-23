import matter
import persist

load("pca9685.be")
load("led_config.be")
load("led_persist.be")
load("led_control.be")
load("led_handlers.be")
load("led_restore.be")
load("led_console.be")

init_persist()
tasmota.set_timer(0, handle_devices)
tasmota.set_timer(5000, restore_state)
