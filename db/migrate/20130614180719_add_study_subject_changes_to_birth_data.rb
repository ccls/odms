class AddStudySubjectChangesToBirthData < ActiveRecord::Migration
	def change
		add_column :birth_data, :study_subject_changes, :text
	end
end
