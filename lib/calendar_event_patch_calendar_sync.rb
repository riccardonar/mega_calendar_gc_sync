module CalendarEventPatchCalendarSync
  def self.included(base)
	base.send(:include, InstanceMethods)
	base.class_eval do 
	  unloadable
	  after_save :save_to_google_calendar
	end
  end

  module InstanceMethods

  def respect_filters
    return true
  end

  def save_to_google_calendar
    evo = CalendarEventSync.new 

    if evo.calendar_ready
      event = CalendarEventSync.find_by(:calendar_event_id => self.id)
      if self.respect_filters
        if event == nil 
          event = CalendarEventSync.new
        end
        event.calendar_event_id = self.id
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
