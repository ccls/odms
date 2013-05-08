class AddOperationalEventsCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :operational_events_count, :integer, :default => 0
	end
end
