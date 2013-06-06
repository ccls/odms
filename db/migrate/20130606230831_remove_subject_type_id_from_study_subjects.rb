class RemoveSubjectTypeIdFromStudySubjects < ActiveRecord::Migration
	def up
		remove_column :study_subjects, :subject_type_id
	end

	def down
		add_column :study_subjects, :subject_type_id, :integer
	end
end
