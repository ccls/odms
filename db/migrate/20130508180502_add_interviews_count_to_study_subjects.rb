class AddInterviewsCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :interviews_count, :integer, :default => 0
	end
end
