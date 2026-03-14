var btn_state = {}
var DIM_STEP      = 5
var DIM_INTERVAL  = 50
var LONG_PRESS    = 600
var DOUBLE_WINDOW = 400

# Проверить что значение является map с ключом "action"
# В Berry строки не имеют метод .contains(), поэтому
# используем try/except для безопасной проверки
def is_event_map(v)
  try
    return v.contains("action")
  except .. as e, m
    return false
  end
end

# Развернуть список имён с подстановкой групп
def btn_expand_targets(raw)
  var result = []
  for t: raw
    if mtr_groups.contains(t)
      for led: mtr_groups[t]
        result.push(led)
      end
    else
      result.push(t)
    end
  end
  return result
end

# Общие цели кнопки (верхний уровень)
def btn_get_targets(btn)
  var raw = []
  if btn.contains("targets")
    raw = btn["targets"]
  elif btn.contains("target")
    raw = [btn["target"]]
  end
  return btn_expand_targets(raw)
end

# Цели для конкретного события
def btn_event_targets(btn, ev)
  if is_event_map(ev)
    var raw = []
    if ev.contains("targets")
      raw = ev["targets"]
    elif ev.contains("target")
      raw = [ev["target"]]
    end
    return btn_expand_targets(raw)
  end
  return btn_get_targets(btn)
end

# Действие из значения события
def btn_event_action(ev)
  if is_event_map(ev)
    return ev["action"]
  end
  return ev
end

# Цели для long (диммирование)
def btn_long_targets(btn)
  if btn.contains("long")
    var ev = btn["long"]
    if is_event_map(ev)
      var raw = []
      if ev.contains("targets")
        raw = ev["targets"]
      elif ev.contains("target")
        raw = [ev["target"]]
      end
      return btn_expand_targets(raw)
    end
  end
  return btn_get_targets(btn)
end

# Проверить что long == dim (в любом синтаксисе)
def btn_long_is_dim(btn)
  if !btn.contains("long") return false end
  var ev = btn["long"]
  if ev == "dim" return true end
  if is_event_map(ev) return ev["action"] == "dim" end
  return false
end

def btn_name(btn)
  return btn["chip"] + "_" + btn["pin"]
end

def btn_is_led(name)
  for dev: devices
    if dev["name"] == name && dev["tp"] != "group" return true end
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

# Универсальное выполнение действия
# action: "toggle" / "on" / "off" / map {"bri": 0..254}
def do_action(action, targets)
  if action == "toggle"
    for target: targets
      if btn_is_led(target)
        led_toggle(target)
      else
        relay_toggle(target)
      end
    end
  elif action == "on"
    for target: targets
      if btn_is_led(target) led_on(target) end
    end
  elif action == "off"
    for target: targets
      if btn_is_led(target) led_off(target) end
    end
  else
    # Попытка обработать как map {"bri": N} или {"b_onoff": N}
    try
      if action.contains("b_onoff")
        # Если выключено — включить с яркостью, если включено — выключить
        var bri = int(action["b_onoff"])
        for target: targets
          if btn_is_led(target)
            if persist.power_values[target] == 0
              led_on(target)
              led_bri(target, bri)
            else
              led_off(target)
            end
          end
        end
      elif action.contains("bri")
        # Установить яркость: сначала bri, потом включить — чтобы включилось сразу с нужной яркостью
        var bri = int(action["bri"])
        for target: targets
          if btn_is_led(target)
            led_bri(target, bri)
            if persist.power_values[target] == 0 led_on(target) end
          end
        end
      end
    except .. as e, m
      print("btn do_action error: " + m)
    end
  end
end

def do_short_action(btn)
  if !btn.contains("short") return end
  var ev = btn["short"]
  do_action(btn_event_action(ev), btn_event_targets(btn, ev))
end

def do_double_action(btn)
  if !btn.contains("double") return end
  var ev = btn["double"]
  do_action(btn_event_action(ev), btn_event_targets(btn, ev))
end

def do_dim_step(btn_nm, btn)
  var st = btn_state[btn_nm]
  if !st["long_active"] return end

  var targets = btn_long_targets(btn)
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

    # Нажатие
    if val == 0 && st["last_val"] == 1
      st["pressed_time"] = tasmota.millis()
      st["long_active"] = false
    end

    # Удержание — диммирование
    if val == 0 && st["last_val"] == 0
      var held = tasmota.millis() - st["pressed_time"]
      if held >= LONG_PRESS && !st["long_active"] && btn_long_is_dim(btn)
        st["long_active"] = true
        st["pending_single"] = false
        var lt = btn_long_targets(btn)
        if persist.power_values[lt[0]] == 0
          for target: lt
            led_on(target)
          end
        end
        do_dim_step(nm, btn)
      end
    end

    # Отпускание
    if val == 1 && st["last_val"] == 0
      var held = tasmota.millis() - st["pressed_time"]
      if st["long_active"]
        st["long_active"] = false
      elif held < LONG_PRESS
        if st["pending_single"]
          # Второй клик — двойной!
          st["pending_single"] = false
          do_double_action(btn)
        else
          if btn.contains("double")
            # Есть двойное действие — ждём второго клика
            st["pending_single"] = true
            st["release_time"] = tasmota.millis()
            var _nm = nm
            var _btn = btn
            tasmota.set_timer(DOUBLE_WINDOW, def()
              var s = btn_state[_nm]
              if s["pending_single"]
                s["pending_single"] = false
                do_short_action(_btn)
              end
            end)
          else
            # Двойной не настроен — сразу без задержки
            do_short_action(btn)
          end
        end
      end
    end

    st["last_val"] = val
  end

  tasmota.set_timer(20, btn_poll)
end
