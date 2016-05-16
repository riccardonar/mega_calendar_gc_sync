module IssuePatchCalendarSync
  def self.included(base)
	base.send(:include, InstanceMethods)
	base.class_eval do 
	  unloadable
	  after_save :save_to_google_calendar
	end
  end

  module InstanceMethods

  def respect_filters
    status = Setting.plugin_mega_calendar_gc_sync['status'].map{|id| id.to_i}
    include_status = status.include? (self.status_id)
    return self.respect_filters_mega_calendar && include_status
  end

  def save_to_google_calendar
    evo = CalendarIssueEventSync.new

    if evo.calendar_ready
      event = CalendarIssueEventSync.find_by(:issue_id => self.id)
      if self.respect_filters
        if event == nil 
          event = CalendarIssueEventSync.new
        end
        event.issue_id = self.id
        event.project_id = self.project_id
        begin
          event.save
        rescue Exception => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.inspect
        end
      else
        if event != nil
          event.destroy
        end
      end
    end
  end
  end
end
