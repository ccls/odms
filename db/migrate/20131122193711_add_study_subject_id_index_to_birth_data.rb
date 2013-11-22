class AddStudySubjectIdIndexToBirthData < ActiveRecord::Migration
	def change
		add_index :birth_data, :study_subject_id
	end
end
