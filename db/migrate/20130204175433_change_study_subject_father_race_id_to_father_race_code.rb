class ChangeStudySubjectFatherRaceIdToFatherRaceCode < ActiveRecord::Migration
	def up
		rename_column :study_subjects, :father_race_id, :father_race_code
	end

	def down
		rename_column :study_subjects, :father_race_code, :father_race_id
	end
end
