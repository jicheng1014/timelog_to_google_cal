require "io/console"
require "active_support/all"

def buildCalDate(file_name,my_date = DateTime.now)
  answer = []
  over_day = false
  last_end_time = nil
  IO.foreach(file_name).reject{|p| p.strip.empty? }.each do |row| 
    data = row.split
    begin_hours = data[0][0..1]
    begin_minutes = data[0][-2..-1]

    end_hours = data[1][0..1]
    end_minutes = data[1][-2..-1]

    print "null \n" if last_end_time.nil? 
    print "last =  #{last_end_time}\n " if last_end_time 
    begin_datetime = my_date.change(hour: begin_hours.to_i,min: begin_minutes.to_i)
    begin_datetime = begin_datetime.next_day if over_day


    end_datetime = my_date.change(hour: end_hours.to_i,min: end_minutes.to_i)  
    over_day = true if end_datetime < begin_datetime
    end_datetime = end_datetime.next_day if over_day

    last_end_time = end_datetime

    minutes_between = (end_datetime - begin_datetime)*60 *24
    title = "#{data[2..-1].join} (#{minutes_between.to_i})"
    answer << { title: title,begin: begin_datetime,end:end_datetime}
  end
  answer

end


