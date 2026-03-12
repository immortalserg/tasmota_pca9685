# tasmota pca9685 Matter

Скрипты для работы с несколькими PCA9685 в Tasmota и управление через Matter

Включите в прошивке Matter и добавьте в Matter ендпоинты Ваших LED лент в виде виртуальных: Dimmer, CT, RGB

загрузите файлы на устройство

включите через консоль SetOption83 1 чтобы обращаться к ендпоинтам Matter по имени

отредактируйте файл _config.be добавив туда PCA9685 и сопоставив выводы PCA9685 c именами виртуальных led в Matter 
```
  {"name": "Led05", "tp": "dimmer", "chip": "pca1", "channels": 4},
  {"name": "Led06", "tp": "rgb",    "chip": "pca1", "channels": {"r": 5, "g": 6, "b": 7}},
  {"name": "Led07", "tp": "ct",     "chip": "pca1", "channels": {"warm": 8, "cold": 9}},
  {"name": "Group1", "tp": "group", "chip": nil, "channels": nil},
  {"name": "Group2", "tp": "group", "chip": nil, "channels": nil},
```
настройте выводы MCP23017 в качестве реле
```
  {"name": "Rel01", "chip": "mcp3", "pin": "GPA0", "inverted": false},
```
или кнопок:
```
  {"chip": "mcp1", "pin": "GPB0", "short": "toggle", "long": "dim", "target": "Led01"},
  {"chip": "mcp1", "pin": "GPB1", "short": "toggle", "long": "dim", "targets": ["Led02", "Led03", "Led04"]},
  # Кнопка управляет всей группой
  {"chip": "mcp1", "pin": "GPB0", "short": "toggle", "long": "dim", "target": "Group1"},
  # Или несколько групп сразу
  {"chip": "mcp1", "pin": "GPB1", "short": "toggle", "long": "dim", "targets": ["Group1", "Group2"]},
```
target: имя из devices[] или relays[]

targets: управление несколькими устройствами 

добавьте группы
```
  "Group1": ["Led01", "Led02", "Led03", "Led04"],
  "Group2": ["Led05", "Led06", "Led07", "Led08"],
  "Group3": ["Led09","Led10","Led11","Led12"],
```

перезагрузите устройство

### Использование из консоли/в Rule
```
br led_on("Led01")
br led_off("Led01")
br led_toggle("Led01")
br led_bri("Led01", 128)
br all_on()
br all_off()
br led_status()
br relay_set(name, true/false)
br relay_toggle(name)
```
### Ошибки

Если определяется датчик INA219 которого у Вас нет возможно не будет работать PCA9685 так как адрес занят несуществующим устройством, надо отключить драйвера ошибочно определенных устрйоств, в консоли выполните:

```
I2cDriver14 0
I2cDriver76 0
```
