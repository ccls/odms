class AddEnrollmentsCountToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :enrollments_count, :integer, :default => 0
	end
end
