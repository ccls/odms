class ChangeOccurredOnToOccurredAtInOperationalEvent < ActiveRecord::Migration
	def up
		change_column :operational_events, :occurred_on, :datetime
		rename_column :operational_events, :occurred_on, :occurred_at
	end

	def down
		rename_column :operational_events, :occurred_at, :occurred_on
		change_column :operational_events, :occurred_on, :date
	end
end
