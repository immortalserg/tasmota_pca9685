# tasmota pca9685 Matter

Скрипты для работы с несколькими PCA9685 в Tasmota и управление через Matter

Включите в прошивке Matter и добавьте в Matter ендпоинты Ваших LED лент в виде виртуальных: Dimmer, CT, RGB

загрузите файлы на устройство

включите через консоль SetOption83 1 чтобы обращаться к ендпоинтам Matter по имени

отредактируйте файл led_config.be добавив туда PCA9685 и сопоставив выводы PCA9685 c именами виртуальных led в Matter

отредактируйте файл mcp_config.be добавив туда MCP23017 и настроив выводы в качестве кнопок или реле

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
