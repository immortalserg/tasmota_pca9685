# Виртуальная группа Matter
# Хелперы для получения параметров устройства по имени
def get_dev_chip(name)
  for dev: devices
    if dev["name"] == name return dev["chip"] end
  end
end

def get_dev_channels(name)
  for dev: devices
    if dev["name"] == name return dev["channels"] end
  end
end

def get_dev_tp(name)
  for dev: devices
    if dev["name"] == name return dev["tp"] end
  end
end

def mtr_group_init()
  for grp_name: mtr_groups.keys()
    # Подписаться на команды этой группы
    tasmota.add_rule("mtrreceived#" + grp_name + "#power",
      def(value)
        if _restoring return end
        var targets = mtr_groups[grp_name]
        for target: targets
          persist_set_power(target, int(value))
          if value == 1
            pwm_on(target,
              get_dev_chip(target),
              get_dev_channels(target),
              get_dev_tp(target))
          else
            pwm_off(get_dev_chip(target),
              get_dev_channels(target),
              get_dev_tp(target))
          end
          # Синхронизировать состояние в Matter
          var cmd = '{"Name":"' + target + '","Power":' + str(int(value)) + ',"Bri":' + str(persist.bri_values[target]) + '}'
          tasmota.cmd("MtrUpdate " + cmd)
        end
        persist.save()
        print(grp_name + " Power: " + str(value))
      end
    )

    tasmota.add_rule("mtrreceived#" + grp_name + "#bri",
      def(brightness)
        if _restoring return end
        var targets = mtr_groups[grp_name]
        var pwm_value = bri_to_pwm(int(brightness))
        for target: targets
          persist_set_pwm(target, pwm_value)
          persist_set_bri(target, int(brightness))
          var pca = get_pca(get_dev_chip(target))
          pca.set_pwm(get_dev_channels(target), pwm_value)
          var cmd = '{"Name":"' + target + '","Power":1,"Bri":' + str(int(brightness)) + '}'
          tasmota.cmd("MtrUpdate " + cmd)
        end
        persist.save()
        print(grp_name + " Bri: " + str(brightness))
      end
    )
  end
  print("Matter groups initialized: " + str(mtr_groups.keys()))
end
