class AddSubjectTypeToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :subject_type, :string, :null => false
	end
end
