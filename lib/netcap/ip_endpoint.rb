class IPEndpoint
  def name
    @name ||= ""
  end

  def abs
    @abs ||= true
  end

  def absolute?
    abs
  end

  def address
    @address ||= ""
  end

  def type
    @type = ""
  end

  def port
    @port ||= 0
  end

  def token
    @token ||= 0
  end

  def initialize(name="", abs=true, address="", type="", port=0, token=0)
    @name = name
    @abs = abs
    @address = address
    @type = type
    @port = port
    @token = token
  end

  def eql?(packet)
    if packet.tcp?
      if absolute?
        packet.ip_dst = address && packet.tcp_dport == port
      else
        packet.ip_dst =~ address && packet.tcp_dport == port
      end
    elsif packet.udp?
      if absolute?
        packet.ip_dst = address && packet.udp_dport == port
      else
        packet.ip_dst =~ address && packet.udp_dport == port
      end
    end
  end
end
