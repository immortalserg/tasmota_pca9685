def handle_devices()
  for dev: devices
    var n    = dev["name"]
    var tp   = dev["tp"]
    var ch   = dev["channels"]
    var chip = dev["chip"]

    # Группы обрабатываются в matter_group.be
    if tp == "group" continue end

    tasmota.add_rule("MtrReceived#" + n + "#Power",
      def(value)
        if _restoring return end
        var pwr = int(value)
        persist_set_power(n, pwr)
        persist.save()
        if pwr == 1
          pwm_on(n, chip, ch, tp)
          print(n + " Power ON")
        else
          pwm_off(chip, ch, tp)
          print(n + " Power OFF")
        end
        tasmota.cmd('MtrUpdate {"Name":"' + n + '","Power":' + str(pwr) + ',"Bri":' + str(persist.bri_values[n]) + '}')
      end
    )

    tasmota.add_rule("MtrReceived#" + n + "#Bri",
      def(brightness)
        if _restoring return end
        var bri = int(brightness)
        var pwm_value = bri_to_pwm(bri)
        persist_set_pwm(n, pwm_value)
        persist_set_bri(n, bri)
        persist.save()
        var pca = get_pca(chip)
        if tp == "dimmer"
          pca.set_pwm(ch, pwm_value)
        elif tp == "rgb"
          var rgb = persist.rgb_values[n]
          var scale = bri / 254.0
          pca.set_pwm(ch["r"], int(rgb["r"] * scale))
          pca.set_pwm(ch["g"], int(rgb["g"] * scale))
          pca.set_pwm(ch["b"], int(rgb["b"] * scale))
        elif tp == "ct"
          var wc = ct_to_warm_cold(persist.ct_values[n], pwm_value)
          pca.set_pwm(ch["warm"], wc[0])
          pca.set_pwm(ch["cold"], wc[1])
        end
        print(n + " Bri: " + str(bri))
        tasmota.cmd('MtrUpdate {"Name":"' + n + '","Power":1,"Bri":' + str(bri) + '}')
      end
    )

    if tp == "rgb"
      tasmota.add_rule("MtrReceived#" + n + "#RGB",
        def(rgb_str)
          if _restoring return end
          var r = int("0x" + rgb_str[0..1])
          var g = int("0x" + rgb_str[2..3])
          var b = int("0x" + rgb_str[4..5])
          var r_pwm = int(r * 4096 / 255)
          var g_pwm = int(g * 4096 / 255)
          var b_pwm = int(b * 4096 / 255)
          persist_set_rgb(n, {"r": r_pwm, "g": g_pwm, "b": b_pwm})
          persist.save()
          var pca = get_pca(chip)
          var scale = persist.bri_values[n] / 254.0
          pca.set_pwm(ch["r"], int(r_pwm * scale))
          pca.set_pwm(ch["g"], int(g_pwm * scale))
          pca.set_pwm(ch["b"], int(b_pwm * scale))
          print(n + " RGB: " + rgb_str)
        end
      )
    end

    if tp == "ct"
      tasmota.add_rule("MtrReceived#" + n + "#CT",
        def(ct)
          if _restoring return end
          persist_set_ct(n, int(ct))
          persist.save()
          var pca = get_pca(chip)
          var wc = ct_to_warm_cold(int(ct), persist.pwm_values[n])
          pca.set_pwm(ch["warm"], wc[0])
          pca.set_pwm(ch["cold"], wc[1])
          print(n + " CT: " + str(ct))
        end
      )
    end
  end
end
