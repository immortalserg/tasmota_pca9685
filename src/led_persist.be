def init_persist()
  if !persist.has("pwm_values")   persist.pwm_values   = {} end
  if !persist.has("bri_values")   persist.bri_values   = {} end
  if !persist.has("power_values") persist.power_values = {} end
  if !persist.has("rgb_values")   persist.rgb_values   = {} end
  if !persist.has("ct_values")    persist.ct_values    = {} end

  for dev: devices
    var n = dev["name"]
    var tp = dev["tp"]
    if !persist.pwm_values.contains(n)   persist.pwm_values[n]   = 4096 end
    if !persist.bri_values.contains(n)   persist.bri_values[n]   = 254  end
    if !persist.power_values.contains(n) persist.power_values[n] = 0    end
    if tp == "rgb"
      if !persist.rgb_values.contains(n) persist.rgb_values[n] = {"r": 4096, "g": 4096, "b": 4096} end
    end
    if tp == "ct"
      if !persist.ct_values.contains(n) persist.ct_values[n] = 326 end
    end
  end
  persist.save()
end
