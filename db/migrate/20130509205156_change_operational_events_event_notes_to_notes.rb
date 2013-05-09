class ChangeOperationalEventsEventNotesToNotes < ActiveRecord::Migration
	def up
		rename_column :operational_events, :event_notes, :notes
	end

	def down
		rename_column :operational_events, :notes, :event_notes
	end
end
