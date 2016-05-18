class CalendarIssueEventSync < ActiveRecord::Base
  unloadable

  belongs_to :issue
  
  before_save :send_to_google_calendar
  before_destroy :delete_from_calendar

  def delete_from_calendar
  	if calendar_ready 
  	  if self.event_id != nil
         begin
	       cal = get_acces_to_google_calendar
	       event_to_delete = cal.find_event_by_id(self.event_id)
	       cal.delete_event(event_to_delete[0])
	     rescue Exception => e
           Rails.logger.error e.message
           Rails.logger.error e.backtrace.inspect
	     end
      end
  	end
  end

  def send_to_google_calendar 
  	if calendar_ready
      issue = Issue.find(self.issue_id)
	  project = Project.find_by_id(issue.project_id)

	  parent_name = " [" + project.name + " ]"

	  p = project
	  while p.parent != nil do 
	    parent_name += " [" + p.parent.name  + " ]"
	    p = p.parent
	  end

	  title = issue.subject + '  #' +  self.issue_id.to_s + " " + parent_name.to_s

	  issue_path = Setting.protocol + '://' + Setting.host_name + "/issues/" + self.issue_id.to_s

	  cal = get_acces_to_google_calendar
	  event = nil
	  attendee = get_attendee(issue)

	  event = cal.find_or_create_event_by_id(self.event_id) do |e|
	    e.title = title
        e.start_time = issue.start_calendar.to_s
        e.end_time = issue.end_calendar.to_s
	    e.description = issue.description.to_s.tr("\r", '.').tr("\n", ' ').tr("\"", '') + " (" + issue_path + ")"
	    e.attendees = attendee
	    #e.status = 'tentative'
	    e.visibility = 'default'
	  end
      self.event_id = event.id
  	end
  end

  def get_attendee(issue)
  	attendee = []
    is_group = false
    user = nil
    gg = nil
    if issue.assigned_to_id != nil
      begin
        user = User.find(issue.assigned_to_id)
      rescue
        gg = Group.find(issue.assigned_to_id)
        is_group = true
      end

      custom_field_id_google_cal = Setting.plugin_mega_calendar_gc_sync['custom_field_id_google_cal']

      if is_group
    	  gg.users.each do |u|
          google_calendar_mail = u.custom_field_value(custom_field_id_google_cal).to_s
          if google_calendar_mail != ""
            hash = {
              'email' => google_calendar_mail,
              'displayName' => u.to_s + ' [' + gg.to_s + ']',
              'responseStatus' => 'accepted'
            }
    		    attendee.push(hash)
    	    end
    	  end
      else
    	  google_calendar_mail = user.custom_field_value(custom_field_id_google_cal).to_s
    	  if google_calendar_mail != ""
      	  attendee = [{
      		  'email' => google_calendar_mail,
      		  'displayName' => user.to_s,
      		  'responseStatus' => 'accepted'
            }]
      	end
      end
    end
  	return attendee
  end

  def calendar_ready 
    if calendar_settings_ready == true && calendar_refres_token_ready == true
  	  return true
  	else
  	  return false
  	end
  end

  def calendar_settings_ready
  	client_id =  Setting.plugin_mega_calendar_gc_sync['client_id']
    client_secret = Setting.plugin_mega_calendar_gc_sync['client_secret']
    calendar_id = Setting.plugin_mega_calendar_gc_sync['calendar_task_id']
    refresh_token = Setting.plugin_mega_calendar_gc_sync['refresh_token']

    if client_id == '' || client_secret == '' || calendar_id == '' ||  client_id == nil || client_secret == nil || calendar_id == nil 
      return false
    else
      return true
    end
  end

  def calendar_refres_token_ready 
  	refresh_token = Setting.plugin_mega_calendar_gc_sync['refresh_token']
    if refresh_token == '' || refresh_token == nil
      return false
    else
      return true
    end
  end

  def get_acces_to_google_calendar(calendar=nil)
  	cal = Google::Calendar.new(
  	  :client_id => Setting.plugin_mega_calendar_gc_sync['client_id'].to_s,
  	  :client_secret => Setting.plugin_mega_calendar_gc_sync['client_secret'].to_s,
  	  :calendar => calendar ? calendar.to_s : Setting.plugin_mega_calendar_gc_sync['calendar_task_id'].to_s,
  	  :redirect_url => "urn:ietf:wg:oauth:2.0:oob",  # this is what Google uses for 'applications'
  	  :refresh_token => Setting.plugin_mega_calendar_gc_sync['refresh_token'].to_s
  	)
  	return cal
  end
end
