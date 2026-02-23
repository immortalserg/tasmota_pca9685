# Класс для управления PCA9685 через I2C
class PCA9685
  var addr
  var wire

  def init(addr)
    self.addr = addr
    self.wire = wire1
    self.reset()
    self.set_freq(1000)
  end

  def reset()
    self.wire.write(self.addr, 0x00, 0x20, 1)
  end

  def set_freq(freq)
    var prescale = int(25000000.0 / (4096.0 * freq) + 0.5) - 1
    var mode1 = self.wire.read(self.addr, 0x00, 1)
    var sleep = (mode1 & 0x7F) | 0x10
    self.wire.write(self.addr, 0x00, sleep, 1)
    self.wire.write(self.addr, 0xFE, prescale, 1)
    self.wire.write(self.addr, 0x00, mode1, 1)
    tasmota.delay(5)
    self.wire.write(self.addr, 0x00, mode1 | 0x80, 1)
  end

  def set_pwm(channel, value)
    var reg = 0x06 + channel * 4
    if value >= 4096
      self.wire.write(self.addr, reg,     0, 1)
      self.wire.write(self.addr, reg + 1, 0x10, 1)
      self.wire.write(self.addr, reg + 2, 0, 1)
      self.wire.write(self.addr, reg + 3, 0, 1)
    elif value == 0
      self.wire.write(self.addr, reg,     0, 1)
      self.wire.write(self.addr, reg + 1, 0, 1)
      self.wire.write(self.addr, reg + 2, 0, 1)
      self.wire.write(self.addr, reg + 3, 0x10, 1)
    else
      self.wire.write(self.addr, reg,     0, 1)
      self.wire.write(self.addr, reg + 1, 0, 1)
      self.wire.write(self.addr, reg + 2, value & 0xFF, 1)
      self.wire.write(self.addr, reg + 3, (value >> 8) & 0x0F, 1)
    end
  end
end
