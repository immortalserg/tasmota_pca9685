init_persist()
tasmota.set_timer(0, handle_devices)
tasmota.set_timer(5000, restore_state)
