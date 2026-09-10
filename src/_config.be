# ======= КОНФИГ PCA9685 =======
pca_chips = {
  "pca1": PCA9685(0x40),
  # "pca2": PCA9685(0x41),
}
# ======= КОНФИГ MCP23017 =======
mcp_chips = {
  "mcp1": MCP23017(0x20),
  # "mcp2": MCP23017(0x21),
}
# ======= КОНФИГ УСТРОЙСТВ =======
devices = [
  {"name": "Led01", "tp": "dimmer", "chip": "pca1", "channels": 0},
  {"name": "Led02", "tp": "dimmer", "chip": "pca1", "channels": 1},
  {"name": "Led03", "tp": "dimmer", "chip": "pca1", "channels": 2},
  {"name": "Led04", "tp": "dimmer", "chip": "pca1", "channels": 3},
  {"name": "Led05", "tp": "dimmer", "chip": "pca1", "channels": 4},
  {"name": "Led06", "tp": "dimmer", "chip": "pca1", "channels": 5},
  {"name": "Led07", "tp": "dimmer", "chip": "pca1", "channels": 6},
  {"name": "Led08", "tp": "dimmer", "chip": "pca1", "channels": 7},
  {"name": "Led09", "tp": "dimmer", "chip": "pca1", "channels": 8},
  {"name": "Led10", "tp": "dimmer", "chip": "pca1", "channels": 9},
  {"name": "Led11", "tp": "dimmer", "chip": "pca1", "channels": 10},
  {"name": "Led12", "tp": "dimmer", "chip": "pca1", "channels": 11},
  {"name": "Led13", "tp": "dimmer", "chip": "pca1", "channels": 12},
  {"name": "Led14", "tp": "dimmer", "chip": "pca1", "channels": 13},
  {"name": "Led15", "tp": "dimmer", "chip": "pca1", "channels": 14},
  {"name": "Led16", "tp": "dimmer", "chip": "pca1", "channels": 15},
  {"name": "Group1", "tp": "group", "chip": nil, "channels": nil},
  {"name": "Group2", "tp": "group", "chip": nil, "channels": nil},
  {"name": "Group3", "tp": "group", "chip": nil, "channels": nil},
]



# ======= КОНФИГ РЕЛЕ =======
#relays = [
#  {"name": "Rel01", "chip": "mcp3", "pin": "GPA0", "inverted": false},
#]

# ======= КОНФИГ КНОПОК =======
buttons = [
  {"chip": "mcp1", "pin": "GPB0", "short": "toggle", "long": "dim", "target": "Led01"},
  {"chip": "mcp1", "pin": "GPB1", "short": "toggle", "long": "dim", "targets": ["Led02", "Led03", "Led04"]},
  {"chip": "mcp1", "pin": "GPB2", "short": "toggle", "long": "dim", "target": "Led03"},
  {"chip": "mcp1", "pin": "GPB3", "short": "toggle", "long": "dim", "target": "Led04"},
  {"chip": "mcp1", "pin": "GPB4", "short": "toggle", "long": "dim", "target": "Led05"},
  {"chip": "mcp1", "pin": "GPB5", "short": "toggle", "long": "dim", "target": "Led06"},
  {"chip": "mcp1", "pin": "GPB6", "short": "toggle", "long": "dim", "target": "Led07"},
  {"chip": "mcp1", "pin": "GPB7", "short": "toggle", "long": "dim", "target": "Led08"},
  {"chip": "mcp1", "pin": "GPA0", "short": "toggle", "long": "dim", "target": "Led09"},
  {"chip": "mcp1", "pin": "GPA1", "short": "toggle", "long": "dim", "target": "Led10"},
  {"chip": "mcp1", "pin": "GPA2", "short": "toggle", "long": "dim", "target": "Led11"},
  {"chip": "mcp1", "pin": "GPA3", "short": "toggle", "long": "dim", "target": "Led12"},
  {"chip": "mcp1", "pin": "GPA4", "short": "toggle", "long": "dim", "target": "Led13"},
  {"chip": "mcp1", "pin": "GPA5", "short": "toggle", "long": "dim", "target": "Led14"},
  {"chip": "mcp1", "pin": "GPA6", "short": "toggle", "long": "dim", "target": "Led15"},
  {"chip": "mcp1", "pin": "GPA7", "short": "toggle", "long": "dim", "target": "Led16"},
]
# ======= КОНФИГ ZIGBEE ВЫКЛЮЧАТЕЛЕЙ =======
# "device"   — короткий сетевой адрес устройства (как в ZbReceived, напр. "0xFF74")
# "endpoint" — номер клавиши на выключателе (1,2,3...); если не указан — считается 1
# Проверить адрес/эндпоинт: в консоли выполнить ZbStatus2, или посмотреть в логе ZbReceived
# short/double/long/target(s) — тот же синтаксис, что и в buttons[]
zb_buttons = [
  {"device": "0xFF74", "endpoint": 1, "short": "toggle", "long": "dim", "target": "Led01"},
  {"device": "0xFF74", "endpoint": 2, "short": "toggle", "long": "dim", "target": "Led02"},
  {"device": "0xFF74", "endpoint": 3, "short": "toggle", "target": "Group1"},
  # {"device": "0xAB12", "endpoint": 1, "short": "toggle", "double": "toggle", "target": "Group1"},
]

mtr_groups = {
  "Group1": ["Led01", "Led02", "Led03", "Led04"],
  "Group2": ["Led05", "Led06", "Led07", "Led08"],
  "Group3": ["Led09","Led10","Led11","Led12"],
}
