# ======= ОБРАБОТКА ZIGBEE ВЫКЛЮЧАТЕЛЕЙ =======
# Использует ту же логику действий, что и button_handler.be
# (do_action / do_short_action / do_double_action / do_dim_step / btn_state),
# только события приходят асинхронно из Zigbee-сети, а не опросом пина.
#
# Пример события:
# {"ZbReceived":{"0xFF74":{"Device":"0xFF74","Click":"single","Endpoint":2,...}}}
#
# Device   — адрес устройства
# Click    — тип клика: "single", "double", "hold" (не у всех устройств есть все 3)
# Endpoint — номер клавиши на самом выключателе (1, 2, 3...)
#
# tasmota.add_rule для "ZbReceived#?#Click" передаёт callback'у:
#   value   — значение Click ("single"/"double"/"hold")
#   trigger — НЕ содержит реальный адрес при wildcard-совпадении,
#             остаётся литералом "ZbReceived#?#Click" — не парсим его
#   data    — весь SENSOR-пакет целиком: {"ZbReceived": {"0xFF74": {...}}}
#             (не сам объект ZbReceived, а на уровень выше) —
#             отсюда сначала берём data["ZbReceived"], затем ключ устройства и Endpoint

def zb_name(device, endpoint)
  return "zb_" + device + "_" + str(endpoint)
end

# Ищет кнопку в zb_buttons по адресу устройства И номеру эндпоинта.
# Если у записи в конфиге endpoint не указан — считается endpoint 1.
def zb_find_button(device, endpoint)
  for zbtn: zb_buttons
    if zbtn["device"] == device
      var ep = zbtn.contains("endpoint") ? zbtn["endpoint"] : 1
      if ep == endpoint return zbtn end
    end
  end
  return nil
end

def zb_init()
  for zbtn: zb_buttons
    var device = zbtn["device"]
    var endpoint = zbtn.contains("endpoint") ? zbtn["endpoint"] : 1
    var nm = zb_name(device, endpoint)
    if !btn_state.contains(nm)
      btn_state[nm] = {
        "pressed_time":   0,
        "long_active":    false,
        "dim_dir":        1,
        "last_val":       1,
        "pending_single": false,
        "release_time":   0
      }
    end
  end
end

def on_zb_click(value, trigger, data)
  # ВАЖНО: при wildcard-совпадении ("?") Tasmota НЕ подставляет реальный
  # адрес обратно в trigger — там остаётся буквально "ZbReceived#?#Click".
  # Кроме того, data — это весь SENSOR-пакет целиком, т.е. {"ZbReceived":{"0xFF74":{...}}},
  # а не сам объект ZbReceived — поэтому спускаемся на уровень ниже перед поиском адреса.
  var zb_data = data.find("ZbReceived", data)

  var device = ""
  for k: zb_data.keys()
    device = k
    break
  end

  if device == ""
    print("ZB: не удалось определить устройство, trigger=" + trigger)
    return
  end

  var info = zb_data[device]
  var endpoint = info.contains("Endpoint") ? int(info["Endpoint"]) : 1

  var zbtn = zb_find_button(device, endpoint)
  if zbtn == nil
    print("ZB: неизвестная клавиша " + device + " EP" + str(endpoint) + " (" + value + ")")
    return
  end

  var nm = zb_name(device, endpoint)
  var st = btn_state[nm]

  if value == "single"
    do_short_action(zbtn)

  elif value == "double"
    do_double_action(zbtn)

  elif value == "hold"
    if !st["long_active"] && btn_long_is_dim(zbtn)
      st["long_active"] = true
      st["dim_dir"] = 1
      var lt = btn_long_targets(zbtn)
      if persist.power_values[lt[0]] == 0
        for target: lt
          led_on(target)
        end
      end
      do_dim_step(nm, zbtn)
    end

  elif value == "release"
    # Остановить диммирование, если оно шло (не все устройства шлют release)
    st["long_active"] = false

  else
    print("ZB: неизвестное событие '" + value + "' от " + device + " EP" + str(endpoint))
  end
end

def zb_init_rules()
  tasmota.add_rule("ZbReceived#?#Click", on_zb_click)
  print("Zigbee switches initialized: " + str(zb_buttons.size()))
end
