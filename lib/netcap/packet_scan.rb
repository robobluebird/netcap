require './netcap/ip_endpoint'
class PacketScan
  # :name => "xboxlive",
  # :abs_addr => true,
  # :addr => "65.55.42.52",
  # :type => "UDP",
  # :port => 3074,
  # :token_val => 2
  #interesting IP endpoints
  def self.ip_dsts
    @@ip_dsts ||= []
  end

  #interesting DNS queries
  def dns_queries
    @dns_queries ||= {:Netflix => ["nflx", "netflix"]}
  end

  #dictionary of ethernet cards manufacturers and first-three tuples
  def self.eth_srcs
    @@eth_srcs ||= []
  end

  #dictionary of events, by manufacturer. Inside the value, we have an
  #array of hashes defining the event number and an array of integers representing
  #that event's token string
  def events
    @events ||= {:Microsoft => [{:event_num => 1, :token_string => [1,2,3]}]}
  end

  #load ip endpoints, ethernet sources, and event dictionary from file system
  def self.import_manufacturers
    File.open("./manus.txt","r").each_line do |line|
      a = line.split("#")
      addr = a[0][0..7].strip.gsub(/[:]/, "")
      if a[1]
        name = a[1][1..-1].strip
      else
        name = a[0].split(',').last.strip
      end
      eth_srcs << [name,addr]
    end
  end

  def self.match_manufacturer(source_mac)
    if manu = eth_srcs.rassoc(source_mac[0..5])
      manu.first
    else
      "not found"
    end
  end

  def self.match_destination(packet)
    self.ip_dsts.each do |ip|
      if ip.eql? packet
        ip
      else
        nil
      end
    end
  end
end
