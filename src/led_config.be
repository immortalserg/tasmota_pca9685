# ======= КОНФИГ PCA9685 =======
pca_chips = {
  "pca1": PCA9685(0x40),
  # "pca2": PCA9685(0x41),
}

# ======= КОНФИГ УСТРОЙСТВ =======
# tp: "dimmer", "ct", "rgb"
# chip: имя из pca_chips
# channels: для dimmer - число, для ct - {warm,cold}, для rgb - {r,g,b}
devices = [
  {"name": "Led01", "tp": "dimmer", "chip": "pca1", "channels": 0},
  {"name": "Led02", "tp": "dimmer", "chip": "pca1", "channels": 1},
  {"name": "Led03", "tp": "dimmer", "chip": "pca1", "channels": 2},
  {"name": "Led04", "tp": "dimmer", "chip": "pca1", "channels": 3},
  {"name": "Led05", "tp": "dimmer", "chip": "pca1", "channels": 4},
  {"name": "Led06", "tp": "rgb",    "chip": "pca1", "channels": {"r": 5, "g": 6, "b": 7}},
  {"name": "Led07", "tp": "ct",     "chip": "pca1", "channels": {"warm": 8, "cold": 9}},
  # {"name": "Led08", "tp": "dimmer", "chip": "pca2", "channels": 0},
]
