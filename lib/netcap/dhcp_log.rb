require 'pcap'
class DHCPPacket < TCPPacket
  def discovers
    @discovers = []
  end

  def offers
    @offers = []
  end

  def requests
    @requests = []
  end

  def look_up_option

  end

  def match_sequence_id

  end
end
