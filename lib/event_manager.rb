require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone)
  phone = phone.scan(/\d+/).join('')

  if (phone.length < 10) || (phone.length > 11)
    phone = nil
  elsif phone.length == 11
    if phone[0] == "1"
      phone = phone[1..10]
    else
      phone = nil
    end
  end

  phone
end

$hours = Hash.new(0)
$wdays = Hash.new(0)

def time_analyzer(time)
  time = DateTime.strptime(time, '%m/%d/%y %H:%M')
  $hours[time.hour] += 1
  $wdays[time.wday] += 1
end

def time_target(time)
  time.sort_by{ |k,v|; v }.reverse.map{ |t|; t.first}[0..2].join(', ')
end

puts "EventManager Initialized!\n\n"

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  phone = clean_phone(row[:homephone])

  time_analyzer(row[:regdate])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result binding

  save_thank_you_letters(id, form_letter)
end

puts "Most popular hours are: #{time_target($hours)}"
puts "Most popular days are: #{time_target($wdays)}"
