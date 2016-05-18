namespace :gc_sync_delete do
	desc "put all tasks on redmine on the specific calendar wich is configured from the plugin configuration"
	task :exec => :environment do
		puts "delete events from google calendar ..."

		evo = CalendarIssueEventSync.new 
		if evo.calendar_ready
			evos = CalendarIssueEventSync.all
			evos.each do |e|
				e.destroy
				puts "suppression of event ##{e.issue_id}"
			end

			evos = CalendarEventSync.all
			evos.each do |e|
				e.destroy
				puts "suppression of event ##{e.calendar_event.id}"
			end
		else
			puts "configuration is not set, please view the plugin configuration for task calendar"
		end
	end
end
