require 'telegram/bot'
require 'open-uri'
require 'lightly'
require 'icalendar'
require 'date'
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))

lightly = Lightly.new dir: File.join(File.dirname(__FILE__), "cache"), life: config["cache_life"], hash: false

def upcoming_events(events, num_days: 7, start_date: DateTime.now, end_date: nil)
	upcoming = []
	end_date = start_date + (num_days * 86400)
	ok_events = events.select { |event| event.dtstart.to_datetime.between?(start_date, end_date) }
	ok_events.each do |event|
		upcoming << {
			event: event,
			start_time: event.dtstart.to_datetime
		}
	end
	upcoming.sort { |a,b| a[:start_time] <=> b[:start_time] }
end

Telegram::Bot::Client.run(config["token"]) do |bot|
	bot.listen do |message|
		case message.text
			when /^\/start/i
				if message.chat.type == 'private'
					bot.api.send_message(chat_id: message.chat.id, text: "Niente da leggere qui", reply_to_message_id: message.message_id)
				end
			when /^\/upcoming/i
				fork do
					output = "Prossimi eventi su *Planet LUG*:\n"
					glob_events = lightly.get "glob_events" do
						temp_events = []
						config["calendars"].each do |name, link|
							puts "Scarico " + name
							cur_ics = lightly.get name do
								open(link).read rescue nil
							end
							if !cur_ics.nil?
								cur_cal = Icalendar::Calendar.parse(cur_ics).first
								cur_cal.events.each do |event|
									event.summary = name + " - " + event.summary
									temp_events << event
								end
							end
						end						
						temp_events
					end
					upcoming_events(glob_events).each do |cur_event|
						event_start = cur_event[:event].dtstart.to_time.localtime.strftime("%d/%m %H:%M")
						output << "\n*" << event_start << "* - " << cur_event[:event].summary
					end
					bot.api.send_message(chat_id: message.chat.id, text: output, reply_to_message_id: message.message_id, parse_mode: "Markdown")
				end
			when /^\/decache/i
				if message.chat.type == 'private'
					lightly.flush
					bot.api.send_message(chat_id: message.chat.id, text: "Detto fatto", reply_to_message_id: message.message_id)
				end
				
		end
	end
end

