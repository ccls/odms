class AddSubjectTypeToStudySubjects < ActiveRecord::Migration
	def change
		add_column :study_subjects, :subject_type, :string, :null => false, :limit => 20
		add_index  :study_subjects, :subject_type
	end
end
