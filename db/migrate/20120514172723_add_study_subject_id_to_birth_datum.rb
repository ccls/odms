class AddStudySubjectIdToBirthDatum < ActiveRecord::Migration
	def change
		add_column :birth_data, :study_subject_id, :integer
	end
end
