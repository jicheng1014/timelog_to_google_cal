require 'rubygems'
require 'json'
require 'active_support/all'
require "google/api_client"
require "yaml"
require "date"
require_relative "cal_txt_scan"

API_VERSION = 'v3'
CACHED_API_FILE = "calendar-#{API_VERSION}.cache"
opt = YAML.load_file "config.yml"
file = "raw.txt"
day = 0
case ARGV.count 

when 0
  puts "day ?   0 is today, 1 is yesterday"
  day = gets
  day = day.to_i


  puts "filename ? default = 'raw.txt'"
  file = gets
  file = 'raw.txt' if file.strip.empty?

when 1
  day = ARGV[0].to_i  
when 2
  day = ARGV[0].to_i  
  file = ARGV[1]
end

standard_date = DateTime.now.next_day(0 - day).change(hour: 0,min:0)

puts "开始处理#{standard_date.to_date.to_s} 的数据，数据来源为#{file}"


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

print "calendar_id = #{calendar_id}"


result = client.execute(:api_method => service.events.list,
                        :parameters => {
                              'calendarId' => calendar_id,
                              'timeMax' => standard_date.next_day(2),
                              'timeMin' => standard_date
})
old_data = result.data.items.select do |item|
  item.description and item.description == standard_date.to_date.to_s
end

for item in old_data
  puts "delete old log data #{item.start.dateTime} - #{item.end.dateTime} #{item.summary} ..."
  # delete
  result = client.execute(:api_method => service.events.delete,
                                                  :parameters => {'calendarId' => calendar_id, 'eventId' => item.id})
  
end



data = buildCalDate(file,standard_date)

for item in data
  event = {
    'summary' => "#{item[:title]}",
    'start' => {
      'dateTime' => "#{item[:begin]}"
    },
    'description' => standard_date.to_date.to_s,
    'end' => {
      'dateTime' => "#{item[:end]}"
    }
  }
  puts "写入记录 #{item[:begin].strftime("%H:%M")} - #{item[:end].strftime("%H:%M")} #{item[:title]}"
  result = client.execute(:api_method => service.events.insert,
                          :parameters => {'calendarId' => calendar_id},
                          :body => JSON.dump(event),
                          :headers => {'Content-Type' => 'application/json'})

end
puts "写完了，可以访问 http://calendar.google.com 了"
