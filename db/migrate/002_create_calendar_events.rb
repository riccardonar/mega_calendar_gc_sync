class CreateCalendarEvents < ActiveRecord::Migration
  def self.up
    create_table :calendar_events_sync do |t|
    	t.column :calendar_event_id , :integer
    	t.column :event_id, :string
    end
  end

  def self.down
  	drop_table :calendar_events_sync
  end
end
