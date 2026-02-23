# Реестр чипов MCP23017
mcp_chips = {
  "mcp1": MCP23017(0x20),
#  "mcp2": MCP23017(0x21),
#  "mcp3": MCP23017(0x22),
# "mcp4": MCP23017(0x23),
}

# Конфиг реле
# inverted: false = HIGH вкл (нормально разомкнутое)
#relays = [
#  {"name": "Rel01", "chip": "mcp3", "pin": "GPA0", "inverted": false},
#  {"name": "Rel02", "chip": "mcp3", "pin": "GPA1", "inverted": false},
#  {"name": "Rel03", "chip": "mcp3", "pin": "GPA2", "inverted": false},
#  {"name": "Rel04", "chip": "mcp3", "pin": "GPA3", "inverted": false},
#  {"name": "Rel05", "chip": "mcp3", "pin": "GPB0", "inverted": false},
#  {"name": "Rel06", "chip": "mcp3", "pin": "GPB1", "inverted": false},
#  {"name": "Rel07", "chip": "mcp4", "pin": "GPA0", "inverted": false},
#  {"name": "Rel08", "chip": "mcp4", "pin": "GPA1", "inverted": false},
  # {"name": "Rel09", "chip": "mcp4", "pin": "GPA2", "inverted": true},  # нормально замкнутое
#]

# Конфиг кнопок
# short: "toggle" - вкл/выкл
# long:  "dim"    - плавное изменение яркости (только для LED devices)
#        nil      - длинное нажатие не используется
# target: имя из devices[] или relays[]
buttons = [
  {"chip": "mcp1", "pin": "GPB0", "short": "toggle", "long": "dim", "target": "Led01"},
  {"chip": "mcp1", "pin": "GPB1", "short": "toggle", "long": "dim", "target": "Led02"},
  {"chip": "mcp1", "pin": "GPA2", "short": "toggle", "long": "dim", "target": "Led03"},
  {"chip": "mcp1", "pin": "GPA3", "short": "toggle", "long": "dim", "target": "Led04"},
  {"chip": "mcp1", "pin": "GPA4", "short": "toggle", "long": "dim", "target": "Led05"},
  {"chip": "mcp1", "pin": "GPA5", "short": "toggle", "long": "dim", "target": "Led06"},
  {"chip": "mcp1", "pin": "GPA6", "short": "toggle", "long": "dim", "target": "Led07"},
  # {"chip": "mcp2", "pin": "GPA2", "short": "toggle", "long": nil, "target": "Rel03"},
]
