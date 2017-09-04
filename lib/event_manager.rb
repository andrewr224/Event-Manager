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

$hour = Hash.new(0)

def time_analyzer(time)
  time = DateTime.strptime(time, '%m/%d/%y %H:%M')
  $hour[time.hour] += 1
end

def hour_target
  hour = $hour.sort_by{ |k,v|; v }.reverse.map{ |hours|; hours.first}
  puts hour[0..2].join(', ')
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

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result binding

  # save_thank_you_letters(id, form_letter)
  time_analyzer(row[:regdate])

end

hour_target
