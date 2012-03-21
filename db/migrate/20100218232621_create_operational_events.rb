class CreateOperationalEvents < ActiveRecord::Migration
	def self.up
		create_table :operational_events do |t|
			t.integer :operational_event_type_id
			t.date    :occurred_on
#			t.integer :enrollment_id
			t.integer :study_subject_id
			t.integer :project_id
			t.string  :description
			t.text    :event_notes
			t.timestamps
		end
		add_index :operational_events, :study_subject_id
		add_index :operational_events, :project_id
		add_index :operational_events, :operational_event_type_id
	end

	def self.down
		drop_table :operational_events
	end
end
