class AddSamplesCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :samples_count, :integer, :default => 0
	end
end
