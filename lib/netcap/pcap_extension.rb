require 'pcap'
require './netcap/packet_scan'
require 'cgi'

module Pcap
  class Packet
    def packet_type
      @packet_type = self.raw_data[12,14].unpack('H2H2').join
    end

    def arp?
      packet_type == "0806"
    end

    def ipv6?
      packet_type == "08DD"
    end
  end

  class IPPacket < Packet
    def eth_src
      @eth_src = self.raw_data[6,12].unpack('H2H2H2H2H2H2').join().upcase
    end

    def eth_dst
      @eth_dst = self.raw_data[0,6].unpack('H2H2H2H2H2H2').join().upcase
    end

    def manu
      @manu = PacketScan.match_manufacturer(eth_src)
    end
  end

  class UDPPacket < IPPacket
    def dns?
      self.udp_sport == 53
    end

    def dns_phrase
      dns_data = self.raw_data[54..self.length]

      query = dns_data.unpack("H*").join.split("00").first
      query_name = [query].pack("H*").gsub(/[^a-zA-Z0-9]/, "")
    end

    def dns_responses
      if @dns_responses
        @dns_responses
      else
        dns_data = self.raw_data[54..self.length]
        if dns_data
          query = dns_data.unpack("H*").join.split("00").first
          query_length = (query.length + 2) / 2

          response_count = self.udp_data[6,2].unpack("H2H2").join.to_i(16)

          responses = []
          offset = query_length + 14
          response_count.times do |count|
            break if offset + 4 > dns_data.length
            response_length = dns_data[offset, 2].unpack("H2H2").join.to_i(16)
            unpackable = "H2" * response_length
            responses << (dns_data[offset + 2, response_length].unpack(unpackable).map do |p|
              p.to_i(16)
            end.join("."))
            offset += response_length + 12
          end

          @dns_responses = responses
        end
      end
    end

    def dhcp?
      if self.udp_sport == 68 && self.udp_data[244,4].unpack("H2H2H2H2").join == "3903F326"
        dhcp_options.each do |opt|
          break true if opt[:option] == "dhcp_type" && opt[:value] == 5
        end
        false
      end
    end

    def dhcp_client_ip
      client_ip = self.udp_data[20,4].unpack("H2H2H2H2").join
    end

    def dhcp_client_mac
      client_mac = self.udp_data[36,16].unpack("H*").join
    end

    def dhcp_your_ip
      your_ip = self.udp_data[24,4].unpack("H2H2H2H2").join
    end

    def dhcp_transaction_id
      transaction_id = self.udp_data[12,4].unpack("H2H2H2H2").join
    end

    def dhcp_options
      if @dhcp_options
        @dhcp_options
      else
        total_packet_length = self.udp_data[4,2].unpack("H2H2").join.to_i(16)
        ptr = 248
        options = []
        until ptr >= total_packet_length
          option_id = self.udp_data[ptr,1].unpack("H*").join
          ptr += 1
          option_length = self.udp_data[ptr, 1].unpack("H*").join.to_i(16)
          ptr += 1
          value = self.udp_data[ptr, option_length].unpack("H*").join
          ptr += option_length
          options << {:option => option_id, :value => value}
        end
        @dhcp_options = dhcp_resolve_options(options)
      end
    end

    def dhcp_resolve_options(options)
      options.map! do |op|
        case op[:option]
        when 1
          #subnet mask
        when 3
          #router address
        when 6
          #dns servers
        when 50
          #address requested
        when 51
          #lease time
        when 53
          op[:option] = "dhcp_type"
          op[:value] = op[:value].to_i(16)
          print "HEY: #{op[:option]} is #{op[:value]}!"
        when 54
          #dhcp server address
        when 55
          #parameter request list
        end
      end
    end
  end

  class TCPPacket < IPPacket
    def http?
      self.tcp_dport == 80
    end

    def http_referred?
      !http_headers.select {|header| header.include? "Referer"}.empty?
    end

    def http_post?
      http_headers[0].include? "POST"
    end

    def http_headers
      if self.tcp_data
        @http_headers ||= self.tcp_data.unpack("H*").join.split("0d0a").map! do |part|
          [part].pack("H*")
        end
      end
    end

    def http_user_agent
      if @http_user_agent
        @http_user_agent
      else
        temp_agent = http_headers.select do |header|
          header.include? "User-Agent"
        end.first

        if temp_agent
          @http_user_agent = temp_agent[12..-1] # parse_agent?
        else
          @http_user_agent = ""
        end
      end
    end

    def http_request_name
      if @http_request_name
        @http_request_name
      else
        temp_agent = http_headers.select do |header|
          header.include? "Host"
        end.first

        if temp_agent
          @http_request_name = temp_agent[6..-1]
        else
          @http_request_name = ""
        end
      end
    end

    def search?
      http_headers[0] =~ /search(\/#|\?)(.*&)*q=/i
    end

    def search_term
      @search_term ||= http_headers[0].match(/[\?&]q=(\w+(\+\w+)*)/i)[1]
    end

    def youtube_request?
      http_headers[0] =~ /youtube\.com%2Fwatch%3Fv%3D/
    end

    def youtube_video_id
      @youtube_video_id ||= http_headers[0].match(/youtube\.com%2Fwatch%3Fv%3D(\w+-*\w+)/i)[1] #.split("?").last.split('&').collect{|i|i.split('=')}.assoc("v").last.split(" ").first
    end

    def parse_agent(agent)
      open = agent.index('(')
      if open
        close = agent.index(')', open)
        if close
          cut_agent = agent[(open + 1)..(close - 1)]
          if agent =~ /ipod|ipad|iphone/i
            temp = cut_agent.split("; ")
            temp[0]
          elsif agent =~ /android/i
            temp = cut_agent.split("; ")
            if temp[2]
              temp[2].gsub("_", ".") + " device"
            else
              "Android Device"
            end
          elsif agent =~ /macintosh/i
            cut_agent.split("; ")[1].gsub("_", ".")
          else
            cut_agent
          end
        else
          agent
        end
      else
        agent
      end
    end

    def http_request_address
    end
  end
end
