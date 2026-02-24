# Berry не помечает вложенные словари как изменённые при persist.save()
# Поэтому переприсваиваем весь словарь перед сохранением

def persist_set_pwm(name, value)
  var tmp = persist.pwm_values
  tmp[name] = value
  persist.pwm_values = tmp
end

def persist_set_bri(name, value)
  var tmp = persist.bri_values
  tmp[name] = value
  persist.bri_values = tmp
end

def persist_set_power(name, value)
  var tmp = persist.power_values
  tmp[name] = value
  persist.power_values = tmp
end

def persist_set_rgb(name, value)
  var tmp = persist.rgb_values
  tmp[name] = value
  persist.rgb_values = tmp
end

def persist_set_ct(name, value)
  var tmp = persist.ct_values
  tmp[name] = value
  persist.ct_values = tmp
end

def init_persist()
  if !persist.has("pwm_values")   persist.pwm_values   = {} end
  if !persist.has("bri_values")   persist.bri_values   = {} end
  if !persist.has("power_values") persist.power_values = {} end
  if !persist.has("rgb_values")   persist.rgb_values   = {} end
  if !persist.has("ct_values")    persist.ct_values    = {} end

  for dev: devices
    var n = dev["name"]
    var tp = dev["tp"]
    if !persist.pwm_values.contains(n)   persist_set_pwm(n, 4096) end
    if !persist.bri_values.contains(n)   persist_set_bri(n, 254)  end
    if !persist.power_values.contains(n) persist_set_power(n, 0)  end
    if tp == "rgb"
      if !persist.rgb_values.contains(n) persist_set_rgb(n, {"r": 4096, "g": 4096, "b": 4096}) end
    end
    if tp == "ct"
      if !persist.ct_values.contains(n) persist_set_ct(n, 326) end
    end
  end
  persist.save()
end
