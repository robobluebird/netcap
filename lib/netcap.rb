# We'll need a couple gems for this: jeweler and ruby-pcap
require 'rubygems'
require 'pcap'
require './netcap/pcap_extension.rb'
require './netcap/packet_scan'
require './netcap/watch_list'
require './netcap/net_http'
require 'sqlite3'

count = 1

watch_list = WatchList.new
PacketScan.import_manufacturers

dev = Pcap.lookupdev
cap = Pcap::Capture.open_live(dev,2500)

#no filter necessary, but if we needed it...
#cap.setfilter("ip") #ether host 7C:ED:8D:E0:65:A8

cap.loop(-1) do |pkt|
  if ip = PacketScan.match_destination(pkt)
  end

  if pkt.ip?
    if pkt.tcp?
      if pkt.http?
        if pkt.http_headers && !pkt.http_referred?
          if watch_list.watching? pkt.eth_src
            watch_list.update do |w|
              if w.address == pkt.eth_src
                if pkt.http_post?
                  w.posts << pkt.http_request_name
                end

                if !w.sites.include? pkt.http_request_name
                  w.counts[pkt.http_request_name] = 1
                  if pkt.http_request_name.length > 0
                    w.sites << pkt.http_request_name

                    if w.agent.length > 0
                      #NetHttp.put_anon(w)
                      w.print
                    else
                      w.agent = pkt.http_user_agent
                    end
                  end
                else
                  if w.counts.include? pkt.http_request_name
                    w.counts[pkt.http_request_name] += 1
                  end
                end

                if pkt.search?
                  unless w.searches.include? pkt.search_term
                    puts pkt.search_term
                    w.searches << pkt.search_term

                    #NetHttp.put_anon(w)
                    w.print
                  end
                end

                if pkt.youtube_request?
                  unless w.youtubes.include? pkt.youtube_video_id
                    puts pkt.youtube_video_id
                    w.youtubes << pkt.youtube_video_id

                    #NetHttp.put_anon(w)
                    w.print
                  end
                end
              end
            end
          else
            watched = Watched.new(pkt.eth_src, PacketScan.match_manufacturer(pkt.eth_src))
            watch_list.add(watched)
          end
        end
      else
        #if not http
      end
    elsif pkt.udp?
      if pkt.dns?
        query = pkt.dns_phrase
        responses = pkt.dns_responses
        #add returned addrii to simple list
      elsif pkt.dhcp?
        #create record in the watch list
      else
      end
    else
      #icmp packet
    end
    #print "."
    count += 1
  elsif pkt.arp?
    #print "."
    count += 1
  else
    #print "."
    count += 1
  end
end

cap.close
