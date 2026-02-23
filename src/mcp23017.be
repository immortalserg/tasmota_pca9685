# Класс для управления MCP23017 через I2C
class MCP23017
  var addr
  var wire
  # Регистры
  static IODIRA   = 0x00
  static IODIRB   = 0x01
  static IPOLA    = 0x02
  static IPOLB    = 0x03
  static GPPUA    = 0x0C
  static GPPUB    = 0x0D
  static GPIOA    = 0x12
  static GPIOB    = 0x13
  static OLATA    = 0x14
  static OLATB    = 0x15

  def init(addr)
    self.addr = addr
    self.wire = wire1
    # Все пины - входы по умолчанию
    self.wire.write(self.addr, self.IODIRA, 0xFF, 1)
    self.wire.write(self.addr, self.IODIRB, 0xFF, 1)
    # Pullup выключен по умолчанию
    self.wire.write(self.addr, self.GPPUA, 0x00, 1)
    self.wire.write(self.addr, self.GPPUB, 0x00, 1)
    # Выходные защёлки в 0
    self.wire.write(self.addr, self.OLATA, 0x00, 1)
    self.wire.write(self.addr, self.OLATB, 0x00, 1)
  end

  # port: "A" или "B", pin: 0-7
  def pin_input(port, pin, pullup)
    var reg_dir = port == "A" ? self.IODIRA : self.IODIRB
    var reg_pu  = port == "A" ? self.GPPUA  : self.GPPUB
    var val_dir = self.wire.read(self.addr, reg_dir, 1)
    var val_pu  = self.wire.read(self.addr, reg_pu,  1)
    val_dir |= (1 << pin)
    if pullup
      val_pu |= (1 << pin)
    else
      val_pu &= ~(1 << pin)
    end
    self.wire.write(self.addr, reg_dir, val_dir, 1)
    self.wire.write(self.addr, reg_pu,  val_pu,  1)
  end

  def pin_output(port, pin)
    var reg_dir = port == "A" ? self.IODIRA : self.IODIRB
    var val_dir = self.wire.read(self.addr, reg_dir, 1)
    val_dir &= ~(1 << pin)
    self.wire.write(self.addr, reg_dir, val_dir, 1)
  end

  def pin_read(port, pin)
    var reg = port == "A" ? self.GPIOA : self.GPIOB
    var val = self.wire.read(self.addr, reg, 1)
    return (val >> pin) & 1
  end

  def pin_write(port, pin, value)
    var reg_ol = port == "A" ? self.OLATA : self.OLATB
    var val = self.wire.read(self.addr, reg_ol, 1)
    if value
      val |= (1 << pin)
    else
      val &= ~(1 << pin)
    end
    self.wire.write(self.addr, reg_ol, val, 1)
  end
end
