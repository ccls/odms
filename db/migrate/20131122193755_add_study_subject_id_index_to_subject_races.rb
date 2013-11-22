class AddStudySubjectIdIndexToSubjectRaces < ActiveRecord::Migration
	def change
		add_index :subject_races, :study_subject_id
	end
end
