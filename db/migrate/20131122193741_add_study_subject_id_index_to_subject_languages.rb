class AddStudySubjectIdIndexToSubjectLanguages < ActiveRecord::Migration
	def change
		add_index :subject_languages, :study_subject_id
	end
end
