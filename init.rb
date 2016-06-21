require 'redmine'
require 'json'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

require_dependency 'issue_patch_calendar_sync'
require_dependency 'calendar_event_patch_calendar_sync'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  require_dependency 'calendar_event'
  Issue.send(:include, IssuePatchCalendarSync)
  CalendarEvent.send(:include, CalendarEventPatchCalendarSync)
end

Redmine::Plugin.register :mega_calendar_gc_sync do
  name 'Mega Calendar: Gc Sync plugin'
  author 'Riccardo Narduzzi'
  description 'This is a plugin for plugin Redmine Mega Calendar'
  version '1.0.1'
  url 'https://github.com/riccardonar/mega_calendar_gc_sync'
  author_url 'https://github.com/riccardonar'

  requires_redmine_plugin :mega_calendar, :version_or_higher => '0.1.0'

  settings :default => {}, :partial => 'settings/calendar_settings'
end

