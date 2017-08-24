require 'csv'
puts "EventManager Initialized!\n\n"

contents = CSV.open 'event_attendees.csv', headers: true
contents.each do |row|
  name = row[2]
  puts name
end
