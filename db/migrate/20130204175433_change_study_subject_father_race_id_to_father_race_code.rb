class ChangeStudySubjectFatherRaceIdToFatherRaceCode < ActiveRecord::Migration
	def change
		rename_column :study_subjects, :father_race_id, :father_race_code
	end
end
