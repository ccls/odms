class AddStudySubjectIdIndexToEnrollments < ActiveRecord::Migration
	def change
		add_index :enrollments, :study_subject_id
	end
end
