def get_mcp(chip_name)
  return mcp_chips[chip_name]
end

def parse_pin(pin_str)
  var port = pin_str[2..2]
  var pin  = int(pin_str[3..3])
  return [port, pin]
end

def relay_init()
  for rel: relays
    var mcp = get_mcp(rel["chip"])
    var pp = parse_pin(rel["pin"])
    mcp.pin_output(pp[0], pp[1])
    mcp.pin_write(pp[0], pp[1], rel["inverted"])
  end
end

def relay_set(name, value)
  for rel: relays
    if rel["name"] == name
      var mcp = get_mcp(rel["chip"])
      var pp = parse_pin(rel["pin"])
      var out = rel["inverted"] ? !value : value
      mcp.pin_write(pp[0], pp[1], out)
      print("Relay " + name + (value ? " ON" : " OFF"))
      return
    end
  end
end

def relay_toggle(name)
  for rel: relays
    if rel["name"] == name
      var mcp = get_mcp(rel["chip"])
      var pp = parse_pin(rel["pin"])
      var reg = pp[0] == "A" ? 0x14 : 0x15
      var cur = mcp.wire.read(mcp.addr, reg, 1)
      var bit = (cur >> pp[1]) & 1
      var logical = rel["inverted"] ? (bit == 0) : (bit == 1)
      relay_set(name, !logical)
      return
    end
  end
end
