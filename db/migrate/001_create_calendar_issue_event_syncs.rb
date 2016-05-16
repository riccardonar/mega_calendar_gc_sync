class CreateCalendarIssueEventSyncs < ActiveRecord::Migration
  def self.up
    create_table :calendar_issue_event_syncs do |t|
    	t.column :project_id, :integer
    	t.column :issue_id , :integer
    	t.column :event_id, :string
    end
  end

  def self.down
  	drop_table :calendar_issue_event_syncs
  end
end
