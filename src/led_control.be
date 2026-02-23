def get_pca(chip_name)
  return pca_chips[chip_name]
end

def bri_to_pwm(bri)
  return int(bri * 4096 / 254)
end

def ct_to_warm_cold(ct, pwm)
  var warm = int(pwm * (ct - 153) / (500 - 153))
  var cold = pwm - warm
  return [warm, cold]
end

def pwm_off(chip_name, channels, tp)
  var pca = get_pca(chip_name)
  if tp == "dimmer"
    pca.set_pwm(channels, 0)
  elif tp == "rgb"
    pca.set_pwm(channels["r"], 0)
    pca.set_pwm(channels["g"], 0)
    pca.set_pwm(channels["b"], 0)
  elif tp == "ct"
    pca.set_pwm(channels["warm"], 0)
    pca.set_pwm(channels["cold"], 0)
  end
end

def pwm_on(name, chip_name, channels, tp)
  var pca = get_pca(chip_name)
  var pwm = persist.pwm_values[name]
  if tp == "dimmer"
    pca.set_pwm(channels, pwm)
  elif tp == "rgb"
    var rgb = persist.rgb_values[name]
    var scale = pwm / 4096.0
    pca.set_pwm(channels["r"], int(rgb["r"] * scale))
    pca.set_pwm(channels["g"], int(rgb["g"] * scale))
    pca.set_pwm(channels["b"], int(rgb["b"] * scale))
  elif tp == "ct"
    var wc = ct_to_warm_cold(persist.ct_values[name], pwm)
    pca.set_pwm(channels["warm"], wc[0])
    pca.set_pwm(channels["cold"], wc[1])
  end
end
