# require 'benchmark'
# http_headers = ["GET /ads/cheesy.jpg HTTP/1.1", "Host: static.reddit.com", "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1", "Accept: image/png,image/*;q=0.8,*/*;q=0.5", "Accept-Language: en-us,en;q=0.5", "Accept-Encoding: gzip, deflate", "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7", "Connection: keep-alive", "Referer: http://www.redditmedia.com/ads/", "Cookie: reddit_first=%7B%22organic_pos%22%3A%201%2C%20%22firsttime%22%3A%20%22first%22%7D; __utma=55650728.909503362.1327595693.1327602666.1327606692.3; __utmc=55650728; __utmz=55650728.1327595693.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _recentclicks2=t3_oxora%2Ct3_oxnnf%2Ct3_oxlxd%2Ct3_oxlo9%2Ct3_oxl8k%2Ct3_oxlcb%2Ct3_oxkzg%2C; __utmb=55650728.1.10.1327606692"]
#
# index_time = Benchmark.realtime do
#   if index = http_headers.find_index {|header| header.include? "User-Agent"}
#     @http_user_agent ||= http_headers[index]
#   else
#     @http_user_agent ||= ""
#   end
# end
# puts "index_time elapsed  #{index_time*1000} milliseconds"
#
# select_time = Benchmark.realtime do
#   temp_agent = http_headers.select do |header|
#     header.include? "User-Agent"
#   end.first
#
#   if temp_agent
#     @http_user_agent = temp_agent[12..-1]
#   else
#     @http_user_agent = ""
#   end
# end
# puts "select_time elapsed #{select_time*1000} milliseconds"
require './netcap/packet_scan'
require 'benchmark'
@namen = []
File.open("manus.txt","r").each_line do |line|
  a = line.split("#")
  addr = a[0][0..7].strip.gsub(/[:]/, "")
  if a[1]
    name = a[1][1..-1].strip
  else
    name = a[0].split(',').last.strip
  end
  @namen << [name,addr]
end
time = Benchmark.realtime do
  @me = @namen.rassoc("001B63")
end
puts "time elapsed  #{time*1000} milliseconds...it's #{@me}"
