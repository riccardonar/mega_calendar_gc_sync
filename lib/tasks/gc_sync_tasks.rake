namespace :gc_sync_tasks do
	desc "put all tasks on redmine on the specific calendar wich is configured from the plugin configuration"
	task :exec => :environment do 
		#require 'colorize'
		puts "syncronizing with google calendar processing ..."#.yellow

		evo = CalendarIssueEventSync.new 
		if evo.calendar_ready
			issues = Issue.all
			#issues = Issue.find([640])
			issues.each do |issue|
				if !issue.respect_filters 
					next
				end

				event = CalendarIssueEventSync.find_by(:issue_id => issue.id)
				if !event.nil?
				    next
				end
				event = CalendarIssueEventSync.new
				event.issue_id = issue.id
				event.project_id = issue.project_id
				begin
					event.save
					puts " EVENT CREATED FOR ISSUE ##{issue.id} "
				rescue Exception => e
					puts "event not created for ISSUE ##{issue.id} "#.red
					puts  "#{issue.subject}"#.red
					puts  "due date : #{issue.due_date.to_s}"#.red
					puts  "start date : #{issue.start_date}"#.red
					puts  e.message
					puts  e.backtrace.inspect
				end
			end

			calendar_events = CalendarEvent.all
			calendar_events.each do |calendar_event|
				if !calendar_event.respect_filters 
					next
				end

				event = CalendarEventSync.find_by(:calendar_event_id => calendar_event.id)
				if !event.nil?
				    next
				end
				event = CalendarEventSync.new

				event.calendar_event_id = calendar_event.id
				begin
					event.save
					puts " EVENT CREATED FOR CALENDAR EVENT ##{calendar_event.id} "
				rescue Exception => e
					puts "event not created for CALENDAR EVENT ##{calendar_event.id} "#.red
					puts  "#{calendar_event.subject}"#.red
					puts  "due date : #{calendar_event.due_date.to_s}"#.red
					puts  "start date : #{calendar_event.start_date}"#.red
					puts  e.message
					puts  e.backtrace.inspect
				end
			end
		else
			puts "configuration is not set, please view the plugin configuration for task calendar".red
		end
	end
end
