def led_on(name)
  for dev: devices
    if dev["name"] == name
      persist.power_values[name] = 1
      persist.save()
      pwm_on(name, dev["chip"], dev["channels"], dev["tp"])
      tasmota.cmd('MtrUpdate {"Name":"' + name + '","Power":1,"Bri":' + str(persist.bri_values[name]) + '}')
      print(name + " ON")
      return
    end
  end
  print("Не найдено: " + name)
end

def led_off(name)
  for dev: devices
    if dev["name"] == name
      persist.power_values[name] = 0
      persist.save()
      pwm_off(dev["chip"], dev["channels"], dev["tp"])
      tasmota.cmd('MtrUpdate {"Name":"' + name + '","Power":0,"Bri":' + str(persist.bri_values[name]) + '}')
      print(name + " OFF")
      return
    end
  end
  print("Не найдено: " + name)
end

def led_toggle(name)
  if persist.power_values[name] == 1
    led_off(name)
  else
    led_on(name)
  end
end

def led_bri(name, bri)
  for dev: devices
    if dev["name"] == name
      var pwm_value = bri_to_pwm(bri)
      persist.pwm_values[name] = pwm_value
      persist.bri_values[name] = bri
      persist.save()
      var pca = get_pca(dev["chip"])
      var tp = dev["tp"]
      var ch = dev["channels"]
      if tp == "dimmer"
        pca.set_pwm(ch, pwm_value)
      elif tp == "rgb"
        var rgb = persist.rgb_values[name]
        var scale = bri / 254.0
        pca.set_pwm(ch["r"], int(rgb["r"] * scale))
        pca.set_pwm(ch["g"], int(rgb["g"] * scale))
        pca.set_pwm(ch["b"], int(rgb["b"] * scale))
      elif tp == "ct"
        var wc = ct_to_warm_cold(persist.ct_values[name], pwm_value)
        pca.set_pwm(ch["warm"], wc[0])
        pca.set_pwm(ch["cold"], wc[1])
      end
      tasmota.cmd('MtrUpdate {"Name":"' + name + '","Power":1,"Bri":' + str(bri) + '}')
      print(name + " Bri: " + str(bri))
      return
    end
  end
  print("Не найдено: " + name)
end

def all_on()
  for dev: devices
    led_on(dev["name"])
  end
end

def all_off()
  for dev: devices
    led_off(dev["name"])
  end
end

def led_status()
  for dev: devices
    var n = dev["name"]
    var power = persist.power_values[n] == 1 ? "ON " : "OFF"
    print(n + " [" + dev["tp"] + "] " + power + " Bri:" + str(persist.bri_values[n]))
  end
end
