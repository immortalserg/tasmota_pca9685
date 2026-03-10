var btn_state = {}
var DIM_STEP     = 5
var DIM_INTERVAL = 50
var LONG_PRESS   = 600

# Получить список целей кнопки (поддержка "target" и "targets")
def btn_get_targets(btn)
  if btn.contains("targets")
    return btn["targets"]
  elif btn.contains("target")
    return [btn["target"]]
  end
  return []
end

def btn_name(btn)
  return btn["chip"] + "_" + btn["pin"]
end

def btn_is_led(name)
  for dev: devices
    if dev["name"] == name return true end
  end
  return false
end

def btn_init()
  for btn: buttons
    var mcp = get_mcp(btn["chip"])
    var pp = parse_pin(btn["pin"])
    mcp.pin_input(pp[0], pp[1], true)
    var nm = btn_name(btn)
    if !btn_state.contains(nm)
      btn_state[nm] = {"pressed_time": 0, "long_active": false, "dim_dir": 1, "last_val": 1}
    end
  end
end

# Короткое нажатие — toggle всех целей кнопки
def do_short_action(btn)
  var targets = btn_get_targets(btn)
  if btn["short"] == "toggle"
    for target: targets
      if btn_is_led(target)
        led_toggle(target)
      else
        relay_toggle(target)
      end
    end
  end
end

# Один шаг диммирования — применяется ко всем целям
def do_dim_step(btn_nm, btn)
  var st = btn_state[btn_nm]
  if !st["long_active"] return end

  var targets = btn_get_targets(btn)

  # Берём яркость первой цели как ориентир
  var first = targets[0]
  var cur_bri = persist.bri_values[first]
  var next_bri = cur_bri + st["dim_dir"] * DIM_STEP

  if next_bri >= 254
    next_bri = 254
    st["dim_dir"] = -1
  elif next_bri <= 0
    next_bri = 0
    st["dim_dir"] = 1
  end

  # Применить ко всем целям
  for target: targets
    led_bri(target, next_bri)
  end

  tasmota.set_timer(DIM_INTERVAL, def()
    do_dim_step(btn_nm, btn)
  end)
end

def btn_poll()
  for btn: buttons
    var mcp = get_mcp(btn["chip"])
    var pp = parse_pin(btn["pin"])
    var nm = btn_name(btn)
    var st = btn_state[nm]
    var val = mcp.pin_read(pp[0], pp[1])
    var targets = btn_get_targets(btn)

    # Нажатие (фронт 1→0)
    if val == 0 && st["last_val"] == 1
      st["pressed_time"] = tasmota.millis()
      st["long_active"] = false
    end

    # Удержание
    if val == 0 && st["last_val"] == 0
      var held = tasmota.millis() - st["pressed_time"]
      if held >= LONG_PRESS && !st["long_active"] && btn["long"] == "dim"
        st["long_active"] = true
        # Если первая цель выключена — включаем все
        if persist.power_values[targets[0]] == 0
          for target: targets
            led_on(target)
          end
        end
        do_dim_step(nm, btn)
      end
    end

    # Отпускание (фронт 0→1)
    if val == 1 && st["last_val"] == 0
      var held = tasmota.millis() - st["pressed_time"]
      if st["long_active"]
        st["long_active"] = false
      elif held < LONG_PRESS
        do_short_action(btn)
      end
    end

    st["last_val"] = val
  end

  tasmota.set_timer(20, btn_poll)
end
