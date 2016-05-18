namespace :gc_sync_get do
	desc "put all tasks on redmine on the specific calendar wich is configured from the plugin configuration"
	task :exec => :environment do
		evo = CalendarIssueEventSync.new 
		if evo.calendar_ready
		    (0..100).each do |contatore|
		    
        		puts "syncronizing with google calendar ..."
		        
                custom_field_id_start = Setting.plugin_mega_calendar['custom_field_id_start']
                custom_field_id_end = Setting.plugin_mega_calendar['custom_field_id_end']
                custom_field_id_google_cal = Setting.plugin_mega_calendar_gc_sync['custom_field_id_google_cal']

                calendar_event = CalendarEvent.new
                users = calendar_event.assignable_users

		        global_cal = evo.get_acces_to_google_calendar

                users.each do |u|
                    google_calendar_mail = u.custom_field_value(custom_field_id_google_cal).to_s
                    if google_calendar_mail == ""
                        next
                    end
                    
                    puts 'searching for calendar of ' + u.to_s
                    
		            cal = evo.get_acces_to_google_calendar(google_calendar_mail)

                    evos = cal.find_events_in_range(Time.now - (60*60*24*0.5), Time.now + (60*60*24*5))
                    #evos = cal.find_events_in_range(Time.now - (60*60*24*2), Time.now)

			        evos.each do |e|
                        event_begin = Time.parse(e.start_time.to_s).localtime
                        event_end = Time.parse(e.end_time.to_s).localtime

			            calendar_event = CalendarIssueEventSync.find_by(:event_id => e.id)
			            if calendar_event.nil?
			                calendar_event = CalendarEventSync.find_by(:event_id => e.id)
			                if !calendar_event.nil?
			                    ce = CalendarEvent.find(calendar_event.calendar_event_id)

                                if event_begin != ce.start || event_end != ce.end
        			                puts 'find calendar event ' + calendar_event.id.to_s + ': update fields to ' + ce.title + ' #' + ce.id.to_s

                                    ce.start = event_begin
                                    ce.end = event_end
                                    ce.save!
                                end
                            else
			                    puts 'new issue, i do not know how to manage'
			                    next
			                    # @todo find a good method to create new issue and not recreate a google calendar event
			                    # the problem is that hook after save issue create e new CalendarIssueEventSync

			                    i = Issue.new
			                    i.init_journal(u, 'From Google Calendar')
			                    i.project ||= Project.find(Setting.plugin_mega_calendar_gc_sync['project_for_new_issues'])
			                    i.tracker ||= Tracker.find(Setting.plugin_mega_calendar['tracker_ids'].first)
			                    i.status ||= IssueStatus.first
			                    i.author ||= u
			                    i.assigned_to ||= u
                                i.subject = e.title
                                i.description = e.description
                                i.start_date = event_begin.to_date.to_s
                                i.due_date = event_end.to_date.to_s
                                i.custom_field_values = {
                                  custom_field_id_start => event_begin.to_datetime.strftime('%H:%M'),
                                  custom_field_id_end => event_end.to_datetime.strftime('%H:%M')
                                }
                                i.save!

                                # update new event with right event_id
                                calendar_event = CalendarIssueEventSync.find_by(:issue_id => i.id)

	                            event_to_delete = cal.find_event_by_id(calendar_event.event_id)
	                            global_cal.delete_event(event_to_delete[0])
			                    calendar_event.event_id = e.id
			                    calendar_event.save!

			                    puts 'create new issue ' + event_to_delete[0].id
			                end
			            else
			                i = Issue.find(calendar_event.issue_id)

                            if event_begin != i.start_calendar || event_end != i.end_calendar
        			            puts 'find issue ' + calendar_event.id.to_s + ': update fields to ' + i.subject + ' #' + i.id.to_s
        			            i.init_journal(u, 'From Google Calendar')

                                i.start_date = event_begin.to_date.to_s
                                i.due_date = event_end.to_date.to_s
                                i.custom_field_values = {
                                  custom_field_id_start => event_begin.to_datetime.strftime('%H:%M'),
                                  custom_field_id_end => event_end.to_datetime.strftime('%H:%M')
                                }
                                i.save!
                            end
			            end
			        end
                end
                sleep 300
            end
		else
			puts "configuration is not set, please view the plugin configuration for task calendar"
		end
	end
end
