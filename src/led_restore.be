def restore_state()
  print("=== restore_state start ===")
  for dev: devices
    var n = dev["name"]
    var tp = dev["tp"]
    var ch = dev["channels"]
    var chip = dev["chip"]
    var power = persist.power_values[n]
    var bri = persist.bri_values[n]

    if power == 1
      pwm_on(n, chip, ch, tp)
    else
      pwm_off(chip, ch, tp)
    end

    var cmd = '{"Name":"' + n + '","Power":' + str(power) + ',"Bri":' + str(bri)
    if tp == "ct"
      cmd += ',"CT":' + str(persist.ct_values[n])
    end
    cmd += '}'
    tasmota.cmd("MtrUpdate " + cmd)
    print("Restore " + n + ": " + cmd)
  end

  tasmota.set_timer(3000, def()
    _restoring = false
    print("=== restore done, handlers active ===")
  end)
end
