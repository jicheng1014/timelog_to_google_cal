require 'rubygems'
require 'json'
require 'active_support/all'
require "google/api_client"
require "yaml"
require "date"
require_relative "cal"

API_VERSION = 'v3'
CACHED_API_FILE = "calendar-#{API_VERSION}.cache"
opt = YAML.load_file "config.yml"

client = Google::APIClient.new(
  :application_name=>opt['application_name'],:application_version => opt["application_version"])

key = Google::APIClient::KeyUtils.load_from_pkcs12(opt["key_file"],opt["key_secret"])

client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/calendar',
  :issuer => opt['service_account_email'],
  :signing_key => key)

client.authorization.fetch_access_token!
service = nil
## Load cached discovered API, if it exists. This prevents retrieving the
## discovery document on every run, saving a round-trip to the discovery service.
if File.exists? CACHED_API_FILE
  File.open(CACHED_API_FILE) do |file|
    service = Marshal.load(file)
  end
else
  service = client.discovered_api('calendar', API_VERSION)
  File.open(CACHED_API_FILE, 'w') do |file|
    Marshal.dump(service, file)
  end
end


result = client.execute(:api_method => service.calendar_list.list,
                      :parameters => {}
                       )
json = result.data.items[0]
calendar_id = json.id


event = {
  'summary' => 'Hello World',
  'start' => {
    'dateTime' => "2015-01-20T01:42:58+08:00"
  },
  'end' => {
    'dateTime' => "2015-01-20T02:42:58+08:00"
  }
}

data = buildCalDate("raw.txt")

for item in data
  event = {
    'summary' => "#{item[:title]}",
    'start' => {
      'dateTime' => "#{item[:begin]}"
    },
    'end' => {
      'dateTime' => "#{item[:end]}"
    }
  }
  result = client.execute(:api_method => service.events.insert,
                          :parameters => {'calendarId' => calendar_id},
                          :body => JSON.dump(event),
                          :headers => {'Content-Type' => 'application/json'})

end
#result = client.execute(:api_method => service.events.insert,
#                        :parameters => {'calendarId' => calendar_id},
#                        :body => JSON.dump(event),
#                        :headers => {'Content-Type' => 'application/json'})
