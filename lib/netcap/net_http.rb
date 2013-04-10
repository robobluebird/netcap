require 'json'
require 'rest-client'
class NetHttp
  ENDPOINT = ""
  SUBDOMAIN = ""
  ACCOUNT_ID = "c79bc5be-1aac-11e1-b052-001b63fffe8e"
  DEVICE_ID = "net123"

  def event_id
  end

  def device_id
  end

  def self.put_anon(watched)
    url = "http://demo.safehaus.heroku.com/network/put_anon"
    sender = Thread.new {
    RestClient.post(url,
    {
      :account_id => 'c79bc5be-1aac-11e1-b052-001b63fffe8e',
      :device_id => 'net123',
      :watched =>
      {
        :address => watched.address,
        :manufacturer => watched.manufacturer,
        :agent => watched.agent,
        :sites => watched.sites.to_s.gsub(/[^.,a-zA-Z0-9]/, ""),
        :searches => watched.searches.to_s.gsub(/[^.,a-zA-Z0-9]/, ""),
        :youtubes => watched.youtubes.to_s.gsub(/[^.,a-zA-Z0-9]/, ""),
        :tokens => watched.tokens.to_s.gsub(/[^.,a-zA-Z0-9]/, "")
      }
    }.to_json, :content_type => :json, :accept => :json) {|res| print " " + res + " "}}.join
  end
end
