class CreateCalendarEventSyncs < ActiveRecord::Migration
  def self.up
    create_table :calendar_event_syncs do |t|
    	t.column :calendar_event_id , :integer
    	t.column :event_id, :string
    end
  end

  def self.down
  	drop_table :calendar_event_syncs
  end
end
